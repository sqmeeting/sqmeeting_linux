#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
#include<windows.h>
#endif


#include "FrtcMediaStaticsInstance.h"
#include "FMakeCallClient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>
#include <QDebug>

QMutex FrtcMediaStaticsInstance::m_Mutex;
FrtcMediaStaticsInstance * FrtcMediaStaticsInstance::sharedMediaStaticsInstance = nullptr;

FrtcMediaStaticsInstance * FrtcMediaStaticsInstance::sharedInstance()
{
    if (nullptr == sharedMediaStaticsInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        sharedMediaStaticsInstance = new FrtcMediaStaticsInstance();
    }
    return sharedMediaStaticsInstance;
}

void FrtcMediaStaticsInstance::releaseInstance()
{
    if (nullptr != sharedMediaStaticsInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete sharedMediaStaticsInstance;
        sharedMediaStaticsInstance = nullptr;
    }
}

FrtcMediaStaticsInstance::FrtcMediaStaticsInstance(QObject *parent) :
    QObject(parent),
    m_thread(nullptr),
    m_timer(nullptr) {

    this->m_thread = new QThread();

    this->m_timer = new QTimer;
    this->m_timer->setTimerType(Qt::PreciseTimer);
    this->m_timer->setInterval(5000);//5000ms
    this->m_timer->moveToThread(this->m_thread);

    QObject::connect(this->m_thread, SIGNAL(started()), this->m_timer, SLOT(start()));
    QObject::connect(this->m_thread, SIGNAL(finished()), this->m_timer, SLOT(stop()));

    QObject::connect(this->m_timer, SIGNAL(timeout()), this, SLOT(slotTimeGetMediaStatics()), Qt::DirectConnection);
}

FrtcMediaStaticsInstance::~FrtcMediaStaticsInstance() {
    qDebug("[%s][%d]: this: %p", Q_FUNC_INFO, __LINE__, this);
}

//开始获取统计信息
void FrtcMediaStaticsInstance::startGetMediaStatics()
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
    if(m_thread == nullptr)
    {
        m_thread = new QThread();
        this->m_timer = new QTimer();  
        this->m_timer->setTimerType(Qt::PreciseTimer);
        this->m_timer->setInterval(5000);//5000ms
        QObject::connect(this->m_timer, SIGNAL(timeout()), this, SLOT(slotTimeGetMediaStatics()), Qt::DirectConnection);
        m_timer->moveToThread(m_thread);

        QObject::connect(this->m_thread, SIGNAL(started()), this->m_timer, SLOT(start()));
        QObject::connect(this->m_thread, SIGNAL(finished()), this->m_timer, SLOT(stop()));
    }
    m_thread->start();
}

//结束获取统计信息
void FrtcMediaStaticsInstance::stopGetMediaStatics()
{
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
    if(m_thread != nullptr && m_thread->isRunning())
    {
        m_thread->requestInterruption();
        m_thread->quit();
        m_thread = nullptr;
        m_timer->deleteLater();
    }
}

void FrtcMediaStaticsInstance::slotTimeGetMediaStatics()
{
    if(m_thread->isInterruptionRequested())
        return;
    getMediaStatics();
}

void FrtcMediaStaticsInstance::getMediaStatics()
{
    if(m_thread->isInterruptionRequested())
        return;
    QString str = FMakeCallClient::sharedCallClient()->get_statics_info();
    if(m_thread->isInterruptionRequested())
        return;
    QVariantMap staticsModel = staticsInfoJosn(str);
    if(m_thread->isInterruptionRequested())
        return;
    QVariantMap mediaStaticsModel = getSignalStatus(staticsModel);
    if(m_thread->isInterruptionRequested())
        return;
    emit cppSendMsgToQMLStatisticsInfo(staticsModel);
    emit cppSendMsgToQMLMediaStatisticsInfo(mediaStaticsModel);
}

