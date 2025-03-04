#ifndef MESSAGEHANDLERSTRATEGY_H
#define MESSAGEHANDLERSTRATEGY_H

// Qt headers
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

// Project headers
#include "FMakeCallClient.h"

class MessageHandlerStrategy {
public:
    // 虚析构函数
    virtual ~MessageHandlerStrategy() = default;

    // 处理消息的纯虚函数
    virtual void handle(const QJsonObject& jsonObject, FMakeCallClient* client) = 0;

protected:
    // 保护构造函数，只允许派生类构造
    MessageHandlerStrategy() = default;

    // 禁用拷贝和赋值
    MessageHandlerStrategy(const MessageHandlerStrategy&) = delete;
    MessageHandlerStrategy& operator=(const MessageHandlerStrategy&) = delete;
};

#endif // MESSAGEHANDLERSTRATEGY_H
