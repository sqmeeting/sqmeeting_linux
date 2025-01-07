#ifndef SVCLAYOUTCHANGEDHANDLER_H
#define SVCLAYOUTCHANGEDHANDLER_H

#include "MessageHandlerStrategy.h"
#include "SDKItemInfo.h"

class SvcLayoutChangedHandler:public MessageHandlerStrategy
{
public:
    SvcLayoutChangedHandler();

public:
    void handle(const QJsonObject& jsonObject, FMakeCallClient* client) override;

    QList<MeetingLayout::SDKItemInfo *> * parseLayoutItems(const QJsonArray& array);
};

#endif // SVCLAYOUTCHANGEDHANDLER_H
