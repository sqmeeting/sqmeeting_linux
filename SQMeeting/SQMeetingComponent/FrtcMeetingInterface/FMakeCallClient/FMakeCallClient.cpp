#if defined (WIN32)
#include<windows.h>
#endif

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "FMakeCallClient.h"
#include "sq_util.h"
#include "FrtcUUID.h"
#include "FrtcInCallModel.h"
#include "FrtcInfoInstance.h"
#include "FrtcMediaStaticsInstance.h"
#include "SDKDeviceContext.h"
#include "SVCLayoutManager.h"
#include "SDKItemInfo.h"
#include "FMeetingViewController.h"
#include "FMeetingWindowController.h"
#include "SDKUserDefault.h"
#include "MessageHandlerStrategy.h"
#include "MessageHandlerFactory.h"

#include <iostream>
#include <mutex>

#ifdef Q_OS_LINUX
static QStringList manufacturerFileList {
    "/sys/class/dmi/id/chassis_vendor",
    "/sys/class/dmi/id/product_family",
    "/sys/class/dmi/id/product_name",
    "/sys/class/dmi/id/product_sku",
    "/sys/class/dmi/id/product_version"
};
#elif defined(Q_OS_MAC)
static QStringList manufacturerFileList {
    "/System/Library/CoreServices/SystemVersion.plist", // Example for Mac
    // You can add more paths specific to macOS if needed
};
#endif

QMutex FMakeCallClient::m_Mutex;
FMakeCallClient * FMakeCallClient::sharedFRMakeCallClient = nullptr;
FMakeCallClient* FMakeCallClient::instance = nullptr;



FMakeCallClient * FMakeCallClient::sharedCallClient()
{
    if (nullptr == sharedFRMakeCallClient)
    {
        QMutexLocker mutexLocker(&m_Mutex);
        sharedFRMakeCallClient = new FMakeCallClient();
    }

    return sharedFRMakeCallClient;
}

void FMakeCallClient::releaseInstance()
{
    if (nullptr != sharedFRMakeCallClient)
    {
        QMutexLocker mutexLocker(&m_Mutex);
        delete sharedFRMakeCallClient;
        sharedFRMakeCallClient = nullptr;
    }
}

FMakeCallClient::FMakeCallClient()
{
    instance = this;

    _contentCapture = new FContentCapture();
    register_sdk(StaticCallback);
}


void FMakeCallClient::register_sdk(CallBackFunction cb)
{
    callback = cb;
    std::string dir = Util::SystemUtil::GetApplicationDocumentDirectory();
    dir = dir + "/";

    std::string log_path = dir + "frtc_call.log";

    std::string app_uuid = FrtcUUID::getApplicationUUID();
    frtc_sdk_init(app_uuid.c_str(), log_path.c_str(), callback);

    qDebug("getDeviceManufacturerInfo is : %s",  qUtf8Printable(getDeviceManufacturerInfo()));


    printf("\nThe product name is %s, and the device manfactureinfo is %s\n", QSysInfo::prettyProductName().toUtf8().constData(), getDeviceManufacturerInfo().toUtf8().constData());
    frtc_set_system_info(getDeviceManufacturerInfo().toUtf8().constData(), QSysInfo::prettyProductName().toUtf8().constData());
}

QString FMakeCallClient::getDeviceManufacturerInfo()
{
    QString ret = "";
    for(auto f : manufacturerFileList)
    {
        if(QFile::exists(f))
        {
            QString content = readFileOneLine(f);

#ifdef Q_OS_MAC
                // For macOS, if we get XML content, parse it
            if (content.startsWith("<?xml"))
            {
                ret.append(parseMacPlist(content));
            }
            else
            {
                ret.append(content);
            }
#else
                // For Linux, just append as is
            ret.append(content);
#endif

            ret.append(" ");
        }
    }
    return ret.trimmed();
}

QString FMakeCallClient::readFileOneLine(const QString & fileName)
{
    QFile file(fileName);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString text = in.readLine().trimmed();
        file.close();
        return text;
    } else {
        return "";
    }
}


