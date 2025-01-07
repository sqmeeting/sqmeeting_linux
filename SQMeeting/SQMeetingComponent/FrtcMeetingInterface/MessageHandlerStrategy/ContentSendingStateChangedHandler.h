#ifndef CONTENTSENDINGSTATECHANGEDHANDLER_H
#define CONTENTSENDINGSTATECHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class ContentSendingStateChangedHandler: public MessageHandlerStrategy
{
public:
    ContentSendingStateChangedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        bool content_start = jsonObject.value("is_sending").toBool();
        client->on_content_start(content_start);
    }
};

#endif // CONTENTSENDINGSTATECHANGEDHANDLER_H
