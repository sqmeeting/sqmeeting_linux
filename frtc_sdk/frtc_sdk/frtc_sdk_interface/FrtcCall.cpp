#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
#include <windows.h>
#include "json.h"
#endif

#include "json.h"
#include "FrtcCall.h"

#include "SDKContextWrapper.h"



//========== ========== for SVCLayout ========== ==========
#include "SVCLayoutManager.h"
//========== ========== for SVCLayout ========== ==========

#include "sq_log.h"

#include <iostream>
#include <algorithm>

#define CHECK_INIT_STATE() if (!_initialized) { return; }
#define CHECK_INIT_STATE_RETURN(ret) if (!_initialized) { return ret; }



/*
 class FrtcCall
 */

std::mutex FrtcCall::m_Mutex;
FrtcCall* FrtcCall::shareInstance = nullptr;

FrtcCall* FrtcCall::sharedCallClient()
{
	if (nullptr == shareInstance)
	{
		std::lock_guard mutexLocker(m_Mutex);
		shareInstance = new FrtcCall();
	}
	return shareInstance;
}

void FrtcCall::releaseInstance()
{
	if (nullptr != shareInstance)
	{
		std::lock_guard mutexLocker(m_Mutex);
		delete shareInstance;
		shareInstance = nullptr;
	}
}

FrtcCall::FrtcCall() :
	call_status(s_call_idle)
	, _initialized(false)
	, reason(0)
	, muteCamera(false)
	, muteMicrophone(false)
	, audioCall(false)
	, displayName("")
	, layoutMode(SVCLayoutModeType::SVC_LAYOUT_MODE_1N5)
	, meeting_msg_callback(nullptr)
	, _sdkContext(nullptr)
	, client_uuid("")
	, clientName("")
	, conferenceName("")
	, conferenceAlias("")
	, serverAddress("")
	, appName("")
	, ownerID("")
	, ownerName("")
	, password("")
	, meetingUrl("")
	, scheduleStartTime(0)
	, scheduleEndTime(0)
	, meetingID("")
	, current_lecture_id("")
{
	this->setupCallStateTransition();
}

void FrtcCall::init(const std::string& uuid, const std::string& log_path)
{
	if(_initialized)
	{
		return;
	}
	this->client_uuid = uuid;
	_sdkContext = std::make_unique<SDKContext>(uuid, log_path);
	_sdkContext->setSDKContextObserver(this);
	_initialized = true;
}

void FrtcCall::set_frtc_client_uuid(const std::string& uuid)
{
}

std::string FrtcCall::get_frtc_client_uuid()
{
	CHECK_INIT_STATE_RETURN(std::string(""));
	return this->client_uuid;
}

void FrtcCall::set_frtc_meeting_msg_callback(PMEETINGMSGCALLBACK callback)
{
	CHECK_INIT_STATE();
	this->meeting_msg_callback = callback;
}

void FrtcCall::callStateTransition(SDKCallStatus call_status)
{
	/*
	if (this->call_status == s_call_idle
			&& call_status == s_call_connected)
	{
		FRTCSDKCallResult reason = FRTCSDK_CALL_CONNECTED;
		this->completionHandler(s_call_connected,
								reason,
								this->conferenceName,
								this->conferenceAlias,
								this->ownerID,
								this->ownerName,
								this->meetingUrl,
								this->scheduleStartTime,
								this->scheduleEndTime,
								this->isLogin());

	}

	if (this->call_status == s_call_idle
			&& call_status == s_call_dis_connected)
	{
		FRTCSDKCallResult result = this->convertToSDKResult(this->reason);
		this->completionHandler(s_call_dis_connected,result,"","","","","",0,0,this->isLogin());
	}

	if (this->call_status == s_call_connected
			&& call_status == s_call_dis_connected)
	{
		FRTCSDKCallResult result = this->convertToSDKResult(this->reason);
		this->frtcDropCall();
		this->completionHandler(s_call_dis_connected,result,"","","","","",0,0,this->isLogin());
	}

	if (this->call_status == s_call_dis_connected
			&& call_status == s_call_connected)
	{
		FRTCSDKCallResult reason = FRTCSDK_CALL_CONNECTED;
		this->completionHandler(s_call_connected,
								reason,
								this->conferenceName,
								this->conferenceAlias,
								this->ownerID,
								this->ownerName,
								this->meetingUrl,
								this->scheduleStartTime,
								this->scheduleEndTime,
								this->isLogin());
	}

	if (this->call_status == s_call_dis_connected
			&& call_status == s_call_dis_connected)
	{
		FRTCSDKCallResult result = this->convertToSDKResult(this->reason);
		this->completionHandler(s_call_dis_connected,
								result,"error","error","error","error","error",0,0,this->isLogin());
	}

	this->call_status = call_status; // current call state.
	*/
}