#ifdef Q_OS_MAC
QString FMakeCallClient::parseMacPlist(const QString &xmlContent)
{
    QString manufacturerInfo = "";
    QXmlStreamReader xml(xmlContent);

    // Debug output to check XML content
    qDebug() << "XML Content: " << xmlContent;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            qDebug() << "Start element: " << xml.name().toString();

            if (xml.name() == "key") {
                QString key = xml.readElementText();
                qDebug() << "Key found: " << key;

                if (key == "ProductName") {
                    xml.readNext();
                    manufacturerInfo.append("Mac Product: " + xml.readElementText() + " ");
                }
                else if (key == "ProductVersion") {
                    xml.readNext();
                    manufacturerInfo.append("Version: " + xml.readElementText() + " ");
                }
                else if (key == "ProductUserVisibleVersion") {
                    xml.readNext();
                    manufacturerInfo.append("User Visible Version: " + xml.readElementText() + " ");
                }
            }
        }
    }

    // Debug output to check if there was any error during parsing
    if (xml.hasError()) {
        qDebug() << "Error parsing XML: " << xml.errorString();
        //manufacturerInfo = "MacBookPro";
        //return "Error parsing plist";
    }

    manufacturerInfo = "MacBookPro";
    return manufacturerInfo;
}
#endif


void FMakeCallClient::make_call(FRTCSDKCallParam call_param,
                                std::function<void()> callSuccessCallBack,
                                std::function<void(int reason)> callFailureCallBack,
                                std::function<void(bool wrongPassword)> inputPasswordCallBack)
{
    this->callSuccessCallBack   = callSuccessCallBack;
    this->callFailureCallBack   = callFailureCallBack;
    this->inputPasswordCallBack = inputPasswordCallBack;
    this->param = call_param;

    audio_mute  = call_param.mute_microphone;
    video_mute  = call_param.mute_camera;

    client_name = QString::fromStdString(call_param.client_name);

    switch_layout_mode(call_param.grid_mode);

    FMeetingViewController::getInstance()->setLayoutMode(call_param.grid_mode);

    std::string server_address = call_param.call_url;

    this->need_password_count = 0;

    CALL_PARAM param;
    param.server_address = server_address.c_str();
    param.meeting_number = call_param.conference_number.c_str();
    param.display_name   = call_param.client_name.c_str();
    param.meeting_pwd    = call_param.meeting_password.c_str();

    QString user_token = SDKUserDefault::getInstance()->getUserToken();
    QString user_id    = SDKUserDefault::getInstance()->getUserInfo()["user_id"].toString();

    qDebug("[%s][%d]: user_token is %s, user_id is : %s", __FUNCTION__, __LINE__, qUtf8Printable(user_token), qUtf8Printable(user_id));

    QByteArray userTokenData = user_token.toUtf8();
    QByteArray userIdData = user_id.toUtf8();

    param.user_token = userTokenData.constData();
    param.user_id = userIdData.constData();


    printf("\n***********%s %s %s %s %s %s %s %s***********\n",param.server_address,
           param.meeting_number,
           param.display_name,
           param.meeting_pwd,
           user_id.toUtf8().constData(),
           user_token.toUtf8().constData(),
           param.user_token,
           param.user_id);

    frtc_call_join(param);
}

void FMakeCallClient::switch_layout_mode(bool grid_mode)
{
    grid_mode = grid_mode;

    frtc_set_layout_mode(grid_mode);

    FMeetingViewController::getInstance()->setLayoutMode(grid_mode);

    SDKUserDefault::getInstance()->setSdkBoolObject(SDK_DEFAULT_LAYOUT_GALLERY, grid_mode); //true: "gallery"; false: "presenter"
}

void FMakeCallClient::send_password(std::string password)
{
    this->meeting_password = password;
    frtc_send_meeting_passowrd(password.c_str());
}

void FMakeCallClient::send_local_video_frame(void * buffer, QString msid, int length, int width, int height, QVideoFrameFormat::PixelFormat format)
{
    QByteArray byteArray = msid.toUtf8();
    const char *stream_id = byteArray.constData();
    frtc_video_frame_send(stream_id, width, height, length, get_frtc_video_format(format), buffer, 0);
}

