#pragma once

#ifdef WIN32
#define FRTC_SDK_API extern "C" __declspec (dllexport)
#define FRTC_SDK_CALLBACK __stdcall
#else
#define FRTC_SDK_API extern "C" __attribute__ ((visibility ("default")))
#define FRTC_SDK_CALLBACK
#endif

typedef enum _VIDEO_COLOR_FORMAT {
	kNoType = 0,
	kARGB = 1,
	kBGRA = 2,
	kABGR = 3,
	kRGBA = 4,
	kYUY2 = 5,
	kUYVY = 6,
	kI420 = 7,
	kYV12 = 8,
	kNV12 = 9,
	kNV21 = 10,
}VIDEO_COLOR_FORMAT;

typedef struct _CALL_PARAM {
    const char* server_address;
    const char* meeting_number;
    const char* display_name;
    const char* meeting_pwd;
    const char* user_id;
    const char* user_token;

} CALL_PARAM;

/*
{"msg_type":"call_state_changed", "call_state" : 1, "reason" : 0}
{"msg_type":"on_meeting_info", ...}
{"msg_type":"content_sending_state_changed", ...}
{"msg_type":"svc_layout_changed", ...}
{"msg_type":"remote_video_stream_received", ...}
{"msg_type":"remote_audio_stream_received", ...}
{"msg_type":"request_video_stream", ...}
{"msg_type":"request_audio_stream", ...}
{"msg_type":"on_participant_list", ...}
{"msg_type":"on_audio_mute_changed", ...}
*/
typedef void (FRTC_SDK_CALLBACK* PMEETINGMSGCALLBACK)(const char* msg);

FRTC_SDK_API void frtc_sdk_init(const char* uuid, const char* log_path, PMEETINGMSGCALLBACK meeting_msg_callback);

FRTC_SDK_API void frtc_call_join(CALL_PARAM call_param);
FRTC_SDK_API void frtc_send_meeting_passowrd(const char* meeting_password);
FRTC_SDK_API void frtc_call_leave();

FRTC_SDK_API void frtc_local_audio_mute(bool mute);
FRTC_SDK_API void frtc_local_video_start();
FRTC_SDK_API void frtc_local_video_stop();
FRTC_SDK_API void frtc_content_start();
FRTC_SDK_API void frtc_content_stop();

FRTC_SDK_API void frtc_remote_video_fetch(const char* msid, unsigned int* width, unsigned int* height, unsigned long* data_len, void** video_data);
FRTC_SDK_API void frtc_remote_audio_fetch(const char* msid, unsigned int sample_rate, unsigned int data_len, void* audio_data);

FRTC_SDK_API void frtc_video_frame_send(const char* msid, int width, int height, unsigned long data_len, VIDEO_COLOR_FORMAT format, void* video_data, int stride = 0);
FRTC_SDK_API void frtc_people_audio_frame_send(const char* msid, unsigned long data_len, unsigned long sample_rate, void* audio_data);
FRTC_SDK_API void frtc_content_audio_frame_send(const char* msid, unsigned long data_len, unsigned long sample_rate, void* audio_data);

FRTC_SDK_API void frtc_set_layout_mode(bool gridMode);

FRTC_SDK_API void frtc_set_camera_stream_mirror(bool video_mirror);

FRTC_SDK_API void frtc_set_intelligent_noise_reduction(bool enable);

FRTC_SDK_API const char * frtc_get_statics();

/*
param: file_meta

{ "version", <SQMeeting App version> },
{ "platform", "uos" },
{ "os", <os version> },
{ "device", <Device manufacturer and model> },
{ "issue",  <Description, input by user> }

return value:
	bigger than 0: upload traction id
	0 or less:	failed
*/
FRTC_SDK_API unsigned long frtc_upload_log(const char *file_meta, const char * file_name, int file_count);
FRTC_SDK_API const char* frtc_log_upload_status_query(unsigned long traction_id);
FRTC_SDK_API void frtc_cancel_log_upload(unsigned long traction_id);
