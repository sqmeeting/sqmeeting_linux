#include "SvcLayoutChangedHandler.h"


SvcLayoutChangedHandler::SvcLayoutChangedHandler()
{

}

void SvcLayoutChangedHandler::handle(const QJsonObject& jsonObject, FMakeCallClient* client)
{
    MeetingLayout::SDKLayoutInfo sdkLayoutInfo;

    sdkLayoutInfo.activeSpeakerSourceId = jsonObject.value("active_speaker_msid").toString().toStdString();
    sdkLayoutInfo.activeSpeakerUuId     = jsonObject.value("active_speaker_uuid").toString().toStdString();
    sdkLayoutInfo.cellCustomUUID        = jsonObject.value("cell_custom_uuid").toString().toStdString();
    sdkLayoutInfo.bContent              = jsonObject.value("has_content").toBool();

    sdkLayoutInfo.layout =
        parseLayoutItems(jsonObject.value("layout_video_list").toArray());
    client->on_svc_layout_changed(&sdkLayoutInfo);
}

QList<MeetingLayout::SDKItemInfo *> * SvcLayoutChangedHandler::parseLayoutItems(const QJsonArray& array)
{
    QList<MeetingLayout::SDKItemInfo *> *layoutItem = new QList<MeetingLayout::SDKItemInfo *>;
    for (const QJsonValue& value : array) {
        if (value.isObject()) {
            QJsonObject jsonObj = value.toObject();

            MeetingLayout::SDKItemInfo *infoItem = new MeetingLayout::SDKItemInfo();

            infoItem->strUUID           = jsonObj["uuid"].toString().toStdString();
            infoItem->strDisplayName    = jsonObj["display_name"].toString().toStdString();
            infoItem->dataSourceID      = jsonObj["msid"].toString().toStdString();
            infoItem->resolution_height = jsonObj["height"].toInt();
            infoItem->resolution_width  = jsonObj["width"].toInt();
            infoItem->is_pinned         = jsonObj["is_pinned"].toBool();
            infoItem->is_active         = jsonObj["is_active"].toBool();

            layoutItem->append(infoItem);
        }
    }

    return layoutItem;
}