QVariantMap FrtcMediaStaticsInstance::staticsInfoJosn(const QString jsonString)
{
    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(jsonString.toUtf8(),&jsonError);

    QVariantMap result;

    if (!document.isNull() && (jsonError.error == QJsonParseError::NoError)) {
        if (document.isObject()) {
            QJsonObject object = document.object();

            //signal_statistics
            if (object.contains("signalStatistics")) {
                QVariantMap  signalInfo;
                QJsonValue signalValue = object["signalStatistics"];
                if (signalValue.isObject()) {
                    QJsonObject signalModel = signalValue.toObject();

                    if (signalModel.contains("callRate")) {
                        signalInfo["call_rate"] = signalModel["callRate"].toInt();
                    }
                }
                result["signal_statistics"] = signalInfo;
            }

            //media_statistics
            if (object.contains("mediaStatistics")) {
                QJsonValue mediaValue = object["mediaStatistics"];
                if (mediaValue.isObject()) {
                    QJsonObject mediaObject = object["mediaStatistics"].toObject();
                    QVariantMap mediaInfo;

                    //arx
                    QJsonValue arxValue = mediaObject["apr"];
                    if (arxValue.isArray()) {
                        QVariantList arxList = this->mediaInfoList(arxValue.toArray());
                        mediaInfo["apr"] = arxList;
                    }

                    //atx
                    QJsonValue atxValue = mediaObject["aps"];
                    if (atxValue.isArray()) {
                        QVariantList atxList = this->mediaInfoList(atxValue.toArray());
                        mediaInfo["aps"] = atxList;
                    }

                    //cvrx
                    QJsonValue cvrxValue = mediaObject["vcr"];
                    if (cvrxValue.isArray()) {
                        QVariantList cvrxList = this->mediaInfoList(cvrxValue.toArray());
                        mediaInfo["vcr"] = cvrxList;
                    }

                    //cvtx
                    QJsonValue cvtxValue = mediaObject["vcs"];
                    if (cvtxValue.isArray()) {
                        QVariantList cvtxList = this->mediaInfoList(cvtxValue.toArray());
                        mediaInfo["vcs"] = cvtxList;
                    }

                    //pvrx
                    QJsonValue pvrxValue = mediaObject["vpr"];
                    if (pvrxValue.isArray()) {
                        QVariantList pvrxList = this->mediaInfoList(pvrxValue.toArray());
                        mediaInfo["vpr"] = pvrxList;
                    }

                    //pvtx
                    QJsonValue pvtxValue = mediaObject["vps"];
                    if (pvtxValue.isArray()) {
                        QVariantList pvtxList = this->mediaInfoList(pvtxValue.toArray());
                        mediaInfo["vps"] = pvtxList;
                    }

                    result["media_statistics"] = mediaInfo;
                }
            }
        }
    }
    return result;
}