void FMakeCallClient::send_video_frame(void * buffer, int length, int width, int height, QVideoFrameFormat::PixelFormat format)
{
    QByteArray byteArray = video_stream_id.toUtf8();
    const char *stream_id = byteArray.constData();
    frtc_video_frame_send(stream_id, width, height, length, get_frtc_video_format(format), buffer, 0);
}

void FMakeCallClient::send_contetn_frame(void * buffer, QString media_id, int length, int width, int height)
{
    QByteArray byteArray = media_id.toUtf8();
    const char *stream_id = byteArray.constData();

    frtc_video_frame_send(stream_id, width, height, length, kARGB, buffer, 0);
}


void FMakeCallClient::receive_video_frame(std::string media_id,void **buffer, unsigned long* length,unsigned int* width,unsigned int* height)
{
   frtc_remote_video_fetch(media_id.c_str(), width, height, length, buffer);
}

void FMakeCallClient::send_audio_frame(int data_len, int sample_rate, void* audio_data)
{
    QByteArray byteArray = audio_request_stream_id.toUtf8();
    const char *stream_id = byteArray.constData();

    frtc_people_audio_frame_send(stream_id, data_len, sample_rate, audio_data);
}

void FMakeCallClient::receive_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate)
{
    QByteArray byteArray = audio_receive_stream_id.toUtf8();
    const char *stream_id = byteArray.constData();

    frtc_remote_audio_fetch(stream_id, sample_rate, length, buffer);
}

void FMakeCallClient::start_content()
{
    frtc_content_start();
}

void FMakeCallClient::stop_content()
{
    frtc_content_stop();
    _contentCapture->stopContent();
}


void FMakeCallClient::completion_handler(const QString& conference_name,
                                         const QString& conference_number,
                                         const QString& owner_id,
                                         const QString& owner_name,
                                         const QString& meeting_url,
                                         const long long schedule_start_time,
                                         const long long schedule_end_time,
                                         bool is_login_call)
{
    FrtcInCallModel *model = new FrtcInCallModel();
    model->ownerID               = owner_id;
    model->meetingUrl            = meeting_url;

    model->scheduleStartTime     = "2022-12-19 88:00";
    model->scheduleEndTime       = "2022-12-19 88:00";

    model->ownerName             = !(owner_name.isEmpty()) ? owner_name : "";

    model->conferenceName        = conference_name;
    model->conferenceNumber      = conference_number;

    model->muteCamera            = param.mute_camera;
    model->muteMicrophone        = param.mute_microphone;

    model->clientName            = QString::fromStdString(param.client_name);

    model->userID                = QString::fromStdString(param.user_id);
    model->userToken             = QString::fromStdString(!(param.user_token.empty()) ? param.user_token : "");
    model->conferencePassword    = QString::fromStdString(!(param.meeting_password.empty()) ? param.meeting_password : (!(this->meeting_password.empty()) ? this->meeting_password : ""));

    model->conferenceStartTime   = "2022-12-19 88:00";

    model->authority             = false;
    model->audioOnly             = param.audio_call;
    model->loginCall             = is_login_call;

    FrtcInfoInstance::sharedFrtcInfoInstance()->inCallModel = model;
    FrtcMediaStaticsInstance::sharedInstance()->startGetMediaStatics();
}

void FMakeCallClient::on_call_state_changed(int call_state, int failure_reason)
{
    if (call_state == 1 && this->call_state != 1)
    {
        this->callSuccessCallBack();
    }
    else if (call_state != 1)
    {
        this->callFailureCallBack(failure_reason);
        FrtcMediaStaticsInstance::sharedInstance()->stopGetMediaStatics();

        if(failure_reason == 10)
        {
            _roster_list.clear();

            QThread* mainThread = QCoreApplication::instance()->thread();

            if (QThread::currentThread() != mainThread) {
                QMetaObject::invokeMethod(SDKDeviceContext::getInstance(), "stopCapture", Qt::QueuedConnection);
            } else {
                SDKDeviceContext::getInstance()->stopVideoCapture();
            }
        }
    }

    this->call_state = call_state;
}

