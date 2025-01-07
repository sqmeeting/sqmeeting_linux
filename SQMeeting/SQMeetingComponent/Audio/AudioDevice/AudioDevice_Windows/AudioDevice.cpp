#include "AudioDevice.h"
#include <QList>
#include <QDebug>

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <assert.h>

/* support for internationalization - i18n */
#include <locale.h>
#include <libintl.h>

#include <time.h>
#include <sys/time.h>
#include <libintl.h>
#include <math.h>
#include <QTimer>
#include <QAudioDeviceInfo>
#include <QAudioInput>
#include <QProcess>

#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include "DeviceMonitor.h"
#include "SDKDeviceContext.h"

struct card {
    struct card *next;
    char *indexstr;
    char *name;
    char *device_name;
};

struct card first_card;


static pa_context *pa_ctx = NULL;
static u_int32_t latency_ms = 15;
static pa_usec_t latency = 0;
static int sample_index = 0;
static audio_buff_t *audio_buffers = NULL; /*pointer to buffers list*/
static int buffer_read_index = 0; /*current read index of buffer list*/
static int buffer_write_index = 0;/*current write index of buffer list*/

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;



QStringListModel AudioDevice::audioinputDeviceList;
QStringListModel AudioDevice::audiosupportedFmtListModel;
QStringListModel AudioDevice::audioChannelCountModel;
QStringList AudioDevice::cardNum;
QStringList AudioDevice::audioDeviceList;
QStringList AudioDevice::audioOutputDeviceList;
QMap<int, QString> AudioDevice::audioDeviceMap;
QMap<QString, int> AudioDevice::audioDeviceSampleRateMap;
QMap<QString, int> AudioDevice::audioDeviceChannelsMap;
QMap<int, QString> AudioDevice::audioCardMap;
QMap<QString, QString> AudioDevice::m_micMap;
QMap<QString, QString> AudioDevice::m_speakerMap;
//int AudioInfo::source_index;
uint AudioDevice::devIndex;

static pthread_t my_read_thread;
static pa_stream *recordstream = NULL;

bool AudioDevice::is20_04 = false;

AudioDevice::AudioDevice()
{
    audio_buff = NULL;
    audio_context = NULL;

    connect(DeviceMonitor::getInstance(),SIGNAL(pushNotification()),this,SLOT(getAudioDeviceList()));
}

void AudioDevice::setDeviceMonitorCallObject(FrtcCallObserverInterface *sdkObserver)
{
    _sdkObserver = sdkObserver;
}

AudioDevice::~AudioDevice()
{

}

/*
 * clean up and disconnect
 * args:
 *    pa_ctx - pointer to pulse context
 *    pa_ml - pointer to pulse mainloop
 *
 * asserts:
 *    none
 *
 * returns:
 *    none
 */
 void AudioDevice::finish(pa_context *pa_ctx, pa_mainloop *pa_ml)
{
    /* clean up and disconnect */
    pa_context_disconnect(pa_ctx);
    pa_context_unref(pa_ctx);
    pa_mainloop_free(pa_ml);
}

/*
 * This callback gets called when our context changes state.
 *  We really only care about when it's ready or if it has failed
 * args:
 *    c -pointer to pulse context
 *    data - pointer to user data
 *
 * asserts:
 *    none
 *
 * retuns: none
 */
static void pa_state_cb(pa_context *c, void *data)
{
    pa_context_state_t state;
    int *pa_ready = (int *)data;
    state = pa_context_get_state(c);
    switch  (state)
    {
        // These are just here for reference
        case PA_CONTEXT_UNCONNECTED:
        case PA_CONTEXT_CONNECTING:
        case PA_CONTEXT_AUTHORIZING:
        case PA_CONTEXT_SETTING_NAME:
        default:
            break;
        case PA_CONTEXT_FAILED:
        case PA_CONTEXT_TERMINATED:
            *pa_ready = 2;
            break;
        case PA_CONTEXT_READY:
            *pa_ready = 1;
            break;
    }
}

void AudioDevice::getAudioDeviceList()
{
    qDebug("------------------------------------------------------------");
    //sleep(1);
    getAudioDeviceListEvent();
    sleep(1);
    getAudioDeviceListEvent();
}

