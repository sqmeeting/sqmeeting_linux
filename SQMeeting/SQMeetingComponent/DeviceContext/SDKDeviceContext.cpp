#if defined (WIN32)
#include<windows.h>
#endif


#include "SDKDeviceContext.h"

#include "FMeetingViewController.h"

#include <QDebug>
#include <iostream>

#include "AudioSink.hpp"

//using namespace std;


SDKDeviceContext * SDKDeviceContext::shareInstance = nullptr;

SDKDeviceContext* SDKDeviceContext::getInstance() {
    //qDebug("[%s][%d] Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr == shareInstance) {
        qDebug("[%s][%d] -> call shareInstance = new SDKDeviceContext()", Q_FUNC_INFO, __LINE__);
        shareInstance = new SDKDeviceContext();
    }
    //qDebug("[%s][%d] Exit", Q_FUNC_INFO, __LINE__);
    return shareInstance;
}

void SDKDeviceContext::releaseInstance() {
    qDebug("[%s][%d] Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d] Exit", Q_FUNC_INFO, __LINE__);
}

SDKDeviceContext::SDKDeviceContext()
{

}

//mic capture local audio
void SDKDeviceContext::startAudioUnitCapture()
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->startAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    AudioCapture::getAudioCapture()->startCaptureAndSend();
}

void SDKDeviceContext::stopAudioUnitCapture()
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->stopAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    AudioCapture::getAudioCapture()->stopCaptureAndSend();
}

//receive remote audio and speaker play

void SDKDeviceContext::startAudioSink()
{
    qDebug("[%s][%d] ->[no Thread]: -> call AudioUnitSinkChan_macOS::getInstance()->startTimerThread() ", Q_FUNC_INFO, __LINE__);
    AudioSink::getAudioSink()->start();
}

void SDKDeviceContext::stopAudioSink()
{
    qDebug("[%s][%d] ->[no Thread]: -> call AudioUnitSinkChan_macOS::getInstance()->stopTimerThread() ", Q_FUNC_INFO, __LINE__);
    AudioSink::getAudioSink()->stop();
}


void SDKDeviceContext::selectCamera(QString id)
{
    UnifiedVideoCapture::getInstance()->frtcSwitchCamera(id);
}

void SDKDeviceContext::getCameraList(std::vector<QString> &cameraList)
{
    cameraList.clear();

    std::vector<QCameraDevice> camera_vector;
    UnifiedVideoCapture::getInstance()->getCameraList(camera_vector);

    for (auto it = camera_vector.begin(); it != camera_vector.end(); it++)
    {
        QString qstr = (*it).description();
         cameraList.push_back(qstr);
    }
}

void SDKDeviceContext::muteMicrophone(bool mute) {
    qDebug("[%s][%d]  -> call AudioUnitCapture::getInstance()->muteMicrophone(mute: %s)", Q_FUNC_INFO, __LINE__, mute?"true":"false");
    AudioCapture::getAudioCapture()->muteMic(mute);
}

void SDKDeviceContext::getMicphoneList(QList<QString> &micList)
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->micphoneList(micList)", Q_FUNC_INFO, __LINE__);
    micList.clear();
    AudioCapture::getAudioCapture()->getMicrophoneNameList(micList);
}

void SDKDeviceContext::micphoneList(std::vector<QAudioDevice> &micList)
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->micphoneList(micList)", Q_FUNC_INFO, __LINE__);
    
}

void SDKDeviceContext::selectMic(QString id)
{
    AudioCapture::getAudioCapture()->selectMic(id);
}

void SDKDeviceContext::getSpeakerList(QList<QString> &spkList)
{
    spkList.clear();
    speakerList(spkList);
}

void SDKDeviceContext::speakerList(QList<QString> &spkList)
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->speakerList(spkList)", Q_FUNC_INFO, __LINE__);
    AudioSink::getAudioSink()->getSpeakerNameList(spkList);
}


void SDKDeviceContext::selectSpeaker(QString id)
{
    qDebug("[%s][%d] ->[no Thread]: -> call AudioUnitSinkChan_macOS::getInstance()->startTimerThread() ", Q_FUNC_INFO, __LINE__);
    AudioSink::getAudioSink()->selectAudioSink(id);
}

QString SDKDeviceContext::getCurrentMicphoneName()
{
    QString name;
    AudioCapture::getAudioCapture()->getCurrentMicName(name);
    return name;
}

QString SDKDeviceContext::getCurrentSpeakerName()
{
    QString name;
    AudioSink::getAudioSink()->getCurrentSpeakerName(name);
    return name;
}

QString SDKDeviceContext::getDefaultMicName()
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->getDefaultMicName()", Q_FUNC_INFO, __LINE__);
    QString name;
    AudioCapture::getAudioCapture()->getSysDefaultMicName(name);
    return name;
}

QString SDKDeviceContext::getDefaultSpeakerName()
{
    qDebug("[%s][%d] -> call AudioUnitCapture::getInstance()->getDefaultSpeakerName()", Q_FUNC_INFO, __LINE__);
    QString name;
    AudioSink::getAudioSink()->getSysDefaultSpeakerName(name);
    return name;
}

//- VideoCapture API
void SDKDeviceContext::setVideoSourceId(const std::string& sourceId)
{
    QString qStrSourceID = QString::fromStdString(sourceId);
    qDebug("[%s][%d] -> call -> set VideoCapture::getInstance()->setSourceID(sourceID : %s)", Q_FUNC_INFO, __LINE__, qStrSourceID.toStdString().data());

    UnifiedVideoCapture::getInstance()->setVideoSourceId(sourceId);
}

//- VideoCapture API

void SDKDeviceContext::initVideoCapture() {
    
}

void SDKDeviceContext::startVideoCapture()
{
    UnifiedVideoCapture::getInstance()->re_new_camera();
}

void SDKDeviceContext::stopCapture()
{
    this->stopVideoCapture();
}

void SDKDeviceContext::stopVideoCapture()
{
    qDebug("[%s][%d][DropCall] -> call VideoCapture::getInstance()->stopTimerThread()", Q_FUNC_INFO, __LINE__);
    UnifiedVideoCapture::getInstance()->stopTimerThread();
}


void SDKDeviceContext::startShareScreen() {
    qDebug("[%s][%d][DropCall] -> call FContentCapture::startCaptureScreen", Q_FUNC_INFO, __LINE__);

    //if (nullptr == m_fContentScreenCapture) {
    //    m_fContentScreenCapture = new FContentCapture();
    //}

    //FRTCShareContentType _shareingDeskType = FRTCSDK_SHARE_CONTENT_DESKTOP;
    //m_fContentScreenCapture->setSourceID();
    //m_fContentScreenCapture->startCaptureScreen();
}

void SDKDeviceContext::stopShareScreen() {
    qDebug("[%s][%d][DropCall] -> call FContentCapture::stopCaptureScreen", Q_FUNC_INFO, __LINE__);

}

void SDKDeviceContext::onOpenCameraComplete(int nOpenResulte) {
    qDebug("[%s][%d]: -> call FMeetingViewController::getInstance()->onOpenCameraComplete(nOpenResulte: %d)", Q_FUNC_INFO, __LINE__, nOpenResulte);
    FMeetingViewController::getInstance()->onOpenCameraComplete(nOpenResulte);
}
