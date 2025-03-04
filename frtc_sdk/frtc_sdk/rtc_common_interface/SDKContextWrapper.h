#ifndef SDKCONTEXT_H
#define SDKCONTEXT_H

#include <list>
#include <mutex>
#include <functional>

#include "object_impl.h"

#include "SDKItemInfo.h"

/**
 Enum for Call state.
 */
enum SDKCallStatus {
    s_call_idle = 0,
    s_call_connected,
    s_call_dis_connected
};

class FrtcCallObserverInterface
{
public:
    virtual ~FrtcCallObserverInterface() {};

	virtual void onCallStateChangedCallBack(SDKCallStatus status, int reason) = 0;
    virtual void onInputPasswordCallBack() = 0;
    virtual void onMeetingInfo(const std::string& meeting_name,
        const std::string& meeting_id,
        const std::string& display_name,
        const std::string& owner_id,
        const std::string& owner_name,
        const std::string& meeting_url,
        const std::string& group_meeting_url,
        long long start_time,
        long long end_time) = 0;
    virtual void onParticipantsNumReportCallBack(int participantsNum) = 0;
    virtual void onParticipantsListReceived(const std::set<std::string>& rosterList) = 0;

    virtual void OnParticipantStatusChanged(std::map<std::string, RTC::ParticipantStatus>& roster_list, bool is_full) = 0;
    virtual void onReceiveUnmuteRequestCallBack(const std::map<std::string, std::string>& partiList) = 0;
    virtual void onContentStateChangedCallBack(bool isSending) = 0;
    virtual void onMuteLockedCallBack(bool muted, bool allowSelfUnmute) = 0;
    virtual void onUnMuteAllowCallBack() = 0;


    virtual void onSVCLayoutChanged(const SDKLayoutInfo& layout) = 0;
    virtual void onLayoutSettingChanged(int max_cell_count, const std::vector<std::string>& lectures) = 0;
	virtual void onVideoStreamReceived(const std::string& msid) = 0;
    virtual void onAudioStreamReceived(const std::string& msid) = 0;
    virtual void OnRequestVideoStream(const std::string& msid, int width, int height, float frame_rate) = 0;
    virtual void OnRequestAudioStream(const std::string& msid) = 0;
    virtual void OnDeleteVideoStream(const std::string& msid) = 0;
    virtual void onPinSpeakerChanged(const std::string& pinSpeakerUuid) = 0;

    virtual void OnMessageOverlayReceived(const RTC::TextOverlay& message) = 0;

    virtual void onContentWaterMaskRecevice(const std::string& contentWater,
                                            const std::string& recordingStatus,
                                            const std::string& liveStatus,
                                            const std::string& liveMeetingUrl,
                                            const std::string& livePassword) = 0;
};

typedef enum CallStatus {
    call_Idle = 0,
    call_Connected,
    call_Disconnected
} CallStatus;



/**
 Enum for Call result.
 */
enum FRTCSDKCallResult {
    FRTCSDK_CALL_SUCCESS = 0,
    FRTCSDK_CALL_MEETINGNOTEXIST,
    FRTCSDK_CALL_REJECTED,
    FRTCSDK_CALL_NOANSWER,
    FRTCSDK_CALL_UNREACHABLE,
    FRTCSDK_CALL_HABGUP,
    FRTCSDK_CALL_ABORTED,
    FRTCSDK_CALL_LOSTCONNECTION,
    FRTCSDK_CALL_LOCKED,
    FRTCSDK_CALL_SERVERERROR,
    FRTCSDK_CALL_NOPERMISSION,
    FRTCSDK_CALL_AUTHFAILED,
    FRTCSDK_CALL_UNABLEPROCESS,
    FRTCSDK_CALL_FAILED,
    FRTCSDK_CALL_CONNECTED,
    FRTCSDK_CALL_STOP,
    FRTCSDK_CALL_INTERRUPT,
    FRTCSDK_CALL_REMOVE,
    FRTCSDK_CALL_PASSWORD_TOO_MANY_RETRIES,
    FRTCSDK_CALL_EXPIRED,
    FRTCSDK_CALL_NOT_STARTED,
    FRTCSDK_CALL_GUEST_UNALLOWED,
    FRTCSDK_CALL_PEOPLE_FULL,
    FRTCSDK_CALL_NO_LICENSE,
    FRTCSDK_CALL_LICENSE_MAX_LIMIT_REACHED,
    FRTCSDK_CALL_EXIT_EXCEPTION
};


