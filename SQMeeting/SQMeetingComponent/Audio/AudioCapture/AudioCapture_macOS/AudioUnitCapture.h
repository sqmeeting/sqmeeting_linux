
#ifndef AUDIOUNITCAPTURE_H
#define AUDIOUNITCAPTURE_H

#include <QDebug>
#include <QString>
#include <QThread>
#include <QtCore/QMutex>

#include <QAudio>
#include <QAudioFormat>
#include <QAudioSource>
#include <QAudioDevice>
#include <QIODevice>
#include <QMediaDevices>

#include "IAudioCapture.h"

class AudioUnitCapture : public QObject, public IAudioCapture {
    Q_OBJECT
    Q_INTERFACES(IAudioCapture)
private:
    QThread *m_thread = nullptr;
signals:
    void startAudioCapture();
    void stopAudioCapture();

public slots:
    void slotStartAudioCapture();
    void slotStopAudioCapture();
    void onAudioInputsChanged();
    void onAudioOutputsChanged();
    
private:
    static QMutex m_Mutex;
    static AudioUnitCapture *shareInstance;
public:
    static AudioUnitCapture* getInstance();
    static void releaseInstance();

    AudioUnitCapture(QObject *parent = nullptr);
    ~AudioUnitCapture();

    
private:
    QAudioFormat  format;
    QMediaDevices *mediaDevices;   
public:
    QAudioDevice input_Device;
    QAudioDevice output_Device;

    QAudioDevice m_selectAudioInputDevice; //mic
    QAudioDevice m_selectAudioOutputDevice; //speaker

    QAudioSource * audioSource;

    QIODevice* input_stream;
    QIODevice* output_stream;
    
public:
    std::vector<QAudioDevice> m_audioInputDeviceList;
    std::vector<QAudioDevice> m_audioOutputDeviceList;

    QString currentMicName;
    QString selectMicName;
    QString secondMicName;

    QString currentSpeakerName;
    QString selectSpeakerName;

    bool isRunning;

public:
    void startAudioUnitCapture();
    void stopAudioUnitCapture();
    
    void setaudioformat(int samplerate, int channelcount, int samplesize) {};
    
    void captureAudioInputData();
    
public:
    int refreshInputDevices();
    int refreshOutputDevices();
    

    //local mic
    void muteMicrophone(bool isMuted);

    void getMicphoneList();
    void micphoneList(std::vector<QAudioDevice> &micList);

    void selectMicByName(const QString& id);
    void restartMainMic();
    bool configMainSrcShan();
    void getMicIDByName(QString name);

    void speakerList(std::vector<QAudioDevice> &micList);
    
public:
    QString getCurrentMicphoneName();
    QString getCurrentSpeakerName();
    QString getDefaultMicName();
    QString getDefaultSpeakerName();

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
    void SelectedMicChanged(const QString& selectedSpeaker) override;
};

#endif // AUDIOUNITCAPTURE_H
