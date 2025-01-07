#include "FrtcUUID.h"
#include <QDebug>
#include <QUuid>
#include <QSettings>
#include <QCoreApplication>

std::string FrtcUUID::appUUID = "eac16b0c-e6b7-4ad5-a430-146792e42bd8";


bool FrtcUUID::saveUUIDToAppConfigFile(QString uuid) {
    //qDebug("[FrtcUUID::%s][%d]", Q_FUNC_INFO, __LINE__);
    QString filePath = QCoreApplication::applicationDirPath() + "/appconfig.ini";
    QSettings setting(filePath, QSettings::IniFormat);
    // save to appconfig.ini.
    QString strGroupNameUser = "UUID";
    setting.beginGroup(strGroupNameUser);
    setting.setValue("uuid", uuid);
    setting.endGroup();
    return true;
}

// read from appconfig.ini.
QString FrtcUUID::readUUIDFromAppConfigFile() {
    //qDebug("[FrtcUUID::%s][%d]", Q_FUNC_INFO, __LINE__);
    QString filePath = QCoreApplication::applicationDirPath() + "/appconfig.ini";
    QSettings setting(filePath, QSettings::IniFormat);
    // read from the appconfig.ini.
    QString strGroupNameUser = "UUID";
    setting.beginGroup(strGroupNameUser);
    QString strUuid = setting.value("uuid").toString();
    setting.endGroup();

    //qDebug("[FrtcUUID::%s][%d]: get the uuid = %s", Q_FUNC_INFO, __LINE__, strUuid.toStdString().data());
    return strUuid;
}

//[Note]: only call one time for FrtcMeeting App, for every user.
QString FrtcUUID::generateApplicationUUID() {
    qDebug("[FrtcUUID::%s][%d]", Q_FUNC_INFO, __LINE__);
    QUuid uuid = QUuid::createUuid();
    QString strUuid = uuid.toString();
    qDebug() << "[FrtcUUID::generateApplicationUUID()] uuid : " << strUuid;
    //output like："{b5eddbaf-984f-418e-88eb-cf0b8ff3e775}"

    //strUuid.remove("{").remove("}").remove("-");
    strUuid.remove("{").remove("}");
    //qDebug("[%s]: uuid = %s", Q_FUNC_INFO, qPrintable(strUuid));
    FrtcUUID::saveUUIDToAppConfigFile(strUuid);
    return strUuid;
}

std::string FrtcUUID::getApplicationUUID() {
    QString strUuid = FrtcUUID::readUUIDFromAppConfigFile();
    if (strUuid.isEmpty()) {
        strUuid = FrtcUUID::generateApplicationUUID();
        //qDebug("[FrtcUUID::%s][%d]: generate a new uuid = %s", Q_FUNC_INFO, __LINE__, strUuid.toStdString().data());
    } else {
        //qDebug("[FrtcUUID::%s][%d]: get the uuid = %s", Q_FUNC_INFO, __LINE__, strUuid.toStdString().data());
    }
    return strUuid.toStdString().data();
}
