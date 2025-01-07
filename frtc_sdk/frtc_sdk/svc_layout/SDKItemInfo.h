#ifndef SVCITEMINFO_H
#define SVCITEMINFO_H

#include <string>
#include <list>


typedef enum _SVCLayoutModeType {
    SVC_LAYOUT_MODE_1N5,
    SVC_LAYOUT_MODE_GALLERY,
    SVC_LAYOUT_MODE_NUMBER
} SVCLayoutModeType;

class SDKItemInfo {
    
public:
    SDKItemInfo();
    
    std::string display_name;
    std::string msid;
    std::string uuid;

    unsigned int ssrc;
    unsigned int resolution_width;
    unsigned int resolution_height;
    float        framerate;
    unsigned int bitrate;
    unsigned int sureface_index;
    unsigned int req_ssrc;
};

typedef struct _SDK_LAYOUT_INFO {
    std::list<SDKItemInfo> layout;
    bool bContent;
    std::string activeSpeakerSourceId;
    std::string activeSpeakerUuId;
    std::string cellCustomUUID;
    SVCLayoutModeType mode;
} SDKLayoutInfo;



#endif // SVCITEMINFO_H
