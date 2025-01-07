#include <QDebug>
#include "FrtcSharingFrameWindow.h"
#include "QtQml/qqmlcontext.h"

QMutex FrtcSharingFrameWindow::m_Mutex;
FrtcSharingFrameWindow *FrtcSharingFrameWindow::shareInstance = nullptr;

FrtcSharingFrameWindow* FrtcSharingFrameWindow::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcSharingFrameWindow();
    }
    return shareInstance;
}

void FrtcSharingFrameWindow::releaseInstance() {
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

FrtcSharingFrameWindow::FrtcSharingFrameWindow(QObject *parent) :
                        QObject(parent),
                        m_isShowSharingBarWindow(false),
                        m_authiority(true),
                        m_meetingOwner(true){}

FrtcSharingFrameWindow::~FrtcSharingFrameWindow() {
    if (nullptr != m_sharingBarWindowComponent) {
        delete m_sharingBarWindowComponent;
        m_sharingBarWindowComponent = nullptr;
    }
    if (nullptr != m_sharingBarWindow) {
        delete m_sharingBarWindow;
        m_sharingBarWindow = nullptr;
    }
}

void FrtcSharingFrameWindow::createSharingBarFrameWindow(QQmlApplicationEngine &engine) {
    if (nullptr != m_sharingBarWindowComponent) {
        m_sharingBarWindowComponent = new QQmlComponent(&engine);
    } else {
         m_sharingBarWindowComponent = new QQmlComponent(&engine);
    }
}

void FrtcSharingFrameWindow::startShowSharingBarFrameWindow() {
    if (m_isShowSharingBarWindow) {
        return;
    } else {
        m_isShowSharingBarWindow = true;
        
        if (nullptr != m_sharingBarWindowComponent) {
            // QQmlEngine *engine = m_sharingBarWindowComponent->engine();
            // if(engine) {
            //     QQmlContext *context = engine->rootContext();

            //     context->setContextProperty("authiority", true);
            //     context->setContextProperty("meetingOwner", true);
            // }

            QVariantMap initialProperties;
            initialProperties["authiority"]     = m_authiority;
            initialProperties["meetingOwner"]   = m_meetingOwner;

            m_sharingBarWindowComponent->loadUrl(QUrl("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcSharingFrameWindow/View/FrtcSharingFrameWindow.qml"));

            if (!m_sharingBarWindowComponent->isReady() ) {
                return;
            }

            QObject *topLevel = m_sharingBarWindowComponent->createWithInitialProperties(initialProperties);
            m_sharingBarWindow = qobject_cast<QQuickWindow *>(topLevel);
            QSurfaceFormat surfaceFormat = m_sharingBarWindow->requestedFormat();
            m_sharingBarWindow->setFormat(surfaceFormat);


            m_sharingBarWindow->show();

            if (nullptr != m_sharingBarWindow) {
                qWarning()<<" -> QmlWindow->setMask(region)";
                QRegion screenRegin(m_sharingBarWindow->screen()->geometry());

                QSize screenSize = m_sharingBarWindow->screen()->geometry().size();

                QRect inBlueBorderScreenRect(10, 10, screenSize.width() - 10 * 2, screenSize.height() - 10 * 2);
                QRegion inBlueBorderScreenRegin(inBlueBorderScreenRect);

                int width;
                if(m_meetingOwner || m_authiority) {
                    width = 650;
                } else {
                    width = 458;
                }
                QRect sharingBarShrinkViewRect((screenSize.width() - 220)/2, 0, 220, 80); //1.FrtcSharingBarShrinkView.qml
                QRect sharingBarExpandViewRect((screenSize.width() - width)/2, 0, width, 40 + 100);//60); //2.FrtcSharingBarExpandView.qml
                QRegion sharingBarRegion(sharingBarExpandViewRect);

                QRegion outoffSharingBarInBlueBorderScreenRegion = inBlueBorderScreenRegin.subtracted(sharingBarRegion);
                QRegion targetRegion = screenRegin.xored(outoffSharingBarInBlueBorderScreenRegion);
                m_sharingBarWindow->setMask(targetRegion);
            }
        }

    }
}

void FrtcSharingFrameWindow::stopShowSharingBarFrameWindow() {
    if (false == m_isShowSharingBarWindow) {
        return;
    } else {
        m_isShowSharingBarWindow = false;

        if (nullptr != m_sharingBarWindow) {
            m_sharingBarWindow->setVisible(false);

            m_sharingBarWindow->deleteLater();
            m_sharingBarWindow = nullptr;
        }
    }
}

void FrtcSharingFrameWindow::setAuthority(bool meeting_owner, bool user_authority)
{
    m_meetingOwner = meeting_owner;
    m_authiority   = user_authority;
}

void FrtcSharingFrameWindow::showSharingBarExpandView(bool bShow) {
    if (nullptr != m_sharingBarWindowComponent) {
        if (nullptr != m_sharingBarWindow) {
            qWarning()<<" -> QmlWindow->setMask(region)";
            QRegion screenRegin(m_sharingBarWindow->screen()->geometry());
            QSize screenSize = m_sharingBarWindow->screen()->geometry().size();

            QRect inBlueBorderScreenRect(10, 10, screenSize.width() - 10 * 2, screenSize.height() - 10 * 2);
            QRegion inBlueBorderScreenRegin(inBlueBorderScreenRect);

            int width;
            if(m_meetingOwner || m_authiority) {
                width = 650;
            } else {
                width = 458;
            }


            QRect sharingBarShrinkViewRect((screenSize.width() - 220)/2, 0, 220, 80); //1.FrtcSharingBarShrinkView.qml
            QRect sharingBarExpandViewRect((screenSize.width() - width)/2, 0, width, 40 + 100); //2.FrtcSharingBarExpandView.qml

            QRegion sharingBarRegion;
            if (bShow) {
                sharingBarRegion = QRegion(sharingBarExpandViewRect);
            } else {
                sharingBarRegion = QRegion(sharingBarShrinkViewRect);
            }

            QRegion outoffSharingBarInBlueBorderScreenRegion = inBlueBorderScreenRegin.subtracted(sharingBarRegion);
            QRegion targetRegion = screenRegin.xored(outoffSharingBarInBlueBorderScreenRegion);
            m_sharingBarWindow->setMask(targetRegion);
        }
    }
}
