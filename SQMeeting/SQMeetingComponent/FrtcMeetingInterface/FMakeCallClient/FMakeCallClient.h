#ifndef FMAKECALLCLIENT_H
#define FMAKECALLCLIENT_H

#include <QtCore/QMutex>

#include <QObject>
#include <QStringList>
#include <qvideoframeformat.h>

#include <iostream>

#include "FContentCapture.h"

#if (QT_VERSION >= QT_VERSION_CHECK(6,2,0))
#include <QAudioDevice>
#else
#include <QAudioDeviceInfo>
#endif

#include "frtc_sdk_api.h"

typedef struct {
    std::string app_name;
    std::string conference_number;
    std::string client_name;
    std::string user_token;
    std::string meeting_password;
    std::string call_url;
    std::string user_id;
    int call_rate;
    bool mute_microphone;
    bool mute_camera;
    bool audio_call;
    bool grid_mode;
} FRTCSDKCallParam;

#ifdef WIN32
    #define CALLBACK_CALLING_CONVENTION __stdcall
#else
    #define CALLBACK_CALLING_CONVENTION
#endif


typedef void (CALLBACK_CALLING_CONVENTION *CallBackFunction)(const char*);
class FMakeCallClient
{
    
public:
    static QMutex m_Mutex;
    static FMakeCallClient *sharedFRMakeCallClient;
    
public:
    static FMakeCallClient* sharedCallClient();
    static void releaseInstance();

private:
    FMakeCallClient();
    VIDEO_COLOR_FORMAT get_frtc_video_format(QVideoFrameFormat::PixelFormat qt_video_format);

public:
   // FMakeCallClient();
    void register_sdk(CallBackFunction cb);

    static void CALLBACK_CALLING_CONVENTION StaticCallback(const char *meeting_message)
    {
        if (instance)
        {
            instance->member_function(meeting_message);
        }
        else
        {
            std::cout << "StaticCallback(const char *meeting_message) == null" << std::endl;
        }
    }

    void member_function(const char *meeting_message);

    void make_call(FRTCSDKCallParam call_param,
                   std::function<void()> callSuccessCallBack,
                   std::function<void(int reason)> callFailureCallBack,
                   std::function<void(bool wrongPassword)> inputPasswordCallBack);

    void switch_layout_mode(bool grid_mode);

    void send_password(std::string password);

    void send_video_frame(void * buffer, int length, int width, int height, QVideoFrameFormat::PixelFormat format);

    void send_local_video_frame(void * buffer, QString msid, int length, int width, int height, QVideoFrameFormat::PixelFormat format);

    void send_contetn_frame(void * buffer, QString media_id, int length, int width, int height);

    void receive_video_frame(std::string media_id,void **buffer, unsigned long* length,unsigned int* width,unsigned int* height);

    void send_audio_frame(int data_len, int sample_rate, void* audio_data);

    void receive_audio_frame(void* buffer, unsigned int length, unsigned int sample_rate);

    void start_content();

    void stop_content();

    void mute_camera(bool mute_camera);

    void mute_micphone(bool mute_micphone);

    void drop_call();

    void video_mirror(bool video_mirror);

    void noise_reduction_enable(bool enable);

    QString get_statics_info();

    QString getDeviceManufacturerInfo();
    QString readFileOneLine(const QString & fileName);

#ifdef Q_OS_MAC
    QString parseMacPlist(const QString &xmlContent);
#endif

    void completion_handler(const QString& conference_name,
                      const QString& conference_number,
                      const QString& owner_id,
                      const QString& owner_name,
                      const QString& meeting_url,
                      const long long schedule_start_time,
                      const long long schedule_end_time,
                      bool is_login_call);

    void on_request_video_stream(QString media_id);

    void on_receive_audio_stream(QString media_id);

    void on_request_audio_stream(QString media_id);

    void on_receive_video_stream(QString media_id);

    void on_receive_pin_speaker_id(QString pin_speaker_id);

    void on_svc_layout_changed(void *buffer);

    void on_content_start(bool is_send_content);

    void on_participants_num(int participants_num);

    void on_participants_list(std::vector<std::string> participants_list, bool is_full);

    void on_audio_muted_changed(bool allow_self_unmuted, bool muted);

    void on_un_mute_request_allowed();

    void on_input_password_request();

    void on_call_state_changed(int call_state, int failure_reason);

    void on_water_mask_changed(const QString& live_meeting_url,
                               const QString& live_password,
                               const QString& live_status,
                               const QString& recording_status);

    void on_message_over_lay(const bool enabled,
                             const int vertical_position,
                             const int display_repetition,
                             const QString& display_speed,
                             const QString& message_text);

    void on_layout_setting_changed(const QString& lecture_id, const int max_cell_count);

    void on_un_mute_request( const QString& name,
                             const QString& uuid);

    std::function<void()> callSuccessCallBack;
    std::function<void(int reason)> callFailureCallBack;
    std::function<void(bool wrongPassCode)> inputPasswordCallBack;

    bool is_in_call();

private:
    static FMakeCallClient* instance;
    CallBackFunction callback = nullptr;

    FRTCSDKCallParam param;
    std::string meeting_password;
    int need_password_count;

    bool video_mute;
    bool audio_mute;
    bool sharing_content;
    bool authority;

    int call_state;

    std::vector<std::string> _roster_list;
    std::mutex rosterMutex;

    QString client_name;
    QString video_stream_id;
    QString audio_receive_stream_id;
    QString audio_request_stream_id;
    QString video_receive_stream_id;

    FContentCapture *_contentCapture;
};


#endif // FMAKECALLCLIENT_H
