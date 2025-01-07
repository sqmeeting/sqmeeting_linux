#ifndef FRTCCALLVIEW_H
#define FRTCCALLVIEW_H

#include <QObject>
#include <QMutex>
#include <QQuickItem>

#include "FrtcMainViewController.h"

//[Note]: FrtcCallView.cpp
//对应 Mac版中 FrtcCallWindow.m
//注意：@interface FrtcCallWindow : NSWindow

class FrtcCallView : public QObject {
    
    Q_OBJECT
    
public:
    //explicit FrtcCallView(QObject *parent = nullptr);
private:
    static QMutex m_Mutex;
    static FrtcCallView *shareInstance;
public:
    static FrtcCallView* getInstance();
    static void releaseInstance();

    FrtcCallView(QObject *parent = nullptr);
    ~FrtcCallView();

public:
    //==================== begin for QML interaction ====================
    //通过Q_INVOKABLE宏标记的public函数可以在QML中访问
    Q_INVOKABLE void onJoinVideoMeetingButtonPressed(QString userName,
                                                     QString meetingID,
                                                     bool mute_mic,
                                                     bool mute_camera,
                                                     bool audioOnlyEnable,
                                                     QString passWord = "");
													 
	Q_INVOKABLE void onJoinVideoMeetingButtonPressedWithPasscode(QString password);

    //==================== begin for QML interaction ====================
signals:
    //signals will trigger the onXXX function of QML.
    void cppInputPasscodeCallbackHandler(const bool wrongPassCode);
    void cppCallSuccessBlockHandler(bool authority, bool meeting_owner, QString ownerName, QString meetingName, QString meetingNumber);
    void cppCallFailureBlockHandler(int reason);
    //==================== end for QML interaction ====================


public:
    //[main.cpp]: frtcCallViewObject->frtcCallWindowdelegate = mainVC; //new FrtcMainViewController()
    FrtcMainViewController * frtcCallWindowdelegate;
//public slots:
//    void slotInputPassCodeCallbackHandler(bool wrongPassCode);
    void inputPasscodeCallbackHandler(bool swrongPassCode);
    void callSuccessBlockHandler();
    void callFailureBlockHandler(int reason);

public:
    QString userName;
    QString userId;
    
    bool login;

public:
    void setLogin(bool login) { this->login = login; };
    bool isLogin() { return this->login; };
    
};

#endif // FRTCCALLVIEW_H
