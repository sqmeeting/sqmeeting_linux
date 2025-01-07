#ifndef AUDIOMUTECHANGEDHANDLER_H
#define AUDIOMUTECHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class AudioMuteChangedHandler : public MessageHandlerStrategy
{
public:
    AudioMuteChangedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        bool allow_self_unmute = jsonObject.value("allow_self_unmute").toBool();
        bool muted = jsonObject.value("muted").toBool();
        client->on_audio_muted_changed(allow_self_unmute, muted);
    }
};

#endif // AUDIOMUTECHANGEDHANDLER_H