//TODO: -Yingyong.Mao
//还需要一堆参数

void FrtcCall::frtcMakeCall(FRTCSDKCallParam callParam,

	std::function<void(SDKCallStatus call_status,
		FRTCSDKCallResult reason,
		std::string conferenceName,
		std::string conferenceNumber,
		std::string ownerID,
		std::string ownerName,
		std::string meetingUrl,
		const long long scheduleStartTime,
		const long long scheduleEndTime,
		bool isLoginCall)> callCompletionHandler)
{


	CHECK_INIT_STATE();
	this->reason = 0;
	this->call_status = s_call_idle;


	this->appName = callParam.appName;
	this->conferenceAlias = callParam.conferenceNumber;
	this->clientName = callParam.clientName;
	this->muteCamera = callParam.muteCamera;
	this->muteMicrophone = callParam.muteMicrophone;
	this->audioCall = callParam.audioCall;

	this->completionHandler = callCompletionHandler;

	if (this->audioCall)
	{
		callParam.callRate = 64;
	}
}


void FrtcCall::make_call(const std::string& server_address,
                         const std::string& meeting_number,
                         const std::string& display_name,
                         const std::string& meeting_pwd,
                         const std::string& user_id,
                         const std::string& user_token)
{
	CHECK_INIT_STATE();
	this->reason = 0;
	this->call_status = s_call_idle;

	this->serverAddress = server_address;
	this->conferenceAlias = meeting_number;
	this->clientName = display_name;
	this->muteCamera = true;
	this->muteMicrophone = true;
	this->audioCall = false;

    if(user_token.empty()) {
        printf("\n----------------------guest_call\n");
        _sdkContext->frtc_make_guest_call(server_address,
            meeting_number,
            display_name,
            0,
            meeting_pwd);
    } else {
        printf("\n----------------------login_call, the user_token is %s, and the user_id is %s\n", user_token.c_str(), user_id.c_str());
        _sdkContext->frtc_make_login_call(server_address,
            meeting_number,
            display_name,
            0,
            meeting_pwd,
            user_token,
            user_id);
    }
}


//Block, callback for SDKContex.
void FrtcCall::callStateBlock(SDKCallStatus call_status, int reason)
{
	CHECK_INIT_STATE();
	this->reason = reason;

	this->call_status = call_status; // current call state.
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "call_state_changed";
		root["call_state"] = call_status;
		root["reason"] = reason;
		meeting_msg_callback(root.toStyledString().c_str());
	}

	this->callStateTransition(call_status); // [Note]: 5: CALL_STATE_CONNECTED

}

void FrtcCall::makeCallBlock(std::string conferenceName, std::string meetingID, std::string displayName, std::string ownerID, std::string ownerName) {

	CHECK_INIT_STATE();
	this->conferenceName = conferenceName.c_str();
	this->meetingID = meetingID.c_str();
	this->displayName = displayName.c_str();
	this->ownerID = ownerID.c_str();
	this->ownerName = ownerName.c_str();


}

void FrtcCall::muteLockedBlock(bool muted, bool allowSelfUnmute)
{

}


void FrtcCall::dialInCallStatusBlock(int dialInCallStatusr)
{

}

const char* FrtcCall::frtcGetCallStaticsInfomation()
{
	staticsInfoStr = std::string(_sdkContext->getStatisticsAsString());
	return staticsInfoStr.c_str();
}

