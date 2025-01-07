#ifndef AUDIODEVICE_H
#define AUDIODEVICE_H

#include <QObject>
#include <QStringListModel>
#include <pulse/pulseaudio.h>
#include <QAudioFormat>
#include <QAudioDevice>
#include <QProcess>
#include <QTimer>
#include <QThread>
#include "alsa.h"

#define pa_memzero(x,l) (memset((x), 0, (l)))
#define pa_zero(x) (pa_memzero(&(x), sizeof(x)))

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000LL
#endif

/*Audio stream flag*/
#define AUDIO_STRM_ON       (1)
#define AUDIO_STRM_OFF      (0)

#define AUDBUFF_NUM     80    /*number of audio buffers*/
#define AUDBUFF_FRAMES  1152  /*number of audio frames per buffer*/

/*Audio Buffer flags*/
#define AUDIO_BUFF_FREE     (0)
#define AUDIO_BUFF_USED     (1)
#define NEXT_IND(ind,size) ind++;if(ind>=size) ind=0

/*audio sample format (definition also in gview_encoder)*/
#ifndef GV_SAMPLE_TYPE_INT16
#define GV_SAMPLE_TYPE_INT16  (0) //interleaved
#define GV_SAMPLE_TYPE_FLOAT  (1) //interleaved
#define GV_SAMPLE_TYPE_INT16P (2) //planar
#define GV_SAMPLE_TYPE_FLOATP (3) //planar
#endif

static void pa_state_cb(pa_context *c, void *data);

typedef float sample_t;
typedef struct _audio_device_t
{
    int id;                 /*audo device id*/
    int channels;           /*max channels*/
    int samprate;           /*default samplerate*/
    double low_latency;     /*default low latency*/
    double high_latency;    /*default high latency*/
    char name[512];         /*device name*/
    char description[256];  /*device description*/
} audio_device_t;

typedef struct _audio_context_t
{
    int api;                      /*audio api for this context*/
    int num_input_dev;            /*number of audio input devices in list*/
    audio_device_t *list_devices; /*audio input devices list*/
    int device;                   /*current device list index*/
    int channels;                 /*channels*/
    int samprate;                 /*sample rate*/
    double latency;               /*current sugested latency*/

    /*all ts are monotonic based: both real and generated*/
    int64_t current_ts;           /*current buffer generated timestamp*/
    int64_t last_ts;              /*last real timestamp (in nanosec)*/
    int64_t snd_begintime;        /*sound capture start ref time*/
    int64_t ts_drift;             /*drift between real and generated ts*/

    sample_t *capture_buff;
    int capture_buff_size;
    float capture_buff_level[2];  /*capture buffer channels level*/

    void *stream;                 /*pointer to audio stream (portaudio)*/

    int stream_flag;             /*stream flag*/
} audio_context_t;

typedef struct _audio_buff_t
{
    void *data; /*sample buffer - usually sample_t (float)*/
    int64_t timestamp;
    int flag;
    float level_meter[2]; /*average sample level*/
}audio_buff_t;

static int source_index;
static int sink_index;

class AudioInput : public QObject
{
    Q_OBJECT

private:
    explicit AudioInput();
    static AudioInput *_instance;
public:
    static AudioInput* getInstance();
   ~AudioInput();
   static QStringListModel audioinputDeviceList;
   static QStringListModel audiosupportedFmtListModel;
   static QStringListModel audioChannelCountModel;
   static QStringList audioDeviceList;
   static QStringList cardNum;
   static QStringList audioOutputDeviceList;
   static QMap<int, QString> audioDeviceMap;
   static QMap<QString, int> audioDeviceSampleRateMap;
   static QMap<QString, int> audioDeviceChannelsMap;
   static QMap<int, QString> audioCardMap;
   static QMap<QString, QString> m_micMap;
   static QMap<QString, QString> m_speakerMap;

   static uint devIndex;

   audio_context_t *audio_context;

   QList <int>sampleRateList;
   QList <int>channelCountList;

   QStringList samplerateStringList;
   QStringList channelCountStringList;

   QList<QAudioDevice> devices;
   uint qtAudioDeviceIndex;

   Alsa alsa;
   static bool is20_04;
   static bool is22_04;

private:
    static void finish(pa_context *pa_ctx, pa_mainloop *pa_ml);

    static void pa_sinklist_cb(pa_context *c, const pa_sink_info *l, int eol, void *userdata);
    static void pa_sourcelist_cb(pa_context *c, const pa_source_info *l, int eol, void *data);
    static void *pulse_read_audio(void *arg);
    static void get_latency(pa_stream *s);
    static int audio_init_buffers(audio_context_t *audio_ctx);
    static int16_t clip_int16 (float in);
    static int audio_free_buffers();
    int pa_get_devicelist(audio_context_t *audio_ctx);
    static void stream_request_cb(pa_stream *s, size_t length, void *data);

    static void audio_fill_buffer(audio_context_t *audio_ctx, int64_t ts, void *arg);

    audio_context_t* audio_init_pulseaudio();

    int getCards(void);

    audio_buff_t *audio_buff;

    QTimer *_timer;
    QThread *_thread;
    QProcess process;

    QList<QString> currentMicList;
    QList<QString> currentSpeakerList;



public slots:
    // Enumerate audio device list
    bool audio_init();
    void setChannelCount(uint index);
    void setSampleRate(int sampleRate);
    int audio_start_pulseaudio();
    int audio_stop_pulseaudio();
    void audio_close_pulseaudio();
    int audio_get_next_buffer(audio_buff_t *buff);
    void audio_delete_buffer(audio_buff_t *audio_buff);
    void recordAudio();

    void getAudioDeviceList();

public:
    void getMicList(QList<QString> &micList);
    void getSpeakerList(QList<QString> &speakserList);
    QMap<QString, QString> getMicMap();
    QMap<QString, QString> getSpeakerMap();
    void updateSupportedInfo(const QString& name);
    void setVolume(int micVolume);
    void getAudioDeviceListEvent();
    void setMicMute(bool mute);
    bool getMicMuteStatus();
};
#endif // AUDIODEVICE_H