QVariantList FrtcMediaStaticsInstance::mediaInfoList(const QJsonArray jsonArray)
{
    QVariantList medioList;
    for (int i = 0 ; i < jsonArray.size(); i ++) {

        QJsonObject arxObj = jsonArray[i].toObject();
        QVariantMap arxMap;

        if (arxObj.contains("mediaType")) {
            QJsonValue pipeName = arxObj["mediaType"];
            arxMap["mediaType"] = pipeName.isNull() ? "" : pipeName.toString();
        }

        if (arxObj.contains("participantName")) {
            QJsonValue participantName = arxObj["participantName"];
            arxMap["participantName"] = participantName.isNull() ? "" :participantName.toString();
        }

        if (arxObj.contains("resolution")) {
            QJsonValue resolution = arxObj["resolution"];
            arxMap["resolution"] = resolution.isNull() ? "" : resolution.toString();
        }

        if (arxObj.contains("csrc")) {
            QJsonValue csrc = arxObj["csrc"];
            if (csrc.isDouble()) {
                arxMap["csrc"] = csrc.toInt();
            }
        }

        if (arxObj.contains("frameRate")) {
            QJsonValue frameRate = arxObj["frameRate"];
            if (frameRate.isDouble()) {
                arxMap["frameRate"] = frameRate.toInt();
            }
        }


        if(arxObj.contains("jitter")) {
            QJsonValue jitter = arxObj["jitter"];
            if (jitter.isDouble()) {
                arxMap["jitter"] = jitter.toInt();
            }
        }

        if (arxObj.contains("logicPacketLoss")) {
            QJsonValue logicPacketLost = arxObj["logicPacketLoss"];
            if (logicPacketLost.isDouble()) {
                arxMap["logicPacketLost"] = logicPacketLost.toInt();
            }
        }

        if (arxObj.contains("logicPacketLossRate")) {
            QJsonValue logicPacketLostRate = arxObj["logicPacketLossRate"];
            if (logicPacketLostRate.isDouble()) {
                arxMap["logicPacketLostRate"] = logicPacketLostRate.toInt();
            }
        }

        if (arxObj.contains("packageLoss")) {
            QJsonValue packageLost = arxObj["packageLoss"];
            if (packageLost.isDouble()) {
                arxMap["packageLost"] = packageLost.toInt();
            }
        }

        if (arxObj.contains("packageLossRate")) {
            QJsonValue packageLostRate = arxObj["packageLossRate"];
            if (packageLostRate.isDouble()) {
                arxMap["packageLostRate"] = packageLostRate.toInt();
            }
        }

        if (arxObj.contains("roundTripTime")) {
            QJsonValue roundTripTime = arxObj["roundTripTime"];
            if (roundTripTime.isDouble()) {
                arxMap["roundTripTime"] = roundTripTime.toInt();
            }
        }

        if (arxObj.contains("rtpActualBitRate")) {
            QJsonValue rtp_actualBitRate = arxObj["rtpActualBitRate"];
            if (rtp_actualBitRate.isDouble()) {
                arxMap["rtp_actualBitRate"] = rtp_actualBitRate.toInt();
            }
        }

        if (arxObj.contains("rtpLogicBitRate")) {
            QJsonValue rtp_settingBitRate = arxObj["rtpLogicBitRate"];
            if (rtp_settingBitRate.isDouble()) {
                arxMap["rtp_settingBitRate"] = rtp_settingBitRate.toInt();
            }
        }

        if (arxObj.contains("ssrc")) {
            QJsonValue ssrc = arxObj["ssrc"];
            if (ssrc.isDouble()) {
                arxMap["ssrc"] = ssrc.toInt();
            }
        }

        if (arxObj.contains("isAlive")) {
            QJsonValue isAlive = arxObj["isAlive"];
            if (isAlive.isBool()) {
                arxMap["isAlive"] = isAlive.toBool();
            }
        }

        medioList.append(arxMap);
    }

    return medioList;
}

