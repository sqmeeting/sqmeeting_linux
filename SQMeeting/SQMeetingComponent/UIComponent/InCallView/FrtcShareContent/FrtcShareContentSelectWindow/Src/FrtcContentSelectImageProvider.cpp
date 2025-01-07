#include "FrtcContentSelectImageProvider.h"

FrtcContentSelectImageProvider::FrtcContentSelectImageProvider():
    QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage FrtcContentSelectImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return this->img;
}

QPixmap	FrtcContentSelectImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    return QPixmap::fromImage(this->img);
}
