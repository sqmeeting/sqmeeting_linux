#if defined(WIN32)
    #define __PRETTY_FUNCTION__ __FUNCSIG__ 
#endif

#include "AudioUnitSinkChan_macOS.h"
#include <QDebug>
#include <QString>
#include <QDateTime>
#include <iostream>

#include <QMediaDevices>

#include <QtMultimedia>
#include <QAudioFormat>

#include "FMakeCallClient.h"

using namespace std;

QMutex AudioUnitSinkChan_macOS::m_Mutex;
AudioUnitSinkChan_macOS * AudioUnitSinkChan_macOS::shareInstance = nullptr;

AudioUnitSinkChan_macOS* AudioUnitSinkChan_macOS::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new AudioUnitSinkChan_macOS();
        shareInstance->setAudioOutput();

        shareInstance->m_thread = new QThread;

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

void AudioUnitSinkChan_macOS::releaseInstance() {
    qDebug("[%s][%d]: delete shareInstance", __PRETTY_FUNCTION__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

AudioUnitSinkChan_macOS::~AudioUnitSinkChan_macOS() {
    if (nullptr != m_timer) {
        qDebug("[%s][%d]: -> call m_timer->deleteLater()", __FUNCTION__, __LINE__);
        m_timer->deleteLater();
        m_timer = nullptr;
    }
}

void AudioUnitSinkChan_macOS::slotStartAudioSink() {
    qDebug("[%s][%d]: -> call this->setAudioOutput()", __FUNCTION__, __LINE__);
    this->setAudioOutput();
}

void AudioUnitSinkChan_macOS::setAudioOutput() {
    qDebug("[%s][%d]: Enter", __FUNCTION__, __LINE__);

    if (nullptr == audioSinkOutput) {
        //qDebug("[%s][%d]: Enter", __FUNCTION__, __LINE__);
        output_stream = nullptr;

        //for test
        //this->currentSpeakerName = "bluez_sink.BC_F2_92_16_6F_FD.a2dp_sink";

        //output_Device = QAudioDeviceInfo::defaultOutputDevice();
        qDebug("[%s][%d]: AudioOutput currentSpeakerName: %s", __FUNCTION__, __LINE__, qUtf8Printable(this->currentSpeakerName));
        qDebug("[%s][%d]: AudioOutput selectSpeakerName: %s", __FUNCTION__, __LINE__, qUtf8Printable(this->selectSpeakerName));
        getSpeakerIDByName(this->currentSpeakerName);
        output_Device = m_selectAudioOutputDevice;

        this->currentSpeakerName = QString(output_Device.description());
        qDebug("[%s][%d]: AudioInput output_Device = m_selectAudioOutputDevice, deviceName() : %s", __FUNCTION__, __LINE__, qUtf8Printable(currentSpeakerName));

        //[Note]: for Qt6.x
        // QAudioDevice outputDevice = QMediaDevices::defaultAudioOutput();
        // QAudioFormat format = outputDevice.preferredFormat();
        // ChannelConfigStereo is 2, Int16 is 2

        // Format
        // QAudioFormat format;
        // format.setSampleRate(48000);
        // format.setChannelCount(1);
        // format.setSampleFormat(QAudioFormat::Int16);
        // qDebug("sampleRate: %d, channelCount: %d, sampleFormat: %d", format.sampleRate(), format.channelCount(), format.sampleFormat());

        // audioSinkOutput = new QAudioSink(output_Device, format);



        //audioSinkOutput.reset(new QAudioSink(output_Device, format));
        //qDebug("------------------------------");
       // qDebug("The outout_device description is %s",qUtf8Printable(outputDevice.description()));
       // output_stream = audioSinkOutput->start();

        // int size = 4096;
        // char *buf = new char[size];

        // FILE *fp = fopen("/Users/dev/Documents/test.pcm", "rb");
        // while (!feof(fp))
        // {
        //     qDebug("in while");
        //     if (audioSinkOutput->bytesFree() < size)
        //     {
        //         QThread::msleep(1);
        //         continue;
        //     }
        //     int len = fread(buf, 1, size, fp);
        //     qDebug("The len is %d", len);
        //     if (len <= 0)break;
        //     output_stream->write(buf, len);
        // }
        // fclose(fp);
        // delete []buf;
        // buf = 0;

        if (nullptr != output_stream) {
            qDebug("[%s][%d]: -111- nullptr != output_stream", __FUNCTION__, __LINE__);
        } else {
            qDebug("[%s][%d]: -111- nullptr == output_stream", __FUNCTION__, __LINE__);
        }
    }
}

AudioUnitSinkChan_macOS::AudioUnitSinkChan_macOS(QObject *parent)
                        :QObject(parent),
                         m_timer(nullptr),
                         audioSinkOutput(nullptr),
                         output_stream(nullptr),
                         isReceiving(false)
{
    qDebug("[%s][%d] Enter", __PRETTY_FUNCTION__, __LINE__);
    refreshOutputDevices();

}

void AudioUnitSinkChan_macOS::startAudioUnit()
{
    qDebug("[%s][%d] -> call startTimerThread()", __PRETTY_FUNCTION__, __LINE__);
    startTimerThread();
}

void AudioUnitSinkChan_macOS::stopAudioUnit()
{
    qDebug("[%s][%d] -> call stopTimerThread()", __PRETTY_FUNCTION__, __LINE__);
    stopTimerThread();
}

void AudioUnitSinkChan_macOS::startTimerThread() {
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
            qDebug("[%s][%d]: m_timer != nullptr.", __FUNCTION__, __LINE__);

        }
    }
}

