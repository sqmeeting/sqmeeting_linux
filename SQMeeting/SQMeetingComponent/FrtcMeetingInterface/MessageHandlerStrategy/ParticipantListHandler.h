#ifndef PARTICIPANTLISTHANDLER_H
#define PARTICIPANTLISTHANDLER_H

#include "MessageHandlerStrategy.h"

class ParticipantListHandler:public MessageHandlerStrategy
{
public:
    ParticipantListHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client);
};

#endif // PARTICIPANTLISTHANDLER_H
