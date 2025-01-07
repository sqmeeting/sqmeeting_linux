//
//  AudioUnitCapture_Windows.cpp
//  class AudioUnitCapture_Windows.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#include "AudioUnitCapture_Windows.h"
#include "frtc_sdk_dist/frtc_sdk/RtcsdkInterface/SDKContextWrapper.h"

//for BASE::SystemUtil::getCPUTime()
#include "./frtc_sdk_dist/dist/include/base/inc/system_util.h"

#include <QDebug>
#include <QDateTime>
#include <iostream>

//#define DEFINE_DUMP_AUDIO_CAPTURE

//using namespace std;

QMutex AudioUnitCapture_Windows::m_Mutex;
AudioUnitCapture_Windows * AudioUnitCapture_Windows::shareInstance = nullptr;

AudioUnitCapture_Windows* AudioUnitCapture_Windows::getInstance()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr == shareInstance)
    {
        qDebug("[AudioUnitCapture_Windows::%s][%d] shareInstance = new AudioUnitCapture_Windows()", Q_FUNC_INFO, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitCapture();
        
        shareInstance->m_thread = new QThread;
        shareInstance->moveToThread(shareInstance->m_thread);
        
        qDebug("[%s][%d]: set isRunning = false", Q_FUNC_INFO, __LINE__);
        shareInstance->isRunning = false;
        
        QObject::connect(shareInstance->m_thread, SIGNAL(started()), shareInstance, SLOT(slotStartAudioCapture()));
        QObject::connect(shareInstance->m_thread, SIGNAL(finished()), shareInstance, SLOT(slotStopAudioCapture()));
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
    return shareInstance;
}

void AudioUnitCapture_Windows::releaseInstance()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        
        delete shareInstance->audioInput;
        delete shareInstance->input_stream;
        
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

AudioUnitCapture_Windows::AudioUnitCapture_Windows(QObject *parent)
: QObject(parent),
  audioInput(nullptr)
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

    currentMicName = "";
    secondMicName = "";
    currentSpeakerName = "";
    isRunning = false;

    refreshInputDevices();
    refreshOutputDevices();
}

