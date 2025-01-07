#include "CallStateChangedHandler.h"

CallStateChangedHandler::CallStateChangedHandler()
{

}

void CallStateChangedHandler::handle(const QJsonObject& jsonObject, FMakeCallClient* client)
{
    int call_state = jsonObject.value("call_state").toInt();

    int reason = jsonObject.value("reason").toInt();

    client->on_call_state_changed(call_state, reason);
}
