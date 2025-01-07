//
//  FrtcSettingViewController.h
//  class FrtcSettingViewController.
//  FrtcMeeting Qt version.
//
//  Created by Yingyong.Mao on 2022/12/11.
//  Copyright © 2022 毛英勇. All rights reserved.
//

#ifndef FRTCCALLVIEW_H
#define FRTCCALLVIEW_H

#include <QObject>

#include <QObject>
#include <QMutex>
#include <QDebug>

class FrtcSettingViewController : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(FrtcSettingViewController)

private:
    static QMutex m_Mutex;
    static FrtcSettingViewController *shareInstance;
public:
    static FrtcSettingViewController* getInstance();
    static void releaseInstance();
    explicit FrtcSettingViewController(QObject *parent = nullptr);
    ~FrtcSettingViewController();

};

#endif // FRTCCALLVIEW_H
