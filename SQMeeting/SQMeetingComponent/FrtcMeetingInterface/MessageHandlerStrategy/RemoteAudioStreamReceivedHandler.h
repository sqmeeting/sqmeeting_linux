#ifndef REMOTEAUDIOSTREAMRECEIVEDHANDLER_H
#define REMOTEAUDIOSTREAMRECEIVEDHANDLER_H

#include "MessageHandlerStrategy.h"

class RemoteAudioStreamReceivedHandler: public MessageHandlerStrategy
{
public:
    RemoteAudioStreamReceivedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        QString media_id = jsonObject.value("msid").toString();
        client->on_receive_audio_stream(media_id);
    }
};

#endif // REMOTEAUDIOSTREAMRECEIVEDHANDLER_H
