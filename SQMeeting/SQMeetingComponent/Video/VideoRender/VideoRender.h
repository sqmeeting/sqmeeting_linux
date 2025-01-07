//
//  VideoRender.h
//  class VideoRender.
//  frtc_sdk Qt version.
//  [Note]: Render for the remote video.
//
//  Created by Yingyong.Mao on 2022/07/7.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef VIDEORENDER_H
#define VIDEORENDER_H

#include <QObject>
#include <QVideoSink>
#include <QPointer>
#include <QVideoFrame>

//#define DEFINE_DUMP_VIDEO_RENDERING

using namespace std;

enum VideoViewRenderPixelType {
    VideoViewRenderPixelType_I420,
    VideoViewRenderPixelType_NV12,
    VideoViewRenderPixelType_Unsupported,
};


// class VideoFrameProviderPrivate;


// //[Qt]:             | [macOS]:
// // VideoRender.cpp  | MetalVideoView.m;
// // VideoRenderView.qml  | VideoMetalVideoView.m.

class VideoRender : public QObject {
    Q_OBJECT
    
    //for UI [VideoRenderView.qml] to read & wirite.
    Q_PROPERTY(QVideoSink* videoSink READ videoSink WRITE setVideoSink NOTIFY videoSinkChanged)

    //for UI [VideoRenderView.qml] to read & wirite.
    //Q_PROPERTY(QAbstractVideoSurface *videoSurface READ videoSurface WRITE setVideoSurface)
    Q_PROPERTY(QString videoUrl READ videoUrl WRITE setVideoUrl NOTIFY videoUrlChanged)
    Q_PROPERTY(bool m_visible READ visible WRITE setVisible NOTIFY visibleChanged)

public:
    explicit VideoRender(QObject *parent = nullptr);
    ~VideoRender();

public:
    void initWithFrame(QRect rect, QString dataSourceID);

    QVideoSink* videoSink() const { return m_videoSink; }
    void setVideoSink(QVideoSink* videoSink) {
        //qDebug("[%s][%d]: -> call m_videoSink = (QVideoSink *)videoSink: %p", __FUNCTION__, __LINE__, videoSink);
        m_videoSink = (QVideoSink *)videoSink;
        //        emit sinkChanged();
    };

signals:
    void videoSinkChanged();

public slots:
    void deliverFrame(/*const*/ QVideoFrame& frame);

private:
    QPointer<QVideoSink> m_videoSink;

public:
    //    QAbstractVideoSurface *videoSurface();
    //    void setVideoSurface(QAbstractVideoSurface *surface);

public:
    QTimer *m_timer = nullptr;
public:
    QString m_videoUrl;
    QString videoUrl() const;
    void setVideoUrl(const QString &url);

    bool m_visible;
    bool visible() const;
    void setVisible(const bool visible);

    //void setFormat(int width, int height, QPixelFormat pixFormat);
    void setFormat(int width, int height, QVideoFrameFormat::PixelFormat pixFormat);

signals:
    /**
     * @brief newVideoFrameAvailable: received new video frame data.
     * @param frame: Video frame data.
     */
    void newVideoFrameAvailable(const QVideoFrame &frame);
    void videoUrlChanged();
    void visibleChanged();

public slots:
    void onNewVideoFrameReceived(const QVideoFrame &frame);
    void onFrameSizeChanged(int width, int height);

signals:
    //signals will trigger the onXXX function of QML.
    //for show/hide mute image.
    void cppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage();


public:
    void getVideoDataAndRender(std::string aDataSourceID);
    void getVideoData(std::string sourceID,
                      void **buffer,
                      unsigned long* length,
                      unsigned int* width,
                      unsigned int* height);

public:
    // [define action with Q_INVOKABLE with public:]: QML could call those mothod for action.
    Q_INVOKABLE void setFrameSize(int x, int y, int width, int height);
    Q_INVOKABLE void startRendering();
    Q_INVOKABLE void stopRendering();
    Q_INVOKABLE void renderMuteImage(bool mute);
    Q_INVOKABLE void setRenderSourceID(QString sourceID);


public:
    int preferredFramesPerSecond;

    std::string uuid;

    std::string m_dataSourceID;

    int m_video_width;
    int m_video_height;

public:
    bool renderMutePic;
    bool isRenderMutePic() { return renderMutePic; };
    bool rendering = false;
    bool isRendering() { return rendering; };
    bool isReceivedNewVideoFrameData = false;

    QVideoFrame QVideoFrame_fromImage(const QImage& image);
    
};

#endif // VIDEORENDER_H
