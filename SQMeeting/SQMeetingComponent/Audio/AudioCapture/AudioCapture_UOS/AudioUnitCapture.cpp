//
//  AudioUnitCapture.cpp
//  class AudioUnitCapture.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#include "AudioUnitCapture.h"

#include <QDateTime>
#include <iostream>

#include "FMakeCallClient.h"

#include "LogHelper.h"


QMap<QString, int> capture_device_name_filter{ {"lavrate",0}, {"samplerate", 1}, {"speexrate", 2}, {"upmix", 3}, {"vdownmix", 4}, {"dmix",5} };


QMutex AudioUnitCapture::m_Mutex;
AudioUnitCapture * AudioUnitCapture::shareInstance = nullptr;

AudioUnitCapture* AudioUnitCapture::getInstance()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr == shareInstance)
    {
        DebugLog("[AudioUnitCapture::%s][%d] shareInstance = new AudioUnitCapture()", Q_FUNC_INFO, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitCapture();
        DebugLog("[%s][%d]: set isRunning = false", Q_FUNC_INFO, __LINE__);
        shareInstance->isRunning = false;
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
    return shareInstance;
}

void AudioUnitCapture::releaseInstance()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        
        delete shareInstance;
        shareInstance = nullptr;
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

AudioUnitCapture::AudioUnitCapture(QObject *parent) : QObject(parent),
    sampleRate(48000),
    channelCount(1),
    sampleType(QAudioFormat::SampleFormat::Int16),
    frameSize(sizeof(int16_t)),
    framesPerBuffer(1920),
    updateDeviceTimer(nullptr)
{
    DebugLog("[%s][%d]", Q_FUNC_INFO, __LINE__);

    selectMicName = "";
    isRunning = false;

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
}

AudioUnitCapture::~AudioUnitCapture()
{
    DebugLog("[%s][%d]", Q_FUNC_INFO, __LINE__);
    if(isRunning)
        stopAudioUnitCapture();
    Pa_Terminate();
}

void AudioUnitCapture::startAudioUnitCapture()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if(isRunning)
        return;

    if(selectMicIndex < 0 || selectMicName == "")
    {
        selectMicIndex = Pa_GetDefaultInputDevice();
        selectMicName = defaultMicName;
        emit SelectedMicChanged(selectMicName);
        DebugLog("no selected device, use default %s, %d", qPrintable(defaultMicName), selectMicIndex);
    }
    else
    {
        DebugLog("Will start audio sink device %s, %d", qPrintable(selectMicName), selectMicIndex);
    }

    PaStreamParameters  inputParameters;
    PaError             err = paNoError;
    int                 i;
    int                 totalFrames;
    int                 numSamples;
    int                 numBytes;
    float               max, val;
    double              average;

    if(isRunning)   goto done;

    inputParameters.device = selectMicIndex;
    if (inputParameters.device == paNoDevice) {
        DebugLog("Error: No selected input device");
        goto done;
    }
    inputParameters.channelCount = this->channelCount;
    inputParameters.sampleFormat = paInt16;
    inputParameters.suggestedLatency = Pa_GetDeviceInfo( inputParameters.device )->defaultLowInputLatency;
    inputParameters.hostApiSpecificStreamInfo = NULL;


    DebugLog("[%s][%d]: Try open stream", Q_FUNC_INFO, __LINE__);

    /* Record some audio. -------------------------------------------- */
    err = Pa_OpenStream(
              &inputStream,
              &inputParameters,
              NULL,                  /* &outputParameters, */
              this->sampleRate,
              this->framesPerBuffer,
              paClipOff,      /* we won't output out of range samples so don't bother clipping them */
              recordCallback,
              this);


    if( err == paNoError )
    {
        DebugLog("[%s][%d]: Try start stream", Q_FUNC_INFO, __LINE__);
        err = Pa_StartStream( inputStream );
        if( err == paNoError )
            isRunning = true;
        else
        {
            ErrorLog("Start audio capture stream failed %d", err);
            isRunning = false;
        }
    }
    else
    {
        ErrorLog("Open stream failed %d", err);
        isRunning = false;
    }

done:
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
    return;    
}

