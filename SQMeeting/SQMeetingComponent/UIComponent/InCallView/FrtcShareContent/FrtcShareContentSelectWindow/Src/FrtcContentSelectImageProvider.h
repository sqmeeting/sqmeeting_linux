#ifndef CONTENT_SELECT_IMAGEPROVIDER_H
#define CONTENT_SELECT_IMAGEPROVIDER_H

#include <QQuickImageProvider>

class FrtcContentSelectImageProvider : public QQuickImageProvider
{
public:
    FrtcContentSelectImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QPixmap	requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

public:
    QImage img;
};

#endif // CONTENT_SELECT_IMAGEPROVIDER_H