void FrtcCall::frtcSetIntelligentNoiseReduction(bool enable)
{
	CHECK_INIT_STATE();
    _sdkContext->setIntelligentNoiseReduction(enable);
}

uint64_t FrtcCall::StartUploadLogs(const std::string& meta_data, const std::string& file_name, int file_count)
{
	logUploadStatusStr.clear();
	return _sdkContext->StartUploadLogsImpl(meta_data, file_name, file_count);
}

const char* FrtcCall::GetUploadStatusImpl(uint64_t traction_id)
{
	logUploadStatusStr = std::string(_sdkContext->GetUploadStatusImpl(traction_id));
	DebugLog("frtcsdk get logupload status %s", logUploadStatusStr.c_str());
	return logUploadStatusStr.c_str();
}

void FrtcCall::CancelLogUpload(uint16_t traction_id)
{
	_sdkContext->CancelUploadLogsImpl(traction_id);
}


void FrtcCall::onSVCLayoutChanged(const SDKLayoutInfo& layoutInfo)
{
	InfoLog("FrtcCall::onSVCLayoutChanged stream count %d, active speaker %s", layoutInfo.layout.size(), layoutInfo.activeSpeakerSourceId.c_str());
	SVCLayoutManager::getInstance()->updateSVCLayout(layoutInfo);
	this->layoutMode = SVCLayoutManager::getInstance()->getSvcLayoutMode();
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "svc_layout_changed";
		root["has_content"] = layoutInfo.bContent;
		root["layout_mode"] = layoutInfo.mode;
		root["active_speaker_msid"] = layoutInfo.activeSpeakerSourceId;
		root["active_speaker_uuid"] = layoutInfo.activeSpeakerUuId;
		root["cell_custom_uuid"] = layoutInfo.cellCustomUUID;

		Json::Value videoList;
		auto svcVideoList = SVCLayoutManager::getInstance()->getSVCLayoutVideo();
		for (auto iter = svcVideoList.begin(); iter != svcVideoList.end(); ++iter)
		{
			Json::Value svcVideo;
			svcVideo["uuid"] = iter->uuid;
			svcVideo["msid"] = iter->msid;
			svcVideo["display_name"] = iter->display_name;
			svcVideo["video_type"] = iter->eVideoType;
			svcVideo["is_active"] = iter->is_active;
			svcVideo["is_pinned"] = iter->is_pinned;
			svcVideo["width"] = iter->resolution_width;
			svcVideo["height"] = iter->resolution_height;

			videoList.append(svcVideo);

			InfoLog("FrtcCall::onSVCLayoutChanged layout stream msid %s, name %s, width %d", iter->msid.c_str(), iter->display_name.c_str(), iter->resolution_width);
		}

		root["layout_video_list"] = videoList;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onPinSpeakerChanged(const std::string& pinSpeakerUuid)
{
    if (meeting_msg_callback)
    {
        Json::Value root;
        root["msg_type"] = "pin_speaker_changed";
        root["pin_speaker_id"] = pinSpeakerUuid;
        meeting_msg_callback(root.toStyledString().c_str());
    }
}

void FrtcCall::onLayoutSettingChanged(int max_cell_count, const std::vector<std::string>& lectures)
{
	if (lectures.empty())
		current_lecture_id = "";
	else
		current_lecture_id = lectures.front();

	SVCLayoutManager::getInstance()->updateLectureID(current_lecture_id);

	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "layout_setting_changed";
		root["lecture_id"] = current_lecture_id;
		root["max_cell_count"] = max_cell_count;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onVideoStreamReceived(const std::string& msid)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "remote_video_stream_received";
		root["msid"] = msid;
		bool isContent = 0 == msid.compare(0, SVCLayoutManager::kContentMSIDPrefixStr.length(), SVCLayoutManager::kContentMSIDPrefixStr);
		root["is_content"] = isContent;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onAudioStreamReceived(const std::string& msid)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "remote_audio_stream_received";
		root["msid"] = msid;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onParticipantsNumReport(int participantsNum)
{

}

void FrtcCall::frtcDropCall()
{
	CHECK_INIT_STATE();
	_sdkContext->dropCall(0);
	//_sdkContext->local
	//_sdkContext->clearVideoData(sourceID);
}

void FrtcCall::setupCallStateTransition()
{

}

void FrtcCall::callStateChangedToConnected()
{
}

void FrtcCall::frtc_remote_video_fetch(const std::string& msid, unsigned int* width, unsigned int* height, unsigned long* data_len, void** video_data)
{
	CHECK_INIT_STATE();
	_sdkContext->getVideoData(msid, video_data, (unsigned int*)data_len, width, height);
}

void FrtcCall::frtc_remote_audio_fetch(const std::string& msid, void* audio_data, unsigned int data_len, unsigned int sample_rate)
{
	CHECK_INIT_STATE();
	_sdkContext->getAudioData(audio_data, data_len, sample_rate);
}

void FrtcCall::send_video_frame(const std::string& msid, int width, int height, unsigned long data_len, VIDEO_COLOR_FORMAT format, void* video_data, unsigned int stride)
{
	CHECK_INIT_STATE();
	_sdkContext->startSendVideoStream(msid, video_data, data_len, width, height, (RTC::VideoColorFormat)format, stride);
}

void FrtcCall::send_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate)
{
	CHECK_INIT_STATE();
	_sdkContext->sendAudioData(buffer, length, sample_rate, false);
}

void FrtcCall::send_content_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate)
{
	CHECK_INIT_STATE();
	_sdkContext->sendAudioDataContent("", buffer, length, sample_rate);
}

