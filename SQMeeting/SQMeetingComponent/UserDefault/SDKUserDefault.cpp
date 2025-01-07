#include "SDKUserDefault.h"
#include <QCoreApplication>
#include <QSettings>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

QMutex SDKUserDefault::m_Mutex;

SDKUserDefault *SDKUserDefault::shareInstance = nullptr;

SDKUserDefault* SDKUserDefault::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new SDKUserDefault();
    }
    return shareInstance;
}

void SDKUserDefault::releaseInstance() {
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

SDKUserDefault::SDKUserDefault(QObject *parent) : QObject(parent) {

}

SDKUserDefault::~SDKUserDefault() {

}

// save to file *.ini.
bool SDKUserDefault::writeToUserConfigFileWithData(QString groupName, QString key, QString data) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;

    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = groupName;
    setting.beginGroup(strGroupNameUser);
    setting.setValue(key, data);
    setting.endGroup();
    return true;
}

// read from the file *.ini.
QString SDKUserDefault::readFromUserConfigFile(QString groupName, QString key) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = groupName;
    setting.beginGroup(strGroupNameUser);
    QString strData = setting.value(key).toString();
    setting.endGroup();

    return strData;
}

//for server address.
bool SDKUserDefault::onQmlSaveServerAddressToUserConfigFile(QString data) {
    writeToUserConfigFileWithData(SERVERCONFIG_GROP, SERVERCONFIG_GROP_SERVERADDRESS_KEY, data);
    return true;
}

QString SDKUserDefault::getServerAddressFromUserConfigFile() {
    QString strSeverAddress = readServerAddressFromUserConfigFile();
    if (strSeverAddress.isEmpty()) {
        strSeverAddress = generateDefaultServerAddress();
        onQmlSaveServerAddressToUserConfigFile(strSeverAddress);
    }

    return strSeverAddress;
}

QString SDKUserDefault::readServerAddressFromUserConfigFile() {
    QString strData = readFromUserConfigFile(SERVERCONFIG_GROP, SERVERCONFIG_GROP_SERVERADDRESS_KEY);
    return strData;
}

QString SDKUserDefault::generateDefaultServerAddress() {
    QString strSeverAddress = QString(DEFAULT_SERVER_ADDRESS);

    return strSeverAddress;
}

//for meeting id.
bool SDKUserDefault::onQmlSaveMeetingIDToUserConfigFile(QString data) {
    writeToUserConfigFileWithData(USERCONFIG_GROP, USERCONFIG_GROP_METTINGID_KEY, data);
    return true;
}

QString SDKUserDefault::getMeetingIDFromUserConfigFile() {
    QString strData = readFromUserConfigFile(USERCONFIG_GROP, USERCONFIG_GROP_METTINGID_KEY);
    return strData;
}

//for user name.
bool SDKUserDefault::onQmlSaveUserNameToUserConfigFile(QString data) {
    writeToUserConfigFileWithData(USERCONFIG_GROP, USERCONFIG_GROP_USERNAME_KEY, data);
    return true;
}

QString SDKUserDefault::getUserNameFromUserConfigFile() {
    QString strData = readFromUserConfigFile(USERCONFIG_GROP, USERCONFIG_GROP_USERNAME_KEY);
    return strData;
}

bool SDKUserDefault::onQmlSaveUserConfigToUserConfigFile(QString meetingID, QString userName, bool micMute, bool cameraMute, bool audioOnly) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;

    QSettings setting(filePath, QSettings::IniFormat);

    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    setting.setValue(USERCONFIG_GROP_METTINGID_KEY, meetingID);
    setting.setValue(USERCONFIG_GROP_USERNAME_KEY, userName);
    setting.setValue(USERCONFIG_GROP_MIC_MUTE_KEY, micMute);
    setting.setValue(USERCONFIG_GROP_CAMERA_MUTE_KEY, cameraMute);
    setting.setValue(USERCONFIG_GROP_AUDIOONLY_KEY, audioOnly);
    setting.endGroup();
    return true;
}

QVariant SDKUserDefault::getUserConfigFromUserConfigFile() {
    QJsonObject Obj;
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);

    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    QString meetingID = setting.value(USERCONFIG_GROP_METTINGID_KEY).toString();
    QString userName = setting.value(USERCONFIG_GROP_USERNAME_KEY).toString();
    bool micMute = setting.value(USERCONFIG_GROP_MIC_MUTE_KEY).toBool();
    bool cameraMute = setting.value(USERCONFIG_GROP_CAMERA_MUTE_KEY).toBool();
    bool audioOnly = setting.value(USERCONFIG_GROP_AUDIOONLY_KEY).toBool();
    setting.endGroup();

    Obj.insert(USERCONFIG_GROP_METTINGID_KEY, meetingID);
    Obj.insert(USERCONFIG_GROP_USERNAME_KEY, userName);
    Obj.insert(USERCONFIG_GROP_MIC_MUTE_KEY, micMute);
    Obj.insert(USERCONFIG_GROP_CAMERA_MUTE_KEY, cameraMute);
    Obj.insert(USERCONFIG_GROP_AUDIOONLY_KEY, audioOnly);

    QVariant varValue = QVariant::fromValue(Obj);
    return varValue;
}

bool SDKUserDefault::onQmlSaveTempSelectMicMute(bool mute) {
    SDKUserDefault::getInstance()->setSdkBoolObject(USERCONFIG_GROP_SELECT_MIC_MUTE_KEY,mute);
    return true;
}

bool SDKUserDefault::onQmlSaveTempSelectCameraMute(bool mute) {
    SDKUserDefault::getInstance()->setSdkBoolObject(USERCONFIG_GROP_SELECT_CAMERA_KEY,mute);
    return true;
}

