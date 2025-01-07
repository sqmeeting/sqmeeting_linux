#ifndef CALLSTATECHANGEDHANDLER_H
#define CALLSTATECHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class CallStateChangedHandler: public MessageHandlerStrategy
{
public:
    CallStateChangedHandler();
public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override;

private:
    int call_state;
};

#endif // CALLSTATECHANGEDHANDLER_H
