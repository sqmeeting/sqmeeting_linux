#ifndef CAMERAEVENTHEADER_H
#define CAMERAEVENTHEADER_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/select.h>
#include <sys/time.h>
//#include <linux/videodev2.h>
#include <stdbool.h>
#include <string>
#include <vector>
#include <list>

struct DEVICE_INFO
{
    std::string device_description;
    std::string bus_info;
    std::vector<std::string> device_paths;
};

struct FormatInfo
{
    unsigned int width;
    unsigned int height;
    unsigned int rate;
};

struct CameraCardBindDeviceName
{
    std::string cardNameOld;
    std::string cameraDeviceName;
};

//因为摄像头设备存在着同名摄像头设备，无法从摄像头名称区分所需要的摄像头，所以另起了一个别名，用来区分管理摄像头设备。
//命名规则： eg. 存在两个摄像头设备为CameraLog,在遍历过程中第一个获取的为 CameraLog，使用原始名称，第二个获取到的设备名为 CameraLog(1)。即使用别名
struct CameraInfo
{
    std::string cameraCardName; 	//摄像头别名即摄像头名称
    std::string cameraCardNameOld;  //摄像头原始名称
    std::string cameraDeviceName;
    std::string pid;
    std::string vid;
    std::list<FormatInfo> formats;
};

struct EventInfo
{
    bool action; //true:add false:remove
    std::string cameraName;
    std::string cameraDeviceName;
    std::string vid;
    std::string pid;
};


#endif // CAMERAEVENTHEADER_H
