#ifndef CAMERAEVENT_H
#define CAMERAEVENT_H

#include <map>
#include <QObject>
#include "CameraEventHeader.h"
#include "FrtcCall.h"

class CameraEvent:public QObject
{
    Q_OBJECT

public:
    CameraEvent();
    ~CameraEvent();
    void setDeviceMonitorCallObject(FrtcCallObserverInterface *sdkObserver);


    /**
     * @name: 获取摄像头列表
     * @msg:
     * @param {*}
     * @return 返回摄像头列表—map
     */
    std::map<std::string, DEVICE_INFO> getCameraList();
    /**
     * @name: 获取摄像头分辨率列表
     * @msg:
     * @param {string} devicename - 摄像头驱动名称
     * @return {*} 摄像头分辨率列表
     */
    std::list<FormatInfo> getCameraResolutions(std::string devicename);
    /**
     * @name: 获取摄像头图像格式列表
     * @msg:
     * @param {*}
     * @return {*} 返回所有信息列表
     */
    std::list<CameraInfo> getCameraFormats();
    /**
     * @name: 获取摄像头输入事件设备vid.pid列表
     * @msg:
     * @param {*}
     * @return {*} 摄像头输入事件vid,pid列表
     */
    std::map<std::string, std::string> getInputVPIDs();
    /**
     * @name: 摄像头列表添加摄像头
     * @msg:
     * @param {string} devicename 摄像头驱动名称
     * @param {string} vid
     * @param {string} pid
     * @param {list<CameraInfo>} &cameras 摄像头列表
     * @return {*} 插入结果
     */
    bool addCameraInfo(std::string devicename, std::string vid, std::string pid, std::list<CameraInfo> &cameras);
    /**
     * @name: 摄像头列表移除摄像头
     * @msg:
     * @param {string} devicename 摄像头驱动名称
     * @param {list<CameraInfo>} &cameras 摄像头列表
     * @return {*} 移除结果
     */
    bool removeCameraInfo(std::string devicename, std::list<CameraInfo> &cameras);
    /**
     * @name: 摄像头推流启动
     * @msg:
     * @param {string} devicename 摄像头驱动名称
     * @param {int} width   分辨率-宽
     * @param {int} height 分辨率-高
     * @param {string} host 目标主机地址
     * @param {string} port 目标主机端口
     * @return {*}
     */
    void cameraGstPushStreamStart(std::string devicename, int width, int height, std::string host, std::string port);
    /**
     * @name: 摄像头推流停止
     * @msg:
     * @param {string} devicename 摄像头驱动名称
     * @return {*}
     */
    void cameraGstPushStreamStop(std::string devicename);

    int udevadmMonitor(struct udev *udev,  struct udev_monitor* &kernelMonitor, fd_set &readFds);
       /**
        * @name: udev admmonitor item 子元素事件
        * @msg:
        * @param {udev_monitor*} &kernelMonitor
        * @param {fd_set} &readFds
        * @return {*}
        */
      EventInfo udevadmMonitorItem(struct udev_monitor* &kernelMonitor, fd_set &readFds);

public slots:
    void getVideoDeviceList();

private:
    std::vector<std::string> currentCameraList;
    FrtcCallObserverInterface *_sdkObserver;
};

#endif // CAMERAEVENT_H
