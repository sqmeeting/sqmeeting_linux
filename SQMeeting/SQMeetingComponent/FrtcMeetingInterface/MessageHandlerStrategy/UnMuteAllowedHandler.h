#ifndef UNMUTEALLOWEDHANDLER_H
#define UNMUTEALLOWEDHANDLER_H

#include "MessageHandlerStrategy.h"

class UnMuteAllowedHandler : public MessageHandlerStrategy
{
public:
    UnMuteAllowedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        client->on_un_mute_request_allowed();
    }
};

#endif // UNMUTEALLOWEDHANDLER_H
