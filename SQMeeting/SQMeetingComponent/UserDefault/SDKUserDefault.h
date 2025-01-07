#ifndef SDKUSERDEFAULT_H
#define SDKUSERDEFAULT_H

#include <QObject>
#include <QMutex>
#include <QDebug>

//default user config file name.
#define USER_CONFIG_FILE_NAME "/userdefault.ini"

//default server Address.
#define DEFAULT_SERVER_ADDRESS "shenqi-demo.internetware.cn:7443"

#define SERVERCONFIG_GROP "ServerConfig"
#define SERVERCONFIG_GROP_SERVERADDRESS_KEY "ServerAddress"

//user meeting config.
#define USERCONFIG_GROP "UserConfig"
//user data
#define USERCONFIG_GROP_METTINGID_KEY      "meetingID"
#define USERCONFIG_GROP_USERNAME_KEY       "userName"
//media mute state.
#define USERCONFIG_GROP_MIC_MUTE_KEY       "micMute"
#define USERCONFIG_GROP_CAMERA_MUTE_KEY    "cameraMute"
#define USERCONFIG_GROP_AUDIOONLY_KEY      "audioOnly"

#define USERCONFIG_GROP_SELECT_MIC_MUTE_KEY "select_micmute"
#define USERCONFIG_GROP_SELECT_CAMERA_KEY   "select_camera"

#define USERCONFIG_GROP_SELECT_VIDEO_MIRROR_KEY "video_mirror"
#define USERCONFIG_GROP_SELECT_NOISE_REDUCTION   "noise_reduction"

#define USERCONFIG_CAMERA_SELECT            "camera_select"

#define SDK_USER_INFO                 "sdkuserinfo"
#define SDK_SERVER_ADDRESS            "sdkServerAddress"
#define SDK_LOGIN_STATE_VALUE         "sdkLoginValue"
#define SDK_AUTO_LOGIN_STATE_VALUE    "sdkAutoLoginValue"
#define SDK_IF_URL_VALUE              "sdkIfUrlCall"
#define SDK_URL_VALUE                 "sdkUrlValue"
#define SDK_LOGIN_USERNAME_VALUE      "sdkLoginUsernameValue"
#define SDK_USER_TOKEN_VALUE          "sdkUserTokenValue"

#define SDK_DEFAULT_LAYOUT_GALLERY    "sdkDefaultLayout" //true: "gallery"; false: "presenter"


class SDKUserDefault : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(SDKUserDefault)

private:
    static QMutex m_Mutex;
    static SDKUserDefault *shareInstance;
public:
    static SDKUserDefault* getInstance();
    void releaseInstance();
    explicit SDKUserDefault(QObject *parent = nullptr);
    ~SDKUserDefault();

public:
    bool writeToUserConfigFileWithData(QString groupName, QString key, QString data);
    QString readFromUserConfigFile(QString groupName, QString key);

public:
    // [set action]: QML call those mothod for action.
    Q_INVOKABLE bool onQmlSaveServerAddressToUserConfigFile(QString data);

    Q_INVOKABLE bool onQmlSaveMeetingIDToUserConfigFile(QString data);
    Q_INVOKABLE bool onQmlSaveUserNameToUserConfigFile(QString data);

    Q_INVOKABLE bool onQmlSaveUserConfigToUserConfigFile(QString meetingID, QString userName, bool micMute, bool cameraMute, bool audioOnly);

    Q_INVOKABLE bool onQmlSaveTempSelectMicMute(bool mute);
    Q_INVOKABLE bool onQmlSaveTempSelectCameraMute(bool mute);
    Q_INVOKABLE bool onQmlSaveSelectGridModel(bool select);
    Q_INVOKABLE bool onQmlSaveVideoMirrored(bool mirrored);
    Q_INVOKABLE bool onQmlSaveIntelligentNoiseReduction(bool reduction);

    Q_INVOKABLE bool onQmlSaveUserInfo(QVariantMap map);
    Q_INVOKABLE bool onQmlSaveLoginState(bool state);
    Q_INVOKABLE bool onQmlSaveAutoLoginState(bool state);
    Q_INVOKABLE bool onQmlSaveLoginUserName(QString userName);
    Q_INVOKABLE bool onQmlSaveUserToken(QString userToken);

    Q_INVOKABLE bool onQmlSaveCameraSelected(QString select_camera);
public:
    // [get data]: QML call those method to get data from CPP.
    Q_INVOKABLE QString getServerAddressFromUserConfigFile();
    QString readServerAddressFromUserConfigFile();
    QString generateDefaultServerAddress();

    Q_INVOKABLE QString getMeetingIDFromUserConfigFile();
    Q_INVOKABLE QString getUserNameFromUserConfigFile();

    Q_INVOKABLE QVariant getUserConfigFromUserConfigFile();

    Q_INVOKABLE QVariant getTempSelectMicMute();
    Q_INVOKABLE QVariant getTempSelectCameraMute();
    Q_INVOKABLE QVariant getSelectGridModel();
    Q_INVOKABLE QVariantMap getUserInfo();
    Q_INVOKABLE QVariant getLoginState();
    Q_INVOKABLE QVariant getAutoLoginState();
    Q_INVOKABLE QString  getLoginUserName();
    Q_INVOKABLE QString  getUserToken();
    Q_INVOKABLE QString  getSelectCamera();
    Q_INVOKABLE bool     getMirrorStatus();
    Q_INVOKABLE bool     getNoiseReductionStatus();

    //
    void setSdkObject(QString defaultKey, QString object);
    QString getSdkObjectForKey(QString defaultKey);

    void setSdkBoolObject(QString defaultKey, bool object);
    bool getSdkBoolObjectForKey(QString defaultKey);

    void setJson(const QString key, const QVariantMap data);
    QVariantMap getJosn(const QString key);
};


#endif // SDKUSERDEFAULT_H
