#include "FContentCapture.h"
#include <QGuiApplication>
#include <QScreen>
#include <QRect>
#include <QtGui/qpixmap.h>
#include <QtMath>
//#include "AudioUnitSinkChan_macOS.h"
#include "FMakeCallClient.h"
#include <iostream>

#define MAX_CONTENT_FRMWIDTH 3840
#define MAX_CONTENT_FRMHEIGHT 2160
#define MAX_CONTENT_FRMSIZE (3840 * 2160)

FContentCapture::FContentCapture(QObject *parent) :
    QObject(parent)
{
}

void FContentCapture::startCaptureScreen()
{
    QScreen *scr = QGuiApplication::primaryScreen();
    QPixmap pix = scr->grabWindow(0);

    int width = pix.width();
    int height = pix.height();

    QImage desktopImage;
    if (width * height <= MAX_CONTENT_FRMSIZE)
    {
        desktopImage = pix.toImage();
    }
    else
    {
        if (width > MAX_CONTENT_FRMWIDTH) {
            width = MAX_CONTENT_FRMWIDTH;
        }
        if (height > MAX_CONTENT_FRMHEIGHT) {
            height = MAX_CONTENT_FRMHEIGHT;
        }
        QPixmap tmppix = pix.scaled(width, height,
                                    Qt::IgnoreAspectRatio,
                                    Qt::SmoothTransformation);
        desktopImage = tmppix.toImage();
    }

    desktopImage = desktopImage.convertToFormat(QImage::Format_ARGB32);
    uchar *data = desktopImage.bits();

    //std::cout << "---------------------------- the _sou" << std::endl;

    FMakeCallClient::sharedCallClient()->send_contetn_frame(data, _sourceID, width * height * 4, width, height);
}

void FContentCapture::dumpContentData(int width, int height, uint8_t*pYuvBuffer)
{
    std::string type1 = "test.yuv";
    std::string path = "/Users/Frtc_Work/";
    std::string path1 =  path + type1;
    if (path1.empty())
    {
        return;
    }
    FILE* fp = fopen(path1.c_str(), "ab+");

    if (fp)
    {
        if (width == 1920 )
        {
            return ;
        }
        fwrite(pYuvBuffer, 1, width * height * 3 / 2, fp);
        fclose(fp);
    }
}

void FContentCapture::startContent()
{
   // _contentRunloop.start();
   // _contentTimerID = _contentRunloop.startTimer(this, &FContentCapture::startCaptureScreen, 66, true);
   std::cout << "222222222----------------------------" << std::endl;


   this->m_thread = new QThread();

   this->m_timer = new QTimer;
   this->m_timer->setTimerType(Qt::PreciseTimer);
   this->m_timer->setInterval(60);
   this->m_timer->moveToThread(this->m_thread);

   QObject::connect(this->m_thread, SIGNAL(started()), this->m_timer, SLOT(start()));
   QObject::connect(this->m_thread, SIGNAL(finished()), this->m_timer, SLOT(stop()));

   QObject::connect(this->m_timer,&QTimer::timeout,[=]() {
       this->startCaptureScreen();
   });

   this->m_thread->start();
}

void FContentCapture::slotTimeOutHandler() {
    //TODO: -yingyong.mao -2022-7-27
    qDebug("[%s][%d]: for m_timer's signal: timeout()", Q_FUNC_INFO, __LINE__);

    startCaptureScreen();

}


void FContentCapture::stopContent()
{
    if (m_thread && m_thread->isRunning())
    {
        // 使用信号槽或 invokeMethod 停止定时器
        QMetaObject::invokeMethod(m_timer, "stop", Qt::QueuedConnection);

        // 停止线程
        m_thread->quit();
        m_thread->wait(); // 等待线程安全退出
    }
}

void FContentCapture::setSourceID(QString sourceID)
{
    _sourceID = sourceID;
}
