#ifndef VIDEOCAPTURE_H
#define VIDEOCAPTURE_H

//#if defined(__APPLE__)

#include <QObject>
#include <QThread>
#include <QMutex>

#include <QTimer>
#include <QCamera>

#define FONT_SIZE 12
#define QCAMERA_CAPTURE_MODE "Image Mode"
#define QCAMERA_VIDEO_MODE "Video Mode"
#define DIR_USERDATA "/userdata"


#include <QAbstractListModel>
#include <QModelIndex>

#include <QMediaRecorder>
#include <QMediaMetaData>

#include <QMessageBox>
#include <QPalette>
#include <QTabWidget>
#include <QtWidgets>
#include <QHBoxLayout>
#include <QVBoxLayout>

#define FONT_SIZE 12
#define QCAMERA_CAPTURE_MODE "Image Mode"
#define QCAMERA_VIDEO_MODE "Video Mode"
#define DIR_USERDATA "/userdata"

#define DIR_HOME QStandardPaths::writableLocation(QStandardPaths::HomeLocation)

#include <QCamera>
#include <QPushButton>
#include <QMainWindow>
#include <QMediaRecorder>
#include <QScopedPointer>

#include <QMediaRecorder>
#include <QMediaMetaData>

//
#include <QMainWindow>
#include <QCamera>


//Qt6
#include <QCamera>
#include <QMediaCaptureSession>
#include <QMediaDevices>
#include <QVideoSink>
#include <QVideoFrame>


#include <iostream>

using namespace std;

//视频输出尺寸
//#define VIDEO_WIDTH  1920
//#define VIDEO_HEIGHT 1080

#define VIDEO_WIDTH  1280
#define VIDEO_HEIGHT 720

//#define VIDEO_WIDTH  1024
//#define VIDEO_HEIGHT 768

//#define VIDEO_WIDTH  640
//#define VIDEO_HEIGHT 480

//[Note]: for video dump.
//#define DEFINE_DUMP_VIDEO_CAPTURE_MACOS


class QtCameraCapture;

class UnifiedVideoCapture : public QObject {

    Q_OBJECT

private:
    static QMutex m_Mutex;
    static UnifiedVideoCapture *shareInstance;
public:
    static UnifiedVideoCapture* getInstance();
    static void releaseInstance();
private:
    UnifiedVideoCapture(QObject *parent = nullptr);
    ~UnifiedVideoCapture();

private:
    QThread *m_thread = nullptr;

signals:
    void complete();


public slots:
    void slotTimeOutHandler(); //for timer.
    void slotProcessVideoFrame(const QVideoFrame &frame);

signals:
    void VideoDataOutput(QImage ); //输出信号

public:
    bool isRecording; //flag for local camera capture recording.
    bool isRunning;

public:
    //actually start the Thread and the Timer for receive remote audio stream.
    void startTimerThread();
    void stopTimerThread();


public:
    QList<QCameraDevice> m_cameraDeviceList;
    QScopedPointer<QCamera> my_camera;

    bool camera_state;

    void refreshCameraDevices();
    void getCameraList(std::vector<QCameraDevice> &cameraList);

    void on_camera1_btn_clicked();


    void initCamera();
    void startCameraCaptureFrame();

    void frtcSwitchCamera(QString id);

    void re_new_camera();

private:
    QString locationDir;

    int imageCnt;
    int videoCnt;
    QMediaDevices mediaDevices;

    QCamera               * m_camera;
    QCameraDevice           m_camera_device;
    QMediaCaptureSession    m_captureSession;
    QVideoSink              m_videoSink;
    int                     frame_num;
    QString                 currentCameraID;

private slots:
    void slotNewVideoFrame(const QVideoFrame &frame);

public:
    std::string sourceID; //for local people, from camera.
    void setVideoSourceId(const std::string& sourceId);
    void onOpenCameraComplete(int nOpenResulte);

    void checkCameraPermission();
    void checkAuthorizationStatus();
};

#endif


//#endif //VIDEOCAPTURE_H



