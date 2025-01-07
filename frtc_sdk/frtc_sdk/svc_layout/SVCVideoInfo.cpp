#include "SVCVideoInfo.h"

SVCVideoInfo::SVCVideoInfo() {
    uuid = "";
    display_name = "";

    eVideoType = VIDEO_TYPE_INVALID; //3
    msid = "";

    resolution_width = 0;
    resolution_height = 0;
    
    removed = false;
    is_active = false;
    maxResolution = false;
    is_pinned = false;
	is_lecture = false;
}