class SDKContext
{
public:
    SDKContext(const std::string& uuid, const std::string log_path);
private:
    ObjectImpl *_impl  = nullptr;
    FrtcCallObserverInterface* _sdkObserver;

    
public:
    bool sendAppContent;
    bool isSendAppContent() { return sendAppContent; };
    void setSDKContextObserver(FrtcCallObserverInterface *sdkObserver);
    void startShareContent();

public:
    void frtc_make_guest_call(
        const std::string& ipAddress,
        const std::string& conferenceAlias,
        const std::string& clientName,
        int callRate,
        const std::string& password);

    void frtc_make_login_call(
        const std::string& ipAddress,
        const std::string& conferenceAlias,
        const std::string& clientName,
        int callRate,
        const std::string& passwor,
        const std::string& user_token,
        const std::string& user_id
        );
    
    
    void onCallStateChanged(RTC::MeetingStatus status, int reason);        
    void layoutChanged(const RTC::LayoutDescription&layout);
    void onLayoutSettingChanged(int max_cell_count, const std::vector<std::string>& lectures);
    void onContentStateChanged(bool isSending);

    void onInputPassCode();



    void onMessageOverLay(const RTC::TextOverlay& overlayMessage);
    
    void onContentWaterMaskRecevice(const std::string& contentWater,
                                    const std::string& recordingStatus,
                                    const std::string& liveStatus,
                                    const std::string& liveMeetingUrl,
                                    const std::string& livePassword);

    void onReceiveUnmuteRequestNotify(const std::map<std::string, std::string>& partiList);
    void onReceiveAllowUnmuteNotify();
    void onParticipantsNumReport(int participantsNum);
    void onContentPriorityChangeResponse(std::string status, std::string transactionKey) {}
    void onMuteLocked(bool muted, bool allowSelfUnmute);

    void onUrMutedDetected();
    void onEncryptStateReport(bool encrypted);
    


    void participantsListReveived(std::set<std::string> rosterList);

	void OnParticipantStatusChanged(std::map<std::string, RTC::ParticipantStatus>& roster_list, bool is_full);

    void onMakeCallBack(const std::string& meeting_name,
        const std::string& meeting_id,
        const std::string& display_name,
        const std::string& owner_id,
        const std::string& owner_name,
        const std::string& meeting_url,
        const std::string& group_meeting_url,
        long long start_time,
        long long end_time);
    
    
    
    
    void videoReveived(const std::string& msid);
    void audioReveived(const std::string& msid);

    void onVideoStreamRequested(const std::string& msid, int width, int height, float framerate);
    void onAudioStreamRequested(const std::string& msid);

    void onDeletedVideoStream(const std::string& msid);
    
public:    
    void startSendVideoStream(std::string msid,
                              void * buffer,
                              size_t length,
                              size_t width,
                              size_t height,
                              RTC::VideoColorFormat type,
                              int stride = 0);
    
    void startSendContentStream(std::string msid,
                                void * buffer,
                                size_t length,
                                size_t width,
                                size_t height,
                                RTC::VideoColorFormat type);
    
    void getVideoData(std::string msid,
                      void **buffer,
                      unsigned int* length,
                      unsigned int* width,
                      unsigned int* height);
    

    void muteLocalVideo(bool muted);
    void muteLocalAudio(bool muted);
    

    void sendAudioData(void* buffer,
                       unsigned int length,
                       unsigned int sample_rate,
                       bool b2ndMic);
    
    void sendAudioDataContent(std::string msid,
                              void * buffer,
                              unsigned int length,
                              unsigned int sample_rate);
    
    void getAudioData(void * buffer,
                      unsigned int length,
                      unsigned int sample_rate);
    
    
    void sendPasscode(std::string passcode);

    void setContentAudio(bool enable, bool isSameDevice);

    void clearVideoData(std::string msid);

    void dropCall(int callIndex);
    
    
    void setGridLayoutMode(bool gridMode);

    void setIntelligentNoiseReduction(bool enable);

    void setVideoMirror(bool video_mirror);
    
public:
    //
    std::string getStatisticsAsString();
    
    //send content
    void startSendContent(std::string name, int index);
    void stopSendingContent();

    void startContent();
    
    //
    std::string onDeviceName();

    int getCPULevel();

    void setCameraCaps(std::string resolutionStr);
    
    std::string getVersion();

public:
    //for share content.
    void startShareScreen();
    void stopShareScreen();

public:
    void aes_decode(const std::string& salt, const std::string& ciphered, std::string& decoded);

    uint64_t StartUploadLogsImpl(const std::string meta_data,
                                 const std::string file_name,
                                 int file_count);

    std::string GetUploadStatusImpl(uint64_t traction_id);
    void CancelUploadLogsImpl(uint64_t traction_id);

    void SetSystemInfoImpl(const std::string &deviceModel,
                           const std::string &osVersion);

};

#endif // SDKCONTEXT_H
