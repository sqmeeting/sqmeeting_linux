#include "object_impl.h"
#include "SDKContextWrapper.h"
#include <iostream>


const std::string SDK_VERSION = "1.0.0.1";

ObjectImpl::ObjectImpl(void)
	:_sdk_context(nullptr),
	_impl_oc_object(nullptr),
	_common_interface(nullptr),
	_is_sending_video(false),
	_is_receive_video(false),
    _is_content(false),
	_intelligent_noise_reduction_enabled(false),
	_sdk_version(SDK_VERSION)
{
}

ObjectImpl::~ObjectImpl()
{
}

bool ObjectImpl::Init(SDKContext* ocObject, const std::string& uuid, const std::string& log_path)
{
	_sdk_context = ocObject;

	if (!_common_interface)
	{
		_common_interface = new CommonInterface(this, uuid, log_path);
	}

	_common_interface->GetLocalPreviewID(local_video_id);

	return true;
}

const char* ObjectImpl::GetSDKVersion()
{
	return _sdk_version.c_str();
}

void ObjectImpl::JoinMeetingNoLoginImpl(const std::string& server_address,
	const std::string& meeting_alias,
	const std::string& display_name,
	const std::string& meeting_password,
	int call_rate)
{
	_common_interface->JoinMeetingNoLogin(server_address,
		meeting_alias,
		display_name,
		meeting_password,
		call_rate);
}

void ObjectImpl::JoinMeetingLoginImpl(const std::string& server_address,
	const std::string& meeting_alias,
	const std::string& display_name,
	const std::string& user_token,
	const std::string& meeting_password,
	int call_rate,
	const std::string& user_id)
{
	_common_interface->JoinMeetingLogin(server_address,
		meeting_alias,
		display_name,
		user_token,
		meeting_password,
		call_rate,
		user_id);
}

void ObjectImpl::EndMeetingImpl(int call_index)
{
	_common_interface->EndMeeting(call_index);
}

void ObjectImpl::SendVideoFrameImpl(std::string media_id,
	void* buffer,
	unsigned int length,
	unsigned int width,
	unsigned int height,
	RTC::VideoColorFormat format,
	unsigned int stride)
{
    _common_interface->SendVideoFrame(media_id, buffer, length, width, height, format, stride);

    if (_is_sending_video && media_id.rfind("VCS", 0) == std::string::npos)
    {
        _common_interface->SendVideoFrame(_peopel_media_id, buffer, length, width, height, format);
    }
}

void ObjectImpl::ReceiveVideoFrameImpl(std::string& media_id,
	void** buffer,
	unsigned int* length,
	unsigned int* width,
	unsigned int* height)
{
	_common_interface->ReceiveVideoFrame(media_id, buffer, length, width, height);
}

void ObjectImpl::ResetVideoFrameImpl(std::string& media_id)
{
	_common_interface->ResetVideoFrame(media_id);
}

void ObjectImpl::SendAudioFrameImpl(void* buffer, unsigned int length, unsigned int sample_rate)
{
	_common_interface->SendAudioFrame(_audio_send_media_id, buffer, length, sample_rate);
}

void ObjectImpl::ReceiveAudioFrameImpl(void* buffer, unsigned int length, unsigned int sample_rate)
{
	_common_interface->ReceiveAudioFrame(_audio_receive_id, buffer, length, sample_rate);
}

void ObjectImpl::StartSendContentImpl()
{

	_common_interface->StartSendContent();
}

void ObjectImpl::StopSendContentImpl()
{
	_common_interface->StopSendContent();
}

void ObjectImpl::SetContentAudioImpl(bool enable, bool isSameDevice)
{
	_common_interface->SetContentAudio(enable, isSameDevice);
}

void ObjectImpl::SendContentAudioFrameImpl(std::string meida_id,
	void* buffer,
	unsigned int length,
	unsigned int sample_rate)
{
	//content audio use apr msid
	_common_interface->SendContentAudioFrame(_audio_receive_id, buffer, length, sample_rate);
}

void ObjectImpl::MuteLocalVideoImpl(bool muted)
{
	_common_interface->MuteLocalVideo(muted);
}

void ObjectImpl::MuteLocalAudioImpl(bool isMuted)
{
	_common_interface->MuteLocalAudio(isMuted);
}

void ObjectImpl::SetLayoutGridModeImpl(bool grid_mode)
{
	_common_interface->SetLayoutGridMode(grid_mode);
}

void ObjectImpl::SetIntelligentNoiseReductionImpl(bool enable)
{
	_common_interface->SetIntelligentNoiseReduction(enable);
	_intelligent_noise_reduction_enabled = enable;
}

void ObjectImpl::SetCameraCapabilityImpl(std::string resolution_str)
{
	return _common_interface->SetCameraCapability(resolution_str);
}

void ObjectImpl::SetCameraStreamMirrorImpl(bool is_mirror)
{
	_common_interface->SetCameraStreamMirror(is_mirror);
}

std::string ObjectImpl::GetMediaStatisticsImpl()
{
	return _common_interface->GetMediaStatistics();
}

void ObjectImpl::VerifyPasscodeImpl(const std::string& passcode)
{
	_common_interface->VerifyPasscode(passcode);
}

uint64_t ObjectImpl::StartUploadLogsImpl(std::string meta_data,
	std::string file_name,
	int file_count)
{
	return _common_interface->StartUploadLogs(meta_data, file_name, file_count);
}

