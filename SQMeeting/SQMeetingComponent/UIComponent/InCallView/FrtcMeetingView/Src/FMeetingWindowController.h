#ifndef FMEETINGWINDOWCONTROLLER_H
#define FMEETINGWINDOWCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QDebug>
//#include <queue>
#include <QQueue>
#include <QVariantList>

//#include <QQmlEngine>
//#include <QJSEngine>

#include <QSize>

#include "FMakeCallClient.h"

//class FMeetingViewController.

class FMeetingWindowController : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FMeetingWindowController);

private:
    static QMutex m_Mutex;
    static FMeetingWindowController *shareInstance;
public:
    static FMeetingWindowController* getInstance();
    void releaseInstance();
    explicit FMeetingWindowController(QObject *parent = nullptr);
    ~FMeetingWindowController();

    //==================== begin for QML interaction ====================
    //1.for incall UI Tabbar button.
public:
    // [set action]: QML emit signal, then those mothods will be called for action.
    Q_INVOKABLE void onQmlLocalAudioMute(bool mute);
    Q_INVOKABLE void onQmlLocalVideoMute(bool mute);
    Q_INVOKABLE void onQmlUserLeaveMeeting();

    Q_INVOKABLE void onQmlStartShareScreen();
    Q_INVOKABLE void onQmlStopShareScreen();

    //1.sharing content is stopped by user because user dropCall.
    //2.sharing content is stopped by server (for others start sharing content now).
    Q_INVOKABLE void onQmlCloseSharingBarWindow();
    Q_INVOKABLE void onQmlShowSharingBarExpandView(bool bShow);

    Q_INVOKABLE void onQmlSwitchGridMode(bool bGallery);
    Q_INVOKABLE QVariant onQmlGetMeetingInfo();
    QVariant getMeetingInfo();
    Q_INVOKABLE void dropCall(int callIndex);
    Q_INVOKABLE void onQmlSetCameraVideoMirror(bool video_mirror);
    Q_INVOKABLE void onNoiseReductionEnable(bool noise_reduction);

    void stopMeetingDuration();

    //2.for sharingBar button.
    Q_INVOKABLE void onQmlMuteLocalAudio(); //Mic
    Q_INVOKABLE void onQmlMuteLocalVideo(); //Camera.
    Q_INVOKABLE void onQmlShowInvitationDialog();
    Q_INVOKABLE void onQmlShowParticipantsDialog();
    Q_INVOKABLE void onQmlShowSettingDialog();
    Q_INVOKABLE void onQmlShowStatisticsDialog();
    Q_INVOKABLE void onQmlShowMessageOverLayDialog();
    Q_INVOKABLE void onQmlShowRecordingDialog();
    Q_INVOKABLE void onQmlShowStopRecordingDialog();
    Q_INVOKABLE void onQmlShowStreamingingDialog();
    Q_INVOKABLE void onQmlShowStopStreamingDialog();
    Q_INVOKABLE void onQmlStopMessageOverLay();
    Q_INVOKABLE void onQmlGetMeetingDuration();

    Q_INVOKABLE QString onQmlGetMeetingNumber();
    Q_INVOKABLE void onQmlSetUserAuthority(bool user_authority, bool meeting_owner);


signals:
    //signals will trigger the onXXX function of QML.
    //for start/stop share content UI change.
    void cppSendMsgToQMLContentStateChangedCallBack(const bool isSending);

    //for sharingBar button.
    void cppSendMsgToQMLMuteLocalAudio(); //Mic
    void cppSendMsgToQMLMuteLocalVideo(); //Camera.
    void cppSendMsgToQMLShowInvitationDialog();
    void cppSendMsgToQMLShowParticipantsDialog();
    void cppSendMsgToQMLShowSettingDialog();
    void cppSendMsgToQMLShowStatisticsDialog();
    void cppSendMsgToQMLShowOverlayMessageDialog();
    void cppSendMsgToQMLStopOverlayMessage();

    void cppSendMsgToQMLShowRecordingDialog();
    void cppSendMsgToQMLShowStopRecordingDialog();

    void cppSendMsgToQMLShowStreamingDialog();
    void cppSendMsgToQMLShowStopStreamingDialog();

    void cppSendMsgToQMLMeetingDuration(QString dural);

    void cppSendMsgToQMLOnMuteLockedCallBack(const bool muted, const bool allowSelfUnmute);
    void cppSendMsgToQMLOnUnMuteReqeustAllowedCallBack();
    void cppSendMsgToQMLOnWaterMaskCallBack(const QString& live_meeting_url,
                                            const QString& live_password,
                                            const QString& live_status,
                                            const QString& recording_status);
    void cppSendMsgToQMLonMessageOverLayCallBack(const bool enabled,
                                                 const int vertical_position,
                                                 const int display_repetition,
                                                 const QString& display_speed,
                                                 const QString& message_text);

    void cppSendMsgToQMLonMessageLayoutSettingChangedCallBack(const QString& lecture_id, const int max_cell_count, bool is_by_setting_speaker);

    void cppSendMsgToQMLOnUnMuteRequestCallBack(const QString& name,const QString& uuid);

    void cppSendMegToQMLOnPinSpeakerChangedCallBack(const QString &pin_uuid);
    
    void cppSendMsgToQMLOpenCameraFailedSetCameraMuteButtonState();
    //==================== end for QML interaction ====================

public:
    void onContentStateChangedCallBack(bool isSending);
    void onMuteLockedCallBack(bool muted, bool allowSelfUnmute);
    void onWaterMaskCallBack(const QString& live_meeting_url,
                             const QString& live_password,
                             const QString& live_status,
                             const QString& recording_status);

    void onMessageOverLayCallBack(const bool enabled,
                                  const int vertical_position,
                                  const int display_repetition,
                                  const QString& display_speed,
                                  const QString& message_text);

    void onLayoutSettingChangedCallBack(const QString& lecture_id, const int max_cell_count);

    void onUMuteRequestCallBack(const QString& name, const QString& uuid);

    void onUnMuteRequestAllowed();
    void onOpenCameraFailedSetCameraMuteButtonState();

    void onReceivePinSpeakerIDCallBack(const QString& pin_uuid);

public slots:
    //void onQmlDynamicLoaded(QObject* dynamicObject); // 动态加载 QML 完成后的回调
    void onQmlDynamicLoaded();
    void onShareBarButtonViewLoaded();

private:
    bool m_sendingContent;
    int i;
    QThread *m_thread = nullptr;
    QTimer  *m_timer = nullptr;

    QElapsedTimer m_elapsedTimer;

    void dealMeetingDuration();

private:
    //QObject* qmlObject;           // 动态加载的 QML 对象
    bool isQmlLoaded;
    //std::queue<QString> pendingMessages; // 保存未处理的消息
    QQueue<QVariantList> pendingMessages; // 队列存储未处理的信号参数

    QString m_live_status;
    QString m_recording_status;
};


#endif // FMEETINGWINDOWCONTROLLER_H
