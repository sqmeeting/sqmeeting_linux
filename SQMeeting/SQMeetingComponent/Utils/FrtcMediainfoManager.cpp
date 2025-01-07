#include "FrtcMediainfoManager.h"
#include "SDKDeviceContext.h"
#include "AudioCapture.hpp"
#include "AudioSink.hpp"
#include "SDKUserDefault.h"

#if defined (WIN32)
#include<windows.h>
#endif

#include "LogHelper.h"


QMutex FrtcMediaInfoManager::m_Mutex;
FrtcMediaInfoManager * FrtcMediaInfoManager::sharedMediaInfoInstance = nullptr;

FrtcMediaInfoManager * FrtcMediaInfoManager::sharedInstance()
{
    if (nullptr == sharedMediaInfoInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        sharedMediaInfoInstance = new FrtcMediaInfoManager();
    }
    return sharedMediaInfoInstance;
}

void FrtcMediaInfoManager::releaseInstance()
{
    if (nullptr != sharedMediaInfoInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete sharedMediaInfoInstance;
        sharedMediaInfoInstance = nullptr;
    }
}

FrtcMediaInfoManager::FrtcMediaInfoManager(QObject *parent) : QObject(parent)
{
    updateDeviceLists();

    connect(&mediaDevices, &QMediaDevices::audioInputsChanged, this, &FrtcMediaInfoManager::onAudioDevicesChanged);
    connect(&mediaDevices, &QMediaDevices::audioOutputsChanged, this, &FrtcMediaInfoManager::onAudioDevicesChanged);
    connect(&mediaDevices, &QMediaDevices::videoInputsChanged, this, &FrtcMediaInfoManager::onVideoDevicesChanged);

    QObject::connect(dynamic_cast<QObject*>(AudioCapture::getAudioCapture()), SIGNAL(MicrophoneChanged(const QList<QString>&)), this, SLOT(onMicChangeResult(const QList<QString>&)));
    QObject::connect(dynamic_cast<QObject*>(AudioCapture::getAudioCapture()), SIGNAL(SelectedMicChanged(const QString&)), this, SLOT(onSelectedMicChanged(const QString&)));

    QObject::connect(dynamic_cast<QObject*>(AudioSink::getAudioSink()), SIGNAL(SpeakerChanged(const QList<QString>&)), this, SLOT(onSpeakerChangeResult(const QList<QString>&)));
    QObject::connect(dynamic_cast<QObject*>(AudioSink::getAudioSink()), SIGNAL(SelectedSpeakerChanged(const QString&)), this, SLOT(onSelectedSpeakerChanged(const QString&)));
}


void FrtcMediaInfoManager::onMicChangeResult(const QList<QString>& micList)
{
    this->_microphoneList.clear(); 
    this->_microphoneList.append(micList);
    this->updateMicphoneList(this->_microphoneList);
}

void FrtcMediaInfoManager::onSelectedMicChanged(const QString& selectedMic)
{
    emit cppSendMsgToQMLSelectedMicChanged(selectedMic);
}

void FrtcMediaInfoManager::onSpeakerChangeResult(const QList<QString>& speakerList)
{
    this->_speakerList.clear(); 
    this->_speakerList.append(speakerList);
    this->updateMicphoneList(this->_speakerList);
}

void FrtcMediaInfoManager::onSelectedSpeakerChanged(const QString& selectedSpeaker)
{
    emit cppSendMsgToQMLSelectedSpeakerChanged(selectedSpeaker);
}

FrtcMediaInfoManager::~FrtcMediaInfoManager() {
    qDebug("[%s][%d]: this: %p", Q_FUNC_INFO, __LINE__, this);
}

void FrtcMediaInfoManager::onVideoDevicesChanged()
{
    updateDeviceLists();

    updateCameraList(_cameraList);
}

void FrtcMediaInfoManager::onAudioDevicesChanged()
{
    DebugLog("onAudioDevicesChanged enter");
    updateDeviceLists();

    updateSpeakerList(_speakerList);
    updateMicphoneList(_microphoneList);
}

