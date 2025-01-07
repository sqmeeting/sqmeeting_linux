#ifndef AUDIODEVICE_H
#define AUDIODEVICE_H

#include <QObject>
#include <QStringListModel>
#include <pulse/pulseaudio.h>
#include <QAudioFormat>
#include <QAudioDeviceInfo>
#include <QProcess>
#include <QTimer>
#include <QThread>
#include "FrtcCall.h"
#include "alsa.h"

static void pa_state_cb(pa_context *c, void *data);

/*Audio stream flag*/
#define AUDIO_STRM_ON       (1)
#define AUDIO_STRM_OFF      (0)

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

class AudioDevice : public QObject
{
    Q_OBJECT

public:
    AudioDevice();
   ~AudioDevice();
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

   QList<QAudioDeviceInfo> devices;
   uint qtAudioDeviceIndex;

   Alsa alsa;
   static bool is20_04;

private:
    static void finish(pa_context *pa_ctx, pa_mainloop *pa_ml);

    static void pa_sinklist_cb(pa_context *c, const pa_sink_info *l, int eol, void *userdata);
    static void pa_sourcelist_cb(pa_context *c, const pa_source_info *l, int eol, void *data);
    int pa_get_devicelist(audio_context_t *audio_ctx);

    int getCards(void);

    audio_buff_t *audio_buff;

    QTimer *_timer;
    QThread *_thread;
    QProcess process;

    std::vector<QString> currentMicList;
    std::vector<QString> currentSpeakerList;

    FrtcCallObserverInterface *_sdkObserver;


    audio_context_t* audio_init_pulseaudio();

public slots:
    // Enumerate audio device list
    bool audio_init();
    int audio_stop_pulseaudio();
    void audio_close_pulseaudio();
    void getAudioDeviceList();

public:
    void getMicList(std::vector<QString> &micList);
    void getSpeakerList(std::vector<QString> &speakserList);
    QMap<QString, QString> getMicMap();
    QMap<QString, QString> getSpeakerMap();
    void setDeviceMonitorCallObject(FrtcCallObserverInterface *sdkObserver);
    void setVolume(int micVolume);
    void getAudioDeviceListEvent();
};
#endif // AUDIODEVICE_H