void FrtcCall::frtcMuteLocalVideo(bool mute)
{
	CHECK_INIT_STATE();
	_sdkContext->muteLocalVideo(mute);
}

void FrtcCall::frtcMuteLocalAudio(bool mute)
{
	CHECK_INIT_STATE();
	_sdkContext->muteLocalAudio(mute);
}

void FrtcCall::frtcSetVideoStreamMirror(bool mirror)
{
    CHECK_INIT_STATE();
    _sdkContext->setVideoMirror(mirror);
}


void FrtcCall::frtcSetGridLayoutMode(bool gridMode)
{
	CHECK_INIT_STATE();
	_sdkContext->setGridLayoutMode(gridMode);
	this->layoutMode = gridMode ? SVCLayoutModeType::SVC_LAYOUT_MODE_GALLERY : SVCLayoutModeType::SVC_LAYOUT_MODE_1N5;
}

void FrtcCall::frtcHideLocalPreview(bool hidden)
{
}

void FrtcCall::sendPasscode(std::string passcode)
{
	CHECK_INIT_STATE();
	_sdkContext->sendPasscode(passcode);
}

void FrtcCall::startShareScreen()
{
	CHECK_INIT_STATE();
	_sdkContext->startShareScreen();
}

void FrtcCall::stopShareScreen()
{
	CHECK_INIT_STATE();
	_sdkContext->stopShareScreen();
}

void FrtcCall::onCallStateChangedCallBack(SDKCallStatus status, int reason)
{
	CHECK_INIT_STATE();
	this->callStateBlock(status, reason);
}

