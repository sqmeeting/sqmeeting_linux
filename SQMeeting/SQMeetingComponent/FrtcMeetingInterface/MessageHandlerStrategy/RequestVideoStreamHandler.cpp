#include "RequestVideoStreamHandler.h"

RequestVideoStreamHandler::RequestVideoStreamHandler()
{

}

void RequestVideoStreamHandler::handle(const QJsonObject& jsonObject, FMakeCallClient* client)
{
    client->on_request_video_stream(jsonObject.value("msid").toString());
}
