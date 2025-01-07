#if defined (UOS)
#elif defined (__APPLE__)
#elif defined (WIN32)
#include<windows.h>
#endif

#include <QtConcurrent/QtConcurrent>
#include <QFuture>
#include "FrtcMainViewController.h"
#include "FrtcCallView.h"

FrtcMainViewController::FrtcMainViewController(QObject *parent)
    : QObject(parent) {
          
}

FrtcMainViewController::~FrtcMainViewController() {

}


void FrtcMainViewController::callSuccessCallBack()
{
    FrtcCallView::getInstance()->callSuccessBlockHandler();
}

void FrtcMainViewController::callFailureCallBack(int reason)
{
    FrtcCallView::getInstance()->callFailureBlockHandler(reason);
}

void FrtcMainViewController::inputPasswordCallBack(bool wrongPassCode)
{
    FrtcCallView::getInstance()->inputPasscodeCallbackHandler(wrongPassCode);
}

void FrtcMainViewController::setInputPasscode(QString passcode)
{
    std::string str_passcode = passcode.toStdString();
    FMakeCallClient::sharedCallClient()->send_password(str_passcode);
}
    
void FrtcMainViewController::makeCall(FRTCSDKCallParam callParam)
{
    QFuture<void> future = QtConcurrent::run(&FrtcMainViewController::make_call, this, callParam);
    /*FMakeCallClient::sharedCallClient()->make_call(callParam,
                                                   std::bind(&FrtcMainViewController::callSuccessCallBack, this),
                                                   std::bind(&FrtcMainViewController::callFailureCallBack, this, std::placeholders::_1),
                                                   std::bind(&FrtcMainViewController::inputPasswordCallBack, this, std::placeholders::_1));*/

    }

void FrtcMainViewController::make_call(FRTCSDKCallParam callParam)
{
    FMakeCallClient::sharedCallClient()->make_call(callParam,
                                                   std::bind(&FrtcMainViewController::callSuccessCallBack, this),
                                                   std::bind(&FrtcMainViewController::callFailureCallBack, this, std::placeholders::_1),
                                                   std::bind(&FrtcMainViewController::inputPasswordCallBack, this, std::placeholders::_1));
}
