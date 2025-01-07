#include "FrtcNetworkManager.h"
#include "SDKUserDefault.h"
#include <QDebug>
#include "FrtcUUID.h"

#define UserAgent "FrtcMeeting/3.4.0 linux"

FrtcNetworkManager* FrtcNetworkManager::s_instance = nullptr;

FrtcNetworkManager* FrtcNetworkManager::instance() {
    if (!s_instance) {
        s_instance = new FrtcNetworkManager();
    }
    return s_instance;
}

FrtcNetworkManager::FrtcNetworkManager(QObject *parent) : QObject(parent), manager(new QNetworkAccessManager(this)) {
    uuid = QString::fromStdString(FrtcUUID::getApplicationUUID());
    setupNetworkManager();
}

void FrtcNetworkManager::get(const QString &url, const QString &userToken, const QVariantMap &params, const QString &requestId) {

    QString resultUrl = generateRestfulUrl(url, userToken);
    QString queryString;
    for (auto it = params.constBegin(); it != params.constEnd(); ++it) {
        if (!queryString.isEmpty()) {
            queryString.append("&");
        }
        queryString.append(QUrl::toPercentEncoding(it.key()) + "=" + QUrl::toPercentEncoding(it.value().toString()));
    }

    QString finalUrlString = resultUrl;
    if (!queryString.isEmpty()) {
        finalUrlString.append("&" + queryString);
    }

    QUrl finalUrl(finalUrlString);
    qDebug() << "Get finalUrl:" << finalUrl.toString();
    qDebug() << "Get params:" << params;

    QNetworkRequest request(finalUrl);
    request.setHeader(QNetworkRequest::UserAgentHeader, UserAgent);
    sendRequest(request, QByteArray(), "GET", false, requestId);
}

void FrtcNetworkManager::post(const QString &url, const QString &userToken,  const QVariantMap &params, const QString &requestId) {

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray data = jsonDoc.toJson(QJsonDocument::Compact);
    QString resultUrl = generateRestfulUrl(url,userToken);
    QUrl finalUrl(resultUrl);
    qDebug() << "Post finalUrl:" << finalUrl.toString();
    qDebug() << "Post params:" << params;

    QNetworkRequest request(finalUrl);
    request.setHeader(QNetworkRequest::UserAgentHeader, UserAgent);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    sendRequest(request, data, "POST", false, requestId);
}

void FrtcNetworkManager::get(const QString &url, const QVariantMap &params, const QString &requestId)
{
    QString queryString;
    for (auto it = params.constBegin(); it != params.constEnd(); ++it) {
        if (!queryString.isEmpty()) {
            queryString.append("&");
        }
        queryString.append(QUrl::toPercentEncoding(it.key()) + "=" + QUrl::toPercentEncoding(it.value().toString()));
    }

    QString finalUrlString = url;
    if (!queryString.isEmpty()) {
        finalUrlString.append("&" + queryString);
    }

    QUrl finalUrl(finalUrlString);
    qDebug() << "Url Get finalUrl:" << finalUrl.toString();
    qDebug() << "Url Get params:" << params;

    QNetworkRequest request(finalUrl);
    request.setHeader(QNetworkRequest::UserAgentHeader, UserAgent);
    sendRequest(request, QByteArray(), "GET", false, requestId);
}

void FrtcNetworkManager::deleteResource(const QString &url, const QString &userToken, const QVariantMap &params, const QString &requestId)
{
    QString resultUrl = generateRestfulUrl(url, userToken);
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray data = jsonDoc.toJson(QJsonDocument::Compact);

    // 是否删除周期性会议
    if (!params.isEmpty()) {
        if (params.contains("deleteGroup")) {
            bool deleteGroup = params.value("deleteGroup").toBool();
            if (deleteGroup) {
                resultUrl += "&deleteGroup=true";
            }
        }
    }

    QUrl finalUrl(resultUrl);
    qDebug() << "Delete finalUrl:" << finalUrl.toString();
    qDebug() << "Delete params:" << params;

    QNetworkRequest request(finalUrl);
    request.setHeader(QNetworkRequest::UserAgentHeader, UserAgent);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    sendRequest(request, data, "DELETE", true, requestId);
}

