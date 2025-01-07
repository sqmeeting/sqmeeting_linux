#ifndef OVERLAYMESSAGEHANDLER_H
#define OVERLAYMESSAGEHANDLER_H

#include "MessageHandlerStrategy.h"

class OverlayMessageHandler : public MessageHandlerStrategy
{
public:
    OverlayMessageHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        client->on_message_over_lay(
            jsonObject.value("enabled").toBool(),
            jsonObject.value("vertical_position").toInt(),
            jsonObject.value("display_repetition").toInt(),
            jsonObject.value("display_speed").toString(),
            jsonObject.value("message_text").toString());
    }
};

#endif // OVERLAYMESSAGEHANDLER_H
