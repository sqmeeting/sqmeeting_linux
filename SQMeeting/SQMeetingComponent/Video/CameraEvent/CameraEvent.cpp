#include "CameraEvent.h"
//-----------------------------------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <getopt.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <malloc.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include <asm/types.h>
#include <linux/videodev2.h>
#include <linux/v4l2-common.h>
#include <linux/v4l2-controls.h>
#include <linux/videodev2.h>
#include <linux/media.h>
#include <linux/input.h>
#include <sys/types.h>
#include <dirent.h>
#include <iostream>
#include <algorithm>
#include <list>
#include <iomanip>
#include <libudev.h>

#include <QDebug>
#include "DeviceMonitor.h"

CameraEvent::CameraEvent()
{
    connect(DeviceMonitor::getInstance(),SIGNAL(pushNotification()),this,SLOT(getVideoDeviceList()));
}

CameraEvent::~CameraEvent()
{

}

void CameraEvent::setDeviceMonitorCallObject(FrtcCallObserverInterface *sdkObserver)
{
    _sdkObserver = sdkObserver;
}

void CameraEvent::getVideoDeviceList()
{
    qDebug() << "Test get video device list slot function";
    std::map<std::string, DEVICE_INFO> updateCameraMap = getCameraList();

    std::vector<std::string> tempCameras;

    for(auto it = updateCameraMap.begin(); it != updateCameraMap.end(); it++)
    {
       tempCameras.push_back(it->first);
    }

    if(currentCameraList != tempCameras)
    {
        qDebug() << "need to update cameras list";
        currentCameraList = tempCameras;

        std::vector<QString> camList;

        for(auto it = currentCameraList.begin(); it != currentCameraList.end(); it++)
        {
             QString qstr = QString::fromStdString(*it);
             camList.push_back(qstr);
        }

        _sdkObserver->updateCameraList(camList);
    }


}

std::map<std::string, DEVICE_INFO> CameraEvent::getCameraList()
{
     std::map<std::string, DEVICE_INFO> cameras;

     std::vector<std::string> files;

     const std::string dev_folder = "/dev/";

     DIR *dir;
     struct dirent *ent;
     if ((dir = opendir(dev_folder.c_str())) != NULL)
     {
         while ((ent = readdir(dir)) != NULL)
         {
             if (strlen(ent->d_name) > 5 && !strncmp("video", ent->d_name, 5)) {

                 std::string file = dev_folder + ent->d_name;

                 const int fd = open(file.c_str(), O_RDWR);
                 v4l2_capability capability;
                 if (fd >= 0) {
                     if (ioctl(fd, VIDIOC_QUERYCAP, &capability) >= 0)
                     {
                         files.push_back(file);
                         std::cout << std::endl;
                         std::cout << "print the file name:" << file << std::endl;
                     }
                     close(fd);
                 }
             }
         }
         closedir(dir);
     }
     else
     {
         std::string msg = "Cannot list " + dev_folder + " contents!";
         throw std::runtime_error(msg);
     }

     std::sort(files.begin(), files.end());

     struct v4l2_capability vcap;

     for (const auto &file : files)
     {
         int fd = open(file.c_str(), O_RDWR);
         std::string bus_info;
         std::string card;

         if (fd < 0)
             continue;
         int err = ioctl(fd, VIDIOC_QUERYCAP, &vcap);
         if (err)
         {
             struct media_device_info mdi;

             err = ioctl(fd, MEDIA_IOC_DEVICE_INFO, &mdi);
             if (!err)
             {
                 if (mdi.bus_info[0])
                     bus_info = mdi.bus_info;
                 else
                     bus_info = std::string("platform:") + mdi.driver;

                 if (mdi.model[0])
                     card = mdi.model;
                 else
                     card = mdi.driver;
             }
         }
         else
         {
             if(vcap.device_caps == (V4L2_CAP_STREAMING + V4L2_CAP_EXT_PIX_FORMAT + V4L2_CAP_VIDEO_CAPTURE))
             {
                 bus_info = reinterpret_cast<const char *>(vcap.bus_info);
                 card = reinterpret_cast<const char *>(vcap.card);

                 std::cout << "print the camera list" << std::endl;
                 std::cout << std::string(card) << "and " << std::string(bus_info) << std::endl;
                 std::cout << "end the camera list" << std::endl;
             }
         }
         close(fd);

         if (!bus_info.empty() && !card.empty())
         {

             if (cameras.find(bus_info) != cameras.end())
             {
                 DEVICE_INFO &device = cameras.at(bus_info);
                 device.device_paths.emplace_back(file);
             }
             else
             {
                 DEVICE_INFO device;
                 device.device_paths.emplace_back(file);
                 device.bus_info = bus_info;
                 device.device_description = card;
                 cameras.insert(std::pair<std::string, DEVICE_INFO>(card, device));
             }
         }
     }

     std::cout << "begin to print the map list" << std::endl;
     for(auto it = cameras.begin(); it != cameras.end(); it++)
     {
         std::cout << it->first << " " << std::endl;
         std::cout << it->second.bus_info << " ";
         std::cout << it->second.device_description << " ";
         std::cout << it->second.device_paths.size() << std::endl;
         for(auto item = it->second.device_paths.begin(); item != it->second.device_paths.end(); item++)
         {
             std::cout << *item << std::endl;
         }
     }

     return cameras;
 }