void FMakeCallClient::on_water_mask_changed(const QString& live_meeting_url,
                           const QString& live_password,
                           const QString& live_status,
                           const QString& recording_status)
{
    FMeetingWindowController::getInstance()->onWaterMaskCallBack(live_meeting_url,
                                                                 live_password,
                                                                 live_status,
                                                                 recording_status);

}

void FMakeCallClient::on_message_over_lay(const bool enabled,
                                          const int vertical_position,
                                          const int display_repetition,
                                          const QString& display_speed,
                                          const QString& message_text)
{
    FMeetingWindowController::getInstance()->onMessageOverLayCallBack(enabled,
                                                                 vertical_position,
                                                                 display_repetition,
                                                                 display_speed,
                                                                 message_text);
}

void FMakeCallClient::on_layout_setting_changed(const QString& lecture_id, const int max_cell_count)
{
    FMeetingWindowController::getInstance()->onLayoutSettingChangedCallBack(lecture_id, max_cell_count);
}

void FMakeCallClient::on_un_mute_request(const QString& name,const QString& uuid)
{
    FMeetingWindowController::getInstance()->onUMuteRequestCallBack(name, uuid);
}

bool FMakeCallClient::is_in_call()
{
    return this->call_state == 1;
}

void FMakeCallClient::on_request_video_stream(QString media_id)
{
    video_stream_id = media_id;

    std::string dataSourceID = media_id.toStdString();

    if (dataSourceID.rfind("VCS-", 0) == 0)
    {
        _contentCapture->setSourceID(media_id);
        _contentCapture->startContent();
    }
}

void FMakeCallClient::on_receive_audio_stream(QString media_id)
{
    audio_receive_stream_id = media_id;
    SDKDeviceContext::getInstance()->startAudioSink();
}

void FMakeCallClient::on_request_audio_stream(QString media_id)
{
    audio_request_stream_id = media_id;
}

void FMakeCallClient::on_receive_video_stream(QString media_id)
{
    video_receive_stream_id = media_id;
    FMeetingViewController::getInstance()->remoteVideoReceived(video_receive_stream_id.toStdString());

}

void FMakeCallClient::on_receive_pin_speaker_id(QString pin_speaker_id)
{
    std::lock_guard<std::mutex> lock(rosterMutex);

    for (auto& roster_item : _roster_list) {
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(roster_item));
        QJsonObject jsonObj = doc.object();

        if (jsonObj.contains("uuid")) {
            jsonObj["user_pin"] = (jsonObj["uuid"].toString() == pin_speaker_id);
        }

        QJsonDocument updatedDoc(jsonObj);
        roster_item = updatedDoc.toJson(QJsonDocument::Compact).toStdString();
    }

    FrtcInfoInstance::sharedFrtcInfoInstance()->udateRosterList(_roster_list);
    FMeetingViewController::getInstance()->onParticipantsListReveived(_roster_list);

    FMeetingWindowController::getInstance()->onReceivePinSpeakerIDCallBack(pin_speaker_id);
}

void FMakeCallClient::on_svc_layout_changed(void *buffer)
{
    MeetingLayout::SDKLayoutInfo *pBuffer = (MeetingLayout::SDKLayoutInfo *)buffer;

    FMeetingViewController::getInstance()->remoteLayoutChanged(pBuffer);
}

void FMakeCallClient::on_content_start(bool is_send_content)
{
    FMeetingViewController::getInstance()->onContentStateChanged(is_send_content);
    FMeetingWindowController::getInstance()->onContentStateChangedCallBack(is_send_content);
}

void FMakeCallClient::on_participants_num(int participants_num)
{
    FrtcInfoInstance::sharedFrtcInfoInstance()->updateRosterNumber(participants_num);
    FMeetingViewController::getInstance()->onParticipantsNumReport(participants_num);
}

