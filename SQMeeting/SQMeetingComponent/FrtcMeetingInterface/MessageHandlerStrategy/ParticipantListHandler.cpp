#include "ParticipantListHandler.h"

ParticipantListHandler::ParticipantListHandler()
{

}


void ParticipantListHandler::handle(const QJsonObject& jsonObject, FMakeCallClient* client)
{
    std::vector<std::string> roster_strings;
    QJsonArray roster_list = jsonObject["roster_list"].toArray();
    bool is_full = jsonObject["is_full"].toBool();

    for (const auto& item : roster_list) {
        QJsonObject participant = item.toObject();
        QJsonDocument participantDoc(participant);
        std::string participantJson = participantDoc.toJson(QJsonDocument::Compact).toStdString();
        roster_strings.push_back(participantJson);
    }

    client->on_participants_list(roster_strings, is_full);
}
