#ifndef IAUDIOSINKHEADER
#define IAUDIOSINKHEADER

#include <QList>
#include <QString>

class IAudioSink
{
public:
    virtual void updateSpeakerNameList() = 0;
    virtual void getSpeakerNameList(QList<QString>& speakerList) = 0;
    virtual void getSysDefaultSpeakerName(QString& speaker) = 0;
    virtual void getCurrentSpeakerName(QString& speaker) = 0;
    virtual void selectAudioSink(const QString& speaker) = 0;
    virtual void setAudioformat(int samplerate, int channelcount, int samplesize) = 0;
    virtual void start() = 0;
    virtual void stop() = 0;
    virtual bool getAudioOutputData(void * buffer,
                      unsigned int length,
                      unsigned int sample_rate) = 0;
    virtual bool isReceivingAudio() = 0;

Q_SIGNALS:
    virtual void SpeakerChanged(const QList<QString>& speakerList) = 0;
    virtual void SelectedSpeakerChanged(const QString& selectedSpeaker) = 0;
};

Q_DECLARE_INTERFACE(IAudioSink, "IAudioSink")

#endif