AudioUnitCapture_Windows::~AudioUnitCapture_Windows()
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture_Windows::startAudioUnitCapture()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if (nullptr != this->m_thread)
    {
        qDebug() << "[AudioUnitCapture_Windows::" << __func__ << "][" << __LINE__ << "]: -> call this->m_thread->start(), and it will call slotStartAudioCapture on this thread";
        this->m_thread->start();
    }
    
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture_Windows::slotStartAudioCapture()
{
    if (true == isRunning)
    {
        qDebug("[%s][%d] isRunning == true, then return.", Q_FUNC_INFO, __LINE__);
        return;
    }
    else
    {
        qDebug("[%s][%d] set isRunning = true, then call captureAudioInputData().", Q_FUNC_INFO, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        this->isRunning = true;
        captureAudioInputData();
    }
}

void AudioUnitCapture_Windows::stopAudioUnitCapture()
{
    if (false == isRunning) {
        qDebug("[%s][%d] isRunning == false, then return.", Q_FUNC_INFO, __LINE__);
        return;
    }
    else
    {
        qDebug("[%s][%d] set isRunning = false, then call this->quit(), this->wait().", Q_FUNC_INFO, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        this->isRunning = false;

        qDebug("[%s][%d]: -> call audioInput->state(): %d", Q_FUNC_INFO, __LINE__, audioInput->state());
        if (true == m_thread->isRunning())
        {
            qDebug("[%s][%d]: -> call m_thread->quit(), then m_thread->wait()", Q_FUNC_INFO, __LINE__);
            m_thread->quit();
            m_thread->wait();
        }
        qDebug("[%s][%d]: -> m_thread->isFinished() : %s -> slotStopAudioCapture()", Q_FUNC_INFO, __LINE__, m_thread->isFinished()? "true":"false");
    }
}

void AudioUnitCapture_Windows::slotStopAudioCapture()
{
    qDebug("[%s][%d]: -> m_thread->isFinished() : %s", Q_FUNC_INFO, __LINE__, m_thread->isFinished()? "true":"false");
    if (nullptr != audioInput)
    {
        qDebug("[%s][%d]: -> call audioInput->state(): %d", Q_FUNC_INFO, __LINE__, audioInput->state());

        qDebug("[%s][%d]: -> call audioInput->stop()", Q_FUNC_INFO, __LINE__);
        audioInput->stop();
        delete audioInput;
        audioInput = nullptr;
    }
}

void AudioUnitCapture_Windows::muteMicrophone(bool isMuted)
{
    if (false == isMuted && false == this->isRunning)
    {
        qDebug("[%s][%d]: audioInput->start()", Q_FUNC_INFO, __LINE__);
        qDebug("[%s][%d]: -> call startAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
        startAudioUnitCapture();
    } else if (true == isMuted && true == this->isRunning)
    {
        qDebug("[%s][%d]: -> call stopAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
        stopAudioUnitCapture();
    }
}

/**
 [macOS version]:
 output audio data for sending  to remote
 SampleRate: 48K
 */

//only 48k
#define FRAME_LEN_1920 (960 * 2)
static unsigned char buffer[FRAME_LEN_1920*16] = {0};
static uint64_t lastFrameCaptureTime = 0;

//1.Capture and send to remote.

void AudioUnitCapture_Windows::captureAudioInputData()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    
    if (nullptr == audioInput) {
        qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

        input_stream = nullptr;
        output_stream = nullptr;
        
        //get audio devices.

        //TODO: set this->currentMicName.
        //configMainSrcShan();

       //input_Device = QAudioDeviceInfo::defaultInputDevice();
        qDebug("[%s][%d]: AudioInput currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentMicName));
        qDebug("[%s][%d]: AudioInput selectMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->selectMicName));
        getMicIDByName(this->currentMicName);
        input_Device = m_selectAudioInputDevice;
        qDebug("[%s][%d]: AudioInput input_Device = m_selectAudioInputDevic.edeviceName() : %s", Q_FUNC_INFO, __LINE__, qPrintable(input_Device.deviceName()));


        //output_Device = QAudioDeviceInfo::defaultOutputDevice();
        //qDebug("[%s][%d]: AudioOutput currentSpeakerName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentSpeakerName));
        //qDebug("[%s][%d]: AudioOutput selectSpeakerName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->selectSpeakerName));
        //getSpeakerIDByName(this->currentSpeakerName);
        //output_Device = m_selectAudioOutputDevice;

        this->currentMicName = QString(input_Device.deviceName());
        //this->currentSpeakerName = QString(output_Device.deviceName());

        qDebug("[%s][%d]: AudioInput name, this->currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentMicName));
        //qDebug("[%s][%d]: AudioOutput name, this->currentSpeakerName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentSpeakerName));

        //set audio format for capture.
        QAudioFormat settings;
        settings.setCodec("audio/pcm");
        settings.setSampleRate(48000);
        settings.setSampleSize(16);
        settings.setChannelCount(1);
        settings.setByteOrder(QAudioFormat::LittleEndian);
        settings.setSampleType(QAudioFormat::SignedInt);
        //settings.setSampleType(QAudioFormat::SampleType(1));
        
        //格式支持判断, 若不支持则选择相近格式
        if (!input_Device.isFormatSupported(settings))
        {
            printf("format not supported, use the nearest settings!!!\n");
            input_Device.nearestFormat(settings);
        }
        
        //create and set audio input.
        qDebug("[%s][%d]: start recording...", Q_FUNC_INFO, __LINE__);
        
        audioInput = new QAudioInput(input_Device, settings, this);
        audioInput->setBufferSize(1920); //then readDataLength : 8000
        qDebug() << "The input volume is " << audioInput->volume();
        audioInput->setVolume(0.3);
        qDebug() << "The new input volume is " << audioInput->volume();
    }
    
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    //将QIODevice指向输入流和输出流
    input_stream = audioInput->start();
    
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    connect(input_stream, &QIODevice::readyRead, [=]()
    {
        //qDebug("[ThreadID: %p][%s][%d]: Audio capture input_stream run loop.", QThread::currentThreadId(), Q_FUNC_INFO, __LINE__);

        //if (false == this->isRunning) {
        //    qDebug("[%s][%d][DEFINE_DUMP_AUDIO_CAPTURE]: returen from Audio capture input_stream run loop.", Q_FUNC_INFO, __LINE__);
        //    return;
        //}
        
        //qDebug("[%s][%d][DEFINE_DUMP_AUDIO_CAPTURE]: Audio capture input_stream run loop.", Q_FUNC_INFO, __LINE__);

        //get current time for log
        /*
        QDateTime current_date_time = QDateTime::currentDateTime();
        QString current_date = current_date_time.toString("yyyy-MM-dd");
        QString current_time = current_date_time.toString("hh:mm:ss.zzz");
        qDebug("[AudioUnitCapture_Windows::%s][%d]: current_time : %s", Q_FUNC_INFO, __LINE__, qPrintable(current_time));
         */

        /*
        static uint64_t startTime = 0;
        static uint64_t endTime = 0;
        uint64_t captureTime = 0;
        startTime = BASE::SystemUtil::getCPUTime();
        captureTime = startTime - lastFrameCaptureTime;
        qDebug("[%s][%d]: |-- captureTime: %lu", Q_FUNC_INFO, __LINE__, captureTime);
        
        lastFrameCaptureTime = startTime;
        */


#ifdef DEFINE_DUMP_AUDIO_CAPTURE
        static bool isFileOpen = false;
        static FILE* fp = nullptr;
        if (false == isFileOpen) {
            qDebug() << "[AudioUnitCapture_Windows::" << Q_FUNC_INFO << "][" << __LINE__ << "]: Capture Audio data, save to file : ./../audioUnitCapure.raw";
            fp = fopen("./../audioUnitCapure.raw", "a+");
            //test
            //fwrite("data 1", 1, 6, fp);
            //fwrite("data 2", 1, 6, fp);
            isFileOpen = true;
        }
#endif

        //当有音频输入时，输入流读取进行录音，然后写给输出流进行监听
        auto data = input_stream->readAll(); //QByteArray

        //int readDataLength = ((QByteArray)data).size();

        //TODO: 按照 1920 个 unsigned char 一个buffer发送
        unsigned int length = FRAME_LEN_1920;
        unsigned int sample_rate = 48000;
        bool b2ndMic = false; //true;
        
        //memcpy(buffer, data, FRAME_LEN_1920);

        //[Note]: on Linux, the length is not fixed value 1920, but maybe a value near to int 2000.
        length = ((QByteArray)data).size();

        if (length > sizeof(buffer)/sizeof(buffer[0])) {
            printf("capture audio length more than 1920(%u)\n", length);
        }
        memcpy(buffer, data, length);
        SDKContext::sharedSDKContext()->sendAudioData(buffer, length, sample_rate, b2ndMic);
        
        //======[Dump Capture audio to local raw file]======
#ifdef DEFINE_DUMP_AUDIO_CAPTURE
        static int i = 0;
        if (200 == i) {
            qDebug("[%s][%d][DEFINE_DUMP_AUDIO_CAPTURE]: close the dump file. -> call fclose(fp)", Q_FUNC_INFO, __LINE__);
            fclose(fp);
            fp = nullptr;
        } else {
            qDebug() << "[AudioUnitCapture_Windows::" << Q_FUNC_INFO << "][" << __LINE__ << "]: save the dump file, -> call fwrite()";
            qDebug("[%s][%d][DEFINE_DUMP_AUDIO_CAPTURE]: -> fclose(fp)", Q_FUNC_INFO, __LINE__);
            if (nullptr != fp) {
                fwrite((QByteArray)data, 1, ((QByteArray)data).size(), fp);

                //short srcAudio[6] = {1, 2, 3, 4, 5, 6};
                //fwrite(srcAudio, 1, sizeof(srcAudio), fp);
                //fwrite("data 3", 1, 6, fp);
            }
        }
#endif
        //==================================================
    });
}

//local mic
int AudioUnitCapture_Windows::refreshInputDevices() {
    m_audioInputDeviceList.clear();

    //get audio input devices name.
    QVector<QString> aDeviceListI;
    QList<QAudioDeviceInfo> audioDeviceListI = QAudioDeviceInfo::availableDevices(QAudio::AudioInput);
    foreach (QAudioDeviceInfo devInfo, audioDeviceListI) {
        if (devInfo.isNull()) {
            continue;
        }
        QString strName = devInfo.deviceName();
        qDebug("[%s][%d]: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));

        if (strName[0] == 65533) {
            qWarning()<<"invalid device";
            continue;
        }

        QString audio_input_str = "input";
        if (nullptr != strName && false == strName.isEmpty()) {
            if (false == strName.contains(audio_input_str, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
                continue;
            }
        }


        QString audio_device_macOS = "FRMeeting Audio Device";
        QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        QString audio_device_poly_weMeet = "WeMeet Audio Device";

        if (nullptr != strName && false == strName.isEmpty()) {
            //qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
            if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else {
                //qDebug("[%s][%d]:  _audioInputDevice.push_back(devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
                m_audioInputDeviceList.push_back(devInfo);
            }
        }

        /*
        if (strName[0] == 65533) continue;
        bool bFound = false;
        foreach (QString dev, aDeviceListI) {
            if (strName == dev) {
                bFound = true;
                qDebug("[%s][%d]: bFound mic name : %s", Q_FUNC_INFO, __LINE__, qPrintable(dev));
            }
        }
        if (bFound == true) continue;
        aDeviceListI.push_back(strName);
        //ui->comboBoxInput->addItem(strName);
        */
    }
    return 0;
}

int AudioUnitCapture_Windows::refreshOutputDevices() {
    m_audioOutputDeviceList.clear();
    
    //get audio output devices name.
    QVector<QString> aDeviceListO;
    QList<QAudioDeviceInfo> audioDeviceListO = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
    foreach (QAudioDeviceInfo devInfo, audioDeviceListO) {
        if (devInfo.isNull()) {
            continue;
        }
        QString strName = devInfo.deviceName();
        //qDebug("[%s][%d]: AudioOutput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));


        if (strName[0] == 65533) {
            qWarning()<<"invalid device";
            continue;
        }

        QString audio_input_str = "output";
        QString bluetooth_audio_input_str = "sink";

        if (nullptr != strName && false == strName.isEmpty()) {
            if (false == strName.contains(audio_input_str, Qt::CaseInsensitive)
                    && false == strName.contains(bluetooth_audio_input_str, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
                continue;
            }
        }

        QString audio_device_macOS = "FRMeeting Audio Device";
        QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        QString audio_device_poly_weMeet = "WeMeet Audio Device";

        if (nullptr != strName && false == strName.isEmpty()) {
            //qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
            if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            } else {
                //qDebug("[%s][%d]:  _audioOutputDevice.push_back(devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
                m_audioOutputDeviceList.push_back(devInfo);
            }
        }
        
        /*
        if (strName[0] == 65533) continue;
        bool bFound = false;
        foreach (QString dev, aDeviceListO) {
            if (strName == dev) {
                bFound = true;
                qDebug("[%s][%d]: bFound speaker name : %s", Q_FUNC_INFO, __LINE__, qPrintable(dev));

            }
        }
        if (bFound == true) continue;
        aDeviceListO.push_back(strName);
        //ui->comboBoxOutput->addItem(strName);
         */
    }
    return 0;
}

void AudioUnitCapture_Windows::micphoneList(std::vector<QAudioDeviceInfo> &micList) {
    micList.clear();
    copy(m_audioInputDeviceList.begin(), m_audioInputDeviceList.end(), inserter(micList, micList.begin()));
}

void AudioUnitCapture_Windows::speakerList(std::vector<QAudioDeviceInfo> &spkList) {
    spkList.clear();
    copy(m_audioOutputDeviceList.begin(), m_audioOutputDeviceList.end(), inserter(spkList, spkList.begin()));
}

QString AudioUnitCapture_Windows::getCurrentMicphoneName() {
    return currentMicName;
}

QString AudioUnitCapture_Windows::getCurrentSpeakerName() {
    return currentSpeakerName;
}

//TODO: Qt5 -> Qt6 -yingyong.Mao -2023-10-23
//默认音频输入输出设备集合之前是 QAudioDeviceInfo::defaultInputDevice()、QAudioDeviceInfo::defaultOutputDevice()，
//现在是 QMediaDevices::defaultAudioInput()、QMediaDevices::defaultAudioOutput()。

QString AudioUnitCapture_Windows::getDefaultMicName() {
    QAudioDeviceInfo input_Device = QAudioDeviceInfo::defaultInputDevice();
    QString strName = QString(input_Device.deviceName());
    qDebug("[%s][%d]: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
    return strName;
}

QString AudioUnitCapture_Windows::getDefaultSpeakerName() {
    QAudioDeviceInfo output_Device = QAudioDeviceInfo::defaultOutputDevice();
    QString strName = QString(output_Device.deviceName());
    qDebug("[%s][%d]: AudioOutput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
    return strName;
}

void AudioUnitCapture_Windows::selectMic(QString id) {
    this->selectMicName = id;
    qDebug("[%s][%d]: AudioInput name, this->selectMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->selectMicName));
    qDebug("[%s][%d]: AudioInput name, this->currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentMicName));

    //refreshOutputDevices();
    //TEST_DEBUG("select mic device name: %s", id);
    QString old_mic = this->currentMicName;
    this->currentMicName = "";

    for (std::vector<QAudioDeviceInfo>::const_iterator it = m_audioInputDeviceList.begin(); it != m_audioInputDeviceList.end(); ++it) {
        //QAudioDeviceInfo *micDevice = (QAudioDeviceInfo)it;
        QString strName = it->deviceName();
        qDebug("[%s][%d]: --- mic: Audioinput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        if (0 == strName.compare(this->selectMicName, Qt::CaseInsensitive)) {
            //qDebug("[%s][%d]: --- mic: Audioinput name set this->currentMicName = this->selectMicName: %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            this->currentMicName = this->selectMicName;
            break;
        }
    }

    if (0 != old_mic.compare(this->currentMicName, Qt::CaseInsensitive) && this->isRunning) {
        qDebug("[%s][%d]: mic changed from %s to %s", Q_FUNC_INFO, __LINE__, qPrintable(old_mic), qPrintable(id));
        restartMainMic();
    }
    if (m_audioInputDeviceList.size() < 2) {
        TEST_INFO("input device count less than 2, no need to handle second mic");
        return;
    }

    /*
    //handle second mic
    QString *old_2ndmic = self.secondMicName;
    AudioDeviceID firstId = [self getMicIDByName:self.currentMicName];
    AudioDeviceID secondId = [self Find2ndMicId:firstId];
    self.secondMicName = [self getMicNameById:secondId];
    TEST_INFO("2nd mic changed from %s to %s", [old_2ndmic UTF8String], [self.secondMicName UTF8String]);
    
    if ( [old_2ndmic isEqualToString:self.secondMicName ] == false && self.isRunning)
    {
        [self restart2ndMic];
    }

    */
    //TEST_DEBUG("after select mic, current mic name: %s,second mic name :%s", [self.currentMicName UTF8String], [self.secondMicName UTF8String]);
}

/*
- (OSStatus)restartMainMic {
    [self.audiMainSrcChan stopAudioUnit];
    if (noErr != [self configMainSrcShan])
    {
        NSLog(@"configure source audio failed");
    }
    [self.audiMainSrcChan startAudioUnit];
    return  noErr;
}
*/

void AudioUnitCapture_Windows::restartMainMic() {
    qDebug("[%s][%d]: -> call stopAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    stopAudioUnitCapture();

    qDebug("[%s][%d]: -> call configMainSrcShan()", Q_FUNC_INFO, __LINE__);
    configMainSrcShan();

    qDebug("[%s][%d]: -> call startAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    startAudioUnitCapture();
}

bool AudioUnitCapture_Windows::configMainSrcShan() {
    qDebug("[%s][%d]: currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(currentMicName));
    if (nullptr == this->currentMicName || this->currentMicName.isEmpty()) {
        qDebug("[%s][%d]: currentMicName is empty, so -> call getDefaultMicName() ", Q_FUNC_INFO, __LINE__);
        this->currentMicName = getDefaultMicName();
        this->m_selectAudioInputDevice = QAudioDeviceInfo::defaultInputDevice();
        return true;
    } else {
        qDebug("[%s][%d]: -> call getMicIDByName(currentMicName : %s)", Q_FUNC_INFO, __LINE__, qPrintable(currentMicName));
        getMicIDByName(this->currentMicName);
    }
    return true;
}

void AudioUnitCapture_Windows::getMicIDByName(QString name) {
    bool isFind = false;
    for (std::vector<QAudioDeviceInfo>::const_iterator it = m_audioInputDeviceList.begin(); it != m_audioInputDeviceList.end(); ++it) {
        //QAudioDeviceInfo *micDevice = (QAudioDeviceInfo)it;
        QString strName = it->deviceName();
        //qDebug("[%s][%d]: --- mic: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));

        if (0 == strName.compare(name, Qt::CaseInsensitive)) {
            //TEST_DEBUG("micphone device is found: %s", name.c_str());
            qDebug("[%s][%d]: micphone device is found, audio input device name: %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            //this->currentMicName = name;
            //this->m_current_input_Device = id;
            isFind = true;

            qDebug("[%s][%d]: it->deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(it->deviceName()));
            m_selectAudioInputDevice = *it;
            qDebug("[%s][%d]: isFind = true, set m_selectAudioInputDevice.deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(m_selectAudioInputDevice.deviceName()));
            //*id = *it;
            break;
        }
    }

    if (false == isFind) {
        qDebug("[%s][%d]: getMicIDByName(currentMicName) return false == isFind -> set this->currentMicName = getDefaultMicName()", Q_FUNC_INFO, __LINE__);
        this->currentMicName = getDefaultMicName();
        this->m_selectAudioInputDevice = QAudioDeviceInfo::defaultInputDevice();
        qDebug("[%s][%d]: set m_selectAudioInputDevice.deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(m_selectAudioInputDevice.deviceName()));
    }
}

