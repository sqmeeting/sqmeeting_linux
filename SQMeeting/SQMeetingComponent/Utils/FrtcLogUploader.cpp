#include "FrtcLogUploader.h"
#include "frtc_sdk_api.h"

#include <QJsonObject>
#include <QJsonDocument>
#include <QSysInfo>
#include <QFile>

#include "LogHelper.h"

QMutex LogUploader::m_Mutex;
LogUploader * LogUploader::shareInstance = nullptr;

LogUploader::LogUploader(QObject *parent)   :   QObject(parent)
    ,uploadQueryTimer(nullptr)
    ,tractionId(0)
{

}
LogUploader::~LogUploader(){}

uint64_t LogUploader::startUploadLogFiles(const QString & meta)
{
    QJsonObject metaObj;
    metaObj.insert("version", "3.4.1");
    metaObj.insert("platform", "linux");/*QSysInfo::prettyProductName().replace(' ', '-')*/
    metaObj.insert("os", QSysInfo::prettyProductName());
    metaObj.insert("device", getDeviceManufacturerInfo());
    metaObj.insert("issue", meta);

    DebugLog("log upload meta %s", QJsonDocument(metaObj).toJson().toStdString().c_str());
    this->tractionId = frtc_upload_log(QJsonDocument(metaObj).toJson().toStdString().c_str(), "sqmeeting_log.log", 4);
    if(uploadQueryTimer != nullptr)
    {
        if(uploadQueryTimer->isActive())
        {
            uploadQueryTimer->disconnect();
            uploadQueryTimer->stop();
        }
        uploadQueryTimer->deleteLater();
        uploadQueryTimer = nullptr;
    }
    uploadQueryTimer = new QTimer(this);
    QObject::connect(uploadQueryTimer, &QTimer::timeout,[=]()
    {
        queryUploadStatus();
    });
    uploadQueryTimer->start(1000);
    return tractionId;
}

void LogUploader::queryUploadStatus()
{
    const char* pStatus = frtc_log_upload_status_query(tractionId);
    QString statusStr = QString::fromUtf8(pStatus);
    DebugLog("log upload status string %s", pStatus);
    QJsonParseError jsonError;
    QJsonDocument document = QJsonDocument::fromJson(statusStr.toUtf8(),&jsonError);
    if(jsonError.error == QJsonParseError::ParseError::NoError)
    {
        int nStatus = document.object()["progress"].toInt();
        emit reportLogUploadProgress(nStatus);
        if(nStatus >= 100)
        {
            DebugLog("log upload completed");
            stopUploadTimer();
            emit logUploadCompleted();
        }
        else if(nStatus < 0)
        {
            DebugLog("log upload errored %d", nStatus);
            stopUploadTimer();
            tractionId = 0;
            emit logUploadCompleted();
        }
    }

    return;
}

void LogUploader::stopUploadTimer()
{
    if(uploadQueryTimer != nullptr)
    {
        uploadQueryTimer->disconnect();
        uploadQueryTimer->stop();
        uploadQueryTimer->deleteLater();
        uploadQueryTimer = nullptr;
    }
}

void LogUploader::cancelUploadLog()
{
    stopUploadTimer();
    frtc_cancel_log_upload(this->tractionId);
}


static QStringList manufacturerFileList { "/sys/class/dmi/id/chassis_vendor", "/sys/class/dmi/id/product_family", "/sys/class/dmi/id/product_name", "/sys/class/dmi/id/product_sku", "/sys/class/dmi/id/product_version"  };
QString LogUploader::getDeviceManufacturerInfo()
{
    QString ret = "";
    for(auto f : manufacturerFileList)
    {
        if(QFile::exists(f))
        {
            ret.append(readFileOneLine(f));
            ret.append(" ");
        }
    }
    return ret.trimmed();
}

QString LogUploader::readFileOneLine(const QString & fileName)
{
    QFile file(fileName);  
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {  
        QTextStream in(&file);  
        QString text = in.readLine().trimmed();  
        file.close();  
        return text;  
    } else {  
        return "";  
    }  
}
