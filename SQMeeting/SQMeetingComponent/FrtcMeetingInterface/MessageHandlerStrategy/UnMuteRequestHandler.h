#ifndef UNMUTEREQUESTHANDLER_H
#define UNMUTEREQUESTHANDLER_H

#include "MessageHandlerStrategy.h"

class UnMuteRequestHandler : public MessageHandlerStrategy
{
public:
    UnMuteRequestHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        QString name = jsonObject.value("name").toString();
        QString uuid = jsonObject.value("uuid").toString();

        client->on_un_mute_request(name, uuid);
    }
};

#endif // UNMUTEREQUESTHANDLER_H
