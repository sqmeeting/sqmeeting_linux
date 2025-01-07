//

#ifndef SVCITEMINFO_H
#define SVCITEMINFO_H

#include <QList>

//using namespace std;
namespace MeetingLayout
{
class SDKItemInfo {
    
public:
    SDKItemInfo();
    
    std::string strDisplayName;
    std::string dataSourceID;
    std::string strUUID;

    unsigned int nSSRC;
    unsigned int resolution_width;
    unsigned int resolution_height;
    float        framerate;
    unsigned int bitrate;
    unsigned int surefaceIndex;
    unsigned int reqSSRC;

    bool is_pinned;
    bool is_active;
};

typedef struct _SDK_LAYOUT_INFO {
    QList<SDKItemInfo *> *layout;
    bool bContent;
    std::string activeSpeakerSourceId;
    std::string activeSpeakerUuId;
    std::string cellCustomUUID;
} SDKLayoutInfo;

}

#endif // SVCITEMINFO_H