bool recordCallbackCalled = false;
unsigned long noDataCnt = 0;

void AudioUnitCapture::stopAudioUnitCapture()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if(isRunning && inputStream)
    {
        DebugLog("will stop stream");
        Pa_StopStream(inputStream);
        Pa_CloseStream(inputStream);
        inputStream = NULL;
        isRunning = false;
        recordCallbackCalled = false;
        noDataCnt = 0;
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}


//only 48k
#define FRAME_LEN_1920 (960 * 2)
static unsigned char buffer[FRAME_LEN_1920*16] = {0};
#define SAMPLE_SILENCE  (0.0f)


int AudioUnitCapture::recordCallback( const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData )
{
    if(!recordCallbackCalled)
    {
        recordCallbackCalled = true;
        DebugLog("Got first audio capture data");
    }
    const unsigned char *rptr = (const unsigned char*)inputBuffer;
    //unsigned char *wptr = buffer;
    AudioUnitCapture* self = static_cast<AudioUnitCapture *>(userData);

    if(inputBuffer == nullptr)
    {
        noDataCnt++;
        memset(buffer, SAMPLE_SILENCE, FRAME_LEN_1920*16);
        if(noDataCnt == 1)
        {
            DebugLog("Audio capture empty data");
        }
    }
    else
    {
        if(noDataCnt > 0)
        {
            noDataCnt = 0;
            DebugLog("Audio capture has data");
        }
        memcpy(buffer, rptr, framesPerBuffer * self->frameSize);
    }


    //dump pcm
    // char pFName[256] = {0};
    // char* sHome = NULL;
    // sHome = getenv("HOME");
    // if (sHome)
    // {
    //     sprintf(pFName,"%s/Documents/%s",sHome, "capture");
    // }

    // char destPath[200] = { 0 };
    // sprintf(destPath,"%s.pcm", pFName );

    // FILE *pSentPCM= fopen(destPath,"a+b");
    // if (pSentPCM)
    // {
    //     fwrite((short *)buffer, self->frameSize, framesPerBuffer, pSentPCM);
    //     fclose(pSentPCM);
    // }

    self->sendAudioDataToRTC(framesPerBuffer * self->frameSize);

    return 0;
}

void AudioUnitCapture::sendAudioDataToRTC(unsigned long length)
{
    FMakeCallClient::sharedCallClient()->send_audio_frame(length, this->sampleRate, buffer);
}

int AudioUnitCapture::DummyPaStreamCallback(const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData ){return 0;}


