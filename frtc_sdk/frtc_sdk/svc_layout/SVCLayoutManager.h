#ifndef SVCLAYOUTMANAGER_H
#define SVCLAYOUTMANAGER_H

#include <mutex>
#include <list>
#include <string>

#include "SVCVideoInfo.h"
#include "SDKContextWrapper.h"


#define REMOTE_PEOPLE_VIDEO_NUMBER 9



typedef struct _SVCLayoutDetail {
    int videoViewNum;
    bool isSymmetical;
    float videoViewDescription[REMOTE_PEOPLE_VIDEO_NUMBER+2][4];  // +2 means adding local and content view
} SVCLayoutDetail;

typedef std::list<SVCVideoInfo> SVCVIDEOLIST;

class SVCLayoutManager {

private:
    static std::mutex m_Mutex;
    static SVCLayoutManager *shareInstance;
public:
    static SVCLayoutManager* getInstance();
    static void releaseInstance();
private:
    SVCLayoutManager();
    ~SVCLayoutManager();

public:
    static const std::string kContentMSIDPrefixStr;

public:

    SVCLayoutDetail gSvcLayoutDetail[SVC_LAYOUT_MODE_NUMBER] = {0};
    void updateSVCLayout(const SDKLayoutInfo& layoutInfo);
	SVCVIDEOLIST& getSVCLayoutVideo() { return m_layout_video; }

    void updateLectureID(const std::string& lecture);
    
private:
    SVCVIDEOLIST                m_layout_video;
	SVCLayoutModeType           m_layout_mode;
    int                         m_remote_video_count;
    bool    		            m_has_content_video;
	bool                        m_is_leture_mode;
    std::string                 m_lecture_id;
    std::string                 m_active_speaker_msid;
    std::string                 m_active_speaker_uuid;

public:

    SVCLayoutModeType getSvcLayoutMode() {return m_layout_mode; }
    
    bool m_gridModeLayout;
    bool isGridModeLayout () { return m_gridModeLayout; }

public:
    void clearRemoteUserInfo();
    
    std::string videoType(VideoType type);    
};

#endif // SVCLAYOUTMANAGER_H
