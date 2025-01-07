#ifndef FCONTENTCAPTURE_H
#define FCONTENTCAPTURE_H

#include <QObject>
#include <QTimer>
#include <QThread>

class FContentCapture : public QObject
{
    Q_OBJECT
public:
    explicit FContentCapture(QObject *parent = nullptr);

public:
    void startCaptureScreen();
    void startContent();
    void stopContent();
    void setSourceID(QString sourceID);
    void dumpContentData(int width, int height, uint8_t*pYuvBuffer);

public slots:
    void slotTimeOutHandler();

private:
    QString _sourceID;
    QTimer  *m_timer = nullptr;
    QThread *m_thread = nullptr;

signals:

};

#endif // FCONTENTCAPTURE_H
