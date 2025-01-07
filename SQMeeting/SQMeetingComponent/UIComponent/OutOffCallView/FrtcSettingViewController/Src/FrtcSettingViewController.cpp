//
//  FrtcSettingViewController.cpp
//  class FrtcSettingViewController.
//  FrtcMeeting Qt version.
//
//  Created by Yingyong.Mao on 2022/12/11.
//  Copyright © 2022 毛英勇. All rights reserved.
//

#include "FrtcSettingViewController.h"

//#include "./frtc_sdk_dist/frtc_sdk/RtcsdkInterface/rtcsdk_suite.h"
//#include "./frtc_sdk_dist/frtc_sdk/RtcsdkInterface/SDKContextWrapper.h"
//#include "./frtc_sdk_dist/frtc_sdk/FrtcInterface/FrtcCall.h"
//#include "../FMakeCallClient/FMakeCallClient.h"


FrtcSettingViewController *FrtcSettingViewController::shareInstance = nullptr;

FrtcSettingViewController* FrtcSettingViewController::getInstance() {
    qDebug("*** *** *** [%s][%d]: shareInstance = this: %p", __PRETTY_FUNCTION__, __LINE__, shareInstance);
    if (nullptr == shareInstance) {
        qDebug("*** *** *** [%s][%d] shareInstance = new FMeetingViewController()", __PRETTY_FUNCTION__, __LINE__);
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcSettingViewController();
    }
    return shareInstance;
}

void FrtcSettingViewController::releaseInstance() {
    qDebug("[%s][%d]: Enter", __PRETTY_FUNCTION__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", __PRETTY_FUNCTION__, __LINE__);
}

FrtcSettingViewController::FrtcSettingViewController(QObject *parent) : QObject(parent) {
    qDebug("*** *** *** [%s][%d]: this: %p", __PRETTY_FUNCTION__, __LINE__, this);

}

FrtcSettingViewController::~FrtcSettingViewController() {
    qDebug("--- --- --- --- *** *** *** [%s][%d]: this: %p", __PRETTY_FUNCTION__, __LINE__, this);

}
