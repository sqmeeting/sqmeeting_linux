//
//  AudioUnitSinkChan_macOS.h
//  class AudioUnitSinkChan_macOS.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef AUDIOUNITSINKCHAN_MACOS_H
#define AUDIOUNITSINKCHAN_MACOS_H



#include <QObject>
#include <QThread>
#include <QTimer>
#include <QMutex>

#include <QAudioDevice>
#include <QAudio>
#include <QAudioFormat>

#include <QAudioInput>
//#include <QAudioOutput>

#include <QIODevice>
#include <QCoreApplication>
#include <QEventLoop>

#include <QAudioSink>
#include "IAudioSink.h"



//#define DEFINE_DUMP_AUDIO_SINK_MACOS

#define FRAME_LEN_1920 960 * 2
//#define FRAME_LEN_1920 512 * 2
static unsigned char * buffer[FRAME_LEN_1920] = {0};

class AudioUnitSinkChan_macOS : public QObject, public IAudioSink {
    
    Q_OBJECT
    Q_INTERFACES(IAudioSink)
private:
    static QMutex m_Mutex;
    static AudioUnitSinkChan_macOS *shareInstance;
    AudioUnitSinkChan_macOS(QObject * parent = nullptr);
    virtual ~AudioUnitSinkChan_macOS();

public:
    static AudioUnitSinkChan_macOS* getInstance();
    static void releaseInstance();
    
private:
    QThread *m_thread = nullptr;
    QTimer  *m_timer = nullptr;
    QEventLoop  *eventLoop;
    
signals:
    void complete();

public slots:
    void slotTimeOutHandler(); //for timer.
    void slotStartAudioSink();
    void slotStopAudioSink();

public:
    std::vector<QAudioDevice> m_audioOutputDeviceList;

    QString currentSpeakerName;
    QString selectSpeakerName;

    //QAudioDeviceInfo input_Device; //audio mic
    QAudioDevice output_Device; //audio speaker
    QAudioDevice m_selectAudioOutputDevice; //speaker

    //QAudioOutput *audioOutput;
    QAudioSink   *audioSinkOutput;   //用于播放原始音频
    //QAudioDevice  audioDeviceOutput;

    QIODevice *output_stream;

    QAudioFormat settings;
    
public:
    bool   isReceiving; //flag for audio stream receive.
    
public:
    void setAudioOutput();
    
    //actually start the Thread and the Timer for receive remote audio stream.
    void startTimerThread();
    void stopTimerThread();
    
    void startAudioUnit();
    void stopAudioUnit();
    
public:
    void getAudioData(void * buffer,
                      unsigned int length,
                      unsigned int sample_rate);
    

        


public:
    int refreshOutputDevices();
    void selectSpeaker(QString id);
    QString getCurrentSpeakerName();
    QString getDefaultSpeakerName();

    void restartMainSpeaker();
    bool configMainSrcShan();
    void getSpeakerIDByName(QString name);


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

signals:
    void SpeakerChanged(const QList<QString>& speakerList) override;
    void SelectedSpeakerChanged(const QString& selectedSpeaker) override;

};

#endif // AUDIOUNITSINKCHAN_MACOS_H
