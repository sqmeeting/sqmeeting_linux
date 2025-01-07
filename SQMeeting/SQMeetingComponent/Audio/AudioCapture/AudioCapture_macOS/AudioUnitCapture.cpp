#include "AudioUnitCapture.h"
#include <QDebug>
#include <QDateTime>
#include <iostream>
#include <QMediaDevices>
#include <QCoreApplication>

#include "FMakeCallClient.h"

//#define DEFINE_DUMP_AUDIO_CAPTURE

using namespace std;

QMutex AudioUnitCapture::m_Mutex;
AudioUnitCapture * AudioUnitCapture::shareInstance = nullptr;

AudioUnitCapture* AudioUnitCapture::getInstance()
{
    if (nullptr == shareInstance)
    {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitCapture();
        
        shareInstance->m_thread = new QThread;
        shareInstance->moveToThread(shareInstance->m_thread);
        
        shareInstance->isRunning = false;
        
        QObject::connect(shareInstance->m_thread, SIGNAL(started()), shareInstance, SLOT(slotStartAudioCapture()));
        QObject::connect(shareInstance->m_thread, SIGNAL(finished()), shareInstance, SLOT(slotStopAudioCapture()));
    }
    return shareInstance;
}

void AudioUnitCapture::releaseInstance()
{
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        
        shareInstance->audioSource->deleteLater();
        delete shareInstance->input_stream;
        
        delete shareInstance;
        shareInstance = nullptr;
    }
}

AudioUnitCapture::AudioUnitCapture(QObject *parent)
: QObject(parent),
  audioSource(nullptr)
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);

    currentMicName = "";
    secondMicName = "";
    currentSpeakerName = "";
    isRunning = false;

    mediaDevices = new QMediaDevices(this);

    refreshInputDevices();
    refreshOutputDevices();

    qDebug("[%s][%d]--------------------------", Q_FUNC_INFO, __LINE__);

    connect(mediaDevices, &QMediaDevices::audioInputsChanged,
            this, &AudioUnitCapture::onAudioInputsChanged);

    connect(mediaDevices, &QMediaDevices::audioOutputsChanged,
            this, &AudioUnitCapture::onAudioOutputsChanged);

   //connect(&QMediaDevices::audioInputsChanged, this, &AudioUnitCapture::onAudioInputsChanged);

    qDebug("[%s][%d]***************************", Q_FUNC_INFO, __LINE__);
}

AudioUnitCapture::~AudioUnitCapture()
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture::onAudioInputsChanged()
{
    qDebug() << "Audio inputs have changed!";
    // 获取并输出当前的音频输入设备信息
    auto audioInputs = mediaDevices->audioInputs();
    qDebug() << "Available audio inputs:";
    for (const auto &input : audioInputs) {
        qDebug() << input.description();
    }
}

void AudioUnitCapture::onAudioOutputsChanged()
{
    qDebug() << "Audio outputs have changed!";
    // 获取并输出当前的音频输出设备信息
    auto audioOutputs = mediaDevices->audioOutputs();
    qDebug() << "Available audio outputs:";
    for (const auto &output : audioOutputs) {
        qDebug() << output.description();
    }
}

void AudioUnitCapture::startAudioUnitCapture()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    if (nullptr != this->m_thread)
    {
        qDebug() << "[AudioUnitCapture::" << __func__ << "][" << __LINE__ << "]: -> call this->m_thread->start(), and it will call slotStartAudioCapture on this thread";
        this->m_thread->start();
    }
    
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

void AudioUnitCapture::slotStartAudioCapture()
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

void AudioUnitCapture::stopAudioUnitCapture()
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

        //qDebug("[%s][%d]: -> call audioInput->state(): %d", Q_FUNC_INFO, __LINE__, audioInput->state());
        if (true == m_thread->isRunning())
        {
            qDebug("[%s][%d]: -> call m_thread->quit(), then m_thread->wait()", Q_FUNC_INFO, __LINE__);
            m_thread->quit();
            m_thread->wait();
        }
        qDebug("[%s][%d]: -> m_thread->isFinished() : %s -> slotStopAudioCapture()", Q_FUNC_INFO, __LINE__, m_thread->isFinished()? "true":"false");
    }
}

void AudioUnitCapture::slotStopAudioCapture()
{
    qDebug("[%s][%d]: -> m_thread->isFinished() : %s", Q_FUNC_INFO, __LINE__, m_thread->isFinished()? "true":"false");
    if (nullptr != audioSource)
    {
        //qDebug("[%s][%d]: -> call audioInput->state(): %d", Q_FUNC_INFO, __LINE__, audioInput->state());

        //qDebug("[%s][%d]: -> call audioInput->stop()", Q_FUNC_INFO, __LINE__);
        audioSource->stop();
        audioSource->deleteLater();
        audioSource = nullptr;
    }
}

