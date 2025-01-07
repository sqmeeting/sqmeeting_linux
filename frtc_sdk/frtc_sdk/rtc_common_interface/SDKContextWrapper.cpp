//
//  SDKContextWrapper.cpp
//  class SDKContext.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2022/06/20.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
//TODO: Qt5 -> Qt6 -yingyong.Mao -2023-10-23
#include<windows.h>
#endif


#include "SDKContextWrapper.h"


#include "FrtcCall.h"

#include <iostream>

SDKContext::SDKContext(const std::string& uuid, const std::string log_path)
	: _impl(nullptr)
	, _sdkObserver(nullptr)
	, sendAppContent(false)
{
	if (nullptr == _impl)
	{
		_impl = new ObjectImpl();

		if (nullptr != _impl)
		{
			_impl->Init(this, uuid, log_path);
		}
	}
}

void SDKContext::frtc_make_guest_call(
	const std::string& ipAddress,
	const std::string& conferenceAlias,
	const std::string& clientName,
	int callRate,
	const std::string& password)
{
	_impl->JoinMeetingNoLoginImpl(ipAddress, conferenceAlias, clientName, password, callRate);
}

void SDKContext::frtc_make_login_call(
    const std::string& ipAddress,
    const std::string& conferenceAlias,
    const std::string& clientName,
    int callRate,
    const std::string& password,
    const std::string& user_token,
    const std::string& user_id
    )
{
    _impl->JoinMeetingLoginImpl(ipAddress, conferenceAlias, clientName, user_token, password, callRate, user_id);
}

void SDKContext::setSDKContextObserver(FrtcCallObserverInterface* sdkObserver)
{
	_sdkObserver = sdkObserver;
}

void SDKContext::layoutChanged(const RTC::LayoutDescription& layout)
{
	std::vector<RTC::LayoutCell> layoutInfo = layout.layout_cells;

	std::list<SDKItemInfo> layoutItem;

	for (std::vector<RTC::LayoutCell>::iterator iter = layoutInfo.begin(); iter != layoutInfo.end(); ++iter) {
		SDKItemInfo infoItem;

		infoItem.uuid = iter->uuid.c_str();
		infoItem.display_name = iter->display_name.c_str();

		infoItem.msid = iter->msid.c_str();
		infoItem.resolution_height = (int)iter->height;
		infoItem.resolution_width = (int)iter->width;

		layoutItem.emplace_back(infoItem);
	}

	SDKLayoutInfo sdkLayoutInfo;
	sdkLayoutInfo.layout = std::move(layoutItem);
	sdkLayoutInfo.activeSpeakerSourceId = layout.active_speaker_msid.c_str();
	sdkLayoutInfo.activeSpeakerUuId = layout.active_speaker_msid.c_str();
	sdkLayoutInfo.cellCustomUUID = layout.pin_speaker_uuid.c_str();
	sdkLayoutInfo.bContent = layout.has_content;
	if (layout.mode != RTC::LayoutMode::kContentRecv && layout.mode != RTC::LayoutMode::kContentSend)
	{
		sdkLayoutInfo.mode = layout.mode == RTC::LayoutMode::k1P5 ? SVC_LAYOUT_MODE_1N5 : SVC_LAYOUT_MODE_GALLERY;
	}
	else
	{
		sdkLayoutInfo.mode = SVC_LAYOUT_MODE_NUMBER;
	}

	this->_sdkObserver->onSVCLayoutChanged(sdkLayoutInfo);

    this->_sdkObserver->onPinSpeakerChanged(layout.pin_speaker_uuid);
}

void SDKContext::onLayoutSettingChanged(int max_cell_count, const std::vector<std::string>& lectures)
{
	if (_sdkObserver)
	{
		_sdkObserver->onLayoutSettingChanged(max_cell_count, lectures);
	}
}

void SDKContext::onMuteLocked(bool muted, bool allowSelfUnmute)
{
	if (_sdkObserver) {
		_sdkObserver->onMuteLockedCallBack(muted, allowSelfUnmute);
	}
}

void SDKContext::onUrMutedDetected()
{
    if(_sdkObserver) {
        _sdkObserver->onUnMuteAllowCallBack();
    }
}

