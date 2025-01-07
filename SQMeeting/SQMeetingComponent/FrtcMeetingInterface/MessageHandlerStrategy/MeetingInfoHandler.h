#ifndef MEETINGINFOHANDLER_H
#define MEETINGINFOHANDLER_H

#include "MessageHandlerStrategy.h"

class MeetingInfoHandler:public MessageHandlerStrategy
{
public:
    MeetingInfoHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override;
};

#endif // MEETINGINFOHANDLER_H
