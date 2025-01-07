#ifndef MESSAGEHANDLERSTRATEGY_H
#define MESSAGEHANDLERSTRATEGY_H

#include "FMakeCallClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>


class MessageHandlerStrategy {
public:
    virtual ~MessageHandlerStrategy() = default;
    virtual void handle(const QJsonObject& jsonObject, FMakeCallClient* client) = 0;
};

#endif // MESSAGEHANDLERSTRATEGY_H