void SDKContext::onEncryptStateReport(bool encrypted)
{

}

void SDKContext::onContentStateChanged(bool isSending)
{
	if (_sdkObserver)
	{
		_sdkObserver->onContentStateChangedCallBack(isSending);
	}
}

void SDKContext::onInputPassCode()
{
	if (_sdkObserver)
	{
		_sdkObserver->onInputPasswordCallBack();
	}
}


void SDKContext::onMessageOverLay(const RTC::TextOverlay& overlayMessage)
{
	if(_sdkObserver)
	{
		_sdkObserver->OnMessageOverlayReceived(overlayMessage);
	}
}


void SDKContext::onContentWaterMaskRecevice(const std::string& contentWater,
	const std::string& recordingStatus,
	const std::string& liveStatus,
	const std::string& liveMeetingUrl,
	const std::string& livePassword)
{
    if(_sdkObserver) {
        _sdkObserver->onContentWaterMaskRecevice(contentWater,
                                                 recordingStatus,
                                                 liveStatus,
                                                 liveMeetingUrl,
                                                 livePassword);
    }
}


void SDKContext::participantsListReveived(const std::set<std::string> rosterList)
{
	if (_sdkObserver)
	{
		_sdkObserver->onParticipantsListReceived(rosterList);
	}
}

void SDKContext::OnParticipantStatusChanged(std::map<std::string, RTC::ParticipantStatus>& roster_list, bool is_full)
{
	if (_sdkObserver)
	{
		_sdkObserver->OnParticipantStatusChanged(roster_list, is_full);
	}
}

void SDKContext::onParticipantsNumReport(int participantsNum)
{
	if (_sdkObserver)
	{
		_sdkObserver->onParticipantsNumReportCallBack(participantsNum);
	}
}

void SDKContext::onReceiveAllowUnmuteNotify()
{
    if(_sdkObserver) {
        _sdkObserver->onUnMuteAllowCallBack();
    }

}

void SDKContext::onReceiveUnmuteRequestNotify(const std::map<std::string, std::string>& partiList)
{
    if(_sdkObserver) {
        _sdkObserver->onReceiveUnmuteRequestCallBack(partiList);
    }

}

void SDKContext::onMakeCallBack(const std::string& meeting_name,
	const std::string& meeting_id,
	const std::string& display_name,
	const std::string& owner_id,
	const std::string& owner_name,
	const std::string& meeting_url,
	const std::string& group_meeting_url,
	long long start_time,
	long long end_time)
{
	if (_sdkObserver)
	{
		_sdkObserver->onMeetingInfo(meeting_name, meeting_id, display_name, owner_id, owner_name, meeting_url, group_meeting_url, start_time, end_time);
	}
}

void SDKContext::videoReveived(const std::string& msid)
{
	if (_sdkObserver)
	{
		_sdkObserver->onVideoStreamReceived(msid);
	}
}

void SDKContext::audioReveived(const std::string& msid)
{
	if (_sdkObserver)
	{
		_sdkObserver->onAudioStreamReceived(msid);
	}
}


void SDKContext::onVideoStreamRequested(const std::string& msid, int width, int height, float framerate)
{
	if (_sdkObserver)
	{
		_sdkObserver->OnRequestVideoStream(msid, width, height, framerate);
	}
}

void SDKContext::onAudioStreamRequested(const std::string& msid)
{
	if (_sdkObserver)
	{
		_sdkObserver->OnRequestAudioStream(msid);
	}
}

void SDKContext::onDeletedVideoStream(const std::string& msid)
{
	if (_sdkObserver)
	{
		_sdkObserver->OnDeleteVideoStream(msid);
	}
}


void SDKContext::onCallStateChanged(RTC::MeetingStatus status, int reason)
{
	SDKCallStatus call_status;
	if (status == RTC::kIdle)
	{
		call_status = s_call_idle;
	}
	else if (status == RTC::kConnected)
	{
		call_status = s_call_connected;
	}
	else
	{
		call_status = s_call_dis_connected;
	}
	if (_sdkObserver)
	{
		_sdkObserver->onCallStateChangedCallBack(call_status, reason);
	}
}


