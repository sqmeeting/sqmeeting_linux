//
//  AudioUnitCapture_Windows.h
//  class AudioUnitCapture_Windows.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef AUDIOUNITCAPTURE_H
#define AUDIOUNITCAPTURE_H

#include <QDebug>
#include <QString>
#include <QThread>
#include <QtCore/QMutex>

#include <QAudio>
#include <QAudioFormat>
#include <QAudioInput>
#include <QAudioOutput>
#include <QIODevice>


class AudioUnitCapture_Windows : public QObject {
    Q_OBJECT
private:
    QThread *m_thread = nullptr;
signals:
    void startAudioCapture();
    void stopAudioCapture();

public slots:
    void slotStartAudioCapture();
    void slotStopAudioCapture();
    
private:
    static QMutex m_Mutex;
    static AudioUnitCapture_Windows *shareInstance;
public:
    static AudioUnitCapture_Windows* getInstance();
    static void releaseInstance();

    AudioUnitCapture_Windows(QObject *parent = nullptr);
    ~AudioUnitCapture_Windows();

    
private:
    QAudioFormat  format;
   
public:
    QAudioDeviceInfo input_Device;
    QAudioDeviceInfo output_Device;

    QAudioDeviceInfo m_selectAudioInputDevice; //mic
    QAudioDeviceInfo m_selectAudioOutputDevice; //speaker

    QAudioInput *audioInput;
    QAudioOutput *audioOutput;

    QIODevice* input_stream;
    QIODevice* output_stream;
    
public:
    std::vector<QAudioDeviceInfo> m_audioInputDeviceList;
    std::vector<QAudioDeviceInfo> m_audioOutputDeviceList;

    QString currentMicName;
    QString selectMicName;
    QString secondMicName;

    QString currentSpeakerName;
    QString selectSpeakerName;

    bool isRunning;

public:
    //- (OSStatus)deleteAudioUnit;
    void startAudioUnitCapture();
    void stopAudioUnitCapture();
    
    void setaudioformat(int samplerate, int channelcount, int samplesize);
    
    void captureAudioInputData();
    
public:
    int refreshInputDevices();
    int refreshOutputDevices();
    

    //local mic
    void muteMicrophone(bool isMuted);

    void getMicphoneList();
    void micphoneList(std::vector<QAudioDeviceInfo> &micList);

    void selectMic(QString id);
    void restartMainMic();
    bool configMainSrcShan();
    void getMicIDByName(QString name);

    void speakerList(std::vector<QAudioDeviceInfo> &micList);
    
public:
    QString getCurrentMicphoneName();
    QString getCurrentSpeakerName();
    QString getDefaultMicName();
    QString getDefaultSpeakerName();
};

#endif // AUDIOUNITCAPTURE_H
