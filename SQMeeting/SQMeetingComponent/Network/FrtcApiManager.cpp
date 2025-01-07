#include "FrtcApiManager.h"
#include "FrtcNetworkManager.h"
#include <QCryptographicHash>
#include <QString>
#include <QDebug>
#include "FrtcUUID.h"
#include "SDKUserDefault.h"

// SHA1

inline const QString salt = "49d88eb34f77fc9e81cbdc5190c7efdc";
inline const QString uselessToken = "uselessToken";

// Rest API URL
inline const QString userLoginUrl        = "/api/v1/user/sign_in";
inline const QString userLogoutUrl       = "/api/v1/user/sign_out";
inline const QString userInfoUrl         = "/api/v1/user/info";
inline const QString updatePasswordUrl   = "/api/v1/user/password";
inline const QString scheduleMeetingUrl  = "/api/v1/meeting_schedule";
inline const QString queryMeetingListUrl = "/api/v1/meeting_room";
inline const QString changeNameUrl       = "/api/v1/meeting";
inline const QString setUserAsLecturer   = "/api/v1/meeting/%1/lecturer";
inline const QString setUserPinUrl       = "/api/v1/meeting/%1/pin";
inline const QString removeUserMeeting   = "/api/v1/meeting/%1/disconnect";
inline const QString muteAllUrl          = "/api/v1/meeting/%1/mute_all";
inline const QString muteOneOrAll        = "/api/v1/meeting/%1/mute";
inline const QString unMuteAllUrl        = "/api/v1/meeting/%1/unmute_all";
inline const QString unmuteOneOrAll      = "/api/v1/meeting/%1/unmute";
inline const QString requestUnmuteUrl    = "/api/v1/meeting/%1/request_unmute";
inline const QString allowUnmuteUrl      = "/api/v1/meeting/%1/allow_unmute";
inline const QString startMessageUrl     = "/api/v1/meeting/%1/overlay";
inline const QString getAllUserListUrl   = "/api/v1/user/public/users";
inline const QString createMeetingUrl    = "/api/v1/meeting_schedule";
inline const QString stopMeetingUrl      = "/api/v1/meeting/%1/stop";
inline const QString recordingUrl        = "/api/v1/meeting/%1/recording";
inline const QString streamingUrl            = "/api/v1/meeting/%1/live";
inline const QString getScheduleMeetingListUrl  = "/api/v1/meeting_schedule/recurrence/%1";
inline const QString deleteNonRecurrentMeeting  = "/api/v1/meeting_schedule/%1";



FrtcApiManager* FrtcApiManager::s_instance = nullptr;

FrtcApiManager* FrtcApiManager::instance() {
    if (!s_instance) {
        s_instance = new FrtcApiManager();
    }
    return s_instance;
}

FrtcApiManager::FrtcApiManager(QObject *parent)
    : QObject{parent}
{
    connect(FrtcNetworkManager::instance(), &FrtcNetworkManager::requestFinished, this, &FrtcApiManager::onRequestFinished);
}

void FrtcApiManager::sign_in(const QString &name, const QString &password)
{
    QVariantMap params;
    params["username"] = name;
    params["secret"]   = secretSha1String(password);
    FrtcNetworkManager::instance()->post(userLoginUrl,uselessToken,params,"frtc_sign_in");
}

void FrtcApiManager::sign_out(const QString &token) {
    FrtcNetworkManager::instance()->post(userLogoutUrl,token,{},"frtc_sign_out");
}

void FrtcApiManager::sign_in_token(const QString &token)
{
    FrtcNetworkManager::instance()->get(userInfoUrl,token,{},"frtc_sign_in_token");
}

void FrtcApiManager::getMeetingRoomList(const QString &token)
{
    FrtcNetworkManager::instance()->get(queryMeetingListUrl,token,{},"frtc_room_list");
}