QVariantMap FrtcMediaStaticsInstance::getSignalStatus(const QVariantMap modelMap)
{
    int patxLoss = 0;
    int parxLoss = 0;
    int pvtxLoss = 0;
    int pvrxLoss = 0;
    int cvrxLoss = 0;
    int cvtxLoss = 0;

    int patxBitrate = 0;
    int parxBitrate = 0;
    int pvtxBitrate = 0;
    int pvrxBitrate = 0;
    int cvrxBitrate = 0;
    int cvtxBitrate = 0;

    int patxRTT = 0;
    int pvtxRTT = 0;
    int cvtxRTT = 0;

    int upRate = 0;
    int downRate = 0;


    QVariantMap meidaInfo = modelMap.value("media_statistics").toMap();

    parxLoss = this->getChannelAvgLostRate(meidaInfo.value("apr").toList());
    patxLoss = this->getChannelAvgLostRate(meidaInfo.value("aps").toList());
    pvrxLoss = this->getChannelAvgLostRate(meidaInfo.value("vpr").toList());
    pvtxLoss = this->getChannelAvgLostRate(meidaInfo.value("vps").toList());
    cvrxLoss = this->getChannelAvgLostRate(meidaInfo.value("vcr").toList());
    cvtxLoss = this->getChannelAvgLostRate(meidaInfo.value("vcs").toList());

    patxBitrate = this->getChanelBitRate(meidaInfo.value("aps").toList());
    parxBitrate = this->getChanelBitRate(meidaInfo.value("apr").toList());
    pvtxBitrate = this->getChanelBitRate(meidaInfo.value("vps").toList());
    pvrxBitrate = this->getChanelBitRate(meidaInfo.value("vpr").toList());
    cvrxBitrate = this->getChanelBitRate(meidaInfo.value("vcr").toList());
    cvtxBitrate = this->getChanelBitRate(meidaInfo.value("vcs").toList());

    patxRTT = this->getChanelRTT(meidaInfo.value("aps").toList());
    pvtxRTT = this->getChanelRTT(meidaInfo.value("vps").toList());
    cvtxRTT = this->getChanelRTT(meidaInfo.value("vcs").toList());

    QVariantMap signalInfo = modelMap.value("signal_statistics").toMap();

    CallRate callRate = this->getCallRate(signalInfo.value("call_rate").toInt());
    upRate =   callRate.upRate;
    downRate = callRate.downRate;

    QVariantMap mediaStaticsModel;

    mediaStaticsModel["rttTime"]  =  patxRTT + pvtxRTT + cvtxRTT;
    mediaStaticsModel["upRate"]   = upRate;
    mediaStaticsModel["downRate"] = downRate;

    mediaStaticsModel["audioUpRate"]     = patxBitrate;
    mediaStaticsModel["audioUpPackLost"] = patxLoss;

    mediaStaticsModel["audioDownRate"]     = parxBitrate;
    mediaStaticsModel["audioDownPackLost"] = parxLoss;

    mediaStaticsModel["videoUpRate"]     = pvtxBitrate;
    mediaStaticsModel["videoUpPackLost"] = pvtxLoss;

    mediaStaticsModel["videoDownRate"]     = pvrxBitrate;
    mediaStaticsModel["videoDownPackLost"] = pvrxLoss;

    mediaStaticsModel["contentUpRate"]     = cvtxBitrate;
    mediaStaticsModel["contentUpPackLost"] = cvtxLoss;

    mediaStaticsModel["contentdownRate"]     = cvrxBitrate;
    mediaStaticsModel["contentdownPackLost"] = cvrxLoss;

    return mediaStaticsModel;
}

int  FrtcMediaStaticsInstance::getChannelAvgLostRate(const QVariantList mediaArray)
{
    QVariantMap stat;
    int size = mediaArray.size();
    int count = 0;
    int avgLostRate = 0;
    if (size > 0) {
        for (int i = 0 ; i < size; i ++) {
            stat = mediaArray[i].toMap();
            count +=  stat.value("packageLostRate").toInt();
        }
        avgLostRate = count / size;
    }
    return avgLostRate;
}

int FrtcMediaStaticsInstance::getChanelBitRate(const QVariantList mediaArray)
{
    QVariantMap stat;
    int size = mediaArray.size();
    int count = 0;

    if (size > 0) {
        for (int i = 0 ; i < size; i ++) {
            stat = mediaArray[i].toMap();
            count +=  stat.value("rtp_actualBitRate").toInt();
        }
    }
    return count;
}

int FrtcMediaStaticsInstance::getChanelRTT(const QVariantList mediaArray)
{
    QVariantMap stat;
    int size = mediaArray.size();
    int count = 0;

    if (size > 0) {
        for (int i = 0 ; i < size; i ++) {
            stat = mediaArray[i].toMap();
            count +=  stat.value("roundTripTime").toInt();
        }
    }
    return count;
}

CallRate FrtcMediaStaticsInstance::getCallRate(const int callRate)
{
    CallRate rate;
    int rates = callRate;
    if (rates > 100000) {
        rate.upRate = rates / 100000;
        rate.downRate = rates % 100000;
    } else {
        rate.upRate = rates;
        rate.downRate = 0;
    }
    return rate;
}