void AudioDevice::getAudioDeviceListEvent()
{
    audioOutputDeviceList.clear();
    m_speakerMap.clear();

    audioDeviceMap.clear();
    audioDeviceList.clear();

    audio_init_pulseaudio();

    std::vector<QString> tmpMicList;
    QStringList::const_iterator constIterator;

    for (constIterator = audioDeviceList.constBegin(); constIterator != audioDeviceList.constEnd(); ++constIterator)
    {
       //std::cout << (*constIterator).toLocal8Bit().constData() << Qt::endl;
        qDebug() << (*constIterator).toLocal8Bit().constData();
        tmpMicList.push_back(*constIterator);
    }

    if (currentMicList != tmpMicList)
    {
        qDebug() << "\n Not do nothing";
        currentMicList = tmpMicList;
        _sdkObserver->updateMicphoneList(currentMicList);

        if (currentMicList.size() != 0)
        {
            SDKDeviceContext::getInstance()->selectMic(currentMicList[0]);
        }
    }

    std::vector<QString> tmpSpeakerList;
    QStringList::const_iterator constIteratorSpeaker;
    for (constIteratorSpeaker = audioOutputDeviceList.constBegin(); constIteratorSpeaker != audioOutputDeviceList.constEnd(); ++constIteratorSpeaker)
    {
        qDebug() << (*constIteratorSpeaker).toLocal8Bit().constData();
        tmpSpeakerList.push_back(*constIteratorSpeaker);
    }

    if (currentSpeakerList != tmpSpeakerList)
    {
        qDebug() << "\n Not do nothing in current spekaer list";
        currentSpeakerList = tmpSpeakerList;
        _sdkObserver->updateSpeakerList(currentSpeakerList);

        if (currentSpeakerList.size() != 0)
        {
            SDKDeviceContext::getInstance()->selectSpeaker(currentSpeakerList[0]);
        }
    }
}

void AudioDevice::pa_sinklist_cb(pa_context *c, const pa_sink_info *l, int eol, void *userdata)
{
    audio_context_t *audio_ctx = (audio_context_t *) userdata;
    /*
     * If eol is set to a positive number,
     * you're at the end of the list
     */

   // printf("\ntest the pa_sinklist_cb is %d\n", eol);
    if (eol > 0) {
        return;
    }
    sink_index++;

    //if (verbosity > 0)
    {
        printf("AUDIO: =======[ Output Device #%d ]=======\n", sink_index);
        printf("       Description: %s\n", l->description);
        printf("       Name: %s\n", l->name);
        printf("       Index: %d\n", l->index);
        printf("       Channels: %d\n", l->channel_map.channels);
        printf("       SampleRate: %d\n", l->sample_spec.rate);
        printf("       Latency: %llu (usec)\n", (long long unsigned) l->latency);
        printf("       Configured Latency: %llu (usec)\n", (long long unsigned) l->configured_latency);
        printf("       Card: %d\n", l->card);
        printf("       monitor_of_sink: %d\n", l->monitor_source);
        printf("\n");
    }

    if (l->card != -1)
    {
        audioOutputDeviceList.append(l->description);
        m_speakerMap.insertMulti(l->description, l->name);
    }
}


/*
 * pa_mainloop will call this function when it's ready to tell us
 *  about a source (input).
 *  Since we're not threading when listing devices,
 *  there's no need for mutexes on the devicelist structure
 * args:
 *    c - pointer to pulse context
 *    l - pointer to source info
 *    eol - end of list
 *    data - pointer to user data (audio context)
 *
 * asserts:
 *    none
 *
 * returns: none
 */