void FMakeCallClient::on_audio_muted_changed(bool allow_self_unmuted, bool muted)
{

    FMeetingWindowController::getInstance()->onMuteLockedCallBack(muted, allow_self_unmuted);
}

void FMakeCallClient::on_un_mute_request_allowed()
{
    qDebug()<<"void FMakeCallClient::on_un_mute_request_allowed()";
    FMeetingWindowController::getInstance()->onUnMuteRequestAllowed();
}

void FMakeCallClient::on_input_password_request()
{
    bool wrongCode = false;
    if (this->need_password_count == 0)
    {
        this->need_password_count = 1;
        wrongCode = false;
    }
    else
    {
        wrongCode = true;
    }

    this->inputPasswordCallBack(wrongCode);
}

void FMakeCallClient::on_participants_list(std::vector<std::string> participants_list, bool is_full)
{
    std::lock_guard<std::mutex> lock(rosterMutex);

    std::unordered_map<std::string, bool> pinStatusMap;
    for (const auto& roster_item : _roster_list) {
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(roster_item));
        QJsonObject jsonObj = doc.object();
        if (jsonObj.contains("uuid") && jsonObj.contains("user_pin")) {
            pinStatusMap[jsonObj["uuid"].toString().toStdString()] = jsonObj["user_pin"].toBool();
        }
    }

    QJsonObject selfJsonObj;
    selfJsonObj["audio_mute"]   = audio_mute;
    selfJsonObj["display_name"] = client_name;
    selfJsonObj["user_id"]      = QString::fromStdString(FrtcUUID::getApplicationUUID());
    selfJsonObj["uuid"]         = QString::fromStdString(FrtcUUID::getApplicationUUID());
    selfJsonObj["video_mute"]   = video_mute;
    selfJsonObj["user_pin"]     = false;

    QJsonDocument selfJsonDoc(selfJsonObj);
    std::string selfJsonString = selfJsonDoc.toJson(QJsonDocument::Compact).toStdString();

    // 如果 is_full 为 true，表示这是完整的参会者名单，不包含自己
    if (is_full) {
        _roster_list.clear();

        _roster_list.push_back(selfJsonString);

        for (const auto& participant : participants_list) {
            QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(participant));
            QJsonObject jsonObj = doc.object();

            // 如果 UUID 在旧名单中存在，则恢复 user_pin 信息
            std::string uuid = jsonObj["uuid"].toString().toStdString();
            if (pinStatusMap.find(uuid) != pinStatusMap.end()) {
                jsonObj["user_pin"] = pinStatusMap[uuid];
            } else {
                jsonObj["user_pin"] = false;  // 默认值
            }

            QJsonDocument updatedDoc(jsonObj);
            _roster_list.push_back(updatedDoc.toJson(QJsonDocument::Compact).toStdString());
        }
    }
    else
    {
        std::string participant = participants_list[0];

        // 解析 JSON 字符串
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(participant));
        QJsonObject jsonObj = doc.object();

        // 判断是否是自己
        if (jsonObj.contains("uuid") && jsonObj["uuid"].toString() == QString::fromStdString(FrtcUUID::getApplicationUUID())) {
            // 如果是自己，提取 display_name 并保存到本地
            client_name = jsonObj["display_name"].toString();
            jsonObj["video_mute"] = video_mute;
            jsonObj["user_pin"] = false;

            QJsonDocument updatedJsonDoc(jsonObj);
            QString updatedJsonString = updatedJsonDoc.toJson(QJsonDocument::Compact);
            std::string updatedStdString = updatedJsonString.toStdString();
            participant = updatedStdString;
        } else {
            std::string uuid = jsonObj["uuid"].toString().toStdString();
            if (pinStatusMap.find(uuid) != pinStatusMap.end()) {
                jsonObj["user_pin"] = pinStatusMap[uuid];
            } else {
                jsonObj["user_pin"] = false;
            }

            QJsonDocument updatedJsonDoc(jsonObj);
            QString updatedJsonString = updatedJsonDoc.toJson(QJsonDocument::Compact);
            participant = updatedJsonString.toStdString();
        }

        // 更新 roster_list 中的信息
        bool found = false;
        for (auto& roster_item : _roster_list) {
            // 解析每个 roster_item 的 JSON 字符串
            QJsonDocument rosterDoc = QJsonDocument::fromJson(QByteArray::fromStdString(roster_item));
            QJsonObject rosterJson = rosterDoc.object();

            // 如果 UUID 匹配到某个参会者，直接替换该元素
            if (rosterJson.contains("uuid") && rosterJson["uuid"].toString() == jsonObj["uuid"].toString()) {
                // 替换 roster_list 中的对应元素
                roster_item = participant;
                found = true;
                break;  // 找到并更新后退出循环
            }
        }

        if (!found) {
            // 如果没有找到对应的参会者，就直接插入到 roster_list 的最后一个位置
            _roster_list.push_back(participant);
        }
    }


    FrtcInfoInstance::sharedFrtcInfoInstance()->udateRosterList(_roster_list);

    FMeetingViewController::getInstance()->onParticipantsListReveived(_roster_list);
}

