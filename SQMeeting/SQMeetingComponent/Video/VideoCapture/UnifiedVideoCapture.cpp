#if defined(__APPLE__) || defined(WIN32) || defined(UOS)

#if defined(WIN32)
    #define __PRETTY_FUNCTION__ __FUNCSIG__ 
#endif


#include "UnifiedVideoCapture.h"

#include <QDebug>
#include <QDateTime>

#include <iostream>
#include <QMediaDevices>
#include "FMakeCallClient.h"
#include "SDKUserDefault.h"

#if defined(WIN32)
    #include "SDKDeviceContext.h"
#endif

using namespace std;


// This is copied from MP; should be consistent with MP definition
enum VideoSampleType {
    SAMPLE_TYPE_NO_TYPE = 0,
    SAMPLE_TYPE_ARGB = 1,
    SAMPLE_TYPE_BGRA = 2 , // ARGB on Windows

    // 4:2:2 packed formats, 16 bits per pixel
    SAMPLE_TYPE_YUY2 = 3, // yuyv
    SAMPLE_TYPE_UYVY = 4, // = kCVPixelFormatType_422YpCbCr8 on Mac

    // 4:2:0 plannar formats, 12 bits per pixel
    SAMPLE_TYPE_I420 = 5, // plane1: YYYY... plane2: UU...  plane3: VV...
    SAMPLE_TYPE_YV12 = 6 , // same as I420, but v plane before u plane
    SAMPLE_TYPE_NV12 = 7, // U/V interleaved. plane1: YYYY... plane2: UVUV...
    SAMPLE_TYPE_NV21 = 8,  // same as NV12, U/V order reversed.
};

unsigned char rgb_buffer[VIDEO_WIDTH * VIDEO_HEIGHT * 3];

void UnifiedVideoCapture::slotProcessVideoFrame(const QVideoFrame &frame)
{
    //========== [convert to YUV420 and send to remote] ==========
    QVideoFrame videoFrame(frame);

    QVideoFrameFormat::PixelFormat pixelFormat = videoFrame.pixelFormat();
    //qDebug("pixelFormat == QVideoFrameFormat::Format_NV12 is %d", pixelFormat);
    int width = videoFrame.width();
    int height = videoFrame.height();
    int planeCount = videoFrame.planeCount();
    uchar *pdata = nullptr;
    int len = 0;

    videoFrame.map(QVideoFrame::ReadOnly);

    // for (int i = 0; i < planeCount; i++) {
    //     //pdata = videoFrame.bits(i);
    //     len += videoFrame.mappedBytes(i);
    //     //m_file.write((const char *)pdata, len);
    // }

    if (pixelFormat == QVideoFrameFormat::Format_UYVY) {
        int width = frame.width();
        int height = frame.height();
        int length = (int) width * height *  2;

        sourceID = "VPL_PREVIEW";
        QString qStrSourceID = QString::fromUtf8(sourceID.c_str());



        len = width * height * 1.5 ;
        size_t frame_size = width * height * 3 / 2;
        char *nv12_content = (char *)malloc(sizeof(char) * frame_size);
        if (!nv12_content) {
            free(nv12_content);
            return ;
        }
        size_t y_size = width * height;
        size_t pixels_in_a_row = width * 2;
        char *nv12_y_ptr = nv12_content;
        char *nv12_uv_ptr = nv12_content + y_size;
        int lines = 0;

        char *uyvy_content = (char*)videoFrame.bits(0);
        size_t file_size = width * height * 2;
        for (int i = 0;i < file_size;i += 4) {
            // copy y channel
            *nv12_y_ptr++ = uyvy_content[i + 1];
            *nv12_y_ptr++ = uyvy_content[i + 3];
            if (0 == i % pixels_in_a_row) {
                ++lines;
            }
            if (lines % 2) {       // extract the UV value of odd rows
                // copy uv channel
                *nv12_uv_ptr++ = uyvy_content[i];
                *nv12_uv_ptr++ = uyvy_content[i + 2];
            }
        }

        sourceID = "VPL_PREVIEW";
        FMakeCallClient::sharedCallClient()->send_local_video_frame(nv12_content, QString::fromStdString(sourceID), width * height * 3 / 2, width, height, QVideoFrameFormat::PixelFormat::Format_NV12);
        free(nv12_content);

    }
    else if(pixelFormat == QVideoFrameFormat::Format_NV12) {

        int width = frame.width();
        int height = frame.height();
        len = width * height * 3 / 2;

        sourceID = "VPL_PREVIEW";
        QString qStrSourceID = QString::fromUtf8(sourceID.c_str());
        
        FMakeCallClient::sharedCallClient()->send_local_video_frame((unsigned char*)videoFrame.bits(0), QString::fromStdString(sourceID), len, width, height, QVideoFrameFormat::PixelFormat::Format_NV12);
    }
    else if(pixelFormat == QVideoFrameFormat::Format_YUV420P)
    {
        int width = frame.width();
        int height = frame.height();
        len = width * height * 3 / 2;

        sourceID = "VPL_PREVIEW";
        QString qStrSourceID = QString::fromUtf8(sourceID.c_str());
        
        FMakeCallClient::sharedCallClient()->send_local_video_frame((unsigned char*)videoFrame.bits(0), QString::fromStdString(sourceID), len, width, height, QVideoFrameFormat::PixelFormat::Format_YUV420P);
    }
    else if(pixelFormat == QVideoFrameFormat::Format_YUYV)
    {
        int width = frame.width();
        int height = frame.height();
        len = width * height * 2;

        sourceID = "VPL_PREVIEW";
        QString qStrSourceID = QString::fromUtf8(sourceID.c_str());
        
        FMakeCallClient::sharedCallClient()->send_local_video_frame((unsigned char*)videoFrame.bits(0), QString::fromStdString(sourceID), len, width, height, QVideoFrameFormat::PixelFormat::Format_YUYV);
    }
    else
    {
        qDebug("Unhandled camera video format %d", pixelFormat);
    }
    videoFrame.unmap();
}

