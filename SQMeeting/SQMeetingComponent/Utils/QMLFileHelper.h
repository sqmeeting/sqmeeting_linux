#pragma once

#include <QObject>
#include <QMutex>

class QMLFileHelper : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(QMLFileHelper)

private:
    static QMutex m_Mutex;
    static QMLFileHelper *shareInstance;
    explicit QMLFileHelper(QObject *parent = nullptr);

public:
    static QMLFileHelper* getInstance()
    {
        if (nullptr == shareInstance) 
        {
            QMutexLocker mutexLocker(&m_Mutex);
            shareInstance = new QMLFileHelper();
        }
        return shareInstance;
    };

    ~QMLFileHelper();
    void releaseInstance()
    {
        if (nullptr != shareInstance) {
            QMutexLocker mutexLocker(&m_Mutex);
            delete shareInstance;
            shareInstance = nullptr;
        }
    };

public:
    Q_INVOKABLE QString readTextFile(const QString & file_url);
    
};