std::list<FormatInfo> CameraEvent::getCameraResolutions(std::string dev)
{
    std::list<FormatInfo> resolutions = {};

    int fd = open(dev.c_str(), O_RDONLY);
    if (fd < 0)
    {
        std::cout << dev << ":Open fail!!!" << std::endl;
    }
    struct v4l2_format vfmt = {.type=V4L2_BUF_TYPE_VIDEO_OUTPUT};
    if(ioctl(fd,VIDIOC_G_FMT, &vfmt))
    {
        std::string format = (vfmt.fmt.pix.pixelformat == V4L2_PIX_FMT_YUYV) ? "YUYV" : std::to_string(vfmt.fmt.pix.pixelformat);
        std::cout << format  <<  " " << vfmt.fmt.pix.width  << " " << vfmt.fmt.pix.height << std::endl;
    }
    else
    {
        std::cout << "vfmt:get fail!" << std::endl;
    }

    struct v4l2_fmtdesc fmt = {.index=0, .type=V4L2_BUF_TYPE_VIDEO_CAPTURE};
    std::cout << "Start Search format resolutions" << std::endl;;

    while(ioctl(fd, VIDIOC_ENUM_FMT, &fmt) >=0 )
    {
        std::cout << "Picture Format:" << fmt.description << std::endl;
        if(fmt.pixelformat == V4L2_PIX_FMT_YUYV)
        {
            std::cout << "Picture Format is YUYV" << std::endl;

            FormatInfo fmtInfo;
            struct v4l2_frmsizeenum frmsize = {.index=0, .pixel_format=fmt.pixelformat};
            while(ioctl(fd, VIDIOC_ENUM_FRAMESIZES, &frmsize) == 0)
            {
                fmtInfo.width = frmsize.discrete.width;
                fmtInfo.height = frmsize.discrete.height;
                fmtInfo.rate = 0;
                std::cout << "Resolution: " << fmtInfo.width << "X" << fmtInfo.height << std::endl;

                struct v4l2_frmivalenum frmival = {.index=0, .pixel_format=frmsize.pixel_format, .width=frmsize.discrete.width, .height=frmsize.discrete.height};
                while(ioctl(fd, VIDIOC_ENUM_FRAMEINTERVALS, &frmival) >= 0)
                {
                    unsigned int maxRate = 0;
                    if(frmival.type == V4L2_FRMIVAL_TYPE_DISCRETE)
                    {
                        //std::cout << '\t' << "frmival.discrete: " << fract2fps_int(frmival.discrete) << std::endl;
                        //maxRate = fract2fps_int(frmival.discrete);
                    }
                    else if (frmival.type == V4L2_FRMIVAL_TYPE_CONTINUOUS || frmival.type == V4L2_FRMIVAL_TYPE_STEPWISE)
                    {
                        //std::cout << "stepwise.max: " << fract2fps(frmival.stepwise.max) << std::endl;
                        //maxRate = fract2fps_int(frmival.stepwise.max);
                    }
                    fmtInfo.rate = (maxRate > fmtInfo.rate) ? maxRate : fmtInfo.rate;
                    frmival.index++ ;
                }
                resolutions.push_back(fmtInfo);
                frmsize.index++;
            }
            break;
        }
        else
        {
            fmt.index ++;
        }
    }
    std::cout << "End Search format resolutions" << std::endl;;
    close(fd);

    return resolutions;
}

