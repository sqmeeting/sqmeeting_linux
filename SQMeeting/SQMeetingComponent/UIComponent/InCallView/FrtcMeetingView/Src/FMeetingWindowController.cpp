#include "FMeetingWindowController.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include "FrtcInCallModel.h"
#include "FrtcInfoInstance.h"
#include "FrtcUUID.h"

#include "FrtcSharingFrameWindow.h"


QMutex FMeetingWindowController::m_Mutex;
FMeetingWindowController *FMeetingWindowController::shareInstance = nullptr;

FMeetingWindowController* FMeetingWindowController::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FMeetingWindowController();
    }
    return shareInstance;
}

void FMeetingWindowController::releaseInstance() {
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

FMeetingWindowController::FMeetingWindowController(QObject *parent) :
    QObject(parent),
    m_sendingContent(false),
    isQmlLoaded(false)
{

}

FMeetingWindowController::~FMeetingWindowController() {
    qDebug("--- --- --- --- *** *** *** [%s][%d]: this: %p", Q_FUNC_INFO, __LINE__, this);
}


void FMeetingWindowController::onQmlDynamicLoaded() {
    //qmlObject = dynamicObject; // 设置 QML 对象引用
    qDebug()<< "----------------void FMeetingWindowController::onQmlDynamicLoaded()-------------";
    isQmlLoaded = true;
    // 处理队列中的消息
    while (!pendingMessages.isEmpty()) {
        QVariantList messageParams = pendingMessages.dequeue();
        if(messageParams[0].toString() == "onWaterMaskCallBack") {
            emit cppSendMsgToQMLOnWaterMaskCallBack(
                                    messageParams[1].toString(),
                                    messageParams[2].toString(),
                                    messageParams[3].toString(),
                                    messageParams[4].toString());
            qDebug() << "Processed pending message: " << messageParams;
        } else if(messageParams[0].toString() == "onMessageOverLayCallBack") {
            qDebug() << "Processed pending message for onMessageOverLayCallBack: " << messageParams;
            emit cppSendMsgToQMLonMessageOverLayCallBack(
                                    messageParams[1].toBool(),
                                    messageParams[2].toInt(),
                                    messageParams[3].toInt(),
                                    messageParams[4].toString(),
                                    messageParams[5].toString());
        }
    }
}

void FMeetingWindowController::onShareBarButtonViewLoaded()
{
    emit cppSendMsgToQMLOnWaterMaskCallBack("",
                                            "",
                                            m_live_status,
                                            m_recording_status);
}


//==================== begin for QML interaction ====================
// [set action]: QML call those mothod for action.
//====================   ====================   ====================

void FMeetingWindowController::onQmlLocalAudioMute(bool mute) {
    FMakeCallClient::sharedCallClient()->mute_micphone(mute);
}

void FMeetingWindowController::onQmlLocalVideoMute(bool mute) {
    FMakeCallClient::sharedCallClient()->mute_camera(mute);
}

void FMeetingWindowController::onQmlStartShareScreen() {
    FMakeCallClient::sharedCallClient()->start_content();
    
    FrtcSharingFrameWindow::getInstance()->startShowSharingBarFrameWindow();
}

void FMeetingWindowController::onQmlSetCameraVideoMirror(bool video_mirror) {
    FMakeCallClient::sharedCallClient()->video_mirror(video_mirror);
}

void FMeetingWindowController::onNoiseReductionEnable(bool noise_reduction) {
    FMakeCallClient::sharedCallClient()->noise_reduction_enable(noise_reduction);
}

void FMeetingWindowController::onQmlStopShareScreen() {
    FMakeCallClient::sharedCallClient()->stop_content();
    FrtcSharingFrameWindow::getInstance()->stopShowSharingBarFrameWindow();
}

void FMeetingWindowController::onQmlCloseSharingBarWindow() {
    FrtcSharingFrameWindow::getInstance()->stopShowSharingBarFrameWindow();
}

void FMeetingWindowController::onQmlShowSharingBarExpandView(bool bShow) {
    FrtcSharingFrameWindow::getInstance()->showSharingBarExpandView(bShow);
}

/*
 * [FMeetingWindowController.cpp]:
 *     onQmlUserLeaveMeeting() is marked as Q_INVOKABLE, so QML could send signal to invoke this funcion.
 *
 * [FMeetingWindow.qml]:
 *     root.qmlUserLeaveMeetingSignal.connect(FMeetingWindowControllerObject.onQmlUserLeaveMeeting);
*/
void FMeetingWindowController::onQmlUserLeaveMeeting() {
    this->dropCall(0);
}

void FMeetingWindowController::onQmlSwitchGridMode(bool bGallery) {
    FMakeCallClient::sharedCallClient()->switch_layout_mode(bGallery);
}

QVariant FMeetingWindowController::onQmlGetMeetingInfo() {
    QVariant varValue = getMeetingInfo();
    return varValue;
}

QVariant FMeetingWindowController::getMeetingInfo() {
    FrtcInCallModel *model = FrtcInfoInstance::sharedFrtcInfoInstance()->inCallModel;

    QString qStrConferenceName      = model->conferenceName;
    QString qStrConferenceNumber    = model->conferenceNumber;
    QString qStrOwnerName           = model->ownerName;
    QString qStrMeetingPasscode     = model->conferencePassword;

    QJsonObject Obj;
    Obj.insert("conferenceName", qStrConferenceName);
    Obj.insert("meetingID", qStrConferenceNumber);
    Obj.insert("ownerName", qStrOwnerName);
    Obj.insert("meetingPasscode", qStrMeetingPasscode);
    QVariant varValue = QVariant::fromValue(Obj);

    return varValue;
}

//2.for sharingBar button.
void FMeetingWindowController::onQmlMuteLocalAudio() {
    emit cppSendMsgToQMLMuteLocalAudio();
}

void FMeetingWindowController::onQmlMuteLocalVideo() {
    emit cppSendMsgToQMLMuteLocalVideo();
}

void FMeetingWindowController::onQmlShowInvitationDialog() {
    emit cppSendMsgToQMLShowInvitationDialog();
}

void FMeetingWindowController::onQmlShowParticipantsDialog() {
    emit cppSendMsgToQMLShowParticipantsDialog();
}

void FMeetingWindowController::onQmlShowSettingDialog() {
    emit cppSendMsgToQMLShowSettingDialog();
}

void FMeetingWindowController::onQmlShowStatisticsDialog() {
    emit cppSendMsgToQMLShowStatisticsDialog();
}

void FMeetingWindowController:: onQmlShowMessageOverLayDialog() {
    emit cppSendMsgToQMLShowOverlayMessageDialog();
}

void FMeetingWindowController::onQmlStopMessageOverLay(){
    emit cppSendMsgToQMLStopOverlayMessage();
}

void FMeetingWindowController::onQmlShowRecordingDialog()
{
    emit cppSendMsgToQMLShowRecordingDialog();
}

void FMeetingWindowController::onQmlShowStopRecordingDialog()
{
    emit cppSendMsgToQMLShowStopRecordingDialog();
}

void FMeetingWindowController::onQmlShowStreamingingDialog()
{
    emit cppSendMsgToQMLShowStreamingDialog();
}

void FMeetingWindowController::onQmlShowStopStreamingDialog()
{
    emit cppSendMsgToQMLShowStopStreamingDialog();
}

void FMeetingWindowController::onQmlGetMeetingDuration() {
    this->m_thread = new QThread();

    this->m_timer = new QTimer;
    this->m_timer->setTimerType(Qt::PreciseTimer);
    this->m_timer->setInterval(1000);
    this->m_timer->moveToThread(this->m_thread);

    QObject::connect(this->m_thread, SIGNAL(started()), this->m_timer, SLOT(start()));
    QObject::connect(this->m_thread, SIGNAL(finished()), this->m_timer, SLOT(stop()));

    QObject::connect(this->m_timer,&QTimer::timeout,[=]() {
        this->dealMeetingDuration();
    });

    this->m_thread->start();
    m_elapsedTimer.start();
}

QString FMeetingWindowController::onQmlGetMeetingNumber()
{
    FrtcInCallModel *model = FrtcInfoInstance::sharedFrtcInfoInstance()->inCallModel;

    QString qStrConferenceNumber      = model->conferenceNumber;

    return qStrConferenceNumber;
}

void FMeetingWindowController::onQmlSetUserAuthority(bool user_authority, bool meeting_owner)
{
    FrtcSharingFrameWindow::getInstance()->setAuthority(meeting_owner, user_authority);
}

void FMeetingWindowController::dealMeetingDuration()
{
    qint64 elapsedSeconds = m_elapsedTimer.elapsed() / 1000;

    QTime time(0, 0);
    time = time.addSecs(elapsedSeconds);

    QString dural;
    if(elapsedSeconds < 3600)
    {
        dural = time.toString("mm:ss");
    }
    else
    {
        dural = time.toString("hh:mm:ss");
    }

    emit cppSendMsgToQMLMeetingDuration(dural);
}

//==================== end for QML interaction ====================

void FMeetingWindowController::stopMeetingDuration() {
    i = 0;
    this->m_thread->quit();
    this->m_thread->exit();
}

void FMeetingWindowController::dropCall(int callIndex) {
    //this->stopMeetingDuration();
    FMakeCallClient::sharedCallClient()->drop_call();
    isQmlLoaded = false;
}

void FMeetingWindowController::onContentStateChangedCallBack(bool isSending)
{
    //1.wants to share, but current is sharing, so return.
    if (isSending && this->m_sendingContent) {
        return;
    }

    //2.wants to stop share, but current is not sharing, so return.
    if (!isSending && !this->m_sendingContent) {
        return;
    }
    //3.sharing content
    this->m_sendingContent = isSending;
    if (isSending) {
        //3.1.local share content.
        qDebug("[%s][%d]: isSending: true, local sharing content...", Q_FUNC_INFO, __LINE__);
    }
}

void FMeetingWindowController::onMuteLockedCallBack(bool muted, bool allowSelfUnmute)
{
    emit cppSendMsgToQMLOnMuteLockedCallBack(muted, allowSelfUnmute);
}

void FMeetingWindowController::onWaterMaskCallBack(const QString& live_meeting_url,
                         const QString& live_password,
                         const QString& live_status,
                         const QString& recording_status)
{
    m_live_status = live_status;
    m_recording_status = recording_status;

    if (isQmlLoaded) {
        emit cppSendMsgToQMLOnWaterMaskCallBack(live_meeting_url,
                                                live_password,
                                                live_status,
                                                recording_status);
    } else {
        QVariantList messageParams = {"onWaterMaskCallBack", live_meeting_url, live_password, live_status, recording_status};
        pendingMessages.enqueue(messageParams);
    }
}

void FMeetingWindowController::onMessageOverLayCallBack(const bool enabled,
                    const int vertical_position,
                    const int display_repetition,
                    const QString& display_speed,
                    const QString& message_text)
{
    if (isQmlLoaded) {
        emit cppSendMsgToQMLonMessageOverLayCallBack(enabled,
                                                     vertical_position,
                                                     display_repetition,
                                                     display_speed,
                                                     message_text);
    } else {
        QVariantList messageParams = {"onMessageOverLayCallBack", enabled, vertical_position, display_repetition, display_speed, message_text};
        pendingMessages.enqueue(messageParams);
    }



    emit cppSendMsgToQMLonMessageOverLayCallBack(enabled,
                                            vertical_position,
                                            display_repetition,
                                            display_speed,
                                            message_text);
}

void FMeetingWindowController::onLayoutSettingChangedCallBack(const QString& lecture_id, const int max_cell_count)
{
    bool is_by_setting_speaker = false;

    if (lecture_id == QString::fromStdString(FrtcUUID::getApplicationUUID())) {
        is_by_setting_speaker = true;
    }

    emit cppSendMsgToQMLonMessageLayoutSettingChangedCallBack(lecture_id, max_cell_count, is_by_setting_speaker);
}

void FMeetingWindowController::onUMuteRequestCallBack(const QString& name, const QString& uuid)
{
    emit cppSendMsgToQMLOnUnMuteRequestCallBack(name, uuid);
}

void FMeetingWindowController::onUnMuteRequestAllowed()
{
    emit cppSendMsgToQMLOnUnMuteReqeustAllowedCallBack();
}

void FMeetingWindowController::onOpenCameraFailedSetCameraMuteButtonState()
{
    emit cppSendMsgToQMLOpenCameraFailedSetCameraMuteButtonState();
}

void FMeetingWindowController::onReceivePinSpeakerIDCallBack(const QString& pin_uuid)
{
    emit cppSendMegToQMLOnPinSpeakerChangedCallBack(pin_uuid);
}
