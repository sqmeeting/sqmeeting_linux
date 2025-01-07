#include "SVCVideoInfo.h"

namespace MeetingLayout
{

SVCVideoInfo::SVCVideoInfo() {
    strUUID = ""; //qt";
    strDisplayName = ""; //qt";

    eVideoType = VIDEO_TYPE_INVALID; //3
    dataSourceID = "";

    resolution_width = 0;
    resolution_height = 0;
    
    removed = false;
    active = false;
    maxResolution = false;
    pin = false;
}
}
