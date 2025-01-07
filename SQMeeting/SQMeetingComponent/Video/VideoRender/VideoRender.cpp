#include "VideoRender.h"

#include <QFile>
#include <QFileInfo>
#include <QSharedPointer>
#include <QTimer>
#include <QDebug>
#include <QDateTime>
#include <QString>


#include <QVideoFrame>
#include "FMakeCallClient.h"

void VideoRender::deliverFrame(QVideoFrame& frame) {
    if (!m_videoSink)
        return;

    m_videoSink->setVideoFrame(frame);
}

void VideoRender::initWithFrame(QRect rect, QString dataSourceID) {

}

VideoRender::VideoRender(QObject *parent)
: QObject(parent) {
    m_video_width = 0;
    m_video_height = 0;

    int width = 1280;
    int height = 720;
    int size = width * height * 3 / 2;
    
    setFormat(width, height, QVideoFrameFormat::Format_YUV420P);


    if (nullptr == m_timer) {
        m_timer = new QTimer(this);

        connect(m_timer, &QTimer::timeout, this, [=] {
            getVideoDataAndRender(this->m_dataSourceID);
        });
    }
}

VideoRender::~VideoRender() {
    qDebug("[%s][%d]: this: %p -> call stopRendering()", __FUNCTION__, __LINE__, this);

    if (m_timer) {
        qDebug("[%s][%d]: -> call m_timer->stop()", __FUNCTION__, __LINE__);
        disconnect(m_timer, &QTimer::timeout, this, nullptr);

        if (m_timer->isActive()) {
            m_timer->stop();
        }
        qDebug("[%s][%d]: -> call m_timer->deleteLater()", __FUNCTION__, __LINE__);
        m_timer->deleteLater();
        m_timer = nullptr;
    }
    qDebug("[%s][%d]: Leave", __FUNCTION__, __LINE__);
}

static void frameCallback(void *context, unsigned char **data, const int &pix_fmt, const int &width, const int &height) {

}



void VideoRender::renderMuteImage(bool mute) {
    qDebug("[%s][%d]: mute: ", Q_FUNC_INFO, __LINE__, mute?"true":"false");

    this->renderMutePic = mute;
    if (isRenderMutePic()) {
        qDebug("[%s][%d]: true == isRenderMutePic()", Q_FUNC_INFO, __LINE__);
    } else {
        this->rendering = true;
    }
}

QString VideoRender::videoUrl() const {
    //qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
    return m_videoUrl;
}

void VideoRender::setVideoUrl(const QString &url)
{

}


void VideoRender::setRenderSourceID(QString sourceID) {
    std::string strDatasourceID = sourceID.toStdString();
    this->m_dataSourceID = strDatasourceID;
}


bool VideoRender::visible() const {
    //qDebug("[%s][%d] m_visible: %s", Q_FUNC_INFO, __LINE__, m_visible?"true":"false");
    return this->m_visible;
    
};
void VideoRender::setVisible(const bool visible) {
    this->m_visible = visible;
};



void VideoRender::setFormat(int width, int height, QVideoFrameFormat::PixelFormat pixFormat)
{
    if (m_video_width != width || m_video_height != height) {
        m_video_width = width;
        m_video_height = height;
        //qDebug("[%s][%d]: current size changed, set m_video_width : %d, m_video_height : %d, video format %s", Q_FUNC_INFO, __LINE__, m_video_width, m_video_height, "QVideoFrame::Format_YUV420P"); //Format_NV12
    } else {
        //qDebug("[%s][%d]: current size not change, so do nothing! m_video_width : %d, m_video_height : %d, video format %s", Q_FUNC_INFO, __LINE__, m_video_width, m_video_height, "QVideoFrame::Format_YUV420P"); //Format_NV12
        return;
    }
}

void VideoRender::onNewVideoFrameReceived(const QVideoFrame &frame)
{

    if (false == isReceivedNewVideoFrameData) {
        qDebug("[%s][%d][this: %p]: -> call m_videoFrameProvider->m_surface->present(frame)", __FUNCTION__, __LINE__, this);
        isReceivedNewVideoFrameData = true;

        QTimer::singleShot(10, this, [=]() {
            qDebug()<<"qtimer timeout after 10 ms";
            qDebug("[%s][%d]: set isReceivedNewVideoFrameData = true, then -> call m_videoFrameProvider->m_surface->present(frame), then -> emit cppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage() --> call renderMuteImage(false)", __FUNCTION__, __LINE__);
            emit cppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage();
        });
    }


}

