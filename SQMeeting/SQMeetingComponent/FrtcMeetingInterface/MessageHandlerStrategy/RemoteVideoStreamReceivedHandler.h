#ifndef REMOTEVIDEOSTREAMRECEIVEDHANDLER_H
#define REMOTEVIDEOSTREAMRECEIVEDHANDLER_H

#include "MessageHandlerStrategy.h"

class RemoteVideoStreamReceivedHandler : public MessageHandlerStrategy
{
public:
    RemoteVideoStreamReceivedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        QString media_id = jsonObject.value("msid").toString();
        client->on_receive_video_stream(media_id);
    }
};

#endif // REMOTEVIDEOSTREAMRECEIVEDHANDLER_H
