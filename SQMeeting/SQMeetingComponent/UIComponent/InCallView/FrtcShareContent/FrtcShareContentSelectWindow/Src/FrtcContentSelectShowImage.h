#ifndef SHOWIMAGE_H
#define SHOWIMAGE_H

#include <QObject>
#include "FrtcContentSelectImageProvider.h"

class FrtcContentSelectShowImage : public QObject
{
    Q_OBJECT
    public:
        explicit FrtcContentSelectShowImage(QObject *parent = 0);
        FrtcContentSelectImageProvider *m_pImgProvider;
    public slots:
        void setImage(QImage image);
    signals:
        void callQmlRefeshImg();

public:
        void captureScreen();

public:
        Q_INVOKABLE void onQMLGetScreenSnapShot();
};

#endif // SHOWIMAGE_H
