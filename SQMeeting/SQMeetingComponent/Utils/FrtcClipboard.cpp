#include "FrtcClipboard.h"
#include <QDebug>

FrtcClipboard::FrtcClipboard(QObject *parent) : QObject(parent)
{
    clipboard = QGuiApplication::clipboard();
}

void FrtcClipboard::setText(QString text)
{
    qDebug() << "[FrtcClipboard::setText]" << text;
    clipboard->setText(text,QClipboard::Clipboard);
}