//==================================================
// for class UnifiedVideoCapture
//==================================================

QMutex UnifiedVideoCapture::m_Mutex;
UnifiedVideoCapture * UnifiedVideoCapture::shareInstance = nullptr;

UnifiedVideoCapture* UnifiedVideoCapture::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new UnifiedVideoCapture();
	    shareInstance->isRecording = false;
    }
    return shareInstance;
}

void UnifiedVideoCapture::releaseInstance() {
    qDebug("[%s][%d]: Enter.", __PRETTY_FUNCTION__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit.", __PRETTY_FUNCTION__, __LINE__);
}

UnifiedVideoCapture::UnifiedVideoCapture(QObject *parent)
                  : QObject(parent),
                    m_camera(nullptr),
                    m_thread(nullptr),
                    isRecording(false)
{
    m_camera_device = QMediaDevices::defaultVideoInput();
    m_camera = new QCamera(m_camera_device); //QCameraDevice

    QString default_camera = SDKUserDefault::getInstance()->getSelectCamera();

    if (default_camera.isNull() || default_camera.isEmpty()) {
        m_camera_device = QMediaDevices::defaultVideoInput();
        m_camera = new QCamera(m_camera_device); //QCameraDevice
    } else {
        const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();

        for (const QCameraDevice &cameraDevice : cameras)
        {
            if (cameraDevice.description().contains(default_camera, Qt::CaseInsensitive))
            {
                m_camera_device = cameraDevice;
                m_camera = new QCamera(m_camera_device);

                qDebug() <<"for loop ************the default_camera is " << default_camera;
            }
        }
    }

    refreshCameraDevices();
}

UnifiedVideoCapture::~UnifiedVideoCapture()
{
    qDebug("[%s][%d]", __PRETTY_FUNCTION__, __LINE__);

}


void UnifiedVideoCapture::startTimerThread()
{

    if (true == isRecording)
    {
        qDebug("[%s][%d] isRecording == true, then return.", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    else
    {
        qDebug("[%s][%d] set isRecording = true, then initCamera and start m_camera loop.", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        isRecording = true;

        initCamera();

#if defined(__APPLE__) || defined (UOS)
        //没用线程
        qDebug("[UnifiedVideoCapture::%s][%d] -> call startCameraCaptureFrame()", __FUNCTION__, __LINE__);
        startCameraCaptureFrame();

#elif defined(WIN32)
        int nOpenResulte = 0; //default: open successfully.

        qDebug("[%s][%d]: -> call onOpenCameraComplete(nOpenResulte: %s)", __FUNCTION__, __LINE__, (nOpenResulte ==0)?"true":"false");
        onOpenCameraComplete(nOpenResulte);
#endif
    }
}

void UnifiedVideoCapture::stopTimerThread()
{
    qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);
    if (false == isRecording)
    {
        qDebug("[%s][%d] isRecording == false, then return.", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    else
    {
        qDebug("[%s][%d] set isRecording = false, then stop m_camera loop.", __PRETTY_FUNCTION__, __LINE__);
        isRecording = false;
        
        qDebug("[%s][%d]: ", __PRETTY_FUNCTION__, __LINE__);

        if (m_camera != nullptr) {
            qDebug("[%s][%d]: -> call m_camera->stop()", __FUNCTION__, __LINE__);
            m_camera->stop();
            m_camera->deleteLater();
            m_camera = nullptr;
        }
    }
    qDebug("[%s][%d]: Exit", __PRETTY_FUNCTION__, __LINE__);
}

//[macOS]: not use the m_timer.
void UnifiedVideoCapture::slotTimeOutHandler() {
    qDebug("[%s][%d]: .", __PRETTY_FUNCTION__, __LINE__);
}

void UnifiedVideoCapture::startCameraCaptureFrame()
{
    if (nullptr != m_camera)
    {
        m_camera->start();
    }
}

void UnifiedVideoCapture::re_new_camera()
{
    m_camera = new QCamera(m_camera_device);
    startTimerThread();
}

void UnifiedVideoCapture::frtcSwitchCamera(QString id)
{
    // if(id == currentCameraID) {
    //     qDebug() << "Target camera is the same ad the current camera, NO change needed.";

    //     return;
    // }

    if(m_camera_device.description().contains(id, Qt::CaseInsensitive)) {
        qDebug("[%s][%d]:Current camera is the same as target, no change needed.", __FUNCTION__, __LINE__);
        return;
    }

    if(m_camera != nullptr) {
        qDebug("[%s][%d]:Stopping and deleting current camera.", __FUNCTION__, __LINE__);

        m_camera->stop();
        m_camera->deleteLater();
        m_camera = nullptr;
    }

    const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();
    bool cameraFound = false;

    for (const QCameraDevice &cameraDevice : cameras)
    {
        if (cameraDevice.description().contains(id, Qt::CaseInsensitive))
        {
            //stopTimerThread();
            m_camera_device = cameraDevice;
            m_camera = new QCamera(m_camera_device);

            qDebug("[%s][%d]:Switched to camera: %s", __FUNCTION__, __LINE__, qUtf8Printable(cameraDevice.description()));

            cameraFound = true;
            break;

            //currentCameraID = id;

            // startTimerThread();

            // return;
        }
    }

    if(!cameraFound) {
        qWarning("[%s][%d]:Camera with id '%s' not found.", __FUNCTION__, __LINE__, qPrintable(id));
        return;
    }

    initCamera();

    startTimerThread();

    m_camera->start();
}

//获取摄像头信息
void UnifiedVideoCapture::refreshCameraDevices()
{
    m_cameraDeviceList = QMediaDevices::videoInputs();

    int i = 0;
    for (const QCameraDevice &cameraDevice : m_cameraDeviceList) {
        qDebug("[%s][%d]: m_cameraDeviceList[%d].description(): %s", __FUNCTION__, __LINE__, i++, qUtf8Printable(cameraDevice.description()));
    }
}


void UnifiedVideoCapture::getCameraList(std::vector<QCameraDevice> &cameraList) {
    cameraList.clear();
    copy(m_cameraDeviceList.begin(), m_cameraDeviceList.end(), inserter(cameraList, cameraList.begin()));
}

//切换摄像头1
void UnifiedVideoCapture::on_camera1_btn_clicked()
{
    my_camera.reset(new QCamera(m_cameraDeviceList[0], this));

    my_camera->start();
    //更新摄像头状态
    camera_state = true;
}

void UnifiedVideoCapture::initCamera() {
    qDebug("[%s][%d]: ", __PRETTY_FUNCTION__, __LINE__);

    checkCameraPermission();
    checkAuthorizationStatus();

    if (m_camera->cameraFormat().isNull())
    {
        auto formats = m_camera_device.videoFormats();

        if (!formats.isEmpty())
        {
            QCameraFormat bestFormat;
            for (const auto &fmt : formats)
            {
                qDebug("enum frame format, format is %d, width is %d, height is %d, max rate is %f",fmt.pixelFormat(), fmt.resolution().width(), fmt.resolution().height(), fmt.maxFrameRate());
                if (fmt.pixelFormat() == QVideoFrameFormat::Format_NV12
                    && fmt.resolution().width() > fmt.resolution().height()
                    && bestFormat.resolution().width() < fmt.resolution().width()
                    && bestFormat.resolution().height() < fmt.resolution().height())
                {

                    qDebug("Test the code about use Formate_NV12");
                    bestFormat = fmt;
                }
                else if(fmt.pixelFormat() == QVideoFrameFormat::Format_YUYV)
                {
                    if(bestFormat.isNull() || 
                        (fmt.resolution().width() * 9 == fmt.resolution().height() * 16
                        && fmt.resolution().width() > bestFormat.resolution().width())
                        )
                    {
                        qDebug("Test the code about use Formate_YUYV, max rate is %f, width is %d, height is %d", fmt.maxFrameRate(), fmt.resolution().width(), fmt.resolution().height());
                        if(fmt.maxFrameRate() >= 29.0f)
                            bestFormat = fmt;
                    }
                }
            }
            m_camera->setCameraFormat(bestFormat);
        }
    }

    m_captureSession.setCamera(m_camera);
    m_captureSession.setVideoSink(&m_videoSink);

    connect(&m_videoSink, &QVideoSink::videoFrameChanged, this, &UnifiedVideoCapture::slotProcessVideoFrame);
    qDebug("[%s][%d] Exit", __PRETTY_FUNCTION__, __LINE__);
}

void UnifiedVideoCapture::slotNewVideoFrame(const QVideoFrame &frame)
{
    QVideoFrame videoFrame = frame;
    /**
     * 我的电脑上返回的格式是Format_NV12：18，每个像素1.5字节，一帧1382400字节，
     * 如果你需要用别的YUV或者RGB格式，则需要自己设置QVideoSink或者QCamera格式
     */
    QVideoFrameFormat::PixelFormat pixelFormat = videoFrame.pixelFormat();
    int width = videoFrame.width();
    int height = videoFrame.height();
    int planeCount = videoFrame.planeCount();
    uchar *pdata = nullptr;
    int len = 0;

    videoFrame.map(QVideoFrame::ReadOnly);

    for (int i = 0; i < planeCount; i++) {
        pdata = videoFrame.bits(i);
        len = videoFrame.mappedBytes(i);
        //m_file.write((const char *)pdata, len);
    }

    frame_num++;
    qDebug("%d, %d, %d, %d, %d, %p, %d", frame_num, pixelFormat, width, height, planeCount, pdata, len);
    qDebug("[%s][%d]: frame_num: %d, pixelFormat: %d, width: %d, height: %d, planeCount: %d, pdata: %p, len: %d",
           __FUNCTION__, __LINE__, frame_num, pixelFormat, width, height, planeCount, pdata, len);

    videoFrame.unmap();
}


void UnifiedVideoCapture::setVideoSourceId(const std::string& sourceId)
{
    QString qstr = QString::fromStdString(sourceId);
    qDebug("[ThreadID: %p][%s][%d]: set this->m_sourceID = %s.", QThread::currentThreadId(), __PRETTY_FUNCTION__, __LINE__, qPrintable(qstr));
    this->sourceID = sourceID;
}

void UnifiedVideoCapture::onOpenCameraComplete(int nOpenResulte)
{
#ifdef WIN32
    if (0 == nOpenResulte) {
        qDebug("[%s][%d]: open camera sucessfully then -> call m_thread->start()", __FUNCTION__, __LINE__);
        m_camera->start(); //[Note]: Windows not use thread.
    } else {
        qDebug("[%s][%d]: open camera failed -> send msg to QML UI", __FUNCTION__, __LINE__);
    }

    qDebug("[%s][%d]: open camera nOpenResulte: %d -> send msg to QML UI", __FUNCTION__, __LINE__, nOpenResulte);
    qDebug("[%s][%d] -> call SDKContext::sharedSDKContext()->onOpenCameraComplete(nOpenResulte: %d)", __FUNCTION__, __LINE__, nOpenResulte);
    SDKDeviceContext::getInstance()->onOpenCameraComplete(nOpenResulte);
#endif
}

void UnifiedVideoCapture::checkCameraPermission()
{
#if QT_CONFIG(permissions)

    QCameraPermission cameraPermission;
    switch (qApp->checkPermission(cameraPermission)) {
    case Qt::PermissionStatus::Undetermined:
        qApp->requestPermission(cameraPermission, this, &UnifiedVideoCapture::checkCameraPermission);
        return;
    case Qt::PermissionStatus::Denied:
        std::cout << "Camera permission is not granted!" << std::endl;
        return;
    case Qt::PermissionStatus::Granted:
        std::cout << "Camera permission is granted!" << std::endl;
        break;
    }

#endif
}

void UnifiedVideoCapture::checkAuthorizationStatus()
{
#if QT_CONFIG(permissions)

    QCameraPermission cameraPermission;
    Qt::PermissionStatus auth_status = Qt::PermissionStatus::Undetermined;
    while(true)
    {
        QThread::msleep(1);
        auth_status = qApp->checkPermission(cameraPermission);

        if(auth_status == Qt::PermissionStatus::Undetermined)
            continue;

        break;
    }

#endif // if QT_CONFIG
}




#endif
