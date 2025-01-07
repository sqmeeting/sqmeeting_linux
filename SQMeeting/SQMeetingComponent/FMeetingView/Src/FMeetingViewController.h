#ifndef FMEETINGVIEWCONTROLLER_H
#define FMEETINGVIEWCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include <QDebug>
#include <QSize>

#include "SVCLayoutManager.h"
#include "SDKItemInfo.h"
#include <QVariant>

class FMeetingViewController;

typedef struct _SDK_LAYOUT_INFO {
    QList<MeetingLayout::SDKItemInfo *> *layout;
    bool bContent;
    std::string activeSpeakerSourceId;
    std::string activeSpeakerUuId;
    std::string cellCustomUUID;
} SDKLayoutInfo;


//class FMeetingViewController.

class FMeetingViewController : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FMeetingViewController);
    
private:
    static QMutex m_Mutex;
    static FMeetingViewController *shareInstance;
public:
    static FMeetingViewController* getInstance();
    void releaseInstance();
    explicit FMeetingViewController(QObject *parent = nullptr);
    ~FMeetingViewController();
    
private:
    //QThread *m_thread = nullptr;
    QTimer  *m_timer = nullptr;
    
signals:
    void complete();
    
    
    
public slots:
    void slotTimeOutHandler(); //for timer.
    
    
    
    //==================== begin for QML interaction ====================
signals:
    //signals will trigger the onXXX function of QML.
    void cppSendMsgToQMLRefreshLayoutMode(const QVariant &mode, const QVariant &value);
    void cppSendMsgToQMLRemoteViewHiddenOrNot(const QVariant &value);
    void cppSendMsgToQMLRemoteVideoReceived(const QVariant &datasourceid);
    void cppSendMsgToQMLLayoutRemoteView(const QVariant &mode, const QVariant &value);
    /*
      [Note]: type var, will be used by js function of QML.
      called after prepareSVCLayoutDetail(), prepareSVCFullScreen3x3LayoutDetail(), prepareSVC3x3LayoutDetail(), or prepareSVCLayoutDetail().
      send to SVCLayout.qml for show view's rect.
     */
    void cppSendMsgToQMLPrepareSVCLayout(const QVariant &mode, const QVariant &value);
    
    //for remote content.
    void cppSendMsgToQMLRemoteContentVideoViewSetHidden(const bool hidden);
    void cppSendMsgToQMLRemoteContentVideoViewRenderMuteImage(const bool mute);
    void cppSendMsgToQMLRemoteContentVideoViewStartRendering();
    void cppSendMsgToQMLRemoteContentVideoViewStopRendering();

    //for local camera preview to enable/disable the localPreview TabBar Button.
    void cppSendMsgToQMLSetLocalPreviewEnable(const bool aEnable);
    
    //for start/stop share content UI change.
    void cppSendMsgToQMLContentStateChangedCallBack(const bool isSending);
    
signals:
    //Use roster list to syn every remote-user's mute states of Mic & Camera.
    void cppSendMsgToQMLUpdateRosterNumber(const int rosterNumber);
    void cppSendMsgToQMLUpdateRosterList(const QVariant &rosterListObject);
    
    //for camera devices.
    void cppSendMsgToQMLOnOpenCameraComplete(const int nOpenResulte);

public slots:
    /*
     * [Note 1]: connect signal and slot.
     * 1.[SVCLayoutManager::refreshLayoutMode()] -> emit signalRefreshLayoutMode;
     * 2.it will call the slot [FMeetingViewController.cpp][slotRefreshLayoutMode()];
     * 3.then slotRefreshLayoutMode() will send the mode data to QML via emit cppSendMsgToQMLRefreshLayoutMode;
     * 4.so [FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode] will refresh SVCLayout of UI.
     *
     * [Note 2]:
     * [FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode], the js function parameters are var type,
     * so, the signale and slot, parameters use QVariant type.
     */
    void slotRefreshLayoutMode(const QVariant &mode, const QVariant &value);
    void slotRemoteViewHiddenOrNot(const QVariant &value);

    // [Qt]: emit cppSendMsgToQMLPrepareSVCLayout() to FMeetingViewController.qml onCppSendMsgToQMLPrepareSVCLayout();
    // then send to SVCLayout.qml.
    void slotPrepareSVCLayout(const QVariant &aSVCLayoutType);

    //void slotRemoteVideoReceived
    
public:
    // [get data]: QML call those method to get data from CPP.
    //Q_INVOKABLE bool getCurrentGridMode();
    Q_INVOKABLE bool getTraditionalLayout();
    Q_INVOKABLE QVariant getSvcLayoutDetail();
    Q_INVOKABLE QString getCellCustomUUID();

    QVariant getCurrentSvcLayoutDetail();
    
private:
    void dropCall(int callIndex);
    
    //==================== end for QML interaction ====================
    
