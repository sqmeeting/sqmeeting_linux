#ifndef FRTCMEDIASTATICSINSTANCE_H
#define FRTCMEDIASTATICSINSTANCE_H

#include <QObject>
#include <QThread>
#include <QTimer>
#include <QMutex>
#include <QVariantMap>

typedef struct {
    int upRate;
    int downRate;
} CallRate;

class FrtcMediaStaticsInstance : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FrtcMediaStaticsInstance);

public:
    static QMutex m_Mutex;
    static FrtcMediaStaticsInstance *sharedMediaStaticsInstance;

public:
    static FrtcMediaStaticsInstance* sharedInstance();
    static void releaseInstance();
    explicit FrtcMediaStaticsInstance(QObject *parent = nullptr);
    ~FrtcMediaStaticsInstance();

public:
    void startGetMediaStatics();
    void stopGetMediaStatics();

signals:
    void cppSendMsgToQMLStatisticsInfo(QVariantMap);
    void cppSendMsgToQMLMediaStatisticsInfo(QVariantMap);

public slots:
    void slotTimeGetMediaStatics(); //for timer

private:
    QThread *m_thread = nullptr;
    QTimer  *m_timer = nullptr;

    void getMediaStatics();
    QVariantMap parseJosn(const QString jsonString);
    QVariantMap staticsInfoJosn(const QString jsonString);
    QVariantMap getSignalStatus(const QVariantMap model);

    QVariantList mediaInfoList(const QJsonArray jsonArray);
    int getChannelAvgLostRate(const QVariantList mediaArray);
    int getChanelBitRate(const QVariantList mediaArray);
    int getChanelRTT(const QVariantList mediaArray);
    CallRate getCallRate(const int callRate);
};

#endif // FRTCMEDIASTATICSINSTANCE_H
