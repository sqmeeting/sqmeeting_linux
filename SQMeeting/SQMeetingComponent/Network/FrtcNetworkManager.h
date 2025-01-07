#ifndef FRTCNETWORKMANAGER_H
#define FRTCNETWORKMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QByteArray>
#include <QTimer>
#include <QSslConfiguration>
#include <QSslSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrlQuery>

class FrtcNetworkManager : public QObject
{
    Q_OBJECT
public:
    static FrtcNetworkManager*  instance();

    void get(const QString &url,
             const QString &userToken = QString(),
             const QVariantMap &params = QVariantMap(),
             const QString &requestId = QString());

    void get(const QString &url,
             const QVariantMap &params = QVariantMap(),
             const QString &requestId = QString());

    void post(const QString &url,
              const QString &userToken = QString(),
              const QVariantMap &params = QVariantMap(),
              const QString &requestId = QString());

    void deleteResource(const QString &url,
                        const QString &userToken = QString(),
                        const QVariantMap &params = QVariantMap(),
                        const QString &requestId = QString());

    void put(const QString &url,
             const QString &userToken = QString(),
             const QVariantMap &params = QVariantMap(),
             const QString &requestId = QString());

signals:
    void requestFinished(bool success, int code, const QJsonObject &json, const QString requestId);

private slots:
    void onReplyFinished();
    void onTimeout();

private:
    explicit FrtcNetworkManager(QObject *parent = nullptr);
    void setupNetworkManager();
    void sendRequest(const QNetworkRequest &request, const QByteArray &data, const QString &method , bool isDelete, const QString &requestId);
    QString generateRestfulUrl(const QString &uri, const QString &userToken);

private:
    QString uuid;
    QNetworkAccessManager *manager;
    static FrtcNetworkManager* s_instance;
    QString secretwSha1String(const QString& password);
};

#endif // FRTCNETWORKMANAGER_H
