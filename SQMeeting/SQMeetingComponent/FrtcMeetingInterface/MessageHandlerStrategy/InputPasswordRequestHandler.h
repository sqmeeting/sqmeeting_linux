#ifndef INPUTPASSWORDREQUESTHANDLER_H
#define INPUTPASSWORDREQUESTHANDLER_H

#include "MessageHandlerStrategy.h"

class InputPasswordRequestHandler:public MessageHandlerStrategy
{
public:
    InputPasswordRequestHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        client->on_input_password_request();
    }
};

#endif // INPUTPASSWORDREQUESTHANDLER_H
