//
//  AudioUnitSinkChan_Windows.cpp
//  class AudioUnitSinkChan_Windows.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#include "AudioUnitSinkChan_Windows.h"
#include "frtc_sdk_dist/frtc_sdk/RtcsdkInterface/SDKContextWrapper.h"

#include <QDebug>
#include <QString>
#include <QDateTime>
#include <iostream>

//using namespace std;

QMutex AudioUnitSinkChan_Windows::m_Mutex;
AudioUnitSinkChan_Windows * AudioUnitSinkChan_Windows::shareInstance = nullptr;

AudioUnitSinkChan_Windows* AudioUnitSinkChan_Windows::getInstance()
{
    if (nullptr == shareInstance) {
        qDebug("[%s][%d]: shareInstance = new AudioUnitSinkChan_Windows()", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitSinkChan_Windows();


        shareInstance->m_thread = new QThread;

        qDebug("[%s][%d]: -> call m_timer = new QTimer", __PRETTY_FUNCTION__, __LINE__);
        shareInstance->m_timer = new QTimer;
        shareInstance->m_timer->setTimerType(Qt::PreciseTimer);
        shareInstance->m_timer->setInterval(20); //20ms
        shareInstance->m_timer->moveToThread(shareInstance->m_thread);

        QObject::connect(shareInstance->m_thread, SIGNAL(started()), shareInstance, SLOT(slotStartAudioSink()));
        QObject::connect(shareInstance->m_thread, SIGNAL(started()), shareInstance->m_timer, SLOT(start()));
        QObject::connect(shareInstance->m_thread, SIGNAL(finished()), shareInstance->m_timer, SLOT(stop()));
        QObject::connect(shareInstance->m_thread, SIGNAL(finished()), shareInstance, SLOT(slotStopAudioSink()));

        QObject::connect(shareInstance->m_timer, SIGNAL(timeout()), shareInstance, SLOT(slotTimeOutHandler()), Qt::DirectConnection);

        shareInstance->isReceiving = false;

        shareInstance->moveToThread(shareInstance->m_thread);
    }
    return shareInstance;
}

void AudioUnitSinkChan_Windows::releaseInstance()
{
    qDebug("[%s][%d]: delete shareInstance", __PRETTY_FUNCTION__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

AudioUnitSinkChan_Windows::~AudioUnitSinkChan_Windows() {
    if (nullptr != m_timer) {
        delete m_timer;
        m_timer = nullptr;
    }
}

/*
void AudioUnitSinkChan_Windows::run()
{
    qDebug("[%s][%d]: ", __PRETTY_FUNCTION__, __LINE__);

    if (nullptr == this->m_timer) {
        qDebug("[%s][%d]: -> call m_timer = new QTimer", __PRETTY_FUNCTION__, __LINE__);
        m_timer = new QTimer;
        m_timer->setTimerType(Qt::PreciseTimer);
        m_timer->setInterval(20); //20ms
        m_timer->moveToThread(this);

        QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(slotTimeOutHandler()));
        m_timer->start();
    }

    QEventLoop event;
    event.exec();
}
*/

void AudioUnitSinkChan_Windows::slotStartAudioSink() {
    qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);
    this->setAudioOutput();
}

void AudioUnitSinkChan_Windows::setAudioOutput()
{
    qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);

    if (nullptr == audioOutput) {
        qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);

        output_stream = nullptr;

        //for test
        //this->currentSpeakerName = "bluez_sink.BC_F2_92_16_6F_FD.a2dp_sink";


        //output_Device = QAudioDeviceInfo::defaultOutputDevice();
        qDebug("[%s][%d]: AudioOutput currentSpeakerName : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(this->currentSpeakerName));
        qDebug("[%s][%d]: AudioOutput selectSpeakerName : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(this->selectSpeakerName));
        getSpeakerIDByName(this->currentSpeakerName);
        output_Device = m_selectAudioOutputDevice;

        this->currentSpeakerName = QString(output_Device.deviceName());
        qDebug("[%s][%d]: AudioInput output_Device = m_selectAudioOutputDevice, deviceName() : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(currentSpeakerName));

        // Format
        QAudioFormat nFormat;
        nFormat.setSampleRate(48000);
        nFormat.setSampleSize(16);
        nFormat.setChannelCount(1);
        nFormat.setCodec("audio/pcm");
        nFormat.setSampleType(QAudioFormat::SignedInt);
        nFormat.setByteOrder(QAudioFormat::LittleEndian);

        /*
        if (audioOutput != nullptr) {
            delete audioOutput;
            audioOutput = nullptr;
        }
        audioOutput = new QAudioOutput(nFormat);
        */

        //QAudioOutput(const QAudioDeviceInfo &audioDevice, const QAudioFormat &format = QAudioFormat(), QObject *parent = nullptr)
        audioOutput = new QAudioOutput(output_Device, nFormat, this);

        output_stream = audioOutput->start();

        if (nullptr != output_stream) {
            qDebug("[%s][%d]: -111- nullptr != output_stream", __PRETTY_FUNCTION__, __LINE__);
        } else {
            qDebug("[%s][%d]: -111- nullptr == output_stream", __PRETTY_FUNCTION__, __LINE__);
        }
    }
}

AudioUnitSinkChan_Windows::AudioUnitSinkChan_Windows(QObject *parent)
                  :QObject(parent),
                   m_timer(nullptr),
                   audioOutput(nullptr),
                   output_stream(nullptr),
                   isReceiving(false)
{
    refreshOutputDevices();
}

void AudioUnitSinkChan_Windows::startAudioUnit()
{
    qDebug("[%s][%d]:  -> call startTimerThread()", __PRETTY_FUNCTION__, __LINE__);
    startTimerThread();
}

void AudioUnitSinkChan_Windows::stopAudioUnit()
{
    qDebug("[%s][%d][dropCall]:  -> call stopTimerThread()", __PRETTY_FUNCTION__, __LINE__);
    stopTimerThread();
}

void AudioUnitSinkChan_Windows::startTimerThread() {
    if (isReceiving) {
        qDebug("[%s][%d] isReceiving == true, then return.", __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        qDebug("[%s][%d] set isReceiving = true, then call m_thread->start().", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        isReceiving = true;
        m_thread->start();
        //m_thread->exec(); //for audio output.

        if (nullptr != m_timer) {
            qDebug("[%s][%d]: m_timer != nullptr.", __PRETTY_FUNCTION__, __LINE__);

        }
    }
}

void AudioUnitSinkChan_Windows::stopTimerThread() {
    if (false == isReceiving) {
        qDebug("[%s][%d] isReceiving == false, then return.", __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        qDebug("[%s][%d] set isReceiving = false, then call this->quit(), this->wait().", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        isReceiving = false;
        
//        if (nullptr != audioOutput) {
//            audioOutput->stop();
//        }
        
        if (true == m_thread->isRunning()) {
            qDebug("[%s][%d]: -> call m_thread->quit(), then m_thread->wait()", __PRETTY_FUNCTION__, __LINE__);
            m_thread->quit();
            m_thread->wait();
        }
        qDebug("[%s][%d]: -> m_thread->isFinished() : %s", __PRETTY_FUNCTION__, __LINE__, m_thread->isFinished()? "true":"false");
    }
}

void AudioUnitSinkChan_Windows::slotStopAudioSink() {
    qDebug("[%s][%d]: -> m_thread->isFinished() : %s", __PRETTY_FUNCTION__, __LINE__, m_thread->isFinished()? "true":"false");

//    if (nullptr != m_timer) {
//        delete m_timer;
//        m_timer = nullptr;
//    }

    if (nullptr != audioOutput) {
        qDebug("[%s][%d]: -> call audioOutput->state(): %d", __PRETTY_FUNCTION__, __LINE__, audioOutput->state());
        qDebug("[%s][%d]: -> call audioOutput->stop()", __PRETTY_FUNCTION__, __LINE__);
//        audioOutput->stop();
        delete audioOutput;
        audioOutput = nullptr;
    }
}


void AudioUnitSinkChan_Windows::slotTimeOutHandler()
{
    //qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);
    
    if (false == isReceiving) {
        qDebug("[%s][%d] isReceiving == false, so return.", __PRETTY_FUNCTION__, __LINE__);
        return;
    }

    //maybe: for write(), everytime, we only use the lengh FRAME_LEN_1920 of the data, so no need to use memset().
    memset(&buffer, 0, FRAME_LEN_1920);
    
    unsigned int length = FRAME_LEN_1920;
    unsigned int sample_rate = 48000;

    QMutexLocker mutexLocker(&m_Mutex);

    getAudioData(buffer, length, sample_rate);
        
    if (nullptr != output_stream)
    {
        //qDebug("[%s][%d]: -> output_stream->write(", __PRETTY_FUNCTION__, __LINE__);
        output_stream->write((char *)buffer, FRAME_LEN_1920);
    }
    
    
    //=================================
    // dump received audio stream
    //=================================
    //======[Sava Audio raw data to file]======
#ifdef DEFINE_DUMP_AUDIO_SINK
        static bool isFileOpen = false;
        static FILE* fp = nullptr;
        if (false == isFileOpen) {
            qDebug("[%s][%d]: open file, ./../../../getAudioData.raw", __PRETTY_FUNCTION__, __LINE__);

            fp = fopen("./../../../getAudioData.raw", "a+");
            //fp = fopen("./getAudioData.raw", "a+");
            //test
            //fwrite("data 1", 1, 6, fp);
            //fwrite("data 2", 1, 6, fp);
            isFileOpen = true;
        }
        
        static int i = 0;
        if (500  <= i++) {
            qDebug("[%s][%d]: close file", __PRETTY_FUNCTION__, __LINE__);
            fclose(fp);
            fp = nullptr;
        } else {
            qDebug("[%s][%d]: save to file", __PRETTY_FUNCTION__, __LINE__);
            if (nullptr != fp) {
                qDebug("[%s][%d]: = = = = = = save to file : length : %d", __PRETTY_FUNCTION__, __LINE__, length);
                //length : 1920
                
                fwrite((char *)buffer, 1, length, fp);
                //                short srcAudio[6] = {1, 2, 3, 4, 5, 6};
                //                //fwrite(srcAudio, 1, sizeof(srcAudio), fp);
                //fwrite("data 3", 1, 6, fp);
            }
        }
#endif
    //======[Sava Audio raw data to file]======
    //=================================
}

void AudioUnitSinkChan_Windows::getAudioData(void * buffer, unsigned int length,unsigned int sample_rate)
{
    //qDebug("[%s][%d]: -> call SDKContext::sharedSDKContext()->getAudioData", __PRETTY_FUNCTION__, __LINE__);
    SDKContext::sharedSDKContext()->getAudioData(buffer, length, sample_rate);
}

int AudioUnitSinkChan_Windows::refreshOutputDevices() {
    m_audioOutputDeviceList.clear();

    //get audio output devices name.
    QVector<QString> aDeviceListO;
    QList<QAudioDeviceInfo> audioDeviceListO = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
    foreach (QAudioDeviceInfo devInfo, audioDeviceListO) {
        if (devInfo.isNull()) {
            continue;
        }
        QString strName = devInfo.deviceName();
        //qDebug("[%s][%d]: AudioOutput name : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));

        QString audio_device_macOS = "FRMeeting Audio Device";
        QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        QString audio_device_poly_weMeet = "WeMeet Audio Device";

        if (nullptr != strName && false == strName.isEmpty()) {
            //qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);
            if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioOutput name : %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioOutput name : %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioOutput name : %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
            } else {
                //qDebug("[%s][%d]:  _audioOutputDevice.push_back(devInfo: AudioOutput name : %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
                m_audioOutputDeviceList.push_back(devInfo);
            }
        }

        /*
        if (strName[0] == 65533) continue;
        bool bFound = false;
        foreach (QString dev, aDeviceListO) {
            if (strName == dev) {
                bFound = true;
                qDebug("[%s][%d]: bFound speaker name : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(dev));

            }
        }
        if (bFound == true) continue;
        aDeviceListO.push_back(strName);
        //ui->comboBoxOutput->addItem(strName);
         */
    }
    return 0;
}

void AudioUnitSinkChan_Windows::selectSpeaker(QString id) {
    this->selectSpeakerName = id;
    qDebug("[%s][%d]: AudioOutput name, this->selectSpeakerName : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(this->selectSpeakerName));
    qDebug("[%s][%d]: AudioOutput name, this->currentSpeakerName : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(this->currentSpeakerName));

    //refreshOutputDevices();
    //TEST_DEBUG("select speaker device name: %s", id);
    QString old_speker = this->currentSpeakerName;
    this->currentSpeakerName = "";

    for (std::vector<QAudioDeviceInfo>::const_iterator it = m_audioOutputDeviceList.begin(); it != m_audioOutputDeviceList.end(); ++it) {
        QString strName = it->deviceName();
        qDebug("[%s][%d]: --- speaker: AudioOutput name : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));


        if (0 == strName.compare(this->selectSpeakerName, Qt::CaseInsensitive)) {
            //qDebug("[%s][%d]: --- speaker: AudioOutput name set this->currentSpeakerName = this->selectSpeakerName: %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
            this->currentSpeakerName = this->selectSpeakerName;
            break;
        }
    }

    if (0 != old_speker.compare(this->selectSpeakerName, Qt::CaseInsensitive) && this->isReceiving) {
        qDebug("[%s][%d]: speaker changed from %s to %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(old_speker), qPrintable(id));
        restartMainSpeaker();
    }

}

void AudioUnitSinkChan_Windows::restartMainSpeaker() {
    qDebug("[%s][%d]: -> call stopAudioUnit()", __PRETTY_FUNCTION__, __LINE__);
    stopAudioUnit();

    qDebug("[%s][%d]: -> call configMainSrcShan()", __PRETTY_FUNCTION__, __LINE__);
    configMainSrcShan();

    //qDebug("[%s][%d]: -> call setSpeaker(this->selectSpeakerName: %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(this->selectSpeakerName));
    //setSpeaker(this->selectSpeakerName);

    qDebug("[%s][%d]: -> call startAudioUnit()", __PRETTY_FUNCTION__, __LINE__);
    startAudioUnit();
}

bool AudioUnitSinkChan_Windows::configMainSrcShan() {
    qDebug("[%s][%d]: currentSpeakerName : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(currentSpeakerName));
    if (nullptr == this->selectSpeakerName || this->selectSpeakerName.isEmpty()) {
        qDebug("[%s][%d]: currentSpeakerName is empty, so -> call getDefaultSpeakerName() ", __PRETTY_FUNCTION__, __LINE__);
        this->selectSpeakerName = getDefaultSpeakerName();
        this->currentSpeakerName = getDefaultSpeakerName();
        this->m_selectAudioOutputDevice = QAudioDeviceInfo::defaultOutputDevice();
        return true;
    } else {
        qDebug("[%s][%d]: -> call getSpeakerIDByName(currentSpeakerName : %s)", __PRETTY_FUNCTION__, __LINE__, qPrintable(currentSpeakerName));
        getSpeakerIDByName(this->selectSpeakerName);
    }
    return true;
}

void AudioUnitSinkChan_Windows::getSpeakerIDByName(QString name) {
    bool isFind = false;
    for (std::vector<QAudioDeviceInfo>::const_iterator it = m_audioOutputDeviceList.begin(); it != m_audioOutputDeviceList.end(); ++it) {
        QString strName = it->deviceName();
        //qDebug("[%s][%d]: --- speaker: AudioOutput name : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));

        if (0 == strName.compare(name, Qt::CaseInsensitive)) {
            //TEST_DEBUG("speaker device is found: %s", name.c_str());
            qDebug("[%s][%d]: speaker device is found, audio output device name: %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
            isFind = true;

            qDebug("[%s][%d]: it->deviceName(): %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(it->deviceName()));
            m_selectAudioOutputDevice = *it;
            qDebug("[%s][%d]: isFind = true, set m_selectAudioOutputDevice.deviceName(): %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(m_selectAudioOutputDevice.deviceName()));
            break;
        }
    }

    if (false == isFind) {
        qDebug("[%s][%d]: getSpeakerIDByName(currentSpeakerName) return false == isFind -> set this->currentSpeakerName = getDefaultSpeakerName()", __PRETTY_FUNCTION__, __LINE__);
        this->currentSpeakerName = getDefaultSpeakerName();
        this->m_selectAudioOutputDevice = QAudioDeviceInfo::defaultOutputDevice();
        qDebug("[%s][%d]: set m_selectAudioOutputDevice.deviceName(): %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(m_selectAudioOutputDevice.deviceName()));
    }
}

QString AudioUnitSinkChan_Windows::getDefaultSpeakerName() {
    QAudioDeviceInfo output_Device = QAudioDeviceInfo::defaultOutputDevice();
    QString strName = QString(output_Device.deviceName());
    qDebug("[%s][%d]: AudioOutput name : %s", __PRETTY_FUNCTION__, __LINE__, qPrintable(strName));
    return strName;
}
