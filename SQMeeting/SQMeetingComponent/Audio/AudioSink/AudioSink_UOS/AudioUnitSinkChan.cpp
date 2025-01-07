//
//  AudioUnitSinkChan.cpp
//  class AudioUnitSinkChan.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#include "AudioUnitSinkChan.h"

#include <QString>
#include <QDateTime>
#include <iostream>

#include "FMakeCallClient.h"

#include "LogHelper.h"

QMap<QString, int> sink_device_name_filter{ {"lavrate",0}, {"samplerate", 1}, {"speexrate", 2}, {"upmix", 3}, {"vdownmix", 4}, {"dmix",5} };    

QMutex AudioUnitSinkChan::m_Mutex;
AudioUnitSinkChan * AudioUnitSinkChan::shareInstance = nullptr;

AudioUnitSinkChan* AudioUnitSinkChan::getInstance()
{
    if (nullptr == shareInstance) {
        DebugLog("[%s][%d]: shareInstance = new AudioUnitSinkChan()", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitSinkChan();
        shareInstance->isReceiving = false;
    }
    return shareInstance;
}

void AudioUnitSinkChan::releaseInstance()
{
    DebugLog("[%s][%d]: delete shareInstance", __PRETTY_FUNCTION__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

AudioUnitSinkChan::~AudioUnitSinkChan() {

    if(receive_buffer)
        delete[] receive_buffer;
}

int AudioUnitSinkChan::DummyPaStreamCallback(const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData ){return 0;}


bool firstAudioSinkData = false;
int AudioUnitSinkChan::playCallback(const void *inputBuffer, void *outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData )
{

    if(!firstAudioSinkData)
    {
        firstAudioSinkData = true;
        DebugLog("Got first audio sink data");
    }

    AudioUnitSinkChan *self = static_cast<AudioUnitSinkChan *>(userData);
    unsigned long size_ = framesPerBuffer * self->frameSize;

    memset(self->receive_buffer,0,size_);
    self->getAudioOutputData(self->receive_buffer, size_, self->sampleRate);

    unsigned char *rptr = self->receive_buffer;
    unsigned char *wptr = static_cast<unsigned char *>(outputBuffer);

    for(int i=0;i<size_;++i)
    {
        *wptr++ = *rptr++;
    }

    return 0;
}

AudioUnitSinkChan::AudioUnitSinkChan(QObject *parent)
                  :QObject(parent),
                   output_stream(nullptr),
                   isReceiving(false),
                   sampleRate(48000),
                   channelCount(1),
                   sampleType(QAudioFormat::SampleFormat::Int16),
                   frameSize(sizeof(int16_t)),
                   framesPerBuffer(960),
                   receive_buffer(nullptr),
                   updateDeviceTimer(nullptr)
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    PaError err = Pa_Initialize();
    if(err != PaErrorCode::paNoError)
    {
        DebugLog("[%s][%d] PortAudio init failed %d", Q_FUNC_INFO, __LINE__, err);
    }
    else
    {
        DebugLog( "[%s][%d] PortAudio version: 0x%08X\n", Q_FUNC_INFO, __LINE__, Pa_GetVersion());
        DebugLog( "[%s][%d] Version text: '%s'\n", Q_FUNC_INFO, __LINE__, Pa_GetVersionInfo()->versionText );
    }

    receive_buffer = new unsigned char[1920];
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

int AudioUnitSinkChan::getSpeakerIDByName(QString name) 
{
    return deviceIndexMap[name];
}

void AudioUnitSinkChan::updateSpeakerList()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if(updateDeviceTimer!=nullptr)
    {
        if(updateDeviceTimer->isActive())
        {
            updateDeviceTimer->disconnect();
            updateDeviceTimer->stop();
        }
        updateDeviceTimer->deleteLater();
        updateDeviceTimer = nullptr;
    }
    updateDeviceTimer = new QTimer(this);
    updateDeviceTimer->setInterval(2000);
    updateDeviceTimer->setSingleShot(true);
    QObject::connect(this->updateDeviceTimer, &QTimer::timeout, this, &AudioUnitSinkChan::pa_getspeakerlist, Qt::ConnectionType::AutoConnection);
    updateDeviceTimer->start();
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitSinkChan::pa_getspeakerlist()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    deviceIndexMap.clear();

    int     i, numDevices;
    const   PaDeviceInfo *deviceInfo;
    PaError err = PaErrorCode::paNoError;

    if(isReceiving && output_stream)
    {
        DebugLog("stop current running speaker");
        stop();
        isReceiving = true; // set to true to restart speaker later
    }    

    numDevices = Pa_GetDeviceCount();
    if( numDevices < 0 )
    {
        DebugLog("[%s][%d] ERROR: Pa_GetDeviceCount returned 0x%x\n", Q_FUNC_INFO, __LINE__, numDevices );
        err = numDevices;
        goto error;
    }

    DebugLog( "Number of devices = %d\n", numDevices );
    for( i=0; i<numDevices; i++ )
    {
        deviceInfo = Pa_GetDeviceInfo( i );
        DebugLog( "--------------------------------------- device #%d\n", i );

        /* Mark global and API specific default devices */
        if( i == Pa_GetDefaultOutputDevice() )
        {
            defaultSpeakerName = deviceInfo->name;
            defaultSpeakerIndex = i;
            DebugLog( "Default speaker %s, %d", deviceInfo->name, i);
        }

        if(deviceInfo->maxOutputChannels > 0)
        {
            if(sink_device_name_filter.contains(deviceInfo->name))
            {
                continue;
            }
            
            if(std::string(deviceInfo->name).find("surround") == 0)
            {
                continue;
            }

            if(strcmp(deviceInfo->name, "front") == 0)
            {
                continue;
            }


            // PaStreamParameters parameters;
            // parameters.device = i;
            // parameters.suggestedLatency = deviceInfo->defaultLowInputLatency;
            // parameters.sampleFormat = paInt16;
            // parameters.channelCount = deviceInfo->maxInputChannels;
            // parameters.hostApiSpecificStreamInfo = NULL;

            // PaStream *stream = NULL;
            // PaError paErr = Pa_OpenStream(&stream,
            //                     NULL,
            //                     &parameters,
            //                     deviceInfo->defaultSampleRate, paFramesPerBufferUnspecified,
            //                     paClipOff | paDitherOff,
            //                     DummyPaStreamCallback, NULL);
            // if (stream && paErr==paNoError)
            // {
            //     Pa_CloseStream(stream);
            DebugLog("enum speaker device %s, %d", deviceInfo->name, i);
                deviceIndexMap.insert(deviceInfo->name, i);
            // }
            // else
            // {
            //     DebugLog( "--------------------------------------- device stream err #%d\n", paErr);
            // }
        }
    }

    if(isReceiving)
    {
        DebugLog("restart running speaker");
        if(deviceIndexMap.contains(selectSpeakerName))
        {
            selectSpeakerIndex = deviceIndexMap[selectSpeakerName];
            DebugLog("find last running speaker name is %s, index is %d", qPrintable(selectSpeakerName), selectSpeakerIndex);
        }
        else
        {
            selectSpeakerIndex = -1;
            DebugLog("not find last running speaker, will use default speaker device %s, %d", qPrintable(defaultSpeakerName), defaultSpeakerIndex);
        }
        isReceiving = false;
        start();
    }

    emit SpeakerChanged(deviceIndexMap.keys());

error:
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
    return;
    
}


//IAudioSink implements
void AudioUnitSinkChan::updateSpeakerNameList()
{
    updateSpeakerList();
}

void AudioUnitSinkChan::getSpeakerNameList(QList<QString>& speakerList)
{
    speakerList = deviceIndexMap.keys();
}

void AudioUnitSinkChan::getSysDefaultSpeakerName(QString& speaker)
{
    speaker = defaultSpeakerName;
}

void AudioUnitSinkChan::getCurrentSpeakerName(QString& speaker)
{
    speaker = selectSpeakerName == "" ? defaultSpeakerName : selectSpeakerName;
}

void AudioUnitSinkChan::selectAudioSink(const QString& speaker)
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if(selectSpeakerName != speaker)
    {
        selectSpeakerName = speaker;
        selectSpeakerIndex = deviceIndexMap[speaker];
        DebugLog("Select audio sink %s, %d", qPrintable(selectSpeakerName), selectSpeakerIndex);
        if(isReceivingAudio())
        {
            DebugLog("stop running speaker");
            stop();
        }
        if(FMakeCallClient::sharedCallClient()->is_in_call())
        {
            start();
        }
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitSinkChan::setAudioformat(int samplerate, int channelcount, int samplesize)
{
    sampleRate = samplerate;
    channelCount = channelcount;
    frameSize = samplesize;
}

void AudioUnitSinkChan::start()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if(isReceiving)
        return;

    if(selectSpeakerIndex < 0 || selectSpeakerName == "")
    {
        selectSpeakerIndex = Pa_GetDefaultOutputDevice();
        selectSpeakerName = defaultSpeakerName;
        emit SelectedSpeakerChanged(selectSpeakerName);
        DebugLog("no selected device, use default %s, %d", qPrintable(selectSpeakerName), selectSpeakerIndex);
    }
    else
    {
        DebugLog("Will start audio sink device %s, %d", qPrintable(selectSpeakerName), selectSpeakerIndex);
    }

    PaStreamParameters  outputParameters;
    PaError             err = paNoError;
    int                 i;
    int                 totalFrames;
    int                 numSamples;
    int                 numBytes;
    float               max, val;
    double              average;

    if(isReceiving)   goto done;

    outputParameters.device = selectSpeakerIndex;
    if (outputParameters.device == paNoDevice) {
        DebugLog("Error: No selected input device.\n");
        goto done;
    }
    outputParameters.channelCount = this->channelCount;
    outputParameters.sampleFormat = paInt16;
    outputParameters.suggestedLatency = Pa_GetDeviceInfo( outputParameters.device )->defaultLowInputLatency;
    outputParameters.hostApiSpecificStreamInfo = NULL;


    DebugLog("[%s][%d]: Try open stream", Q_FUNC_INFO, __LINE__);

    /* Record some audio. -------------------------------------------- */
    err = Pa_OpenStream(
              &output_stream,           
              NULL,  
              &outputParameters,                /* &outputParameters, */
              this->sampleRate,
              this->framesPerBuffer,
              paClipOff,
              playCallback,
              this);


    if( err == paNoError && output_stream)
    {
        DebugLog("[%s][%d]: Try start stream", Q_FUNC_INFO, __LINE__);
        //checkAudioSinkBuffer();
        err = Pa_StartStream(output_stream);
        if( err == paNoError )
            isReceiving = true;
        else
        {
            ErrorLog("Audio sink start stream failed %d", err);
        }
    }
    else
    {
        ErrorLog("[%s][%d]: Open stream failed, err: %d, output_stream is %s", Q_FUNC_INFO, __LINE__, err, output_stream ? "not null" : "null");
    }

done:
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
    return;
    
}

void AudioUnitSinkChan::stop()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if(isReceiving && output_stream)
    {
        Pa_StopStream(output_stream);
        Pa_CloseStream(output_stream);
        output_stream = nullptr;
        this->isReceiving = false;
        firstAudioSinkData = false;
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

bool AudioUnitSinkChan::isReceivingAudio()
{
    return isReceiving;
}

bool AudioUnitSinkChan::getAudioOutputData(void * buffer,
                      unsigned int length,
                      unsigned int sample_rate)
{
    FMakeCallClient::sharedCallClient()->receive_audio_frame(buffer, length, sample_rate);
    return true;
}