bool SDKUserDefault::onQmlSaveSelectGridModel(bool select) {
    SDKUserDefault::getInstance()->setSdkBoolObject(SDK_DEFAULT_LAYOUT_GALLERY,select);
    return true;
}

bool SDKUserDefault::onQmlSaveVideoMirrored(bool mirrored) {
    SDKUserDefault::getInstance()->setSdkBoolObject(USERCONFIG_GROP_SELECT_VIDEO_MIRROR_KEY,mirrored);
    return true;

}
bool SDKUserDefault::onQmlSaveIntelligentNoiseReduction(bool reduction) {
    SDKUserDefault::getInstance()->setSdkBoolObject(USERCONFIG_GROP_SELECT_NOISE_REDUCTION,reduction);
    return true;

}

bool SDKUserDefault::onQmlSaveUserInfo(QVariantMap map) {
    SDKUserDefault::getInstance()->setJson(SDK_USER_INFO,map);
    return true;
}

bool SDKUserDefault::onQmlSaveLoginState(bool state) {
    SDKUserDefault::getInstance()->setSdkBoolObject(SDK_LOGIN_STATE_VALUE,state);
    return true;
}

bool SDKUserDefault::onQmlSaveAutoLoginState(bool state) {
    SDKUserDefault::getInstance()->setSdkBoolObject(SDK_AUTO_LOGIN_STATE_VALUE,state);
    return true;
}

bool SDKUserDefault::onQmlSaveLoginUserName(QString userName) {
    SDKUserDefault::getInstance()->setSdkObject(SDK_LOGIN_USERNAME_VALUE,userName);
    return true;
}

bool SDKUserDefault::onQmlSaveUserToken(QString userToken) {
    SDKUserDefault::getInstance()->setSdkObject(SDK_USER_TOKEN_VALUE,userToken);
    return true;
}

bool SDKUserDefault::onQmlSaveCameraSelected(QString select_camera) {
    qDebug() << "*********the select_camera is************** " << select_camera;
    SDKUserDefault::getInstance()->setSdkObject(USERCONFIG_CAMERA_SELECT,select_camera);
    return true;
}

QString SDKUserDefault::getSelectCamera() {
    return SDKUserDefault::getInstance()->getSdkObjectForKey(USERCONFIG_CAMERA_SELECT);
}

QString SDKUserDefault::getUserToken() {
    return SDKUserDefault::getInstance()->getSdkObjectForKey(SDK_USER_TOKEN_VALUE);
}

bool  SDKUserDefault::getMirrorStatus() {
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(USERCONFIG_GROP_SELECT_VIDEO_MIRROR_KEY);
}

bool  SDKUserDefault::getNoiseReductionStatus() {
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(USERCONFIG_GROP_SELECT_NOISE_REDUCTION);
}

QString SDKUserDefault::getLoginUserName() {
    return SDKUserDefault::getInstance()->getSdkObjectForKey(SDK_LOGIN_USERNAME_VALUE);
}

QVariant SDKUserDefault::getAutoLoginState() {
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(SDK_AUTO_LOGIN_STATE_VALUE);
}

QVariant SDKUserDefault::getLoginState() {
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(SDK_LOGIN_STATE_VALUE);
}

QVariantMap SDKUserDefault::getUserInfo() {
    return SDKUserDefault::getInstance()->getJosn(SDK_USER_INFO);
}

QVariant SDKUserDefault::getTempSelectMicMute()
{
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(USERCONFIG_GROP_SELECT_MIC_MUTE_KEY);
}

QVariant SDKUserDefault::getTempSelectCameraMute()
{
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(USERCONFIG_GROP_SELECT_CAMERA_KEY);
}

QVariant SDKUserDefault::getSelectGridModel()
{
    return SDKUserDefault::getInstance()->getSdkBoolObjectForKey(SDK_DEFAULT_LAYOUT_GALLERY);
}

void SDKUserDefault::setSdkObject(QString defaultKey, QString object) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    //qDebug("[%s][%d]: save to file *.ini. filePath: %s, key: %s, object: %s", Q_FUNC_INFO, __LINE__, qPrintable(filePath), qPrintable(defaultKey), qPrintable(object));
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    setting.setValue(defaultKey, object);
    setting.endGroup();
}

QString SDKUserDefault::getSdkObjectForKey(QString defaultKey) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    QString object = setting.value(defaultKey).toString();
    setting.endGroup();

    return object;
}

void SDKUserDefault::setSdkBoolObject(QString defaultKey, bool object) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;

    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    setting.setValue(defaultKey, object);
    setting.endGroup();
}

bool SDKUserDefault::getSdkBoolObjectForKey(QString defaultKey) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    bool object = setting.value(defaultKey).toBool();
    setting.endGroup();

    return object;
}

void SDKUserDefault::setJson(const QString key, const QVariantMap data) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);

    QJsonObject jsonObj = QJsonObject::fromVariantMap(data);
    QJsonDocument jsonDoc(jsonObj);
    QString jsonString = jsonDoc.toJson(QJsonDocument::Compact);

    setting.setValue(key, jsonString);
    setting.endGroup();
}

QVariantMap SDKUserDefault::getJosn(const QString key) {
    QString filePath = QCoreApplication::applicationDirPath() + USER_CONFIG_FILE_NAME;
    QSettings setting(filePath, QSettings::IniFormat);
    QString strGroupNameUser = QString(USERCONFIG_GROP);
    setting.beginGroup(strGroupNameUser);
    QString jsonString = setting.value(key, "{}").toString();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    QVariantMap object = jsonDoc.object().toVariantMap();
    setting.endGroup();
    return object;
}

