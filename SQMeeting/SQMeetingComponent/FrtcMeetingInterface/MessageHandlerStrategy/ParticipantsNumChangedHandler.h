#ifndef PARTICIPANTSNUMCHANGEDHANDLER_H
#define PARTICIPANTSNUMCHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class ParticipantsNumChangedHandler: public MessageHandlerStrategy
{
public:
    ParticipantsNumChangedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        int participants_num = jsonObject.value("participants_num").toInt();
        client->on_participants_num(participants_num);
    }
};

#endif // PARTICIPANTSNUMCHANGEDHANDLER_H
