//
//  AudioUnitCapture.h
//  class AudioUnitCapture.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef AUDIOUNITCAPTURE_H
#define AUDIOUNITCAPTURE_H

#include <QDebug>
#include <QString>
#include <QMap>
#include <QThread>
#include <QtCore/QMutex>

#include <QAudio>
#include <QAudioFormat>
#include <QAudioInput>
#include <QAudioOutput>
#include <QIODevice>
#include <QAudioSource>
#include <QAudioDevice>
#include <QMediaDevices>

#include <AudioDevice.h>

#include "IAudioCapture.h"


#include <portaudio.h>

class AudioUnitCapture : public QObject, public IAudioCapture{
    Q_OBJECT
    Q_INTERFACES(IAudioCapture)
private:
    QThread *m_thread = nullptr;

private:
    static QMutex m_Mutex;
    static AudioUnitCapture *shareInstance;

    static int recordCallback(const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData );

    static int DummyPaStreamCallback(const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData );

public:
    static AudioUnitCapture* getInstance();
    static void releaseInstance();

    AudioUnitCapture(QObject *parent = nullptr);
    ~AudioUnitCapture();

    
private:
    QMediaDevices *mediaDevices;  
    QMap<QString, int> deviceIndexMap;

    QString selectMicName;
    int selectMicIndex;
    QString defaultMicName;
    int defaultMicIndex;


    int  channelCount;
    QAudioFormat::SampleFormat sampleType;
    int  sampleRate;
    int  framesPerBuffer;
    int  frameSize;


    bool isRunning;
    PaStream*           inputStream;

    QTimer * updateDeviceTimer;

    void onAudioInputsChanged();

    void startAudioUnitCapture();
    void stopAudioUnitCapture();
    void captureAudioInputData();
    void sendAudioDataToRTC(unsigned long length);
    void muteMicrophone(bool isMuted);

    void updateMicList();

private slots:
    void pa_getmiclist();

public:
    //IAudioCapture implements
    void updateMicrophoneNameList();
    void getMicrophoneNameList(QList<QString>& micList);
    void getSysDefaultMicName(QString& mic);
    void getCurrentMicName(QString& mic);
    void selectMic(const QString& mic);
    void muteMic(bool mute);
    bool isMicMuted();
    void setAudioformat(int samplerate, int channelcount, int samplesize);
    void startCaptureAndSend();
    void stopCaptureAndSend();
    bool isCaptureRunning();

signals:
    void MicrophoneChanged(const QList<QString>& micList) override;
    void SelectedMicChanged(const QString& mic) override;
};

#endif // AUDIOUNITCAPTURE_H
