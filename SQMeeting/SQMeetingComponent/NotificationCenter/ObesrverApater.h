//
//  ObesrverApater.h
//  class ObesrverApater.
//  frtc_sdk Qt version.
//  [Note]: [In call] Conference UI.
//
//  Created by Yingyong.Mao on 2022/09/23.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef OBESRVERAPATER_H
#define OBESRVERAPATER_H

#include <QObject>
class ObesrverApater;

class ObesrverApaterFactory {
public:
    static ObesrverApaterFactory *getInstance();
    static void realese();
    static ObesrverApaterFactory* instance;

    ObesrverApater* createObesrverApater();

private:
    ObesrverApaterFactory() {}
};

//中间层，用来连接信号槽
class ObesrverApater : public QObject {
    Q_OBJECT
public:
    explicit ObesrverApater(QObject *parent = 0);

signals:
    void notify();
};

#endif // OBESRVERAPATER_H
