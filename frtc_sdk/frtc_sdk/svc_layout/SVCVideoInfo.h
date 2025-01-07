#ifndef SVCVIDEOINFO_H
#define SVCVIDEOINFO_H

#include <string>

typedef enum {
    VIDEO_TYPE_LOCAL_PEOPLE = 0,
    VIDEO_TYPE_REMOTE_PEOPLE,
    VIDEO_TYPE_REMOTE_CONTENT,
    VIDEO_TYPE_INVALID
} VideoType;


struct SVCVideoInfo {   
public:
    SVCVideoInfo();
    ~SVCVideoInfo() {};
public:
    std::string uuid;
    std::string display_name;

    VideoType eVideoType;
    std::string msid;

    int resolution_width;
    int resolution_height;
    
    bool removed;
    bool is_active;
    bool maxResolution;
    bool is_pinned;
    bool is_lecture;
};

#endif // SVCVIDEOINFO_H
