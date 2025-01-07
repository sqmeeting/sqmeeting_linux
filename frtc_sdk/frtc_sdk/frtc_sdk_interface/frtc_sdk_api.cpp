#include "frtc_sdk_api.h"

#include "FrtcCall.h"
#include "frtc_user_api.h"

void frtc_sdk_init(const char* uuid, const char* log_path, PMEETINGMSGCALLBACK meeting_msg_callback)
{
    std::cout << "----------------------------------------" << std::endl;
    std::cout << "The uuid is "<< uuid << "The log_path is " << log_path << std::endl;
    std::cout << "----------------------------------------" << std::endl;
    FrtcCall::sharedCallClient()->init(uuid, log_path);
	FrtcCall::sharedCallClient()->set_frtc_meeting_msg_callback(meeting_msg_callback);
	frtc_user_api::getInstance().set_uuid(uuid);
}

FRTC_SDK_API void frtc_call_join(CALL_PARAM call_param)
{
    printf("\n------%s %s %s %s %s %s------\n",call_param.server_address,
           call_param.meeting_number,
           call_param.display_name,
           call_param.meeting_pwd,
           call_param.user_id,
           call_param.user_token);

    FrtcCall::sharedCallClient()->make_call(call_param.server_address,
                                            call_param.meeting_number,
                                            call_param.display_name,
                                            call_param.meeting_pwd,
                                            call_param.user_id,
                                            call_param.user_token);
}

FRTC_SDK_API void frtc_send_meeting_passowrd(const char* meeting_password)
{
    FrtcCall::sharedCallClient()->sendPasscode(meeting_password);
}

FRTC_SDK_API void frtc_call_leave()
{
	FrtcCall::sharedCallClient()->frtcDropCall();
}

FRTC_SDK_API void frtc_local_audio_mute(bool mute)
{
	FrtcCall::sharedCallClient()->frtcMuteLocalAudio(mute);
}

FRTC_SDK_API void frtc_local_video_start()
{
	FrtcCall::sharedCallClient()->frtcMuteLocalVideo(false);

}
FRTC_SDK_API void frtc_local_video_stop()
{
	FrtcCall::sharedCallClient()->frtcMuteLocalVideo(true);
}

FRTC_SDK_API void frtc_content_start()
{
    FrtcCall::sharedCallClient()->startShareScreen();
}

FRTC_SDK_API void frtc_content_stop()
{
    FrtcCall::sharedCallClient()->stopShareScreen();
}

FRTC_SDK_API void frtc_remote_video_fetch(const char* msid, unsigned int* width, unsigned int* height, unsigned long* data_len, void** video_data)
{
	FrtcCall::sharedCallClient()->frtc_remote_video_fetch(msid, width, height, data_len, video_data);
}

FRTC_SDK_API void frtc_remote_audio_fetch(const char* msid, unsigned int sample_rate, unsigned int data_len, void* audio_data)
{
	FrtcCall::sharedCallClient()->frtc_remote_audio_fetch(msid, audio_data, data_len, sample_rate);
}

FRTC_SDK_API void frtc_video_frame_send(const char* msid, int width, int height, unsigned long data_len, VIDEO_COLOR_FORMAT format, void* video_data, int stride)
{
	FrtcCall::sharedCallClient()->send_video_frame(msid, width, height, data_len, format, video_data);
}

FRTC_SDK_API void frtc_people_audio_frame_send(const char* msid, unsigned long data_len, unsigned long sample_rate, void* audio_data)
{
	FrtcCall::sharedCallClient()->send_audio_frame(audio_data, data_len, sample_rate);
}

FRTC_SDK_API void frtc_content_audio_frame_send(const char* msid, unsigned long data_len, unsigned long sample_rate, void* audio_data)
{
	FrtcCall::sharedCallClient()->send_content_audio_frame(audio_data, data_len, sample_rate);
}

FRTC_SDK_API void frtc_set_layout_mode(bool gridMode)
{
	FrtcCall::sharedCallClient()->frtcSetGridLayoutMode(gridMode);
}

FRTC_SDK_API void frtc_set_camera_stream_mirror(bool video_mirror)
{
    FrtcCall::sharedCallClient()->frtcSetVideoStreamMirror(video_mirror);
}

FRTC_SDK_API void frtc_set_intelligent_noise_reduction(bool enable)
{
    FrtcCall::sharedCallClient()->frtcSetIntelligentNoiseReduction(enable);
}

FRTC_SDK_API const char * frtc_get_statics()
{
    return FrtcCall::sharedCallClient()->frtcGetCallStaticsInfomation();
}

FRTC_SDK_API unsigned long frtc_upload_log(const char *file_meta, const char * file_name, int file_count)
{
	return FrtcCall::sharedCallClient()->StartUploadLogs(file_meta, file_name, file_count);
}

FRTC_SDK_API const char* frtc_log_upload_status_query(unsigned long traction_id)
{
	return FrtcCall::sharedCallClient()->GetUploadStatusImpl(traction_id);
}

FRTC_SDK_API void frtc_cancel_log_upload(unsigned long traction_id)
{
	FrtcCall::sharedCallClient()->CancelLogUpload(traction_id);
}