std::list<CameraInfo> CameraEvent::getCameraFormats()
{
    std::list<CameraInfo> cameraInfos;
    std::map<std::string, DEVICE_INFO> cameras = getCameraList();

    std::map<std::string, std::string> vpIDs = getInputVPIDs();
    for(auto it=cameras.begin(); it != cameras.end(); it++)
    {
        CameraInfo camInfo = {.cameraCardName = it->first, .cameraCardNameOld = it->second.device_description, .cameraDeviceName=it->second.bus_info};
        camInfo.formats = getCameraResolutions(camInfo.cameraDeviceName);
        camInfo.vid = vpIDs[camInfo.cameraCardNameOld].substr(0, 4);
        camInfo.pid = vpIDs[camInfo.cameraCardNameOld].substr(5, 4);
        cameraInfos.push_back(camInfo);
    }

    std::cout << "Output Cameras Info:" << std::endl;
    for(auto it: cameraInfos)
    {
        std::cout << it.cameraCardName << " " << it.cameraCardNameOld << " " << it.cameraDeviceName << " " << it.vid << " " << it.pid << std::endl;
        for(auto itr : it.formats)
        {
            std::cout << itr.height << " " << itr.width << " " << itr.rate << std::endl;
        }
    }

    return cameraInfos;
}

static int get_intputdevice_info(std::string file, std::string &cardname, std::string &vpID)
{
    int fd = open(file.c_str(), O_RDWR);
    std::string bus_info;
    char cardName[256] = "";
    struct input_id inputId;
    if (fd < 0)
        return 1;
    int err_id = ioctl(fd, EVIOCGID, &inputId);
    if (err_id)
    {
        std::cout << "err_id:" << err_id << std::endl;
    }
    else
    {
        std::stringstream buf;
        buf << std::hex << std::setw(4) << std::setfill('0') << inputId.vendor << ":" << std::setw(4) << std::setfill('0') << inputId.product;
        buf >> vpID;
        int len = ioctl(fd, EVIOCGNAME(sizeof(cardName)), cardName);
        std::cout << "cardName:" << std::string(cardName, len) << " VID/PID value:" << vpID << std::endl;
    }
    close(fd);
    cardname = reinterpret_cast<const char *>(cardName);

    return err_id;
}

std::map<std::string, std::string> CameraEvent::getInputVPIDs()
{
    std::map<std::string, std::string> inputInfos;

    DIR *dp;
    struct dirent *ep;
    std::vector<std::string> files;

    dp = opendir("/dev/input");
    if (dp == nullptr) {
        perror ("Couldn't open the directory");
        return {};
    }
    while ((ep = readdir(dp)))
        if (std::string(ep->d_name).find("event") != std::string::npos)
            files.push_back(std::string("/dev/input/") + ep->d_name);
    closedir(dp);

    std::sort(files.begin(), files.end());

    for (const auto &file : files)
    {
        std::string card,vpID;
        int err_id = get_intputdevice_info(file, card, vpID);
        if(err_id)
            continue;
        if(!inputInfos.count(card))
        {
            inputInfos[card] = vpID;
        }
    }

    return inputInfos;
}

bool CameraEvent::addCameraInfo(std::string devicename, std::string vid, std::string pid, std::list<CameraInfo> &cameras)
{
    CameraInfo info = {.cameraCardName = "", .cameraCardNameOld = "", .cameraDeviceName = devicename, .pid = pid, .vid = vid};

    int fd = open(devicename.c_str(), O_RDWR);
    std::string bus_info;
    std::string card;
    struct v4l2_capability vcap;

    if (fd < 0)
    {
        std::cout << "Open file fail:" << devicename << std::endl;
        return false;
    }
    int err = ioctl(fd, VIDIOC_QUERYCAP, &vcap);
    bool is_mate = 0;
    if (err)
    {

    } else
    {
        if(vcap.device_caps == (V4L2_CAP_STREAMING + V4L2_CAP_EXT_PIX_FORMAT + V4L2_CAP_VIDEO_CAPTURE))
        {
            bus_info = reinterpret_cast<const char *>(vcap.bus_info);
            card = reinterpret_cast<const char *>(vcap.card);
            std::cout << std::string(card) <<" "<< std::string(devicename) << " " << std::string(bus_info) << std::endl;
        }
        else if(vcap.device_caps == (V4L2_CAP_STREAMING + V4L2_CAP_META_CAPTURE + V4L2_CAP_EXT_PIX_FORMAT))
        {
            is_mate = true;
        }
    }
    close(fd);
    if(err || is_mate)
    {
        std::cout << "Open devicename fail:" << devicename << " or deveice type is mate" <<std::endl;
        return false;
    }

    bool InsertFlags = false;
    int count = 0;;
    for(auto it: cameras)
    {
        if(std::string(card) == it.cameraCardNameOld)
        {
            count++;
            InsertFlags = true;
        }
    }
    info.cameraCardName = (count) ? card + "(" + std::to_string(count) + ")" : card;
    info.cameraCardNameOld = card;
    info.formats = getCameraResolutions(devicename);

    cameras.push_back(info);
    return true;
}