void FrtcApiManager::change_name(const QString meeting_number,const QString &name)
{
    QString uuid = QString::fromStdString(FrtcUUID::getApplicationUUID());
    QVariantMap params;
    params["client_id"]     = uuid;
    params["display_name"]  = name;

    QString change_name_url = changeNameUrl + "/" + meeting_number;

    FrtcNetworkManager::instance()->post(change_name_url, "", params, "change_guest_name");
}

void FrtcApiManager::login_change_name(const QString user_token,const QString meeting_number, const QString &name, const QString &client_identifier)
{
    QString change_name_url = changeNameUrl + "/" + meeting_number + "/" + "participant";

    qDebug() << "The client_id is " << client_identifier;

    qDebug()<< "The change_name_url is " << change_name_url;

    QVariantMap params;
    params["client_id"]     = client_identifier;
    params["display_name"]  = name;

    FrtcNetworkManager::instance()->post(change_name_url, user_token, params, "login_change_name");

}

void FrtcApiManager::mute_all(const QString user_token, const QString meeting_number, bool allow_self_unmute)
{
    QVariantMap params;
    params["allow_self_unmute"] = allow_self_unmute;

    //qDebug() << "mute_all_url finalUrl:" << mute_all_url;
    QString mute_all_url = muteAllUrl.arg(meeting_number);
    qDebug() << "mute_all_url finalUrl:" << mute_all_url;

    FrtcNetworkManager::instance()->post(mute_all_url, user_token, params, "mute_all_participants");
}

void FrtcApiManager::mute_participant(const QString user_token, const QString meeting_number, bool allow_self_unmute,const QVector<QString> &clientIdentifierArray)
{
    QVariantMap params;
    params["allow_self_unmute"] = allow_self_unmute;
    params["participants"]     =  clientIdentifierArray;

    QString mute_one_all_url = muteOneOrAll.arg(meeting_number);

    FrtcNetworkManager::instance()->post(mute_one_all_url, user_token, params,  "mute_one_all_url");
}

void FrtcApiManager::un_mute_all(const QString user_token, const QString meeting_number)
{
    QString un_mute_all_url = unMuteAllUrl.arg(meeting_number);
    FrtcNetworkManager::instance()->post(un_mute_all_url, user_token, {},  "un_mute_all_participants");
}

void FrtcApiManager:: un_mute_participant(const QString user_token, const QString meeting_number,const QVector<QString> &clientIdentifierArray)
{
    QVariantMap params;
    params["participants"]     =  clientIdentifierArray;

    QString un_mute_one_all_url = unmuteOneOrAll.arg(meeting_number);

    FrtcNetworkManager::instance()->post(un_mute_one_all_url, user_token, params,  "un_mute_one_all_url");
}

void FrtcApiManager::request_un_mute(const QString user_token, const QString meeting_number)
{
    QString request_un_mute_url = requestUnmuteUrl.arg(meeting_number);
    FrtcNetworkManager::instance()->post(request_un_mute_url, user_token, {},  "request_un_mute");
}

void FrtcApiManager::allow_user_un_mute(const QString user_token, const QString meeting_number, const QVector<QString> &clientIdentifierArray)
{
    QString request_un_mute_url = allowUnmuteUrl.arg(meeting_number);

    QVariantMap params;
    params["participants"] = clientIdentifierArray;

    FrtcNetworkManager::instance()->post(request_un_mute_url, user_token, params,  "allow_user_un_mute");
}


void FrtcApiManager::set_user_lecturer(const QString user_token, const QString meeting_number,const QString &client_identifier)
{
    QString set_user_lecturer_url = setUserAsLecturer.arg(meeting_number);
    QVariantMap params;
    params["lecturer"] = client_identifier;

    FrtcNetworkManager::instance()->post(set_user_lecturer_url, user_token, params,  "set_user_lecture");
}

void FrtcApiManager:: un_set_user_lecturer(const QString user_token, const QString meeting_number,const QString &client_identifier)
{
    QString set_user_lecturer_url = setUserAsLecturer.arg(meeting_number);

    FrtcNetworkManager::instance()->deleteResource(set_user_lecturer_url, user_token, {}, "remove_user");
}