void FrtcCall::onMeetingInfo(const std::string& meeting_name,
	const std::string& meeting_id,
	const std::string& display_name,
	const std::string& owner_id,
	const std::string& owner_name,
	const std::string& meeting_url,
	const std::string& group_meeting_url,
	long long start_time,
	long long end_time)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "on_meeting_info";
		root["meeting_name"] = meeting_name;
		root["meeting_id"] = meeting_id;
		root["display_name"] = display_name;
		root["owner_id"] = owner_id;
		root["owner_name"] = owner_name;
		root["meeting_url"] = meeting_url;
		root["group_meeting_url"] = group_meeting_url;
		root["start_time"] = static_cast<int64_t>(start_time);
		root["end_time"] = static_cast<int64_t>(end_time);

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onInputPasswordCallBack()
{
	if (meeting_msg_callback)
	{
		Json::Value root;
        root["msg_type"] = "on_input_password_request";
        //root["call_state"] = SDKCallStatus::s_call_dis_connected;
        //root["reason"] = reason;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onParticipantsNumReportCallBack(int participantsNum)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "on_participants_num_changed";
		root["participants_num"] = participantsNum;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onParticipantsListReceived(const std::set<std::string>& rosterList)
{
	//handle participant exit
	//re-build roster_list from rosterList 
	std::lock_guard<std::mutex> lock(roster_list_mutex);

	Json::Value root;
	root["msg_type"] = "on_participant_list";
	root["is_full"] = true;

	Json::Value roster;

	std::map<std::string, RTC::ParticipantStatus> new_list;
	for (auto iter = rosterList.begin(); iter != rosterList.end(); ++iter)
	{
		RTC::ParticipantStatus status;
		auto item = new_list.emplace(*iter, status);
		auto found = roster_map.find(*iter);
		if (found != roster_map.end())
		{
			item.first->second = found->second;
			Json::Value participant;
			participant["uuid"] = found->first;
			participant["display_name"] = found->second.display_name;
			participant["user_id"] = found->second.user_id;
			participant["audio_mute"] = found->second.audio_mute;
			participant["video_mute"] = found->second.video_mute;
			roster.append(participant);
		}
	}
	roster_map = new_list;
	if (meeting_msg_callback)
	{
		root["roster_list"] = roster;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onReceiveUnmuteRequestCallBack(const std::map<std::string, std::string>& partiList)
{

    Json::Value root;
    root["msg_type"] = "on_un_mute_request";

    // root["uuid"] = pair.first;
    // root["name"] = pair.second;

    for (const auto& pair : partiList) {
        std::cout << "Key: " << pair.first << ", Value: " << pair.second << std::endl;

        root["uuid"] = pair.first;
        root["name"] = pair.second;
    }

    meeting_msg_callback(root.toStyledString().c_str());
}

void FrtcCall::OnParticipantStatusChanged(std::map<std::string, RTC::ParticipantStatus>& rosterList, bool is_full)
{
	std::lock_guard<std::mutex> lock(roster_list_mutex);

	Json::Value root;
	root["msg_type"] = "on_participant_list";
	root["is_full"] = is_full;
	Json::Value roster;

	for (auto iter = rosterList.begin(); iter != rosterList.end(); ++iter)
	{
		auto found = roster_map.find(iter->first);
		if (found != roster_map.end())
		{
			found->second = iter->second;
		}
		else
		{
			roster_map.emplace(iter->first, iter->second);
		}

		Json::Value participant;
		participant["uuid"] = iter->first;
		participant["display_name"] = iter->second.display_name;
		participant["user_id"] = iter->second.user_id;
		participant["audio_mute"] = iter->second.audio_mute;
		participant["video_mute"] = iter->second.video_mute;
		roster.append(participant);
	}

	if (meeting_msg_callback)
	{
		root["roster_list"] = roster;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onContentStateChangedCallBack(bool isSending)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "content_sending_state_changed";
		root["is_sending"] = isSending;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onMuteLockedCallBack(bool muted, bool allowSelfUnmute)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "on_audio_mute_changed";
		root["muted"] = muted;
		root["allow_self_unmute"] = allowSelfUnmute;
		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onUnMuteAllowCallBack()
{
    if (meeting_msg_callback)
    {
        Json::Value root;
        root["msg_type"] = "on_allow_un_mute_agree";
        meeting_msg_callback(root.toStyledString().c_str());
    }
}

void FrtcCall::OnRequestVideoStream(const std::string& msid, int width, int height, float frame_rate)
{
	bool isContent = 0 == msid.compare(0, SVCLayoutManager::kContentMSIDPrefixStr.length(), SVCLayoutManager::kContentMSIDPrefixStr);
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "request_video_stream";
		root["msid"] = msid;
		root["width"] = width;
		root["height"] = height;
		root["frame_rate"] = frame_rate;
		root["is_content"] = isContent;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::OnRequestAudioStream(const std::string& msid)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "request_audio_stream";
		root["msid"] = msid;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::OnDeleteVideoStream(const std::string& msid)
{
	auto currentLayout = SVCLayoutManager::getInstance()->getSVCLayoutVideo();

	auto it = std::find_if(currentLayout.begin(), currentLayout.end(), [&](const SVCVideoInfo& layout)
	{ return layout.msid == msid && layout.resolution_width < 0; });

	if (it == currentLayout.end() && meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "delete_video_stream";
		root["msid"] = msid;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::OnMessageOverlayReceived(const RTC::TextOverlay& message)
{
	if (meeting_msg_callback)
	{
		Json::Value root;
		root["msg_type"] = "on_message_overlay";
		root["enabled"] = message.enabled;
		root["message_text"] = message.text;
		root["color"] = message.color;
		root["font_size"] = message.font_size;
		root["font"] = message.font;
		root["vertical_position"] = message.vertical_position;
		root["display_repetition"] = message.display_repetition;
		root["display_speed"] = message.display_speed;
		root["text_overlay_type"] = message.text_overlay_type;
		root["background_transparency"] = message.background_transparency;

		meeting_msg_callback(root.toStyledString().c_str());
	}
}

void FrtcCall::onContentWaterMaskRecevice(const std::string& contentWater,
                                            const std::string& recordingStatus,
                                            const std::string& liveStatus,
                                            const std::string& liveMeetingUrl,
                                            const std::string& livePassword)
{
    if(meeting_msg_callback)
    {
        Json::Value root;
        root["msg_type"] = "on_water_mask";
        root["recording_status"]    = recordingStatus;
        root["live_status"]         = liveStatus;
        root["live_meeting_url"]    = liveMeetingUrl;
        root["live_password"]       = livePassword;

        meeting_msg_callback(root.toStyledString().c_str());
    }
}

FRTCSDKCallResult FrtcCall::convertToSDKResult(int reason)
{
	FRTCSDKCallResult result;
	if (reason == 28) {
		result = FRTCSDK_CALL_SUCCESS;
	}
	else if (reason == 5) {
		result = FRTCSDK_CALL_UNREACHABLE;
	}
	else if (reason == 23) {
		result = FRTCSDK_CALL_LOCKED;
	}
	else if (reason == 22) {
		result = FRTCSDK_CALL_MEETINGNOTEXIST;
	}
	else if (reason == 0) {
		result = FRTCSDK_CALL_ABORTED;
	}
	else if (reason == 4) {
		result = FRTCSDK_CALL_NOANSWER;
	}
	else if (reason == 2) {
		result = FRTCSDK_CALL_HABGUP;
	}
	else if (reason == 8) {
		result = FRTCSDK_CALL_LOSTCONNECTION;
	}
	else if (reason == 18) {
		result = FRTCSDK_CALL_SERVERERROR;
	}
	else if (reason == 12) {
		result = FRTCSDK_CALL_NOPERMISSION;
	}
	else if (reason == 13) {
		result = FRTCSDK_CALL_AUTHFAILED;
	}
	else if (reason == 16) {
		result = FRTCSDK_CALL_REJECTED;
	}
	else if (reason == 17) {
		result = FRTCSDK_CALL_UNABLEPROCESS;
	}
	else if (reason == 38) {
		result = FRTCSDK_CALL_STOP;
	}
	else if (reason == 39) {
		result = FRTCSDK_CALL_INTERRUPT;
	}
	else if (reason == 40) {
		result = FRTCSDK_CALL_REMOVE;
	}
	else if (reason == 41) {
		result = FRTCSDK_CALL_PASSWORD_TOO_MANY_RETRIES;
	}
	else if (reason == 43) {
		result = FRTCSDK_CALL_EXPIRED;
	}
	else if (reason == 44) {
		result = FRTCSDK_CALL_NOT_STARTED;
	}
	else if (reason == 45) {
		result = FRTCSDK_CALL_GUEST_UNALLOWED;
	}
	else if (reason == 46) {
		result = FRTCSDK_CALL_PEOPLE_FULL;
	}
	else if (reason == 47) {
		result = FRTCSDK_CALL_NO_LICENSE;
	}
	else if (reason == 48) {
		result = FRTCSDK_CALL_LICENSE_MAX_LIMIT_REACHED;
	}
	else if (reason == 49) {
		result = FRTCSDK_CALL_EXIT_EXCEPTION;
	}
	else {
		result = FRTCSDK_CALL_FAILED;
	}
	return result;
}


