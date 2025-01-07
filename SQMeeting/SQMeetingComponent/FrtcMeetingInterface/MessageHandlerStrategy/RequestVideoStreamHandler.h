#ifndef REQUESTVIDEOSTREAMHANDLER_H
#define REQUESTVIDEOSTREAMHANDLER_H

#include "MessageHandlerStrategy.h"

class RequestVideoStreamHandler:public MessageHandlerStrategy
{
public:
    RequestVideoStreamHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override;
};

#endif // REQUESTVIDEOSTREAMHANDLER_H