void FrtcApiManager::set_user_pin(const QString user_token, const QString meeting_number, const QVector<QString> &clientIdentifierArray)
{
    QString set_user_pin_url = setUserPinUrl.arg(meeting_number);
    QVariantMap params;
    params["participants"] = clientIdentifierArray;

    FrtcNetworkManager::instance()->post(set_user_pin_url, user_token, params,  "set_user_pin");
}

void FrtcApiManager::set_user_un_pin(const QString user_token, const QString meeting_number)
{
    QString set_user_un_pin_url = setUserPinUrl.arg(meeting_number);
    FrtcNetworkManager::instance()->deleteResource(set_user_un_pin_url, user_token, {}, "un_pin_user");
}

void FrtcApiManager::remove_user_from_meeting(const QString &user_token, const QString meeting_number,const QString &client_identifier)
{
    QString remove_user_from_meeting_url = removeUserMeeting.arg(meeting_number);

    QVector<QString> client_id_vector = {client_identifier};

    QVariantMap params;
    params["participants"] = client_id_vector;

    FrtcNetworkManager::instance()->deleteResource(remove_user_from_meeting_url, user_token, params, "remove_user");
}

void FrtcApiManager::owner_stop_meeting(const QString &user_token, const QString meeting_number)
{
    QString stop_meeting_url = stopMeetingUrl.arg(meeting_number);

    FrtcNetworkManager::instance()->post(stop_meeting_url, user_token, {},  "owner_stop_meeting");
}

void FrtcApiManager::start_overlay_message(const QString &user_token, const QString meeting_number,const QVariantMap params)
{
    QString start_overlay_message_url = startMessageUrl.arg(meeting_number);

    FrtcNetworkManager::instance()->post(start_overlay_message_url, user_token, params,  "start_overlay_meeting");

}

void FrtcApiManager:: stop_overlay_message(const QString &user_token, const QString meeting_number)
{
    QString start_overlay_message_url = startMessageUrl.arg(meeting_number);

    FrtcNetworkManager::instance()->deleteResource(start_overlay_message_url, user_token, {}, "stop_overlay_meeting");

}

void FrtcApiManager::start_recording(const QString &user_token, const QString meeting_number)
{
    QString start_recording_url = recordingUrl.arg(meeting_number);

    QVariantMap params;
    params["meeting_number"] = meeting_number;

    FrtcNetworkManager::instance()->post(start_recording_url, user_token, params,  "start_recording_meeting");
}

void FrtcApiManager::stop_recording(const QString &user_token, const QString meeting_number)
{
    QString stop_recording_url = recordingUrl.arg(meeting_number);

    QVariantMap params;
    params["meeting_number"] = meeting_number;


    FrtcNetworkManager::instance()->deleteResource(stop_recording_url, user_token, params,  "stop_recording_meeting");
}

void FrtcApiManager::start_streaming(const QString &user_token, const QString &streaming_password, const QString &meeting_number)
{
    QString start_streaming_url = streamingUrl.arg(meeting_number);

    QVariantMap params;
    params["meeting_number"] = meeting_number;
    params["live_password"] = streaming_password;


    FrtcNetworkManager::instance()->post(start_streaming_url, user_token, params,  "start_streaming_meeting");
}

void FrtcApiManager::stop_streaming(const QString &user_token, const QString &meeting_number)
{
    QString stop_streaming_url = streamingUrl.arg(meeting_number);

    QVariantMap params;
    params["meeting_number"] = meeting_number;

    FrtcNetworkManager::instance()->deleteResource(stop_streaming_url, user_token, params,  "stop_streaming_meeting");
}

