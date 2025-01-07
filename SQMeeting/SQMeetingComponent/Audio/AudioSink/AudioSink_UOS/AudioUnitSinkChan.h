//
//  AudioUnitSinkChan.h
//  class AudioUnitSinkChan.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef AUDIOUNITSINKCHAN_H
#define AUDIOUNITSINKCHAN_H

#include <QObject>
#include <QThread>
#include <QTimer>
#include <QMutex>

#include <QAudio>
#include <QAudioFormat>
#include <QAudioInput>
#include <QAudioOutput>
#include <QIODevice>
#include <QCoreApplication>
#include <QEventLoop>

#include "IAudioSink.h"

#include <portaudio.h>

#define FRAME_LEN_1920 960 * 2
#define SAMPLE_SILENCE  (0.0f)

class AudioUnitSinkChan : public QObject, public IAudioSink {
    
    Q_OBJECT
    Q_INTERFACES(IAudioSink)
private:
    static QMutex m_Mutex;
    static AudioUnitSinkChan *shareInstance;
    AudioUnitSinkChan(QObject * parent = nullptr);
    ~AudioUnitSinkChan();

public:
    static AudioUnitSinkChan* getInstance();
    static void releaseInstance();

private:
    static int playCallback( const void *inputBuffer, void *outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData );

    static int DummyPaStreamCallback(const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData );

private:
    QMap<QString, int> deviceIndexMap;


    int     defaultSpeakerIndex;
    QString defaultSpeakerName;
    int     selectSpeakerIndex;
    QString selectSpeakerName;


    int  channelCount;
    QAudioFormat::SampleFormat sampleType;
    int  sampleRate;
    int  framesPerBuffer;
    int  frameSize;

    bool   isReceiving; //flag for audio stream receive.
    unsigned char *receive_buffer;
    PaStream *output_stream;

    QTimer * updateDeviceTimer;

private:
    void updateSpeakerList();

private slots:
    void pa_getspeakerlist();


public:
    int getSpeakerIDByName(QString name);

    //IAudioSink implements
    void updateSpeakerNameList();
    void getSpeakerNameList(QList<QString>& speakerList);
    void getSysDefaultSpeakerName(QString& speaker);
    void getCurrentSpeakerName(QString& speaker);
    void selectAudioSink(const QString& speaker);
    void setAudioformat(int samplerate, int channelcount, int samplesize);
    void start();
    void stop();
    bool getAudioOutputData(void * buffer,
                      unsigned int length,
                      unsigned int sample_rate);
    bool isReceivingAudio();

Q_SIGNALS:
    void SpeakerChanged(const QList<QString>& speakerList) override;
    void SelectedSpeakerChanged(const QString& selectedSpeaker) override;
};

#endif // AUDIOUNITSINKCHAN_H
