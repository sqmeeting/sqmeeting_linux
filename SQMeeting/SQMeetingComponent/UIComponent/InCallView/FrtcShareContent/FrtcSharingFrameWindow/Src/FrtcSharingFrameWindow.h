//
//  FrtcSharingFrameWindow.h
//  class FrtcSharingFrameWindow.
//  FrtcMeeting Qt version.
//  [Note]: [In call] Conference UI.
//
//  Created by Yingyong.Mao on 2023/02/24.
//  Copyright © 2023 毛英勇. All rights reserved.
//


#ifndef FRTC_SHARING_FRAME_WINDOW_H
#define FRTC_SHARING_FRAME_WINDOW_H

#include <QObject>
#include <QTimer>
#include <QMutex>

//#include <QQmlEngine>
//#include <QJSEngine>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QRegion>
#include <QScreen>


class FrtcSharingFrameWindow: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FrtcSharingFrameWindow);
    
private:
    static QMutex m_Mutex;
    static FrtcSharingFrameWindow *shareInstance;
public:
    static FrtcSharingFrameWindow* getInstance();
    void releaseInstance();
    explicit FrtcSharingFrameWindow(QObject *parent = nullptr);
    ~FrtcSharingFrameWindow();
    
public:
    void createSharingBarFrameWindow(QQmlApplicationEngine &engine);
    void startShowSharingBarFrameWindow();
    void stopShowSharingBarFrameWindow();
    void showSharingBarExpandView(bool bShow);
    void setAuthority(bool meeting_owner, bool user_authority);
private:
    bool m_isShowSharingBarWindow;
    QQmlComponent *m_sharingBarWindowComponent;
    QQuickWindow *m_sharingBarWindow;

    bool m_authiority;
    bool m_meetingOwner;
    //QQmlApplicationEngine *engine;
};

#endif // FRTC_SHARING_FRAME_WINDOW_H
