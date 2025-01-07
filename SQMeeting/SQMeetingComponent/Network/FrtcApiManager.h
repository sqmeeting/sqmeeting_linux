#ifndef FRTCAPIMANAGER_H
#define FRTCAPIMANAGER_H

#include <QObject>

const QString frtc_login = "frtc_login";

class FrtcApiManager : public QObject
{
    Q_OBJECT
public:
    static FrtcApiManager*  instance();

public:
    Q_INVOKABLE void sign_in(const QString &name, const QString &passwrod);
    Q_INVOKABLE void sign_out(const QString &token);
    Q_INVOKABLE void sign_in_token(const QString &token);
    Q_INVOKABLE void change_name(const QString meeting_number, const QString &name);
    Q_INVOKABLE void login_change_name(const QString user_token, const QString meeting_number, const QString &name, const QString &client_identifier);
    Q_INVOKABLE void mute_all(const QString user_token, const QString meeting_number, bool allow_self_unmute);
    Q_INVOKABLE void mute_participant(const QString user_token, const QString meeting_number, bool allow_self_unmute,const QVector<QString> &clientIdentifierArray);
    Q_INVOKABLE void un_mute_all(const QString user_token, const QString meeting_number);
    Q_INVOKABLE void un_mute_participant(const QString user_token, const QString meeting_number,const QVector<QString> &clientIdentifierArray);

    Q_INVOKABLE void request_un_mute(const QString user_token, const QString meeting_number);
    Q_INVOKABLE void allow_user_un_mute(const QString user_token, const QString meeting_number, const QVector<QString> &clientIdentifierArray);
    Q_INVOKABLE void set_user_lecturer(const QString user_token, const QString meeting_number,const QString &client_identifier);
    Q_INVOKABLE void un_set_user_lecturer(const QString user_token, const QString meeting_number,const QString &client_identifier);
    Q_INVOKABLE void set_user_pin(const QString user_token, const QString meeting_number, const QVector<QString> &clientIdentifierArray);
    Q_INVOKABLE void set_user_un_pin(const QString user_token, const QString meeting_number);


    Q_INVOKABLE void remove_user_from_meeting(const QString &user_token, const QString meeting_number,const QString &client_identifier);
    Q_INVOKABLE void owner_stop_meeting(const QString &user_token, const QString meeting_number);
    Q_INVOKABLE void start_overlay_message(const QString &user_token, const QString meeting_number,const QVariantMap params);
    Q_INVOKABLE void stop_overlay_message(const QString &user_token, const QString meeting_number);
    Q_INVOKABLE void start_recording(const QString &user_token, const QString meeting_number);
    Q_INVOKABLE void stop_recording(const QString &user_token, const QString meeting_number);
    Q_INVOKABLE void start_streaming(const QString &user_token, const QString &streaming_password, const QString &meeting_number);
    Q_INVOKABLE void stop_streaming(const QString &user_token, const QString &streaming_password);
    Q_INVOKABLE void getMeetingRoomList(const QString &token);
    Q_INVOKABLE void getScheduledMeetingList(const QString &token);
    Q_INVOKABLE void getUserList(const QString &token, const QString &page, const QString &filter);
    Q_INVOKABLE void createMeeting(const QString &token, const QVariantMap &meetingParams);
    Q_INVOKABLE void instantMeeting(const QString &token, const QString &meetingName);
    Q_INVOKABLE void modifyPassword(const QString &token, const QString &oldPsd, const QString &updatePsd);
    Q_INVOKABLE void updateNoRecurrenceMeeting(const QString &token, const QString &reservationId, const QVariantMap &meetingParams);
    Q_INVOKABLE void updateRecurrenceMeeting(const QString &token, const QString &reservationId, const QVariantMap &meetingParams);
    Q_INVOKABLE void getRecurrenceMeetingGroupByPage(const QString &token, const QString &groupId, const QString &requestId = "frtc_getRecurrenceMeeting_list");
    Q_INVOKABLE void deleteMeeting(const QString &token, const QString &reservationId,bool deleteGroup, const QString &requestId = "frtc_deleteMeeting");
    Q_INVOKABLE void getScheduledMeetingDetail(const QString &token, const QString &reservationId);

    Q_INVOKABLE void log(const QString &message);


    /*
 * - (void)frtcMuteAllParticipants:(NSString *)usertoken
                  meetingNumber:(NSString *)meetingNumber
                           mute:(BOOL)allowSelfUnmute
       muteAllCompletionHandler:(nullable void (^)(void))completionHandler
                 muteAllFailure:(nullable void (^)(NSError *error))muteAllFailure;
 */


signals:
    void signInRequestCompleted(bool success, const QJsonObject &json);
    void signInTokenRequestCompleted(bool success, const QJsonObject &json);
    void signOutRequestCompleted(bool success, const QJsonObject &json);
    void signExpiredCompleted();
    void queryMeetingRoomListRequestCompleted(bool success, const QJsonObject &json);
    void scheduledMeetingListRequestCompleted(bool success, const QJsonObject &json);
    void userListCompleted(bool success, const QJsonObject &json);
    void creatMeetingCompleted(bool success, const QJsonObject &json);
    void instantMeetingCompleted(bool success, const QJsonObject &json);
    void muteAllCompleted(bool success);
    void unMuteAllCompleted(bool success);
    void recurrenceMeetingListCompleted(bool success,const QJsonObject &json);
    void recurrenceMeetingListOneCompleted(bool success,const QJsonObject &json);
    void deleteMeetingCompleted(bool success,const QJsonObject &json);
    void deleteMeetingListCompleted(bool success,const QJsonObject &json);
    void updateNoRecurrenceMeetingCompleted(bool success,const QJsonObject &json);
    void updateRecurrenceMeetingCompleted(bool success,const QJsonObject &json);
    void startOverlayMessageCompleted(bool success);
    void modifyPasswordCompleted(bool success);
    void stopOverlayMessageCompleted(bool success);
    void detailScheduleMeetingCompleted(bool success,const QJsonObject &json);
    void startRecordingCompleted(bool success);
    void stopRecordingCompleted(bool success);
    void startStreamingingCompleted(bool success);
    void stopStreamingCompleted(bool success);

private slots:
    void onRequestFinished(bool success, int code, const QJsonObject &json, const QString &requestId);

private:
    static FrtcApiManager* s_instance;
    explicit FrtcApiManager(QObject *parent = nullptr);
    QString secretSha1String(const QString& password);
};

#endif // FRTCAPIMANAGER_H
