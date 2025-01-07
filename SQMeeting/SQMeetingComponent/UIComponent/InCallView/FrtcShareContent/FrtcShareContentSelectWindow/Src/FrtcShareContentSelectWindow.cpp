#include <QDebug>
#include "FrtcShareContentSelectWindow.h"


QMutex FrtcShareContentSelectWindow::m_Mutex;
FrtcShareContentSelectWindow *FrtcShareContentSelectWindow::shareInstance = nullptr;

FrtcShareContentSelectWindow* FrtcShareContentSelectWindow::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcShareContentSelectWindow();
    }
    return shareInstance;
}

void FrtcShareContentSelectWindow::releaseInstance() {
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

FrtcShareContentSelectWindow::FrtcShareContentSelectWindow(QObject *parent) :
                              QObject(parent),
                              m_isShowSharingBarWindow(false) {}

FrtcShareContentSelectWindow::~FrtcShareContentSelectWindow() {
    qDebug("[%s][%d]: this: %p", Q_FUNC_INFO, __LINE__, this);
    if (nullptr != m_sharingBarWindowComponent) {
        delete m_sharingBarWindowComponent;
        m_sharingBarWindowComponent = nullptr;
    }
    if (nullptr != m_sharingBarWindow) {
        delete m_sharingBarWindow;
        m_sharingBarWindow = nullptr;
    }
}

void FrtcShareContentSelectWindow::startShowSharingBarFrameWindow() {
    if (m_isShowSharingBarWindow) {
        return;
    } else {
        m_isShowSharingBarWindow = true;
        
        if (nullptr != m_sharingBarWindowComponent) {
            m_sharingBarWindowComponent->loadUrl(QUrl("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcShareContentSelectWindow/View/FrtcShareContentSelectWindow.qml"));

            if (!m_sharingBarWindowComponent->isReady() ) {
                qWarning("%s", qPrintable(m_sharingBarWindowComponent->errorString()));
                return;
            }

            m_sharingBarWindow->show();

        }
    }
}

void FrtcShareContentSelectWindow::stopShowSharingBarFrameWindow() {
    if (false == m_isShowSharingBarWindow) {
        return;
    } else {
        m_isShowSharingBarWindow = false;

        if (nullptr != m_sharingBarWindow) {
            m_sharingBarWindow->setVisible(false);
        }
    }
}

void FrtcShareContentSelectWindow::createSharingBarFrameWindow(QQmlApplicationEngine &engine) {
    if (nullptr != m_sharingBarWindowComponent) {
        m_sharingBarWindowComponent = new QQmlComponent(&engine);
    }
}
