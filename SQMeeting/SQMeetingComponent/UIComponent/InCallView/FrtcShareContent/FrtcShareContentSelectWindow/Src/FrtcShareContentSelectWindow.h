#ifndef FRTC_SHARE_CONTET_SELECT_WINDOW_H
#define FRTC_SHARE_CONTET_SELECT_WINDOW_H

#include <QObject>
#include <QTimer>
#include <QMutex>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QRegion>
#include <QScreen>


class FrtcShareContentSelectWindow: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FrtcShareContentSelectWindow);
    
private:
    static QMutex m_Mutex;
    static FrtcShareContentSelectWindow *shareInstance;
public:
    static FrtcShareContentSelectWindow* getInstance();
    void releaseInstance();
    explicit FrtcShareContentSelectWindow(QObject *parent = nullptr);
    ~FrtcShareContentSelectWindow();
    
public:
    void createSharingBarFrameWindow(QQmlApplicationEngine &engine);
    void startShowSharingBarFrameWindow();
    void stopShowSharingBarFrameWindow();
    
private:
    bool m_isShowSharingBarWindow;
    QQmlComponent *m_sharingBarWindowComponent;
    QQuickWindow *m_sharingBarWindow;
    //QQmlApplicationEngine *engine;
};

#endif // FRTC_SHARE_CONTET_SELECT_WINDOW_H