void AudioUnitSinkChan_macOS::stopTimerThread()
{
    //qDebug("[%s][%d]: Enter", __FUNCTION__, __LINE__);
    if (false == isReceiving) {
        qDebug("[%s][%d]: Leave. for isReceiving == false, then return.", __FUNCTION__, __LINE__);
        return;
    } else {
        qDebug("[%s][%d] set isReceiving = false, then call this->quit(), this->wait().", __FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        isReceiving = false;

        //        if (nullptr != audioOutput) {
        //            audioOutput->stop();
        //        }

        if (true == m_thread->isRunning()) {
            qDebug("[%s][%d]: -> call m_thread->quit(), then m_thread->wait()", __FUNCTION__, __LINE__);
            m_thread->quit();
            m_thread->wait();
        }
        qDebug("[%s][%d]: -> m_thread->isFinished() : %s", __FUNCTION__, __LINE__, m_thread->isFinished()? "true":"false");
    }
    qDebug("[%s][%d]: Leave", __FUNCTION__, __LINE__);
}

void AudioUnitSinkChan_macOS::slotStopAudioSink() {
    //qDebug("[%s][%d]: -> m_thread->isFinished() : %s", __FUNCTION__, __LINE__, m_thread->isFinished()? "true":"false");

    //    if (nullptr != m_timer) {
    //        delete m_timer;
    //        m_timer = nullptr;
    //    }

    if (nullptr != audioSinkOutput) {
        //qDebug("[%s][%d]: -> call audioSinkOutput->state(): %d", __FUNCTION__, __LINE__, audioSinkOutput->state());
        //qDebug("[%s][%d]: -> call audioSinkOutput->stop()", __FUNCTION__, __LINE__);
        audioSinkOutput->stop();
        audioSinkOutput->deleteLater();
        //delete audioSinkOutput;
        audioSinkOutput = nullptr;
    }
}


void AudioUnitSinkChan_macOS::slotTimeOutHandler() {
    
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

    // char pFName[256] = {0};
    // char* sHome = NULL;
    // sHome = getenv("HOME");
    // if (sHome)
    // {
    //     sprintf(pFName,"%s/Documents/%s",sHome, "test");
    // }

    // char destPath[200] = { 0 };
    // sprintf(destPath,"%s.pcm", pFName );

    // FILE *pSentPCM= fopen(destPath,"a+b");
    // if (pSentPCM)
    // {
    //     fwrite((short *)buffer, 2, length / 2, pSentPCM);
    //     fclose(pSentPCM);
    // }

    // int size = 4096;
    // char *buf = new char[size];

    // FILE *fp = fopen("/Users/dev/Documents/test.pcm", "rb");
    // while (!feof(fp))
    // {
    //     qDebug("in while");
    //     if (audioSinkOutput->bytesFree() < size)
    //     {
    //         QThread::msleep(1);
    //         continue;
    //     }
    //     int len = fread(buf, 1, size, fp);
    //     qDebug("The len is %d", len);
    //     if (len <= 0)break;
    //     output_stream->write(buf, len);
    // }
    // fclose(fp);
    // delete []buf;
    // buf = 0;

    if(nullptr == output_stream)
    {
        QAudioFormat format;
        format.setSampleRate(48000);
        format.setChannelCount(1);
        format.setSampleFormat(QAudioFormat::Int16);
        qDebug("sampleRate: %d, channelCount: %d, sampleFormat: %d", format.sampleRate(), format.channelCount(), format.sampleFormat());

        audioSinkOutput = new QAudioSink(output_Device, format);

        output_stream = audioSinkOutput->start();

    }
        
    if (nullptr != output_stream)
    {
        //qDebug("[%s][%d]: -> output_stream->write(", __PRETTY_FUNCTION__, __LINE__);
        output_stream->write((char *)buffer, FRAME_LEN_1920);
    }
}

void AudioUnitSinkChan_macOS::getAudioData(void * buffer,
                                     unsigned int length,
                                     unsigned int sample_rate)
{
    FMakeCallClient::sharedCallClient()->receive_audio_frame(buffer, length, sample_rate);
}

int AudioUnitSinkChan_macOS::refreshOutputDevices() {
    m_audioOutputDeviceList.clear();

    //get audio output devices name.
    QVector<QString> aDeviceListO;
    QList<QAudioDevice> audioDeviceListO = QMediaDevices::audioOutputs();
    foreach (QAudioDevice devInfo, audioDeviceListO) {
        if (devInfo.isNull()) {
            continue;
        }
        QString strName = devInfo.description();
        //qDebug("[%s][%d]: AudioOutput name : %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));

        QString audio_device_macOS = "FRMeeting Audio Device";
        QString audio_device_microsoft_teams = "Microsoft Teams Audio";
        QString audio_device_poly_weMeet = "WeMeet Audio Device";

        if (nullptr != strName && false == strName.isEmpty()) {
            //qDebug("[%s][%d]: Enter", __FUNCTION__, __LINE__);
            if (0 == strName.compare(audio_device_macOS, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_macOS (devInfo: AudioOutput name : %s)", __FUNCTION__, __LINE__, qUtf8Printable(strName));
            } else if (0 == strName.compare(audio_device_microsoft_teams, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_microsoft_teams (devInfo: AudioOutput name : %s)", __FUNCTION__, __LINE__, qUtf8Printable(strName));
            } else if (0 == strName.compare(audio_device_poly_weMeet, Qt::CaseInsensitive)) {
                //qDebug("[%s][%d]: === ::: is audio_device_poly_weMeet (devInfo: AudioOutput name : %s)", __FUNCTION__, __LINE__, qUtf8Printable(strName));
            } else {
                qDebug("[%s][%d]:  _audioOutputDevice.push_back(devInfo: AudioOutput name : %s)", __FUNCTION__, __LINE__, qUtf8Printable(strName));
                m_audioOutputDeviceList.push_back(devInfo);
            }
        }

        /*
    if (strName[0] == 65533) continue;
    bool bFound = false;
    foreach (QString dev, aDeviceListO) {
        if (strName == dev) {
            bFound = true;
            qDebug("[%s][%d]: bFound speaker name : %s", __FUNCTION__, __LINE__, qUtf8Printable(dev));
        }
    }
    if (bFound == true) continue;
    aDeviceListO.push_back(strName);
    //ui->comboBoxOutput->addItem(strName);
*/
    }
    qDebug("[%s][%d]: Leave", __FUNCTION__, __LINE__);
    return 0;
}

void AudioUnitSinkChan_macOS::selectSpeaker(QString id) {
    this->selectSpeakerName = id;
    qDebug("[%s][%d]: AudioOutput name, this->selectSpeakerName : %s", __FUNCTION__, __LINE__, qUtf8Printable(this->selectSpeakerName));
    qDebug("[%s][%d]: AudioOutput name, this->currentSpeakerName : %s", __FUNCTION__, __LINE__, qUtf8Printable(this->currentSpeakerName));

    //refreshOutputDevices();
    //TEST_DEBUG("select speaker device name: %s", id);
    QString old_speker = this->currentSpeakerName;
    this->currentSpeakerName = "";

    for (std::vector<QAudioDevice>::const_iterator it = m_audioOutputDeviceList.begin(); it != m_audioOutputDeviceList.end(); ++it) {
        QString strName = it->description();
        qDebug("[%s][%d]: --- speaker: AudioOutput name : %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));

        int result = strName.compare(this->selectSpeakerName, Qt::CaseInsensitive);
        qDebug("[%s][%d]: isReceiving: %s, compare result: %d, strName: %s, selectSpeakerName: %s, currentSpeakerName: %s", __FUNCTION__, __LINE__, isReceiving?"true":"false", result, qUtf8Printable(strName), qUtf8Printable(selectSpeakerName), qUtf8Printable(currentSpeakerName));
        if (0 == result) {
            qDebug("[%s][%d]: --- speaker: AudioOutput name set this->currentSpeakerName = this->selectSpeakerName: %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));
            this->currentSpeakerName = this->selectSpeakerName;
            break;
        }
    }

    int result = old_speker.compare(this->selectSpeakerName, Qt::CaseInsensitive);
    qDebug("[%s][%d]: isReceiving: %s, compare result: %d, old_speker: %s, selectSpeakerName: %s, currentSpeakerName: %s", __FUNCTION__, __LINE__, isReceiving?"true":"false", result, qUtf8Printable(old_speker), qUtf8Printable(selectSpeakerName), qUtf8Printable(currentSpeakerName));
    if ((0 != result) && this->isReceiving) {
        qDebug("[%s][%d]: speaker changed from %s to %s", __FUNCTION__, __LINE__, qUtf8Printable(old_speker), qUtf8Printable(id));
        restartMainSpeaker();
    }
}

void AudioUnitSinkChan_macOS::restartMainSpeaker() {
    qDebug("[%s][%d]: -> call stopAudioUnit()", __FUNCTION__, __LINE__);
    stopAudioUnit();

    qDebug("[%s][%d]: -> call configMainSrcShan()", __FUNCTION__, __LINE__);
    configMainSrcShan();

    //qDebug("[%s][%d]: -> call setSpeaker(this->selectSpeakerName: %s)", __FUNCTION__, __LINE__, qUtf8Printable(this->selectSpeakerName));
    //setSpeaker(this->selectSpeakerName);

    qDebug("[%s][%d]: -> call startAudioUnit(), with this->selectSpeakerName: %s)", __FUNCTION__, __LINE__, qUtf8Printable(this->selectSpeakerName));
    startAudioUnit();
}

bool AudioUnitSinkChan_macOS::configMainSrcShan() {
    qDebug("[%s][%d]: currentSpeakerName : %s", __FUNCTION__, __LINE__, qUtf8Printable(currentSpeakerName));
    if (nullptr == this->selectSpeakerName || this->selectSpeakerName.isEmpty()) {
        qDebug("[%s][%d]: currentSpeakerName is empty, so -> call getDefaultSpeakerName() ", __FUNCTION__, __LINE__);
        this->selectSpeakerName = getDefaultSpeakerName();
        this->currentSpeakerName = getDefaultSpeakerName();
        this->m_selectAudioOutputDevice = QMediaDevices::defaultAudioOutput();
        return true;
    } else {
        qDebug("[%s][%d]: -> call getSpeakerIDByName(currentSpeakerName : %s)", __FUNCTION__, __LINE__, qUtf8Printable(currentSpeakerName));
        getSpeakerIDByName(this->selectSpeakerName);
    }
    qDebug("[%s][%d]: -> set default devices for: currentSpeakerName: %s, selectSpeakerName: %s", __FUNCTION__, __LINE__, qUtf8Printable(currentSpeakerName), qUtf8Printable(selectSpeakerName));
    return true;
}

void AudioUnitSinkChan_macOS::getSpeakerIDByName(QString name) {
    qDebug("[%s][%d]: Enter", __FUNCTION__, __LINE__);

    bool isFind = false;
    for (std::vector<QAudioDevice>::const_iterator it = m_audioOutputDeviceList.begin(); it != m_audioOutputDeviceList.end(); ++it) {
        QString strName = it->description();
        //qDebug("[%s][%d]: --- speaker: AudioOutput name : %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));

        if (0 == strName.compare(name, Qt::CaseInsensitive)) {
            //TEST_DEBUG("speaker device is found: %s", name.c_str());
            qDebug("[%s][%d]: speaker device is found, audio output device name: %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));
            isFind = true;

            qDebug("[%s][%d]: it->deviceName(): %s", __FUNCTION__, __LINE__, qUtf8Printable(it->description()));
            m_selectAudioOutputDevice = *it;
            qDebug("[%s][%d]: isFind = true, set m_selectAudioOutputDevice.deviceName(): %s", __FUNCTION__, __LINE__, qUtf8Printable(m_selectAudioOutputDevice.description()));
            break;
        }
    }

    if (false == isFind) {
        qDebug("[%s][%d]: getSpeakerIDByName(currentSpeakerName) return false == isFind -> set this->currentSpeakerName = getDefaultSpeakerName()", __FUNCTION__, __LINE__);
        this->currentSpeakerName = getDefaultSpeakerName();
        this->m_selectAudioOutputDevice = QMediaDevices::defaultAudioOutput();
        qDebug("[%s][%d]: set m_selectAudioOutputDevice.deviceName(): %s", __FUNCTION__, __LINE__, qUtf8Printable(m_selectAudioOutputDevice.description()));
    }

    qDebug("[%s][%d]: Leave", __FUNCTION__, __LINE__);
}

QString AudioUnitSinkChan_macOS::getDefaultSpeakerName() {
    QAudioDevice output_Device = QMediaDevices::defaultAudioOutput();

    QString strName = QString(output_Device.description());
    qDebug("[%s][%d]: AudioOutput name : %s", __FUNCTION__, __LINE__, qUtf8Printable(strName));
    return strName;
}

//IAudioSink implements
void AudioUnitSinkChan_macOS::updateSpeakerNameList()
{
    refreshOutputDevices();
}

void AudioUnitSinkChan_macOS::getSpeakerNameList(QList<QString>& speakerList)
{
    for(auto d : m_audioOutputDeviceList)
    {
        speakerList.push_back(d.description());
    }
}

void AudioUnitSinkChan_macOS::getSysDefaultSpeakerName(QString& speaker)
{
    refreshOutputDevices();
    for(auto d : m_audioOutputDeviceList)
    {
        if(d.isDefault())
        {
            speaker = d.description();
            return;
        }
    }
}

void AudioUnitSinkChan_macOS::getCurrentSpeakerName(QString& speaker)
{
    refreshOutputDevices();
    speaker = selectSpeakerName;
}

void AudioUnitSinkChan_macOS::selectAudioSink(const QString& speaker)
{
    selectSpeaker(speaker);
}

void AudioUnitSinkChan_macOS::setAudioformat(int samplerate, int channelcount, int samplesize)
{
    
}

void AudioUnitSinkChan_macOS::start()
{
    startAudioUnit();
}

void AudioUnitSinkChan_macOS::stop()
{
    stopAudioUnit();
}

bool AudioUnitSinkChan_macOS::getAudioOutputData(void * buffer,
                    unsigned int length,
                    unsigned int sample_rate)
{
    getAudioData(buffer, length, sample_rate);
    return true;
}

bool AudioUnitSinkChan_macOS::isReceivingAudio()
{
    return isReceiving;
}