void VideoRender::onFrameSizeChanged(int width, int height)
{
    
}

void VideoRender::setFrameSize(int x, int y, int width, int height)
{
    QString qStrDataSourceID = QString::fromStdString(m_dataSourceID);
}

void VideoRender::startRendering() {
    if (false == rendering) {
        qDebug("[%s][%d]: current false == rendering, so -> set this->rendering = true, and The m_dataSourceID start rendering.", Q_FUNC_INFO, __LINE__);
        this->rendering = true;
        
        qDebug("[%s][%d]: -> call m_videoFrameProvider->m_timer->start(30)", Q_FUNC_INFO, __LINE__);
        m_timer->start(30);
        
    }
}

void VideoRender::stopRendering() {
    isReceivedNewVideoFrameData = false;
    //QString qStrDataSourceID = QString::fromUtf8(m_dataSourceID.c_str());
    //qDebug("[%s][%d]: In Metal Video View The source id is m_dataSourceID: %s stop rendering. set isReceivedNewVideoFrameData: false", __FUNCTION__, __LINE__, qPrintable(qStrDataSourceID));
    if (true == rendering) {
        //qDebug("[%s][%d]: now true == rendering, so  -> set rendering = false, and -> call m_timer->stop()", __FUNCTION__, __LINE__);
        this->rendering = false;
        m_timer->stop();

        qDebug("[%s][%d][this: %p]: -> call SDKContext::sharedSDKContext()->clearVideoData(m_dataSourceID: %s)", __FUNCTION__, __LINE__, this, m_dataSourceID.c_str());
        //SDKContext::sharedSDKContext()->clearVideoData(m_dataSourceID);
    }
}

void VideoRender::getVideoDataAndRender(std::string aDataSourceID)
{
    //std::cout << "The get video data and render's aDataSourceID is " << aDataSourceID << std::endl;
    unsigned long videoLength = 0;
    unsigned int videoWidth = 0;
    unsigned int videoHeight = 0;

    void  *buffer = (void *)malloc(1920 * 1080 * 3 / 2);


    getVideoData(aDataSourceID, &buffer, &videoLength, &videoWidth, &videoHeight);

    if(videoLength <= 0)
    {
        free(buffer);
        return;
    }



    QVideoFrameFormat format(QSize(videoWidth, videoHeight), QVideoFrameFormat::Format_YUV420P);
    format.setViewport(QRect(0, 0, videoWidth, videoHeight));
    QVideoFrame *videoFrame = new QVideoFrame(format);

    if (videoFrame->map(QVideoFrame::WriteOnly))
    {
        memcpy(videoFrame->bits(0), buffer, videoLength);
        videoFrame->setStartTime(0);
        videoFrame->unmap();
       //emit newVideoFrameAvailable(*videoFrame);

        deliverFrame(*videoFrame);
    }

    free(buffer);

    delete videoFrame;
}

QVideoFrame VideoRender::QVideoFrame_fromImage(const QImage& image)
{
    QVideoFrameFormat    frameFormat(image.size(), QVideoFrameFormat::pixelFormatFromImageFormat(image.format()));
    QVideoFrame vidFrame(frameFormat); vidFrame.map(QVideoFrame::WriteOnly);

    qsizetype image_rowbytesI(image.bytesPerLine());
    qsizetype frame_rowbytesI(vidFrame.bytesPerLine(0));

    const uchar* imageBitsP(image.bits());
    uchar* frameBitsP(vidFrame.bits(0));

    int maxRowY(image.size().height());

    //CF_ASSERT(image_rowbytesI <= frame_rowbytesI);
    for (int rowY = 0; rowY < maxRowY; ++rowY)
    {
        std::copy(imageBitsP, imageBitsP + image_rowbytesI, frameBitsP);
        imageBitsP += image_rowbytesI;
        frameBitsP += frame_rowbytesI;
    }
    vidFrame.unmap();

    return vidFrame;
}

void VideoRender::getVideoData(std::string sourceID,
                               void **buffer,
                               unsigned long* length,
                               unsigned int* width,
                               unsigned int* height)
{
    FMakeCallClient::sharedCallClient()->receive_video_frame(sourceID, buffer, length, width, height);

}
