#ifndef REQUESTAUDIOSTREAMHANDLER_H
#define REQUESTAUDIOSTREAMHANDLER_H

#include "MessageHandlerStrategy.h"

class RequestAudioStreamHandler : public MessageHandlerStrategy
{
public:
    RequestAudioStreamHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        QString media_id = jsonObject.value("msid").toString();
        client->on_request_audio_stream(media_id);
    }
};

#endif // REQUESTAUDIOSTREAMHANDLER_H