void FrtcMediaInfoManager::updateDeviceLists()
{
    DebugLog("updateDeviceLists enter");
    // 更新摄像头列表
    _cameraList.clear();
    const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();

    for (const QCameraDevice &camera : cameras)
    {
        _cameraList.push_back(camera.description());
    }

    QString select_camera = SDKUserDefault::getInstance()->getSelectCamera();

    bool found = false;
    for (const QString &camera : _cameraList)
    {
        if (camera == select_camera)
        {
            found = true;
            break;
        }
    }

    if (!found && !_cameraList.empty())
    {
        // 如果本地存储的摄像头不在新列表中，并且新列表非空
        QString newCamera = _cameraList.front();

        // 更新本地存储为新的摄像头
        SDKUserDefault::getInstance()->onQmlSaveCameraSelected(newCamera);

        // 通知摄像头已更改
        frtcSelectCamera(newCamera);
    }
    else if (found)
    {
        DebugLog("Stored camera is still available, no action needed.");
    }
    else
    {
        DebugLog("No available cameras found.");
    }

    // 更新麦克风列表
    _microphoneList.clear();
    AudioCapture::getAudioCapture()->updateMicrophoneNameList();
    AudioCapture::getAudioCapture()->getMicrophoneNameList(_microphoneList);


    // 更新扬声器列表
    _speakerList.clear();
    AudioSink::getAudioSink()->updateSpeakerNameList();
    AudioSink::getAudioSink()->getSpeakerNameList(_speakerList);
}

QStringList FrtcMediaInfoManager::getCameraList()
{
    qDebug("[%s][%d]: get the camera_list to the ui", Q_FUNC_INFO, __LINE__);
    if(_cameraList.size() == 0)
    {
        qDebug("[%s][%d]: the _camreaList size == 0, so get camera list from SDKDeviceContext", Q_FUNC_INFO, __LINE__);
        SDKDeviceContext::getInstance()->getCameraList(_cameraList);
    }

    QStringList list;
    foreach (const QString &str, _cameraList) {
        list.append(str);
    }
    return list;
}

QStringList FrtcMediaInfoManager::getMicrophoneList()
{
    SDKDeviceContext::getInstance()->getMicphoneList(_microphoneList);
    return _microphoneList;
}

QStringList FrtcMediaInfoManager::getSpeakerList()
{
    SDKDeviceContext::getInstance()->getSpeakerList(_speakerList);
    return _speakerList;
}

QString FrtcMediaInfoManager::getCurrentCamera()
{
    return "321";
}

QString FrtcMediaInfoManager::getCurrentSpeakerName()
{
    //eturn  FMakeCallClient::sharedCallClient()->getCurrentSpeakerName();
    return SDKDeviceContext::getInstance()->getCurrentSpeakerName();
}

QString FrtcMediaInfoManager::getCurrentMicphoneName()
{
    //return  FMakeCallClient::sharedCallClient()->getCurrentMicphoneName();
    return SDKDeviceContext::getInstance()->getCurrentMicphoneName();
}

void FrtcMediaInfoManager::frtcSelectMic(QString id)
{
    SDKDeviceContext::getInstance()->selectMic(id);
}

void FrtcMediaInfoManager::frtcSelectCamera(QString id)
{
    SDKDeviceContext::getInstance()->selectCamera(id);
}

void FrtcMediaInfoManager::stopCamera()
{
    SDKDeviceContext::getInstance()->stopVideoCapture();
}

void FrtcMediaInfoManager::frtcSelectSpeaker(QString id)
{
    SDKDeviceContext::getInstance()->selectSpeaker(id);
}

void FrtcMediaInfoManager::updateCameraList(std::vector<QString> camera_list)
{
    QStringList list;
    for (const QString& str : camera_list) {
        list.append(str);
    }

    emit cppSendMsgToQMLCameraListChanged(list);
}

void FrtcMediaInfoManager::updateSpeakerList(QList<QString> speaker_list)
{
    emit cppSendMsgToQMLSpeakerListChanged(speaker_list);
}

void FrtcMediaInfoManager::updateMicphoneList(QList<QString> micphone_list)
{
    emit cppSendMsgToQMLMicrophoneListChanged(micphone_list);
}