std::string ObjectImpl::GetUploadStatusImpl(uint64_t traction_id)
{
	return _common_interface->GetUploadStatus(traction_id);
}

void ObjectImpl::CancelUploadLogsImpl(uint64_t traction_id)
{
	_common_interface->CancelUploadLogs(traction_id);
}

void ObjectImpl::OnMeetingJoinInfoCallBack(const std::string& meeting_name,
	const std::string& meeting_id,
	const std::string& display_name,
	const std::string& owner_id,
	const std::string& owner_name,
	const std::string& meeting_url,
	const std::string& group_meeting_url,
	long long start_time,
	long long end_time)
{
	_sdk_context->onMakeCallBack(meeting_name,
		meeting_id,
		display_name,
		owner_id,
		owner_name,
		meeting_url,
		group_meeting_url,
		start_time,
		end_time);

}

void ObjectImpl::OnMeetingStatusChangeCallBack(RTC::MeetingStatus status,
	int reason,
	const std::string& call_id)

{
	_sdk_context->onCallStateChanged(status, reason);
}

void ObjectImpl::OnMeetingJoinFailCallBack(RTC::MeetingStatusChangeReason reason)
{
	RTC::MeetingStatus status = RTC::kDisconnected;

	_sdk_context->onCallStateChanged(status, reason);
}

void ObjectImpl::OnParticipantCountCallBack(int parti_count)
{
	_sdk_context->onParticipantsNumReport(parti_count);
}

void ObjectImpl::OnParticipantListCallBack(const std::set<std::string>& uuid_list)
{
	_sdk_context->participantsListReveived(uuid_list);
}

void ObjectImpl::OnParticipantStatusChangeCallBack(std::map<std::string, RTC::ParticipantStatus>& roster_list,
	bool is_full)
{
	_sdk_context->OnParticipantStatusChanged(roster_list, is_full);
}

void ObjectImpl::OnRequestVideoStreamCallBack(const std::string& msid,
	int width,
	int height,
	float frame_rate)
{
	if (msid.rfind("VCS", 0) == std::string::npos)
	{
		_is_sending_video = true;
		_peopel_media_id = msid;
        _is_content = false;
    }
    else
    {
        _is_content = true;
        _sdk_context->onVideoStreamRequested(msid, width, height, frame_rate);
    }
}

void ObjectImpl::OnAddVideoStreamCallBack(const std::string& msid,
	int width,
	int height,
	uint32_t ssrc)
{
	_is_receive_video = true;
	_remote_media_id = msid;

	_sdk_context->videoReveived(msid);
}

void ObjectImpl::OnRequestAudioStreamCallBack(const std::string& msid)
{
	_audio_send_media_id = msid;
	_sdk_context->onAudioStreamRequested(msid);
}

void ObjectImpl::OnAddAudioStreamCallBack(const std::string& msid)
{
	_audio_receive_id = msid;

	_sdk_context->audioReveived(msid);
}

void ObjectImpl::OnDetectAudioMuteCallBack()
{
	_sdk_context->onUrMutedDetected();
}

void ObjectImpl::OnTextOverlayCallBack(RTC::TextOverlay* text_overly)
{
	_sdk_context->onMessageOverLay(*text_overly);
}

void ObjectImpl::OnMeetingSessionStatusCallBack(const std::string& watermark_msg,
	const std::string& recording_status,
	const std::string& streaming_status,
	const std::string& streaming_url,
	const std::string& streaming_pwd)
{
	_sdk_context->onContentWaterMaskRecevice(watermark_msg, recording_status, streaming_status, streaming_url, streaming_pwd);
}

void ObjectImpl::OnUnmuteRequestCallBack(const std::map<std::string, std::string>& parti_list)
{
	_sdk_context->onReceiveUnmuteRequestNotify(parti_list);
}

void ObjectImpl::OnUnmuteAllowCallBack()
{
	_sdk_context->onReceiveAllowUnmuteNotify();
}

void ObjectImpl::OnMuteLockCallBack(bool muted, bool allow_self_unmute)
{
	_sdk_context->onMuteLocked(muted, allow_self_unmute);
}

void ObjectImpl::OnContentStatusChangeCallBack(RTC::ContentStatus status)
{
		_sdk_context->onContentStateChanged(status == RTC::ContentStatus::kContentSending);
}

void ObjectImpl::OnContentTokenResponseCallBack(bool rejected)
{
	// [(__bridge id)(_impl_oc_object) onContentPriorityChangeResponse:status withKey:transactionKey];
}

void ObjectImpl::OnLayoutChangeCallBack(const RTC::LayoutDescription& layout)
{
	_sdk_context->layoutChanged(layout);
}

void ObjectImpl::OnLayoutSettingCallBack(int max_cell_count,
	const std::vector<std::string>& lectures)
{
	_sdk_context->onLayoutSettingChanged(max_cell_count, lectures);
}

void ObjectImpl::OnPasscodeRequestCallBack()
{
	_sdk_context->onInputPassCode();
}

void ObjectImpl::OnDeleteVideoStreamCallBack(const std::string& msid)
{
	//if(msid.rfind("VCS", 0) == std::string::npos)
	{
	    _sdk_context->onDeletedVideoStream(msid);
	}
}

int ObjectImpl::GetCPULevelImpl()
{
	return _common_interface->GetCPULevel();
}

void ObjectImpl::GetLocalPreviewID(std::string& localVideoId)
{
	_common_interface->GetLocalPreviewID(localVideoId);
}