void FrtcApiManager::getScheduledMeetingList(const QString &token)
{
    QString serverAddress = SDKUserDefault::getInstance()->getServerAddressFromUserConfigFile();
    QString uuid = QString::fromStdString(FrtcUUID::getApplicationUUID());
    QString restfulUrl = "https://" + serverAddress + scheduleMeetingUrl + "?client_id=" + uuid + "&token=" + token + "&page_num=1&page_size=500";
    FrtcNetworkManager::instance()->get(restfulUrl,{},"frtc_scheduled_meeting_list");
}

void FrtcApiManager::getUserList(const QString &token, const QString &page, const QString &filter)
{
    QString serverAddress = SDKUserDefault::getInstance()->getServerAddressFromUserConfigFile();
    QString uuid = QString::fromStdString(FrtcUUID::getApplicationUUID());

    QString restfulUrl;

    if (filter.isEmpty()) {
        restfulUrl = "https://" + serverAddress +  getAllUserListUrl + "?client_id=" + uuid + "&token=" + token + "&page_num=" + page + "&page_size=50";
    }else {
        QString encodedFilter = QUrl::toPercentEncoding(filter, "!@#$^&%*+,:;='\"`<>()[]{}/\\| ");
        restfulUrl = "https://" + serverAddress +  getAllUserListUrl + "?client_id=" + uuid + "&token=" + token + "&page_num=" + page + "&page_size=50&filter=" + encodedFilter;
    }
    qDebug() << "restfulUrl : " << restfulUrl ;
    FrtcNetworkManager::instance()->get(restfulUrl,{},"frtc_getUser_list");
}

void FrtcApiManager::createMeeting(const QString &token, const QVariantMap &meetingParams)
{
    FrtcNetworkManager::instance()->post(createMeetingUrl,token,meetingParams,"frtc_create_meeting");
}

void FrtcApiManager::updateNoRecurrenceMeeting(const QString &token, const QString &reservationId, const QVariantMap &meetingParams)
{
    QString requestUrl = deleteNonRecurrentMeeting.arg(reservationId);
    FrtcNetworkManager::instance()->post(requestUrl,token,meetingParams,"frtc_update_noRecurrence_meeting");
}

void FrtcApiManager::updateRecurrenceMeeting(const QString &token, const QString &reservationId, const QVariantMap &meetingParams)
{
    QString requestUrl = getScheduleMeetingListUrl.arg(reservationId);
    FrtcNetworkManager::instance()->post(requestUrl,token,meetingParams,"frtc_update_recurrence_meeting");
}

void FrtcApiManager::getRecurrenceMeetingGroupByPage(const QString &token, const QString &groupId, const QString &requestId)
{
    QString requestUrl = getScheduleMeetingListUrl.arg(groupId);
    QVariantMap params;
    params["page_num"]     = 1;
    params["page_size"]  = 100;
    FrtcNetworkManager::instance()->get(requestUrl,token,params,requestId);
}

void FrtcApiManager::deleteMeeting(const QString &token, const QString &reservationId,bool deleteGroup, const QString &requestId)
{
    QString requestUrl = deleteNonRecurrentMeeting.arg(reservationId);
    QVariantMap params;
    if (deleteGroup) {
        params["deleteGroup"]     = true;
    }
    FrtcNetworkManager::instance()->deleteResource(requestUrl,token,params,requestId);
}

void FrtcApiManager::getScheduledMeetingDetail(const QString &token, const QString &reservationId)
{
    QString requestUrl = deleteNonRecurrentMeeting.arg(reservationId);
    FrtcNetworkManager::instance()->get(requestUrl,token,{},"frtc_get_scheduleMeetingDetail");
}

void FrtcApiManager::instantMeeting(const QString &token, const QString &meetingName)
{
    QVariantMap params;
    params["meeting_type"] = "instant";
    params["meeting_name"]  = meetingName;
    FrtcNetworkManager::instance()->post(scheduleMeetingUrl,token,params,"frtc_instant_meeting");
}

