#ifndef PINSPEAKERCHANGEDHANDLER_H
#define PINSPEAKERCHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class PinSpeakerChangedHandler : public MessageHandlerStrategy
{
public:
    PinSpeakerChangedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        QString pin_speaker_id = jsonObject.value("pin_speaker_id").toString();
        client->on_receive_pin_speaker_id(pin_speaker_id);
    }
};

#endif // PINSPEAKERCHANGEDHANDLER_H
