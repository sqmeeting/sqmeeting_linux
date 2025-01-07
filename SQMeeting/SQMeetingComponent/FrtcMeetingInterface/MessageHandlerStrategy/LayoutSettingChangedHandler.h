#ifndef LAYOUTSETTINGCHANGEDHANDLER_H
#define LAYOUTSETTINGCHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"

class LayoutSettingChangedHandler : public MessageHandlerStrategy
{
public:
    LayoutSettingChangedHandler();

    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override {
        client->on_layout_setting_changed(
            jsonObject.value("lecture_id").toString(),
            jsonObject.value("max_cell_count").toInt());
    }
};

#endif // LAYOUTSETTINGCHANGEDHANDLER_H
