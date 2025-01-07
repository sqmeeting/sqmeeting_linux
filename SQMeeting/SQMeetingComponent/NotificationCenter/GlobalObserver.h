//
//  GlobalObserver.h
//  class GlobalObserver.
//  frtc_sdk Qt version.
//  [Note]: [In call] Conference UI.
//
//  Created by Yingyong.Mao on 2022/09/23.
//  Copyright © 2022 毛英勇. All rights reserved.
//


#ifndef GLOBALOBSERVER_H
#define GLOBALOBSERVER_H

#include <QObject>
#include <QVariant>
#include "ObesrverApater.h"

struct relationData
{
    QString type;
    QObject *reciver;
//    ObesrverApater *obesrverApater;
    const char *method;
};

class GlobalObserver : public QObject
{
    Q_OBJECT
public:
    static GlobalObserver* getGlobalObserver();
    static void release();
    static GlobalObserver *m_pInst;

    void attach(const QString type, QObject *reciver, const char *method);
    void detach(const QString type, const QObject* reciver);

    void notify(const QString type,
                QGenericArgument val0 = QGenericArgument(nullptr),
                QGenericArgument val1 = QGenericArgument(),
                QGenericArgument val2 = QGenericArgument(),
                QGenericArgument val3 = QGenericArgument(),
                QGenericArgument val4 = QGenericArgument(),
                QGenericArgument val5 = QGenericArgument(),
                QGenericArgument val6 = QGenericArgument(),
                QGenericArgument val7 = QGenericArgument(),
                QGenericArgument val8 = QGenericArgument(),
                QGenericArgument val9 = QGenericArgument());

signals:

private:
    explicit GlobalObserver(QObject *parent = 0);
    ~GlobalObserver();

private:
    QList<relationData*> m_oRelationList;
};

#endif // GLOBALOBSERVER_H
