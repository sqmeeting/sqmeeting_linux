#include "MeetingInfoHandler.h"

MeetingInfoHandler::MeetingInfoHandler()
{

}

void MeetingInfoHandler:: handle(const QJsonObject& jsonObject, FMakeCallClient* client)
{
    client->completion_handler(
        jsonObject.value("meeting_name").toString(),
        jsonObject.value("meeting_id").toString(),
        jsonObject.value("owner_id").toString(),
        jsonObject.value("owner_name").toString(),
        jsonObject.value("meeting_url").toString(),
        0, 0, false
        );
}