void AudioUnitCapture::muteMicrophone(bool isMuted)
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

void AudioUnitCapture::captureAudioInputData()
{
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    
    if (nullptr == audioSource) {
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
        //qDebug("[%s][%d]: AudioInput input_Device = m_selectAudioInputDevic.edeviceName() : %s", Q_FUNC_INFO, __LINE__, qPrintable(input_Device.deviceName()));


        //output_Device = QAudioDeviceInfo::defaultOutputDevice();
        //qDebug("[%s][%d]: AudioOutput currentSpeakerName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentSpeakerName));
        //qDebug("[%s][%d]: AudioOutput selectSpeakerName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->selectSpeakerName));
        //getSpeakerIDByName(this->currentSpeakerName);
        //output_Device = m_selectAudioOutputDevice;

        this->currentMicName = QString(input_Device.description());
        //this->currentSpeakerName = QString(output_Device.deviceName());

        qDebug("[%s][%d]: AudioInput name, this->currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentMicName));
        QAudioFormat settings;
        settings.setSampleRate(48000);
        settings.setChannelCount(1);

        settings.setSampleFormat(QAudioFormat::Int16);
        
        //格式支持判断, 若不支持则选择相近格式
        // if (!input_Device.isFormatSupported(settings))
        // {
        //     printf("format not supported, use the nearest settings!!!\n");
        //     input_Device.nearestFormat(settings);
        // }
        
        //create and set audio input.
        qDebug("[%s][%d]: start recording...", Q_FUNC_INFO, __LINE__);
        
        audioSource = new QAudioSource(input_Device, settings, this);
        input_stream = audioSource->start();

        // audioInput->setBufferSize(1920); //then readDataLength : 8000
        // qDebug() << "The input volume is " << audioInput->volume();
        // audioInput->setVolume(0.3);
        // qDebug() << "The new input volume is " << audioInput->volume();
    }
    
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    //将QIODevice指向输入流和输出流
    input_stream = audioSource->start();
    
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);

    connect(input_stream, &QIODevice::readyRead, [=]()
    {
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

        // char pFName[256] = {0};
        // char* sHome = NULL;
        // sHome = getenv("HOME");
        // if (sHome)
        // {
        //     sprintf(pFName,"%s/Documents/%s",sHome, "capture");
        // }

        // char destPath[200] = { 0 };
        // sprintf(destPath,"%s.pcm", pFName );

        // FILE *pSentPCM= fopen(destPath,"a+b");
        // if (pSentPCM)
        // {
        //     fwrite((short *)buffer, 2, length / 2, pSentPCM);
        //     fclose(pSentPCM);
        // }

    //SDKContext::sharedSDKContext()->sendAudioData(buffer, 1024, sample_rate, b2ndMic);

        FMakeCallClient::sharedCallClient()->send_audio_frame(length, sample_rate, buffer);
    });
}

