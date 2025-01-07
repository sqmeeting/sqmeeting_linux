#ifndef SVCVIDEOINFO_H
#define SVCVIDEOINFO_H

#include <iostream>

//using namespace std;

namespace MeetingLayout
{

typedef enum {
    VIDEO_TYPE_LOCAL = 0,
    VIDEO_TYPE_REMOTE,
    VIDEO_TYPE_CONTENT,
    VIDEO_TYPE_INVALID
} VideoType;


class SVCVideoInfo {
    
public:
    SVCVideoInfo();

public:
    std::string strUUID;
    std::string strDisplayName;

    VideoType eVideoType;
    std::string dataSourceID;

    int resolution_width;
    int resolution_height;
    
    bool removed;
    bool active;
    bool maxResolution;
    bool pin;

    bool isRemoved () {
        return removed;
    }
    
    bool isActive () {
        return active;
    }
    
    bool isMaxResolution () {
        return maxResolution;
    }

    bool isPin () {
        return pin;
    }
};
}

#endif // SVCVIDEOINFO_H