void AudioDevice::pa_sourcelist_cb(pa_context *c, const pa_source_info *l, int eol, void *data)
{
    //printf("\ntest the pa_sourcelist_cb is %d\n", eol);
//    audioDeviceMap.clear();
//    audioDeviceList.clear();
    audio_context_t *audio_ctx = (audio_context_t *) data;

    int channels = 1;

     /*
     * If eol is set to a positive number,
     * you're at the end of the list
     */
    if (eol > 0) {
        return;
    }
    
    ++source_index;

    if (l->sample_spec.channels <1) {
        channels = 1;
    } else {
        channels = l->sample_spec.channels;
    }
    double my_latency = 0.0;

    printf("AUDIO: =======[ Input Device #%d ]=======\n", source_index);
    printf("       Description: %s\n", l->description);
    printf("       Name: %s\n", l->name);
    printf("       Index: %d\n", l->index);
    printf("       Channels: %d (default to: %d)\n", l->sample_spec.channels, channels);
    printf("       SampleRate: %d\n", l->sample_spec.rate);
    printf("       Latency: %llu (usec)\n", (long long unsigned) l->latency);
    printf("       Configured Latency: %llu (usec)\n", (long long unsigned) l->configured_latency);
    printf("       Card: %d\n", l->card);
    printf("       monitor_of_sink: %d\n", l->monitor_of_sink);

//    const char *value = pa_proplist_gets(l->proplist, "device.string");
//    printf("\nThe pa_proplist_gets_value is %s\n", value);

    printf("\n");

    if (my_latency <= 0.0) {
        my_latency = (double) latency_ms / 1000;
    }
    
    if (l->monitor_of_sink == PA_INVALID_INDEX)
    {
        printf("       Name: %s\n", l->name);
        audio_ctx->num_input_dev++;
        /*add device to list*/
        audio_ctx->list_devices = (audio_device_t *)realloc(audio_ctx->list_devices, audio_ctx->num_input_dev * sizeof(audio_device_t));
        if (audio_ctx->list_devices == NULL)
        {
            fprintf(stderr,"AUDIO: FATAL memory allocation failure (pa_sourcelist_cb): %s\n", strerror(errno));
            exit(-1);
        }

        devIndex++;

        const char *value = pa_proplist_gets(l->proplist, "device.string");
        printf("\nThe pa_proplist_gets_value is %s\n", value);
        cardNum.append(value);

        /*fill device data*/
        audio_ctx->list_devices[audio_ctx->num_input_dev-1].id = l->index; /*saves dev id*/
        strncpy(audio_ctx->list_devices[audio_ctx->num_input_dev-1].name,  l->name, 511);
        strncpy(audio_ctx->list_devices[audio_ctx->num_input_dev-1].description, l->description, 255);
        audio_ctx->list_devices[audio_ctx->num_input_dev-1].channels = channels;
        audio_ctx->list_devices[audio_ctx->num_input_dev-1].samprate = l->sample_spec.rate;
        audio_ctx->list_devices[audio_ctx->num_input_dev-1].low_latency = my_latency; /*in seconds*/
        audio_ctx->list_devices[audio_ctx->num_input_dev-1].high_latency = my_latency; /*in seconds*/
        audioDeviceList.append(audio_ctx->list_devices[audio_ctx->num_input_dev-1].description);
        audioDeviceMap.insertMulti(devIndex, audio_ctx->list_devices[audio_ctx->num_input_dev-1].name);
        audioDeviceSampleRateMap.insertMulti(audio_ctx->list_devices[audio_ctx->num_input_dev-1].name, audio_ctx->list_devices[audio_ctx->num_input_dev-1].samprate);
        audioDeviceChannelsMap.insertMulti(audio_ctx->list_devices[audio_ctx->num_input_dev-1].name, audio_ctx->list_devices[audio_ctx->num_input_dev-1].channels);
        m_micMap.insertMulti(audio_ctx->list_devices[audio_ctx->num_input_dev-1].description, audio_ctx->list_devices[audio_ctx->num_input_dev-1].name);
    }
}


/*
 * iterate the main loop until all devices are listed
 * args:
 *    audio_ctx - pointer to audio context
 *
 * asserts:
 *    audio_ctx is not null
 *
 * returns: error code
 */
