#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
#include<windows.h>
#endif


#include "SVCLayoutManager.h"
#include "sq_log.h"

#include <iostream>




//==================================================
// for SVC Layout
//==================================================

const std::string SVCLayoutManager ::kContentMSIDPrefixStr = "VCR";


//==================================================
// for class SVCLayoutManager
//==================================================

std::mutex SVCLayoutManager::m_Mutex;
SVCLayoutManager* SVCLayoutManager::shareInstance = nullptr;

SVCLayoutManager* SVCLayoutManager::getInstance() {
	if (nullptr == shareInstance) {
		std::lock_guard mutexLocker(m_Mutex);
		shareInstance = new SVCLayoutManager();
	}
	return shareInstance;
}

void SVCLayoutManager::releaseInstance() {
	if (nullptr != shareInstance) {
		std::lock_guard mutexLocker(m_Mutex);
		delete shareInstance;
		shareInstance = nullptr;
	}
}

SVCLayoutManager::SVCLayoutManager()
	: m_layout_mode(SVC_LAYOUT_MODE_NUMBER),
	m_remote_video_count(0),
	m_has_content_video(false),
	m_is_leture_mode(false),
	m_lecture_id(""),
	m_active_speaker_msid(""),
	m_active_speaker_uuid("")

 {
}

SVCLayoutManager::~SVCLayoutManager() {
}

void SVCLayoutManager::updateSVCLayout(const SDKLayoutInfo& layoutInfo)
{
	//remove unavailable video and update existing video
	auto iter = m_layout_video.begin();
	while (iter != m_layout_video.end())
	{
		auto found = std::find_if(layoutInfo.layout.begin(), layoutInfo.layout.end(), [&iter](const SDKItemInfo& item) { return iter->msid == item.msid; });
		if (found != layoutInfo.layout.end())
		{
			iter->display_name = found->display_name;
			iter->resolution_width = found->resolution_width;
			iter->resolution_height = found->resolution_height;
			iter->is_active = layoutInfo.activeSpeakerSourceId == found->msid;
			iter->is_pinned = layoutInfo.cellCustomUUID == found->uuid;
			bool isContent = found->msid.compare(0, SVCLayoutManager::kContentMSIDPrefixStr.length(), SVCLayoutManager::kContentMSIDPrefixStr) == 0;
			iter->eVideoType = isContent ? VIDEO_TYPE_REMOTE_CONTENT : VIDEO_TYPE_REMOTE_PEOPLE;
			++iter;
		}
		else
		{
			iter = m_layout_video.erase(iter);
		}
	}

	//add new video
	auto newiter = layoutInfo.layout.begin();
	for (newiter; newiter != layoutInfo.layout.end(); ++newiter)
	{
		auto found = std::find_if(m_layout_video.begin(), m_layout_video.end(), [&newiter](const SVCVideoInfo& item) { return newiter->msid == item.msid; });
		if (found == m_layout_video.end())
		{
			SVCVideoInfo videoInfo;
			videoInfo.uuid = newiter->uuid;
			videoInfo.msid = newiter->msid;
			videoInfo.display_name = newiter->display_name;
			videoInfo.resolution_width = newiter->resolution_width;
			videoInfo.resolution_height = newiter->resolution_height;
			videoInfo.is_active = layoutInfo.activeSpeakerSourceId == newiter->msid;
			videoInfo.is_pinned = layoutInfo.cellCustomUUID == newiter->uuid;
			videoInfo.eVideoType = layoutInfo.bContent ? VIDEO_TYPE_REMOTE_CONTENT : VIDEO_TYPE_REMOTE_PEOPLE;
			m_layout_video.emplace_back(videoInfo);
		}
	}

	m_has_content_video = layoutInfo.bContent;
	m_remote_video_count = m_layout_video.size();
	m_active_speaker_msid = layoutInfo.activeSpeakerSourceId;
	m_active_speaker_uuid = layoutInfo.activeSpeakerUuId;
	if (layoutInfo.mode != SVC_LAYOUT_MODE_NUMBER)
	{
		m_layout_mode = layoutInfo.mode;
	}
}

void SVCLayoutManager::updateLectureID(const std::string& lecture)
{
	m_is_leture_mode = lecture != "";
	m_lecture_id = lecture;
	for (auto& layout : m_layout_video)
	{
		if (!m_is_leture_mode)
			layout.is_lecture = false;
		else
		{
			if (layout.msid == m_lecture_id)
			{
				layout.is_lecture = true;
			}
			else
			{
				layout.is_lecture = false;
			}
		}
	}
}

std::string SVCLayoutManager::videoType(VideoType type) {
	if (type == VideoType::VIDEO_TYPE_REMOTE_PEOPLE) {
		return "VIDEO_TYPE_REMOTE";
	}
	else if (type == VideoType::VIDEO_TYPE_LOCAL_PEOPLE) {
		return "VIDEO_TYPE_LOCAL";
	}
	else if (type == VideoType::VIDEO_TYPE_REMOTE_CONTENT) {
		return "VIDEO_TYPE_CONTENT";
	}
	else {
		return "VIDEO_TYPE_INVALID";
	}
}

void SVCLayoutManager::clearRemoteUserInfo() {
	m_layout_video.clear();
}
