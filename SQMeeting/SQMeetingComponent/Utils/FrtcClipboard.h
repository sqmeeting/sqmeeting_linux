#ifndef FRTCCLIPBOARD_H
#define FRTCCLIPBOARD_H

#include <QObject>
#include <QGuiApplication>
#include <QClipboard>

//复制内容到剪切板
class FrtcClipboard : public QObject
{
    Q_OBJECT
public:
    explicit FrtcClipboard(QObject *parent = nullptr);
    Q_INVOKABLE void setText(QString text);
private:
    QClipboard *clipboard;
};

#endif // FRTCCLIPBOARD_H