int AudioDevice::pa_get_devicelist(audio_context_t *audio_ctx)
{
   // audioDeviceList.append("--Select device--");
    /*assertions*/
    //printf("\ntest1\n");
    assert(audio_ctx != NULL);

    /* Define our pulse audio loop and connection variables */
    pa_mainloop *pa_ml;
    pa_mainloop_api *pa_mlapi;
    pa_operation *pa_op = NULL;
    pa_context *pa_ctx;

    /* We'll need these state variables to keep track of our requests */
    int state = 0;
    int pa_ready = 0;

    if (is20_04)
    {
        process.start("bash", QStringList() << "-c" << "sudo pulseaudio -D");
        process.waitForFinished();
        if (process.exitStatus() <0)
        {
            qDebug() << Q_FUNC_INFO << "process exit status 0";
            qDebug() << "AUDIO: PULSE - unable to connect to server: pa_context_connect failed\n";
            return -1;
        }
    }

    /* Create a mainloop API and connection to the default server */
    pa_ml = pa_mainloop_new();
    pa_mlapi = pa_mainloop_get_api(pa_ml);
    pa_ctx = pa_context_new(pa_mlapi, "getDevices");

    /* This function connects to the pulse server */
    if (pa_context_connect(pa_ctx, NULL, (pa_context_flags_t)0x0000U, NULL) < 0)
    {
        process.start("bash", QStringList() << "-c" << "sudo pulseaudio -D");
        process.waitForFinished();
        if (process.exitStatus() <0)
        {
            fprintf(stderr,"AUDIO: PULSE - unable to connect to server: pa_context_connect failed\n");
            finish(pa_ctx, pa_ml);
            return -1;
        }
        pa_context_connect(pa_ctx, NULL, (pa_context_flags_t)0x0000U, NULL);
    }
    /*
     * This function defines a callback so the server will tell us
     * it's state.
     * Our callback will wait for the state to be ready.
     * The callback will modify the variable to 1 so we know when we
     * have a connection and it's ready.
     * If there's an error, the callback will set pa_ready to 2
     */
    pa_context_set_state_callback(pa_ctx, pa_state_cb, &pa_ready);

    /*
     * Now we'll enter into an infinite loop until we get the data
     * we receive or if there's an error
     */
    for (;;)
    {
        /*
         * We can't do anything until PA is ready,
         * so just iterate the mainloop and continue
         */
       // printf("\nrun loop run loop runloop\n");
        if (pa_ready == 0)
        {
            pa_mainloop_iterate(pa_ml, 1, NULL);
            continue;
        }
        /* We couldn't get a connection to the server, so exit out */
        if (pa_ready == 2)
        {
            finish(pa_ctx, pa_ml);
            return -1;
        }
        /*
         * At this point, we're connected to the server and ready
         * to make requests
         */
        switch (state)
        {
            /* State 0: we haven't done anything yet */
            case 0:
                /*
                 * This sends an operation to the server.
                 * pa_sinklist_cb is our callback function and a pointer
                 * o our devicelist will be passed to the callback
                 * (audio_ctx) The operation ID is stored in the
                 * pa_op variable
                 */
               // printf("\ntest2\n");
                pa_op = pa_context_get_sink_info_list(
                          pa_ctx,
                          pa_sinklist_cb,
                          (void *) audio_ctx);
                // printf("\ntest3\n");
                /* Update state for next iteration through the loop */
                state++;
                break;
            case 1:
                /*
                 * Now we wait for our operation to complete.
                 * When it's complete our pa_output_devicelist is
                 * filled out, and we move along to the next state
                 */
                if (pa_operation_get_state(pa_op) == PA_OPERATION_DONE)
                {
                    pa_operation_unref(pa_op);

                    /*
                     * Now we perform another operation to get the
                     * source(input device) list just like before.
                     * This time we pass a pointer to our input structure
                     */
                    // printf("\ntest4\n");
                    pa_op = pa_context_get_source_info_list(
                              pa_ctx,
                              pa_sourcelist_cb,
                              (void *) audio_ctx);
                    // printf("\ntest5\n");
                    /* Update the state so we know what to do next */
                    state++;
                }
                break;
            case 2:
                if (pa_operation_get_state(pa_op) == PA_OPERATION_DONE)
                {
                    /*
                     * Now we're done,
                     * clean up and disconnect and return
                     */
                    pa_operation_unref(pa_op);
                    finish(pa_ctx, pa_ml);
                    // printf("\ntest6\n");
                    return 0;
                }
                break;
            default:
                /* We should never see this state */
                printf("AUDIO: Pulseaudio in state %d\n", state);
                return -1;
        }
        /*
         * Iterate the main loop and go again.  The second argument is whether
         * or not the iteration should block until something is ready to be
         * done.  Set it to zero for non-blocking.
         */
        pa_mainloop_iterate(pa_ml, 1, NULL);
    }

    return 0;
}

 bool AudioDevice::audio_init()
 {
     cardNum.clear();
     audio_close_pulseaudio();
     audioDeviceList.clear();
     audio_context = audio_init_pulseaudio();
     if (audio_context == NULL) {
         return false;
     }
     audioinputDeviceList.setStringList(audioDeviceList);

//     QStringList cardName;
//     cardName.clear();
//     cardName = cardNum.at(0).split(":");

//        // close mixer
//     alsa.closeMixer();

//        // opne, attach, load mixer
//     alsa.initializeMixer("hw:"+cardName.at(1));
//     qDebug() << "The initializeMixer is " << cardName.at(1);

     setVolume(15);

     return true;
 }


 audio_context_t* AudioDevice::audio_init_pulseaudio()
 {
     audio_context_t *audio_ctx = (audio_context_t *)calloc(1, sizeof(audio_context_t));

     devIndex = 0;

     if (audio_ctx == NULL)
     {
         fprintf(stderr,"AUDIO: FATAL memory allocation failure (audio_init_pulseaudio): %s\n", strerror(errno));
         exit(-1);
     }

     if (pa_get_devicelist(audio_ctx) < 0)
     {
         fprintf(stderr, "AUDIO: Pulseaudio failed to get audio device list from PULSE server\n");
         free(audio_ctx);
         return NULL;
     }
     audio_context = audio_ctx;

     return audio_ctx;
 }

 /*
  * stop and join the main loop iteration thread
  * args:
  *   audio_ctx - pointer to audio context data
  *
  * asserts:
  *   audio_ctx is not null
  *
  * returns: error code
  */
 int AudioDevice::audio_stop_pulseaudio()
 {
     _timer->stop();

     /*assertions*/
     assert(audio_context != NULL);

     audio_context->stream_flag = AUDIO_STRM_OFF;

     printf("AUDIO: (pulseaudio) read thread joined\n");

     return 0;
 }

 /*
  * close and clean audio context for pulseaudio api
  * args:
  *   audio_ctx - pointer to audio context data
  *
  * asserts:
  *   none
  *
  * returns: none
  */
 void AudioDevice::audio_close_pulseaudio()
 {
     if (audio_context == NULL) {
         return;
     }
     if (audio_context->stream_flag == AUDIO_STRM_ON) {
         audio_stop_pulseaudio();
     }

     if (audio_context->list_devices != NULL) {
         free(audio_context->list_devices);
     }
     audio_context->list_devices = NULL;

     if (audio_context->capture_buff) {
         free(audio_context->capture_buff);
     }
     free(audio_context);
 }

 void AudioDevice::getMicList(std::vector<QString> &micList)
 {
     QStringList::const_iterator constIterator;

     for (constIterator = audioDeviceList.constBegin(); constIterator != audioDeviceList.constEnd(); ++constIterator)
     {
        // std::cout << (*constIterator).toLocal8Bit().constData() << Qt::endl;
         micList.push_back(*constIterator);
     }

     currentMicList = micList;
 }

 void AudioDevice::getSpeakerList(std::vector<QString> &speakserList)
 {
     QStringList::const_iterator constIterator;

     for (constIterator = audioOutputDeviceList.constBegin(); constIterator != audioOutputDeviceList.constEnd(); ++constIterator)
     {
         //std::cout << (*constIterator).toLocal8Bit().constData() << Qt::endl;
         qDebug() << "The audio out device list is " << *constIterator;
         speakserList.push_back(*constIterator);
     }

     currentSpeakerList = speakserList;
 }

 QMap<QString, QString> AudioDevice::getMicMap()
 {
     QMap<QString, QString> tempMap = m_micMap;
     tempMap.detach();

     QList<QString> keyList = tempMap.uniqueKeys();
     QList<QString> valueList = tempMap.values();

     return tempMap;
 }

 QMap<QString, QString> AudioDevice::getSpeakerMap()
 {
     QMap<QString, QString> tempMap = m_speakerMap;
     tempMap.detach();

     QList<QString> keyList = tempMap.uniqueKeys();
     QList<QString> valueList = tempMap.values();

     return tempMap;
 }

 void AudioDevice::setVolume(int micVolume)
 {

     // get mute status
     long min, max;
     // Using Alsa, get volume
     qreal volume = alsa.getAlsaVolume(&min, &max); // min - 0 , max 6 -> in see3cam_cu38 camera
     qDebug() << "The Current volume is " << volume;

     if (alsa.setAlsaVolume(micVolume) < 0 )
     {
         // mic volume [ While setting mic volume, In slider (Range: 1-100), In camera (Range 1-7) ]
         qDebug() << "Set volume failure";
         qreal volume = alsa.getAlsaVolume(&min, &max); // min - 0 , max 6 -> in see3cam_cu38 camera
         qDebug() << "The new Current volume is " << volume;

     }
     else
     {

        qDebug() << "Set volume success";
     }
 }
