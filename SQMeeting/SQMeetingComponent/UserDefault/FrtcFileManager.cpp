#include "FrtcFileManager.h"
#include "SDKUserDefault.h"

FrtcFileManager::FrtcFileManager(QObject *parent) : QObject(parent) {
    ensureFileExists();
}

QString FrtcFileManager::getFilePath() const {
    QString userId = SDKUserDefault::getInstance()->getUserInfo()["user_id"].toString();
    return QString("%1/FrtcMeeting_%2.json").arg(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)).arg(userId);;
}

void FrtcFileManager::ensureFileExists() {
    QString filePath = getFilePath();
    QFile file(filePath);
    if (!file.exists()) {
        QDir().mkpath(QFileInfo(filePath).absolutePath());
        if (file.open(QIODevice::WriteOnly)) {
            file.write("[]"); // Initialize with an empty JSON array
            file.close();
        }
    }
}

void FrtcFileManager::saveMeetingData(const QVariantMap &dictionary) {
    QString filePath = getFilePath();
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open file for reading:" << file.errorString();
        return;
    }

    QByteArray fileData = file.readAll();
    file.close();

    QJsonArray jsonArray = QJsonDocument::fromJson(fileData).array();

    QString meetingStartTime = dictionary.value("meetingStartTime").toString();
    for (const QJsonValue &value : jsonArray) {
        QJsonObject obj = value.toObject();
        if (obj.value("meetingStartTime").toString() == meetingStartTime) {
            return;
        }
    }

    jsonArray.prepend(QJsonObject::fromVariantMap(dictionary));

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open file for writing:" << file.errorString();
        return;
    }

    file.write(QJsonDocument(jsonArray).toJson(QJsonDocument::Indented));
    file.close();
}

QVariantList FrtcFileManager::loadMeetingData() {
    QString filePath = getFilePath();
    QFile file(filePath);
    QVariantList result;

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open file for reading:" << file.errorString();
        return result;
    }

    QByteArray fileData = file.readAll();
    file.close();

    QJsonArray jsonArray = QJsonDocument::fromJson(fileData).array();
    for (const QJsonValue &value : jsonArray) {
        result.append(value.toVariant());
    }

    return result;
}

void FrtcFileManager::deleteDataByMeetingStartTime(const QString &meetingStartTime, bool deleteAll) {
    QString filePath = getFilePath();
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open file for reading:" << file.errorString();
        return;
    }

    QByteArray fileData = file.readAll();
    file.close();

    QJsonArray jsonArray = QJsonDocument::fromJson(fileData).array();
    QJsonArray updatedArray;

    if (!deleteAll) {
        for (const QJsonValue &value : jsonArray) {
            QJsonObject obj = value.toObject();
            if (obj.value("meetingStartTime").toString() != meetingStartTime) {
                updatedArray.append(obj);
            }
        }
    }

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open file for writing:" << file.errorString();
        return;
    }

    file.write(QJsonDocument(updatedArray).toJson(QJsonDocument::Indented));
    file.close();
}