void FrtcApiManager::modifyPassword(const QString &token, const QString &oldPsd, const QString &updatePsd)
{
    QVariantMap params;
    params["secret_old"] = secretSha1String(oldPsd);
    params["secret_new"] = secretSha1String(updatePsd);
    FrtcNetworkManager::instance()->put(updatePasswordUrl,token,params,"frtc_modify_password");
}



void FrtcApiManager::onRequestFinished(bool success, int code, const QJsonObject &json, const QString &requestId)
{
    qDebug() << "success:" << success;
    qDebug() << "code:" << code;
    qDebug() << "json:" << json;
    qDebug() << "requestId:" << requestId;
    //emit apiRequestCompleted(success,code,json,requestId);

    if (code == 401) {
        emit signExpiredCompleted();
        return;
    }

    if (requestId == "frtc_sign_in") {
        emit signInRequestCompleted(success,json);
    } else if (requestId == "frtc_sign_out") {
        emit signOutRequestCompleted(success,json);
    } else if (requestId == "frtc_sign_in_token") {
        emit signInTokenRequestCompleted(success,json);
    } else if (requestId == "frtc_room_list") {
        emit queryMeetingRoomListRequestCompleted(success,json);
    } else if (requestId == "frtc_scheduled_meeting_list") {
        emit scheduledMeetingListRequestCompleted(success,json);
    } else if (requestId == "frtc_getUser_list") {
        emit userListCompleted(success,json);
    } else if (requestId == "frtc_create_meeting") {
        emit creatMeetingCompleted(success,json);
    } else if (requestId == "frtc_instant_meeting") {
        emit instantMeetingCompleted(success,json);
    } else if (requestId == "frtc_update_noRecurrence_meeting") {
        emit updateNoRecurrenceMeetingCompleted(success,json);
    } else if (requestId == "frtc_update_recurrence_meeting") {
        emit updateRecurrenceMeetingCompleted(success,json);
    } else if (requestId == "mute_all_participants") {
        emit muteAllCompleted(success);
    } else if(requestId == "un_mute_all_participants") {
        emit unMuteAllCompleted(success);
    } else if (requestId == "frtc_getRecurrenceMeeting_list") {
        emit recurrenceMeetingListCompleted(success,json);
    } else if (requestId == "frtc_getRecurrenceMeetingOne_list") {
        emit recurrenceMeetingListOneCompleted(success,json);
    } else if (requestId == "frtc_deleteMeeting") {
        emit deleteMeetingCompleted(success,json);
    } else if (requestId == "frtc_deleteMeeting_list") {
        emit deleteMeetingListCompleted(success,json);
    } else if (requestId == "start_overlay_meeting") {
        emit startOverlayMessageCompleted(success);
    } else if (requestId == "stop_overlay_meeting") {
        emit stopOverlayMessageCompleted(success);
    } else if (requestId == "frtc_get_scheduleMeetingDetail") {
        emit detailScheduleMeetingCompleted(success,json);
    } else if (requestId == "start_recording_meeting") {
        emit startRecordingCompleted(success);
    } else if (requestId == "frtc_modify_password") {
        emit modifyPasswordCompleted(success);
    } else if(requestId == "stop_recording_meeting") {
        emit stopRecordingCompleted(success);
    } else if(requestId == "start_streaming_meeting") {
        emit startStreamingingCompleted(success);
    } else if(requestId == "stop_streaming_meeting") {
        emit stopStreamingCompleted(success);
    }
}

QString FrtcApiManager::secretSha1String(const QString& password) {
    QString shaResult = password + salt;
    QByteArray data = shaResult.toUtf8();
    QByteArray digest = QCryptographicHash::hash(data, QCryptographicHash::Sha1);

    QString output;
    output.reserve(digest.size() * 2);
    for (int i = 0; i < digest.size(); ++i) {
        output.append(QString("%1").arg((uint8_t)digest[i], 2, 16, QChar('0')));
    }
    return output;
}

void FrtcApiManager::log(const QString &message) {
    std::cout << "[LOG] " << message.toStdString() << std::endl;
}
