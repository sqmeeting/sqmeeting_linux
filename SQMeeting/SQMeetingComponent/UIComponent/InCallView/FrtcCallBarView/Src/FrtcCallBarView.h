//
//  FrtcCallBarView.h
//  class FrtcCallBarView.
//  frtc_sdk Qt version.
//  [Note]: [In call] Conference UI.
//
//  Created by Yingyong.Mao on 2022/11/27.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef FRTCCALLBARVIEW_H
#define FRTCCALLBARVIEW_H

#include <QObject>
#include <QMutex>
#include <QDebug>

#include <QQmlEngine>
#include <QJSEngine>




//class FrtcCallBarView.

class FrtcCallBarView : public QObject {
    Q_OBJECT
    
public:
    explicit FrtcCallBarView(QObject *parent = nullptr);
    ~FrtcCallBarView();
    
public:
    //通过Q_INVOKABLE宏标记的public函数可以在QML中访问
    Q_INVOKABLE void onQmlLocalAudioMute(bool mute);
    Q_INVOKABLE void onQmlLocalVideoMute(bool mute);
    
    //Q_INVOKABLE void localVideoMute(bool mute);
    //Q_INVOKABLE void frtcMuteLocalAudio(bool mute);

    

    //- (void)showSettingWindow;
    //- (void)dropCall;
    //- (void)showNameList;
    //- (void)showMeetingInfo;
    //- (void)poverContentAudio;
    //- (void)muteAudioByUser;
    //- (void)enableMesage:(BOOL)enable;
    //- (void)showVideoRecordingWindow:(BOOL)show;
    //- (void)showVideoStreamingWindow:(BOOL)show;
    //- (void)showVideoStreamUrlWindow;

    /*
    void showSettingWindow();

    void dropCall();

    void showNameList();

    void showMeetingInfo();

    void poverContentAudio();

    void muteAudioByUser();

    void enableMesage(bool enable);

    void showVideoRecordingWindow(bool show);

    void showVideoStreamingWindow(bool show);

    void showVideoStreamUrlWindow();
     */
};


#endif // FRTCCALLBARVIEW_H

