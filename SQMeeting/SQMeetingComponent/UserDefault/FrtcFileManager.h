#ifndef FRTCFILEMANAGER_H
#define FRTCFILEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

class FrtcFileManager : public QObject {
    Q_OBJECT

public:
    explicit FrtcFileManager(QObject *parent = nullptr);

    Q_INVOKABLE void saveMeetingData(const QVariantMap &dictionary);
    Q_INVOKABLE QVariantList loadMeetingData();
    Q_INVOKABLE void deleteDataByMeetingStartTime(const QString &meetingStartTime, bool deleteAll = false);

private:
    void ensureFileExists();
    QString getFilePath() const;
};

#endif // FRTCFILEMANAGER_H
