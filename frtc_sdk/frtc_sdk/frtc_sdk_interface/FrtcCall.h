#ifndef FRTCCALL_H
#define FRTCCALL_H

#include <iostream>
#include <mutex>
#include <functional>
#include <vector>
#include <memory>

#include "SDKContextWrapper.h"
#include "frtc_sdk_api.h"

//=================================================
// Enum.
//=================================================



/**
 Enum for Set sdk config key.Currently only supports configuring server addresses
 */
enum FRTCSDKConfigParamKey {
	CFG_SERVER_ADDR = 0,
	CFG_ENABLE_NOISE_BLOCKER,
	CFG_INCALL_WND_TITLE,
	CFG_INCALL_WND_ICON_PATH,
	CFG_CAMERA_QUALITY_PREFERENCE,
	CFG_ENABLE_ACOUSTIC_FENCE
};

typedef struct {
	std::string appName;
	std::string conferenceNumber;
	std::string clientName;
	std::string userToken;
	std::string password;
	std::string callUrl;
	std::string userID;
	int callRate;
	bool muteMicrophone;
	bool muteCamera;
	bool audioCall;
	bool gridMode;
} FRTCSDKCallParam;

typedef struct {
	int index;
	uint32_t displayID;
} MonitorInfo;

/**
 Enum for Share content type.
 */

enum FRTCShareContentType {
	FRTCSDK_SHARE_CONTENT_IDLE = 0,
	FRTCSDK_SHARE_CONTENT_DESKTOP = 1,
	FRTCSDK_SHARE_CONTENT_APPLICATION = 2,
};

class FrtcCall : FrtcCallObserverInterface
{
private:
	static std::mutex m_Mutex;
	static FrtcCall* shareInstance;
public:
	static FrtcCall* sharedCallClient();
	static void releaseInstance();

private:
	FrtcCall();


public:
	void init(const std::string& uuid, const std::string& log_path);
	void set_frtc_client_uuid(const std::string& uuid);
	void set_frtc_meeting_msg_callback(PMEETINGMSGCALLBACK callback);
	std::string get_frtc_client_uuid();

public:
	SDKCallStatus call_status; // current call state.

	int reason;
	int callStatusCode;

	std::function<void(SDKCallStatus call_status,
		FRTCSDKCallResult reason,
		std::string conferenceName,
		std::string conferenceNumber,
		std::string ownerID,
		std::string ownerName,
		std::string meetingUrl,
		const long long scheduleStartTime,
		const long long scheduleEndTime,
		bool isLoginCall)> completionHandler;

	std::function<void()> passwordBlock;

private:
	bool _initialized;

	std::unique_ptr<SDKContext> _sdkContext;

	PMEETINGMSGCALLBACK meeting_msg_callback;

	std::string client_uuid;
	std::string clientName;
	std::string conferenceName;
	std::string conferenceAlias;
	std::string serverAddress;
	std::string appName;
	std::string ownerID;
	std::string ownerName;
	std::string password;
	std::string meetingUrl;
	long long scheduleStartTime;
	long long scheduleEndTime;

	//
	std::string meetingID;
	std::string displayName;

	std::mutex roster_list_mutex;
	std::map<std::string, RTC::ParticipantStatus> roster_map;
	std::string current_lecture_id;

	std::string staticsInfoStr;
	std::string logUploadStatusStr;

private:
	bool muteCamera;
	bool muteMicrophone;
	bool login;
	bool audioCall;
	bool startAudioUnit;
	bool reconnect;
	SVCLayoutModeType layoutMode;

public:
	bool isMuteCamera() { return muteCamera; }
	bool isMuteMicrophone() { return muteMicrophone; }
	bool isLogin() { return login; }
	bool isAudioCall() { return audioCall; }
	bool isStartAudioUnit() { return startAudioUnit; }
	bool isReconnect() { return reconnect; }

public:
	void callStateTransition(SDKCallStatus call_status);

	void frtcMakeCall(FRTCSDKCallParam callParam,

		std::function<void(SDKCallStatus call_status,
			FRTCSDKCallResult reason,
			std::string conferenceName,
			std::string conferenceNumber,
			std::string ownerID,
			std::string ownerName,
			std::string meetingUrl,
			const long long scheduleStartTime,
			const long long scheduleEndTime,
			bool isLoginCall)> callCompletionHandler
	);