bool CameraEvent::removeCameraInfo(std::string cardName, std::list<CameraInfo> &cameras)
{
    auto it = cameras.begin();
    bool ret = false;
    for(it; it != cameras.end(); it++)
    {
        if((*it).cameraCardName == cardName)
        {
            ret = true;
            it = cameras.erase(it);
            qDebug("[%s]", Q_FUNC_INFO);
            //cameraGstPushStreamStop((*it).cameraDeviceName);
        }
    }
    return ret;
}

int CameraEvent::udevadmMonitor(struct udev *udev, struct udev_monitor* &kernelMonitor, fd_set &readFds)
{
    if(getuid() != 0)
    {
        std::cout << "root privileges needed to subscribe to kernel events." << std::endl;
        udev_monitor_unref(kernelMonitor);
        return 0;
    }

    std::cout << "monitor will print the received events." << std::endl;

    kernelMonitor = udev_monitor_new_from_netlink(udev, "udev");
    if(kernelMonitor == nullptr)
    {
        udev_monitor_unref(kernelMonitor);
        return 3;
    }

    udev_monitor_filter_add_match_subsystem_devtype(kernelMonitor, "video4linux", nullptr);

    if(udev_monitor_enable_receiving(kernelMonitor) < 0)
    {
        udev_monitor_unref(kernelMonitor);
        return 4;
    }

    std::cout << "UEVENT the kernel uevent:" << std::endl;
    return 1;
}
//单次事件具体信息获取
EventInfo CameraEvent::udevadmMonitorItem(struct udev_monitor* &kernelMonitor, fd_set &readFds)
{
    EventInfo info;
    int fdCount = 0;
    FD_ZERO(&readFds);
    if(kernelMonitor != nullptr) {
        FD_SET(udev_monitor_get_fd(kernelMonitor), &readFds);
    }
    fdCount = select(udev_monitor_get_fd(kernelMonitor)+1, &readFds, nullptr, nullptr, nullptr);
    if(!fdCount)
    {
        if(errno != EINTR)
        {
            std::cout << "error receiving uevent message" << std::endl;
        }
        return {};
    }

    if((kernelMonitor != nullptr) && FD_ISSET(udev_monitor_get_fd(kernelMonitor), &readFds))
    {
        struct udev_device *device = udev_monitor_receive_device(kernelMonitor);
        if(device == nullptr)
        {
            return {};
        }
        if(std::string(udev_device_get_action(device)) == std::string("add") || std::string(udev_device_get_action(device)) == std::string("remove"))
        {
            struct udev_list_entry *devAttributes;
            udev_list_entry_foreach(devAttributes, udev_device_get_properties_list_entry(device))
            {
                std::string name(udev_list_entry_get_name(devAttributes));
                std::string value(udev_list_entry_get_value(devAttributes));
                if(name == std::string("ACTION"))
                    info.action = (value == std::string("add")) ? true : false;
                if(name == std::string("ID_V4L_PRODUCT"))
                    info.cameraName = value;
                if(name == std::string("ID_MODEL_ID"))
                    info.pid = value;
                if(name == std::string("ID_VENDOR_ID"))
                    info.vid = value;
            }
            info.cameraDeviceName = reinterpret_cast<const char *>(udev_device_get_devnode(device));

            std::cout   << udev_device_get_action(device) << " "
                        << udev_device_get_devpath(device) << " "
                        << udev_device_get_subsystem(device) << " "
                        << udev_device_get_devnode(device) << " "
                        << info.cameraName << " "
                        << info.vid << " "
                        << info.pid << " "
                        << std::endl;

        }
        udev_device_unref(device);
    }

    return info;
}
