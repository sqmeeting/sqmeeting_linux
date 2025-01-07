#ifndef WATERMASKHANDLER_H
#define WATERMASKHANDLER_H

#include "MessageHandlerStrategy.h"

class WaterMaskHandler : public MessageHandlerStrategy
{
public:
    WaterMaskHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        client->on_water_mask_changed(
            jsonObject.value("live_meeting_url").toString(),
            jsonObject.value("live_password").toString(),
            jsonObject.value("live_status").toString(),
            jsonObject.value("recording_status").toString());
    }
};

#endif // WATERMASKHANDLER_H