void FrtcNetworkManager::put(const QString &url, const QString &userToken, const QVariantMap &params, const QString &requestId)
{
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray data = jsonDoc.toJson(QJsonDocument::Compact);
    QString resultUrl = generateRestfulUrl(url,userToken);
    QUrl finalUrl(resultUrl);
    qDebug() << "put finalUrl:" << finalUrl.toString();
    qDebug() << "put params:" << params;

    QNetworkRequest request(finalUrl);
    request.setHeader(QNetworkRequest::UserAgentHeader, UserAgent);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    sendRequest(request, data, "PUT", false, requestId);
}

void FrtcNetworkManager::onReplyFinished() {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply) {
        bool success = false;
        int code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "response code = " << code;
        QJsonObject jsonObj;
        QString requestId = reply->property("requestId").toString();

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
            if (!jsonDoc.isNull() && jsonDoc.isObject()) {
                jsonObj = jsonDoc.object();
                //qDebug() << "response success JSON response" << jsonObj;
            } else {
                qDebug() << "Failed to parse JSON response";
            }
        } else {
            qDebug() << "Network error:" << reply->errorString();
            jsonObj["error"] = reply->errorString();
        }

        if (code == 200) {
            success = true;
        }

        emit requestFinished(success, code, jsonObj, requestId);
        reply->deleteLater();
    }
}

void FrtcNetworkManager::onTimeout() {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (reply) {
        reply->abort();
    }
}

void FrtcNetworkManager::setupNetworkManager() {
    manager->setRedirectPolicy(QNetworkRequest::NoLessSafeRedirectPolicy);
    manager->setStrictTransportSecurityEnabled(true);

    // 设置超时时间
    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);
    connect(timer, &QTimer::timeout, this, &FrtcNetworkManager::onTimeout);

    // 设置SSL配置
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
    QSslConfiguration::setDefaultConfiguration(sslConfig);
}

void FrtcNetworkManager::sendRequest(const QNetworkRequest &request, const QByteArray &data, const QString &method, bool isDelete,const QString &requestId) {
    QNetworkReply *reply;
    if (method == "POST") {
        reply = manager->post(request, data);
    } else if(method == "DELETE") {
        reply = manager->sendCustomRequest(request, "DELETE", data);
    } else if(method == "GET") {
        reply = manager->get(request);
    } else if (method == "PUT") {
        reply = manager->put(request, data);
    } else {
        reply = manager->get(request);
    }

    reply->setProperty("requestId", requestId);
    connect(reply, &QNetworkReply::finished, this, &FrtcNetworkManager::onReplyFinished);

    QTimer *timer = new QTimer(reply);
    timer->setSingleShot(true);
    connect(timer, &QTimer::timeout, this, &FrtcNetworkManager::onTimeout);
    connect(reply, &QNetworkReply::finished, timer, &QTimer::stop);
    connect(reply, &QNetworkReply::finished, timer, &QTimer::deleteLater);
    timer->start(10000); // 10秒超时
}

QString FrtcNetworkManager::generateRestfulUrl(const QString &uri, const QString &userToken)
{
    QString serverAddress = SDKUserDefault::getInstance()->getServerAddressFromUserConfigFile();
    QString restfulUrl;

    if (uri == "/api/v1/user/sign_in") {
        restfulUrl = "https://" + serverAddress + uri + "?client_id=" + uuid;
    } else if (uri == "/api/v1/user/public/users") {
        restfulUrl = "https://" + serverAddress + uri + "?client_id=" + uuid + "&token=" + userToken + "&page_num=1&page_size=50";
    } else if (userToken.isEmpty() && uri.contains("request_unmute")) {
        restfulUrl = "https://" + serverAddress + uri + "?client_id=" + uuid;
    } else if (userToken.isEmpty()) {
        restfulUrl = "https://" + serverAddress + uri + "/participant?client_id=" + uuid;
    } else {
        restfulUrl = "https://" + serverAddress + uri + "?client_id=" + uuid + "&token=" + userToken;
    }
    return restfulUrl;
}