void SDKContext::startSendVideoStream(std::string msid, void* buffer, size_t length, size_t width, size_t height, RTC::VideoColorFormat type, int stride)
{
	_impl->SendVideoFrameImpl(msid, (unsigned char*)buffer, (unsigned int)length, (unsigned int)width, (unsigned int)height, type, stride);
}

void SDKContext::startSendContentStream(std::string msid, void* buffer, size_t length, size_t width, size_t height, RTC::VideoColorFormat type)
{
    _impl->SendVideoFrameImpl(msid, (unsigned char*)buffer, (unsigned int)length, (unsigned int)width, (unsigned int)height, type, 0);
}

void SDKContext::getVideoData(std::string msid, void** buffer, unsigned int* length, unsigned int* width, unsigned int* height)
{
	_impl->ReceiveVideoFrameImpl(msid, buffer, length, width, height);
}

void SDKContext::muteLocalVideo(bool muted)
{
	_impl->MuteLocalVideoImpl(muted);
}

void SDKContext::muteLocalAudio(bool isMuted)
{
	_impl->MuteLocalAudioImpl(isMuted);
}

void SDKContext::sendAudioData(void* buffer, unsigned int length, unsigned int sample_rate, bool b2ndMic)
{
	_impl->SendAudioFrameImpl(buffer, length, sample_rate);
}


void SDKContext::sendAudioDataContent(std::string msid, void* buffer, unsigned int length, unsigned int sample_rate)
{
	_impl->SendContentAudioFrameImpl(msid, buffer, length, sample_rate);
}


void SDKContext::getAudioData(void* buffer, unsigned int length, unsigned int sample_rate)
{
	_impl->ReceiveAudioFrameImpl(buffer, length, sample_rate);
}

void SDKContext::sendPasscode(std::string passcode)
{
	_impl->VerifyPasscodeImpl(passcode);
}

void SDKContext::setContentAudio(bool enable, bool isSameDevice)
{
	_impl->SetContentAudioImpl(enable, isSameDevice);
}

void SDKContext::clearVideoData(std::string msid)
{
	_impl->ResetVideoFrameImpl(msid);
}

void SDKContext::dropCall(int callIndex)
{
	_impl->EndMeetingImpl(callIndex);
}


void SDKContext::setGridLayoutMode(bool gridMode)
{
	_impl->SetLayoutGridModeImpl(gridMode);
}

void SDKContext::setIntelligentNoiseReduction(bool enable)
{
	_impl->SetIntelligentNoiseReductionImpl(enable);
}

void SDKContext::setVideoMirror(bool video_mirror)
{
    _impl->SetCameraStreamMirrorImpl(video_mirror);
}


std::string SDKContext::getStatisticsAsString()
{
	std::string staticsString = _impl->GetMediaStatisticsImpl();

	return staticsString;
}

void SDKContext::startSendContent(std::string name, int index)
{
	_impl->StartSendContentImpl();
}

void SDKContext::startContent()
{
	_impl->StartSendContentImpl();
}

void SDKContext::stopSendingContent()
{
	_impl->StopSendContentImpl();
}


std::string SDKContext::onDeviceName()
{
	return "Qt device";
}


int SDKContext::getCPULevel()
{
	return _impl->GetCPULevelImpl();
}

void SDKContext::setCameraCaps(std::string resolutionStr)
{
	_impl->SetCameraCapabilityImpl(resolutionStr);
}

std::string SDKContext::getVersion()
{
	std::string ver = _impl->GetSDKVersion();
	return ver;
}


void SDKContext::startShareScreen() {
	_impl->StartSendContentImpl();
}

void SDKContext::stopShareScreen() {
	_impl->StopSendContentImpl();
}

void SDKContext::aes_decode(const std::string& salt, const std::string& ciphered, std::string& decoded)
{
}

uint64_t SDKContext::StartUploadLogsImpl(const std::string meta_data, const std::string file_name, int file_count)
{
	return _impl->StartUploadLogsImpl(meta_data, file_name, file_count);
}

std::string SDKContext::GetUploadStatusImpl(uint64_t traction_id)
{
	return _impl->GetUploadStatusImpl(traction_id);
}

void SDKContext::CancelUploadLogsImpl(uint64_t traction_id)
{
	_impl->CancelUploadLogsImpl(traction_id);
}