void AudioUnitCapture::updateMicList()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if(updateDeviceTimer != nullptr)
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
    QObject::connect(this->updateDeviceTimer, &QTimer::timeout, this, &AudioUnitCapture::pa_getmiclist, Qt::ConnectionType::AutoConnection);
    updateDeviceTimer->start();
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture::pa_getmiclist()
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    deviceIndexMap.clear();
    int     i, numDevices;
    const   PaDeviceInfo *deviceInfo;
    PaError err = PaErrorCode::paNoError;

    if(isRunning && inputStream)
    {
        DebugLog("stop current running mic");
        stopAudioUnitCapture();
        isRunning = true;//set to ture to restart mic after
    }
    
    numDevices = Pa_GetDeviceCount();
    if( numDevices < 0 )
    {
        ErrorLog("[%s][%d] ERROR: Pa_GetDeviceCount returned 0x%x\n", Q_FUNC_INFO, __LINE__, numDevices );
        err = numDevices;
        goto error;
    }

    DebugLog( "Number of devices = %d\n", numDevices );
    for( i=0; i<numDevices; i++ )
    {
        deviceInfo = Pa_GetDeviceInfo( i );
        DebugLog( "--------------------------------------- device #%d\n", i );

        /* Mark global and API specific default devices */
        if( i == Pa_GetDefaultInputDevice() )
        {
            DebugLog( "Default Input  %s, %d", deviceInfo->name, i);
            defaultMicName = QString::fromLocal8Bit(deviceInfo->name);
            defaultMicIndex = i;
        }

        if(deviceInfo->maxInputChannels > 0)
        {
            if(capture_device_name_filter.contains(deviceInfo->name))
            {
                continue;
            }
        //     PaStreamParameters parameters;
        //     parameters.device = i;
        //     parameters.suggestedLatency = deviceInfo->defaultLowInputLatency;
        //     parameters.sampleFormat = paInt16;
        //     parameters.channelCount = deviceInfo->maxInputChannels;
        //     parameters.hostApiSpecificStreamInfo = NULL;

        //     PaStream *stream = NULL;
        //     PaError paErr = Pa_OpenStream(&stream,
        //                         &parameters,
        //                         NULL,
        //                         deviceInfo->defaultSampleRate, paFramesPerBufferUnspecified,
        //                         paClipOff | paDitherOff,
        //                         DummyPaStreamCallback, NULL);
        //     if (stream && paErr==paNoError)
        //     {
        //         Pa_CloseStream(stream);
        DebugLog("enum mic device %s, %d", deviceInfo->name, i);
                deviceIndexMap.insert(QString::fromLocal8Bit(deviceInfo->name), i);
            // }
            // else
            // {
            //     DebugLog( "--------------------------------------- device stream err #%d\n", paErr);
            // }
        }
    }

    if(isRunning)
    {
        DebugLog("restart running mic");
        if(deviceIndexMap.contains(selectMicName))
        {
            DebugLog("find last running mic name is %s", qPrintable(selectMicName));
            selectMicIndex = deviceIndexMap[selectMicName];
        }
        else
        {

            DebugLog("not find last running mic name, will use default device %s, %d", qPrintable(defaultMicName), defaultMicIndex);
            selectMicIndex = -1;
        }
        isRunning = false;
        startAudioUnitCapture();
    }

    emit MicrophoneChanged(deviceIndexMap.keys());

    error:
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
        return;
}

void AudioUnitCapture::updateMicrophoneNameList()
{
    updateMicList();
}


//IAudioCapture implements
void AudioUnitCapture::getMicrophoneNameList(QList<QString>& micList)
{
    micList = deviceIndexMap.keys();
}

void AudioUnitCapture::getSysDefaultMicName(QString& mic)
{
    mic = defaultMicName;
}

void AudioUnitCapture::getCurrentMicName(QString& mic)
{
    mic = selectMicName == "" ? defaultMicName : selectMicName;
}

void AudioUnitCapture::selectMic(const QString& mic)
{
    DebugLog("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    DebugLog("select mic name %s", qPrintable(mic));
    if(mic != selectMicName)
    {
        selectMicName = mic;
        selectMicIndex = deviceIndexMap[mic];
        DebugLog("select new mic %s, %d", qPrintable(mic), selectMicIndex);
        if(isCaptureRunning())
        {
            stopAudioUnitCapture();
        }
        if(FMakeCallClient::sharedCallClient()->is_in_call())
        {
            startAudioUnitCapture();
        }
    }
    DebugLog("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture::muteMic(bool mute)
{
    mute ? stopAudioUnitCapture() : startAudioUnitCapture();
}

bool AudioUnitCapture::isMicMuted()
{
    return !isRunning;
}

void AudioUnitCapture::setAudioformat(int samplerate, int channelcount, int samplesize)
{
    DebugLog("[%s][%d] set sample rate: %d, channel count: %d, sample size: %d\n", Q_FUNC_INFO, __LINE__, samplerate, channelcount, samplesize);
    this->channelCount = channelcount;
    this->sampleRate = samplerate;
    //this->framesPerBuffer = samplesize;
}

void AudioUnitCapture::startCaptureAndSend()
{
    startAudioUnitCapture();
}

void AudioUnitCapture::stopCaptureAndSend()
{
    stopAudioUnitCapture();
}

bool AudioUnitCapture::isCaptureRunning()
{
    return isRunning;
}
