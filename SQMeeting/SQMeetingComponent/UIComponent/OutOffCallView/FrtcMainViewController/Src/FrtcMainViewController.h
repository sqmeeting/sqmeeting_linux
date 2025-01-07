//
//  FrtcMainViewController.h
//  class FrtcMainViewController.
//  FrtcMeeting Qt version.
//
//  Created by Yingyong.Mao on 2022/08/13.
//  Copyright © 2022 毛英勇. All rights reserved.
//

#ifndef FRTCCALLVIEWCONTROLLER_H
#define FRTCCALLVIEWCONTROLLER_H

#include <QObject>
#include <QQuickItem>
#include "FMakeCallClient.h"

//[Note]: FrtcCallView.cpp
//对应 Mac版中 FrtcCallWindow.m
//注意：@interface FrtcCallWindow : NSWindow

class FrtcMainViewController : public QObject {
    
    Q_OBJECT
public:
    explicit FrtcMainViewController(QObject *parent = nullptr);
    ~FrtcMainViewController();

signals:
    void signalInputPassCodeCallback(bool wrongPassCode);
public:
    void setInputPasscode(QString passcode);

public: 
    void callSuccessCallBack();
    void callFailureCallBack(int reason);
    void inputPasswordCallBack(bool wrongPassCode);
    void makeCall(FRTCSDKCallParam callParam);
public:
    void make_call(FRTCSDKCallParam callParam);

private:
    bool callSuccess;
public:
    bool isCallSuccess() { return callSuccess; }
    
};

#endif // FRTCCALLVIEWCONTROLLER_H
