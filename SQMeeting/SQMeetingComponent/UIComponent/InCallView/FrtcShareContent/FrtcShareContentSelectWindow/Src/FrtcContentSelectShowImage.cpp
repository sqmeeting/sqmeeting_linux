#include "FrtcContentSelectShowImage.h"
#include <QTimer>
#include <QDebug>

#include <QGuiApplication>
#include <QScreen>

FrtcContentSelectShowImage::FrtcContentSelectShowImage(QObject *parent) :
    QObject(parent) {
    m_pImgProvider = new FrtcContentSelectImageProvider();
}

void FrtcContentSelectShowImage::captureScreen() {
    int targetWidth = 113;
    int targetHeight = 70;
    QScreen *scr = QGuiApplication::primaryScreen();
    QPixmap pix = scr->grabWindow(0).scaled(targetWidth, targetHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    QImage desktopImage;
    desktopImage = pix.toImage();
    this->setImage(desktopImage);
}

void FrtcContentSelectShowImage::setImage(QImage image) {
    m_pImgProvider->img = image;
    emit callQmlRefeshImg();
}

void FrtcContentSelectShowImage::onQMLGetScreenSnapShot() {
    captureScreen();
}

