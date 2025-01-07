#pragma once

#include <QObject>
#include <QMutex>
#include <QTimer>


class LogUploader: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(LogUploader)

private:
    static QMutex m_Mutex;
    static LogUploader *shareInstance;
    explicit LogUploader(QObject *parent = nullptr);
public:
    static LogUploader* getInstance()
    {
        if (nullptr == shareInstance) 
        {
            QMutexLocker mutexLocker(&m_Mutex);
            shareInstance = new LogUploader();
        }
        return shareInstance;
    };

    ~LogUploader();
    void releaseInstance()
    {
        if (nullptr != shareInstance) {
            QMutexLocker mutexLocker(&m_Mutex);
            delete shareInstance;
            shareInstance = nullptr;
        }
    };

public:
    Q_INVOKABLE uint64_t startUploadLogFiles(const QString & meta);
    Q_INVOKABLE void cancelUploadLog();

signals:
    void logUploadCompleted();
    void reportLogUploadProgress(int progress);

private:
    uint64_t tractionId;
    QTimer* uploadQueryTimer;
    void queryUploadStatus();
    void stopUploadTimer();

    QString getDeviceManufacturerInfo();
    QString readFileOneLine(const QString & fileName);
};