#ifndef FRTCMEDIAINFOMANAGER_H
#define FRTCMEDIAINFOMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QtCore/QMutex>
#include <QMediaDevices>
#include <QSet>
#include <QDebug>
#include <QAudioDevice>

class FrtcMediaInfoManager : public QObject
{
    Q_OBJECT
public:
    static QMutex m_Mutex;
    static FrtcMediaInfoManager *sharedMediaInfoInstance;

public:
    static FrtcMediaInfoManager* sharedInstance();
    static void releaseInstance();
    explicit FrtcMediaInfoManager(QObject *parent = nullptr);
    ~FrtcMediaInfoManager();

public:

    Q_INVOKABLE QStringList getCameraList();
    Q_INVOKABLE QStringList getMicrophoneList();
    Q_INVOKABLE QStringList getSpeakerList();

    Q_INVOKABLE QString getCurrentCamera();
    Q_INVOKABLE QString getCurrentMicphoneName();
    Q_INVOKABLE QString getCurrentSpeakerName();

    Q_INVOKABLE void frtcSelectCamera(QString id);
    Q_INVOKABLE void frtcSelectMic(QString id);
    Q_INVOKABLE void frtcSelectSpeaker(QString id);
    Q_INVOKABLE void stopCamera();

public:
    void updateMicphoneList(QList<QString> micphone_list);
    void updateSpeakerList(QList<QString> speaker_list);
    void updateCameraList(std::vector<QString> camera_list);
    void updateDeviceLists();
signals:
    void cppSendMsgToQMLCameraListChanged(QStringList cameraList);
    void cppSendMsgToQMLMicrophoneListChanged(QStringList micphoneList);
    void cppSendMsgToQMLSpeakerListChanged(QStringList speakerList);

    void cppSendMsgToQMLSelectedMicChanged(const QString& selectedMic);
    void cppSendMsgToQMLSelectedSpeakerChanged(const QString& selectedSpeakere);

private slots:
    void onVideoDevicesChanged();
    void onAudioDevicesChanged();

    void onMicChangeResult(const QList<QString>& micList);
    void onSelectedMicChanged(const QString& selectedMic);

    void onSpeakerChangeResult(const QList<QString>& speakerList);
    void onSelectedSpeakerChanged(const QString& selectedSpeaker);
private:
    QList<QString> _microphoneList;
    QList<QString> _speakerList;
    std::vector<QString> _cameraList;


    QMediaDevices mediaDevices;

    QSet<QString> getDeviceList() {
        QSet<QString> deviceList;
        QList<QAudioDevice> devices = QMediaDevices::audioInputs();
        for (const QAudioDevice &device : devices) {
            deviceList.insert(device.description());
        }
        return deviceList;
    }

    void updateDeviceList() {
        currentDevices = getDeviceList();
    }

    QSet<QString> currentDevices;
};

#endif // FRTCMEDIAINFOMANAGER_H