    void make_call(const std::string& server_address,
                   const std::string& meeting_number,
                   const std::string& display_name,
                   const std::string& meeting_pwd,
                   const std::string& user_id,
                   const std::string& user_token);

	/**
	 Hang up the call.
	 */
	void frtcDropCall();

	void setupCallStateTransition();

	void callStateChangedToConnected();

	void frtc_remote_video_fetch(const std::string& msid, unsigned int* width, unsigned int* height, unsigned long* data_len, void** video_data);
	void frtc_remote_audio_fetch(const std::string& msid, void* audio_data, unsigned int data_len, unsigned int sample_rate);

	void send_video_frame(const std::string& msid, int width, int height, unsigned long data_len, VIDEO_COLOR_FORMAT format, void* video_data, unsigned int stride = 0);
	void send_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate);
	void send_content_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate);


	//Media Control API

	/**
	 Client use this function to use camera.

	 @param mute  YES is mute, No is unmute.

	 */
	void frtcMuteLocalVideo(bool mute);

	/**
	 Client use this function to use camera.

	 @param mute  YES is mute No is unmute.

	 */
	void frtcMuteLocalAudio(bool mute);

    void frtcSetVideoStreamMirror(bool mirror);

	//Block, callback for SDKContext.
public:
	void callStateBlock(SDKCallStatus call_status, int reason);

	void makeCallBlock(std::string conferenceName, std::string meetingID, std::string displayName, std::string ownerID, std::string ownerName);

	void muteLockedBlock(bool muted, bool allowSelfUnmute);

	void dialInCallStatusBlock(int dialInCallStatusr);

	void onParticipantsNumReport(int participantsNum);

	/**
	 choose video layout mode.

	 @param gridMode YES tranditional layout No 3x3 layout.
	 */
	void frtcSetGridLayoutMode(bool gridMode);
	void frtcHideLocalPreview(bool hidden);

	void sendPasscode(std::string passcode);
	/**
	 Get the Meeiing's statics Information.
	 */
	const char * frtcGetCallStaticsInfomation();

    void frtcSetIntelligentNoiseReduction(bool enable);

	uint64_t StartUploadLogs(const std::string& meta_data, const std::string& file_name, int file_count);
	const char* GetUploadStatusImpl(uint64_t traction_id);
	void CancelLogUpload(uint16_t traction_id);

public:
	//for share content.
	void startShareScreen();
	void stopShareScreen();

public:
	void onCallStateChangedCallBack(SDKCallStatus status, int reason);
	void onMeetingInfo(const std::string& meeting_name,
		const std::string& meeting_id,
		const std::string& display_name,
		const std::string& owner_id,
		const std::string& owner_name,
		const std::string& meeting_url,
		const std::string& group_meeting_url,
		long long start_time,
		long long end_time);
	void onInputPasswordCallBack();
	void onParticipantsNumReportCallBack(int participantsNum);
	void onParticipantsListReceived(const std::set<std::string>& rosterList);
	void OnParticipantStatusChanged(std::map<std::string, RTC::ParticipantStatus>& rosterList, bool is_full);
    void onReceiveUnmuteRequestCallBack(const std::map<std::string, std::string>& partiList);
	void onContentStateChangedCallBack(bool isSending);
	void onMuteLockedCallBack(bool muted, bool allowSelfUnmute);
    void onUnMuteAllowCallBack();

	void onSVCLayoutChanged(const SDKLayoutInfo& layoutInfo);
    void onPinSpeakerChanged(const std::string& pinSpeakerUuid);
	void onLayoutSettingChanged(int max_cell_count, const std::vector<std::string>& lectures);
	void onVideoStreamReceived(const std::string& msid);
	void onAudioStreamReceived(const std::string& msid);
	void OnRequestVideoStream(const std::string& msid, int width, int height, float frame_rate);
	void OnRequestAudioStream(const std::string& msid);

	void OnDeleteVideoStream(const std::string& msid);

	void OnMessageOverlayReceived(const RTC::TextOverlay& message);

    void onContentWaterMaskRecevice(const std::string& contentWater,
                                    const std::string& recordingStatus,
                                    const std::string& liveStatus,
                                    const std::string& liveMeetingUrl,
                                    const std::string& livePassword);
private:
	FRTCSDKCallResult convertToSDKResult(int reason);

};

#endif // FRTCCALL_H
