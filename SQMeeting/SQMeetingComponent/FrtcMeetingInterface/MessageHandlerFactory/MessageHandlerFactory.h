#ifndef MESSAGEHANDLERFACTORY_H
#define MESSAGEHANDLERFACTORY_H

#include <iostream>
#include <QString>
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
    MessageHandlerFactory();

public:
    static std::unique_ptr<MessageHandlerStrategy> createHandler(const QString& messageType) {
        if (messageType == "call_state_changed") {
            return std::make_unique<CallStateChangedHandler>();
        } else if (messageType == "on_meeting_info") {
            return std::make_unique<MeetingInfoHandler>();
        } else if (messageType == "request_video_stream") {
            return std::make_unique<RequestVideoStreamHandler>();
        } else if (messageType == "remote_audio_stream_received") {
            return std::make_unique<RemoteAudioStreamReceivedHandler>();
        } else if (messageType == "request_audio_stream") {
            return std::make_unique<RequestAudioStreamHandler>();
        } else if (messageType == "svc_layout_changed") {
            return std::make_unique<SvcLayoutChangedHandler>();
        } else if (messageType == "content_sending_state_changed") {
            return std::make_unique<ContentSendingStateChangedHandler>();
        } else if (messageType == "on_participants_num_changed") {
            return std::make_unique<ParticipantsNumChangedHandler>();
        } else if (messageType == "remote_video_stream_received") {
            return std::make_unique<RemoteVideoStreamReceivedHandler>();
        } else if (messageType == "on_participant_list") {
            return std::make_unique<ParticipantListHandler>();
        } else if (messageType == "on_audio_mute_changed") {
            return std::make_unique<AudioMuteChangedHandler>();
        } else if (messageType == "on_input_password_request") {
            return std::make_unique<InputPasswordRequestHandler>();
        } else if (messageType == "on_allow_un_mute_agree") {
            return std::make_unique<UnMuteAllowedHandler>();
        } else if (messageType == "on_message_overlay") {
            return std::make_unique<OverlayMessageHandler>();
        } else if (messageType == "on_water_mask") {
            return std::make_unique<WaterMaskHandler>();
        } else if(messageType == "on_un_mute_request") {
            return std::make_unique<UnMuteRequestHandler>();
        } else if(messageType == "layout_setting_changed") {
            return std::make_unique<LayoutSettingChangedHandler>();
        } else if(messageType == "pin_speaker_changed") {
            return std::make_unique<PinSpeakerChangedHandler>();
        }
        return nullptr;  // 未知的消息类型
    }
};

#endif // MESSAGEHANDLERFACTORY_H
