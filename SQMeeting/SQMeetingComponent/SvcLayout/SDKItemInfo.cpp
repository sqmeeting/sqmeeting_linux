#include "SDKItemInfo.h"

namespace MeetingLayout
{
SDKItemInfo::SDKItemInfo() {
    strDisplayName = "";
    dataSourceID = "";
    strUUID = "";

    nSSRC = 0;
    resolution_width = 0;
    resolution_height = 0;
    framerate = 0.0;
    bitrate = 0;
    surefaceIndex = 0;
    reqSSRC = 0;
}
}
