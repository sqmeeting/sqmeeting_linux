//
//  AudioUnitSinkChan_Windows.h
//  class AudioUnitSinkChan_Windows.
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

//TODO: Qt5 QAudioInput -> Qt6: QAudioSource -yingyong.Mao -2023-10-23
#include <QAudioInput>

//TODO: Qt5 QAudioOutput -> Qt6: QAudioSink -yingyong.Mao -2023-10-23

#include <QAudioOutput>
#include <QIODevice>
#include <QCoreApplication>
#include <QEventLoop>



//#define DEFINE_DUMP_AUDIO_SINK

#define FRAME_LEN_1920 960 * 2
//#define FRAME_LEN_1920 512 * 2
static unsigned char * buffer[FRAME_LEN_1920] = {0};

class AudioUnitSinkChan_Windows : public QObject {
    
    Q_OBJECT
private:
    static QMutex m_Mutex;
    static AudioUnitSinkChan_Windows *shareInstance;
    AudioUnitSinkChan_Windows(QObject * parent = nullptr);
    ~AudioUnitSinkChan_Windows();

public:
    static AudioUnitSinkChan_Windows* getInstance();
    static void releaseInstance();
    
private:
    QThread *m_thread = nullptr;
    QTimer  *m_timer = nullptr;
    QEventLoop  *eventLoop;
//protected:
//    void run() override;

signals:
    void complete();
    
public slots:
    void slotTimeOutHandler(); //for timer.
    void slotStartAudioSink();
    void slotStopAudioSink();
public:
    std::vector<QAudioDeviceInfo> m_audioOutputDeviceList;

    QString currentSpeakerName;
    QString selectSpeakerName;

    //QAudioDeviceInfo input_Device; //audio mic
    QAudioDeviceInfo output_Device; //audio speaker
    QAudioDeviceInfo m_selectAudioOutputDevice; //speaker

    //QAudioInput *audioInput;
    QAudioOutput *audioOutput;

    //QIODevice* input_stream;
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
    /*
     - (void)getAudioData:(void *)buffer
     dataLength:(unsigned int)length
     sampleRate:(unsigned int)sample_rate;
     
     */
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
};

#endif // AUDIOUNITSINKCHAN_H
