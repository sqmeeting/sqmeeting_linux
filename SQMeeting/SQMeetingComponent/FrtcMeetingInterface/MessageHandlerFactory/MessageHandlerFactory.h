#ifndef MESSAGEHANDLERFACTORY_H
#define MESSAGEHANDLERFACTORY_H

#include <iostream>
#include <QString>
#include <unordered_map>
#include <functional>
#include "MessageHandlerStrategy.h"
#include "CallStateChangedHandler.h"
#include "MeetingInfoHandler.h"
#include "RequestVideoStreamHandler.h"
#include "RemoteAudioStreamReceivedHandler.h"
#include "RequestAudioStreamHandler.h"
#include "SvcLayoutChangedHandler.h"
#include "ContentSendingStateChangedHandler.h"
#include "ParticipantsNumChangedHandler.h"
#include "RemoteVideoStreamReceivedHandler.h"
#include "ParticipantListHandler.h"
#include "AudioMuteChangedHandler.h"
#include "InputPasswordRequestHandler.h"
#include "UnMuteAllowedHandler.h"
#include "WaterMaskHandler.h"
#include "OverlayMessageHandler.h"
#include "UnMuteRequestHandler.h"
#include "LayoutSettingChangedHandler.h"
#include "PinSpeakerChangedHandler.h""

class MessageHandlerFactory
{
public:
    MessageHandlerFactory() = delete;  // 防止实例化

    static std::unique_ptr<MessageHandlerStrategy> createHandler(const QString& messageType) {
        static const std::unordered_map<QString, std::function<std::unique_ptr<MessageHandlerStrategy>()>> handlers = {
            {"call_state_changed", []() { return std::make_unique<CallStateChangedHandler>(); }},
            {"on_meeting_info", []() { return std::make_unique<MeetingInfoHandler>(); }},
            {"request_video_stream", []() { return std::make_unique<RequestVideoStreamHandler>(); }},
            {"remote_audio_stream_received", []() { return std::make_unique<RemoteAudioStreamReceivedHandler>(); }},
            {"request_audio_stream", []() { return std::make_unique<RequestAudioStreamHandler>(); }},
            {"svc_layout_changed", []() { return std::make_unique<SvcLayoutChangedHandler>(); }},
            {"content_sending_state_changed", []() { return std::make_unique<ContentSendingStateChangedHandler>(); }},
            {"on_participants_num_changed", []() { return std::make_unique<ParticipantsNumChangedHandler>(); }},
            {"remote_video_stream_received", []() { return std::make_unique<RemoteVideoStreamReceivedHandler>(); }},
            {"on_participant_list", []() { return std::make_unique<ParticipantListHandler>(); }},
            {"on_audio_mute_changed", []() { return std::make_unique<AudioMuteChangedHandler>(); }},
            {"on_input_password_request", []() { return std::make_unique<InputPasswordRequestHandler>(); }},
            {"on_allow_un_mute_agree", []() { return std::make_unique<UnMuteAllowedHandler>(); }},
            {"on_message_overlay", []() { return std::make_unique<OverlayMessageHandler>(); }},
            {"on_water_mask", []() { return std::make_unique<WaterMaskHandler>(); }},
            {"on_un_mute_request", []() { return std::make_unique<UnMuteRequestHandler>(); }},
            {"layout_setting_changed", []() { return std::make_unique<LayoutSettingChangedHandler>(); }},
            {"pin_speaker_changed", []() { return std::make_unique<PinSpeakerChangedHandler>(); }}
        };

        auto it = handlers.find(messageType);
        if (it != handlers.end()) {
            return it->second();
        }

        // 添加日志记录未知消息类型
        qWarning() << "Unknown message type received:" << messageType;
        return nullptr;
    }

    // 用于注册新的消息处理器（如果需要运行时注册的话）
    static bool registerHandler(const QString& messageType, 
                              std::function<std::unique_ptr<MessageHandlerStrategy>()> creator) {
        static std::unordered_map<QString, std::function<std::unique_ptr<MessageHandlerStrategy>()>> customHandlers;
        
        if (customHandlers.find(messageType) != customHandlers.end()) {
            qWarning() << "Handler already exists for message type:" << messageType;
            return false;
        }

        customHandlers[messageType] = creator;
        return true;
    }
};

#endif // MESSAGEHANDLERFACTORY_H