//local mic
int AudioUnitCapture::refreshInputDevices()
{
    m_audioInputDeviceList.clear();

    //get audio input devices name.
    QVector<QString> aDeviceListI;
    QList<QAudioDevice> audioDeviceListI = QMediaDevices::audioInputs();

    qDebug("find audio inputs device count %d", audioDeviceListI.size());

    foreach (QAudioDevice devInfo, audioDeviceListI)
    {
        if (devInfo.isNull())
        {
            continue;
        }
        QString strName = devInfo.description();
        qDebug("[%s][%d]: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));

        QChar replacementChar(65533);

        if(strName[0] == replacementChar)
        {
            qWarning()<<"invalid device";
            continue;
        }

        // QString audio_input_str = "input";
        // if (nullptr != strName && false == strName.isEmpty())
        // {
        //     if (false == strName.contains(audio_input_str, Qt::CaseInsensitive))
        //     {
        //         qDebug("[%s]555555555555", Q_FUNC_INFO);
        //         qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //         continue;
        //     }
        // }


        // QString audio_device_macOS = "FRMeeting Audio Device";
        // QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        // QString audio_device_poly_weMeet = "WeMeet Audio Device";

        // if (nullptr != strName && false == strName.isEmpty()) {
        //     qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
        //     if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive))
        //     {
        //         qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive))
        //     {
        //         qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive))
        //     {
        //         qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else
        //     {
        //         qDebug("[%s][%d]:  _audioInputDevice.push_back(devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //         //m_audioInputDeviceList.push_back(devInfo);
        //     }

        //     m_audioInputDeviceList.push_back(devInfo);
        // }

        m_audioInputDeviceList.push_back(devInfo);

        if (strName[0] == replacementChar)
            continue;

        bool bFound = false;

        foreach (QString dev, aDeviceListI)
        {
            if (strName == dev)
            {
                bFound = true;
                qDebug("[%s][%d]: bFound mic name : %s", Q_FUNC_INFO, __LINE__, qPrintable(dev));
            }
        }
        if (bFound == true) continue;
        aDeviceListI.push_back(strName);

        //ui->comboBoxInput->addItem(strName);

    }
    return 0;
}

int AudioUnitCapture::refreshOutputDevices()
{
    m_audioOutputDeviceList.clear();
    
    //get audio output devices name.
    QVector<QString> aDeviceListO;
    QList<QAudioDevice> audioDeviceListO = QMediaDevices::audioOutputs();
    foreach (QAudioDevice devInfo, audioDeviceListO) {
        if (devInfo.isNull()) {
            continue;
        }
        QString strName = devInfo.description();
        //qDebug("[%s][%d]: AudioOutput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));


        // if (strName[0] == 65533) {
        //     qWarning()<<"invalid device";
        //     continue;
        // }

        // QString audio_input_str = "output";
        // QString bluetooth_audio_input_str = "sink";

        // if (nullptr != strName && false == strName.isEmpty()) {
        //     if (false == strName.contains(audio_input_str, Qt::CaseInsensitive)
        //             && false == strName.contains(bluetooth_audio_input_str, Qt::CaseInsensitive)) {
        //         //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioInput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //         continue;
        //     }
        // }

        // QString audio_device_macOS = "FRMeeting Audio Device";
        // QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        // QString audio_device_poly_weMeet = "WeMeet Audio Device";

        // if (nullptr != strName && false == strName.isEmpty()) {
        //     //qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
        //     if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive)) {
        //         //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive)) {
        //         //qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive)) {
        //         //qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
        //     } else {
        //         //qDebug("[%s][%d]:  _audioOutputDevice.push_back(devInfo: AudioOutput name : %s)", Q_FUNC_INFO, __LINE__, qPrintable(strName));
                 m_audioOutputDeviceList.push_back(devInfo);
        //     }
        // }
        
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

void AudioUnitCapture::micphoneList(std::vector<QAudioDevice> &micList)
{
    micList.clear();

    if(m_audioInputDeviceList.size() == 0)
    {

    }
    for (std::vector<QAudioDevice>::const_iterator it = m_audioInputDeviceList.begin(); it != m_audioInputDeviceList.end(); ++it) {
        //QAudioDeviceInfo *micDevice = (QAudioDeviceInfo)it;
        QString strName = it->description();
        QString strID = QString(it->id());
    }

    copy(m_audioInputDeviceList.begin(), m_audioInputDeviceList.end(), inserter(micList, micList.begin()));
}

void AudioUnitCapture::speakerList(std::vector<QAudioDevice> &spkList)
{
    spkList.clear();
    copy(m_audioOutputDeviceList.begin(), m_audioOutputDeviceList.end(), inserter(spkList, spkList.begin()));
}

QString AudioUnitCapture::getCurrentMicphoneName() {
    return currentMicName;
}

QString AudioUnitCapture::getCurrentSpeakerName() {
    return currentSpeakerName;
}

QString AudioUnitCapture::getDefaultMicName() {
    QAudioDevice input_Device = QMediaDevices::defaultAudioInput();
    QString strName = QString(input_Device.description());
    qDebug("[%s][%d]: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
    return strName;
}

QString AudioUnitCapture::getDefaultSpeakerName() {
    QAudioDevice output_Device = QMediaDevices::defaultAudioOutput();
    QString strName = QString(output_Device.description());
    qDebug("[%s][%d]: AudioOutput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
    return strName;
}

void AudioUnitCapture::selectMicByName(const QString& id) {
    this->selectMicName = id;
    qDebug("[%s][%d]: AudioInput name, this->selectMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->selectMicName));
    qDebug("[%s][%d]: AudioInput name, this->currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(this->currentMicName));

    //refreshOutputDevices();
    //TEST_DEBUG("select mic device name: %s", id);
    QString old_mic = this->currentMicName;
    this->currentMicName = "";

    for (std::vector<QAudioDevice>::const_iterator it = m_audioInputDeviceList.begin(); it != m_audioInputDeviceList.end(); ++it) {
        //QAudioDeviceInfo *micDevice = (QAudioDeviceInfo)it;
        QString strName = it->description();
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
        return;
    }
}

void AudioUnitCapture::restartMainMic()
{
    qDebug("[%s][%d]: -> call stopAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    stopAudioUnitCapture();

    qDebug("[%s][%d]: -> call configMainSrcShan()", Q_FUNC_INFO, __LINE__);
    configMainSrcShan();

    qDebug("[%s][%d]: -> call startAudioUnitCapture()", Q_FUNC_INFO, __LINE__);
    startAudioUnitCapture();
}

bool AudioUnitCapture::configMainSrcShan() {
    qDebug("[%s][%d]: currentMicName : %s", Q_FUNC_INFO, __LINE__, qPrintable(currentMicName));
    if (nullptr == this->currentMicName || this->currentMicName.isEmpty()) {
        qDebug("[%s][%d]: currentMicName is empty, so -> call getDefaultMicName() ", Q_FUNC_INFO, __LINE__);
        this->currentMicName = getDefaultMicName();
        this->m_selectAudioInputDevice = QMediaDevices::defaultAudioInput();
        return true;
    } else {
        qDebug("[%s][%d]: -> call getMicIDByName(currentMicName : %s)", Q_FUNC_INFO, __LINE__, qPrintable(currentMicName));
        getMicIDByName(this->currentMicName);
    }
    return true;
}

void AudioUnitCapture::getMicIDByName(QString name) {
    bool isFind = false;
    for (std::vector<QAudioDevice>::const_iterator it = m_audioInputDeviceList.begin(); it != m_audioInputDeviceList.end(); ++it) {
        //QAudioDeviceInfo *micDevice = (QAudioDeviceInfo)it;
        QString strName = it->description();
        //qDebug("[%s][%d]: --- mic: AudioInput name : %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));

        if (0 == strName.compare(name, Qt::CaseInsensitive)) {
            //TEST_DEBUG("micphone device is found: %s", name.c_str());
            qDebug("[%s][%d]: micphone device is found, audio input device name: %s", Q_FUNC_INFO, __LINE__, qPrintable(strName));
            //this->currentMicName = name;
            //this->m_current_input_Device = id;
            isFind = true;

            qDebug("[%s][%d]: it->deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(it->description()));
            m_selectAudioInputDevice = *it;
            qDebug("[%s][%d]: isFind = true, set m_selectAudioInputDevice.deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(m_selectAudioInputDevice.description()));
            //*id = *it;
            break;
        }
    }

    if (false == isFind) {
        qDebug("[%s][%d]: getMicIDByName(currentMicName) return false == isFind -> set this->currentMicName = getDefaultMicName()", Q_FUNC_INFO, __LINE__);
        this->currentMicName = getDefaultMicName();
        this->m_selectAudioInputDevice = QMediaDevices::defaultAudioInput();
        qDebug("[%s][%d]: set m_selectAudioInputDevice.deviceName(): %s", Q_FUNC_INFO, __LINE__, qPrintable(m_selectAudioInputDevice.description()));
    }
}


//IAudioCapture implements
void AudioUnitCapture::updateMicrophoneNameList()
{
    std::vector<QAudioDevice> tmp;

    micphoneList(tmp);
}

void AudioUnitCapture::getMicrophoneNameList(QList<QString>& micList)
{
    for(auto i : m_audioInputDeviceList)
    {
        micList.push_back(i.description());
    }
}

void AudioUnitCapture::getSysDefaultMicName(QString& mic)
{
    mic = getDefaultMicName();
}

void AudioUnitCapture::getCurrentMicName(QString& mic)
{
    mic = getCurrentMicphoneName();
}

void AudioUnitCapture::selectMic(const QString& mic)
{
    selectMicByName(mic);
}

void AudioUnitCapture::muteMic(bool mute)
{
    muteMicrophone(mute);
}

bool AudioUnitCapture::isMicMuted()
{
    return isMicMuted();
}

void AudioUnitCapture::setAudioformat(int samplerate, int channelcount, int samplesize)
{
    setaudioformat(samplerate, channelcount, samplesize);
}

void AudioUnitCapture::startCaptureAndSend()
{
    startAudioUnitCapture();
}

void AudioUnitCapture::stopCaptureAndSend()
{
    stopAudioCapture();
}

bool AudioUnitCapture::isCaptureRunning()
{
    return isRunning;
}
