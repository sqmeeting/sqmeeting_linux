#ifndef IAUDIOCAPTUREHEADER
#define IAUDIOCAPTUREHEADER

#include <QList>
#include <QString>

class IAudioCapture
{
public:
    virtual void updateMicrophoneNameList() = 0;
    virtual void getMicrophoneNameList(QList<QString>& micList) = 0;
    virtual void getSysDefaultMicName(QString& mic) = 0;
    virtual void getCurrentMicName(QString& mic) = 0;
    virtual void selectMic(const QString& mic) = 0;
    virtual void muteMic(bool mute) = 0;
    virtual bool isMicMuted() = 0;
    virtual void setAudioformat(int samplerate, int channelcount, int samplesize) = 0;
    virtual void startCaptureAndSend() = 0;
    virtual void stopCaptureAndSend() = 0;
    virtual bool isCaptureRunning() = 0;
signals:
    virtual void MicrophoneChanged(const QList<QString>& micList) = 0;
    virtual void SelectedMicChanged(const QString& mic) = 0;

};

Q_DECLARE_INTERFACE(IAudioCapture, "IAudioCapture")

#endif