public:

    void hiddenLocalView(bool hide);
    //Qt:
    void refreshCurrentLayout();
    void refreshLayoutMode(MeetingLayout::SVCLayoutModeType mode, QList<MeetingLayout::SVCVideoInfo *> * viewArray);
    void remoteViewHiddenOrNot(QList<MeetingLayout::SVCVideoInfo *> * viewArray);
    void layoutRemoteView(MeetingLayout::SVCLayoutModeType mode, QList<MeetingLayout::SVCVideoInfo *> * viewArray);
    
    void setLayoutMode(bool isGridLayout);
    void remoteLayoutChanged(MeetingLayout::SDKLayoutInfo * buffer);
    
    void onContentStateChanged(bool isSending);
    void onContentWaterMaskRecevice(std::string contentWater);


    void remoteVideoReceived(std::string dataSourceID);
    
public:
    bool userPinStatus(std::string userUUID);
       
private:
    bool m_sendingContent;
    bool m_fullScreen;
    bool m_contentLayoutReady;
    bool m_returnToFullScreen;
    bool m_remoteViewHidden;
    bool m_exitFromeFullScreen;
    bool m_waterMask;

public:
    bool isSendingContent() {return m_sendingContent; };
    void setSendingContent(bool sendingContent) { m_sendingContent = sendingContent; }
    
    bool isFullScreen() {return m_fullScreen; }
    void setFullScreen(bool fullScreen) { m_fullScreen = fullScreen; }
    
    bool isContentLayoutReady() {return m_contentLayoutReady; }
    void setContentLayoutReady(bool contentLayoutReady) { m_contentLayoutReady = contentLayoutReady; }
    
    bool isReturnToFullScreen() {return m_returnToFullScreen; }
    void setReturnToFullScreen(bool returnToFullScreen) { m_returnToFullScreen = returnToFullScreen; }
    
    bool isRemoteViewHidden() {return m_remoteViewHidden; }
    void setRemoteViewHidden(bool remoteViewHidden) { m_remoteViewHidden = remoteViewHidden; }
    
    bool isExitFromeFullScreen() {return m_exitFromeFullScreen; }
    void setExitFromeFullScreen(bool exitFromeFullScreen) { m_exitFromeFullScreen = exitFromeFullScreen; }
    
    bool isWaterMask() {return m_waterMask; }
    void setWaterMask(bool waterMask) { m_waterMask = waterMask; }

    int m_remotePeopleCount;

private:
    QSize fullScreenSize;
    int width;
    int height;

    std::string m_cellCustomUUID;

    QList<std::string> * m_remotePeopleVideoViewList;
    std::string m_activeSpeakerDatasoucceID;

    bool m_content;
    bool m_muteCamera;
    bool m_muteMicrophone;
    bool m_traditionalLayout; //1.true: 1x5 2.false: 3x3 (full screen or not).
public:
    bool m_currentGridMode;
    bool m_localViewHiddenByUser;

public:
    bool isContent() {return m_content; };
    void setContent(bool content) { m_content = content; }
    
    bool isMuteCamera() {return m_muteCamera; };
    void setMuteCamera(bool muteCamera) { m_muteCamera = muteCamera; }

    bool isMuteMicrophone() {return m_muteMicrophone; };
    void setMuteMicrophone(bool muteMicrophone) { m_muteMicrophone = muteMicrophone; }
    
    bool isTraditionalLayout() {return m_traditionalLayout; };
    void setTraditionalLayout(bool traditionalLayout) { m_traditionalLayout = traditionalLayout; }
    
    bool isCurrentGridMode() {return m_currentGridMode; };
    void setCurrentGridMode(bool currentGridMode) { m_currentGridMode = currentGridMode; };
    
    bool isLocalViewHiddenByUser() {return m_localViewHiddenByUser; };
    void setLocalViewHiddenByUser(bool localViewHiddenByUser) { m_localViewHiddenByUser = localViewHiddenByUser; }
    
private:
    std::string callName;
    std::string conferenceName;
    std::string conferenceAlias;
    std::string appName;
    
    bool m_audioCall;
    bool m_sendContentAudio;
    bool m_sendAppContent;
    
public:
    bool isAudioCall() {return m_audioCall; };
    void setAudioCall(bool audioCall) { m_audioCall = audioCall; }
    
    bool isSendContentAudio() {return m_sendContentAudio; };
    void setSendContentAudio(bool sendContentAudio) { m_sendContentAudio = sendContentAudio; }
    
    bool isSendAppContent() {return m_sendAppContent; };
    void setSendAppContent(bool sendAppContent) { m_sendAppContent = sendAppContent; }

    int shareContentType;
    
    QSize currentScreenSize;
    QList<std::string> * rosterListArray;
    
    
public:
    //Use roster list to syn every remote-user's mute states of Mic & Camera.
    void onParticipantsNumReport(int participantsNum);
    void onParticipantsListReveived(std::vector<std::string> rosterList);
    
    void onOpenCameraComplete(int nOpenResulte);
};

#endif // FMEETINGVIEWCONTROLLER_H