void FMakeCallClient::mute_camera(bool mute_camera)
{
    this->video_mute = mute_camera;

    if(mute_camera)
    {
        frtc_local_video_stop();
        SDKDeviceContext::getInstance()->stopVideoCapture();
    }
    else
    {
        frtc_local_video_start();
        SDKDeviceContext::getInstance()->startVideoCapture();
    }
}

void FMakeCallClient::mute_micphone(bool mute_micphone)
{
    this->audio_mute = mute_micphone;
    frtc_local_audio_mute(mute_micphone);

    SDKDeviceContext::getInstance()->muteMicrophone(mute_micphone);
}

void FMakeCallClient::drop_call()
{
    frtc_call_leave();

    _roster_list.clear();

    SDKDeviceContext::getInstance()->stopAudioUnitCapture();
    SDKDeviceContext::getInstance()->stopAudioSink();
    SDKDeviceContext::getInstance()->stopVideoCapture();
}

void FMakeCallClient::video_mirror(bool video_mirror)
{
    frtc_set_camera_stream_mirror(video_mirror);
}

void FMakeCallClient::noise_reduction_enable(bool enable)
{
    frtc_set_intelligent_noise_reduction(enable);
}

QString FMakeCallClient::get_statics_info()
{
    const char *statics_info = frtc_get_statics();
    QString qstr = QString::fromUtf8(statics_info);

    return qstr;

}

void FMakeCallClient::member_function(const char *meeting_message)
{
    //std::cout << meeting_message << std::endl;
    QByteArray jsonData(meeting_message);
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);

    if (!doc.isObject()) {
        std::cerr << "Invalid JSON" << std::endl;
        return;
    }

    QJsonObject jsonObject = doc.object();
    QString msgType = jsonObject.value("msg_type").toString();

    // 使用工厂类创建处理器
    std::unique_ptr<MessageHandlerStrategy> handler = MessageHandlerFactory::createHandler(msgType);

    if (handler) {
        handler->handle(jsonObject, this);  // 调用策略的 handle 方法
    } else {
        std::cerr << "Unknown message type: " << msgType.toStdString() << std::endl;
    }
}



VIDEO_COLOR_FORMAT FMakeCallClient::get_frtc_video_format(QVideoFrameFormat::PixelFormat qt_video_format)
{
    VIDEO_COLOR_FORMAT ret = VIDEO_COLOR_FORMAT::kNoType;
    switch (qt_video_format)
    {
    case QVideoFrameFormat::PixelFormat::Format_NV12:
        ret = VIDEO_COLOR_FORMAT::kNV12;
        break;
    case QVideoFrameFormat::PixelFormat::Format_YUV420P:
        ret = VIDEO_COLOR_FORMAT::kI420;
        break;
    case QVideoFrameFormat::PixelFormat::Format_YUYV:
        ret = VIDEO_COLOR_FORMAT::kYUY2;
        break;
    default:
        break;
    }
    return ret;
}



