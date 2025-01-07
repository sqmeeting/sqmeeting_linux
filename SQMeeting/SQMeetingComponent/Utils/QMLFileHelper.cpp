#include "QMLFileHelper.h"
#include <QFile>
#include <QTextDocument>


QMutex QMLFileHelper::m_Mutex;
QMLFileHelper * QMLFileHelper::shareInstance = nullptr;

QMLFileHelper::QMLFileHelper(QObject *parent)   :   QObject(parent)
{

}
QMLFileHelper::~QMLFileHelper(){}

QString QMLFileHelper::readTextFile(const QString & file_url)
{
    QString ret;
    QFile file(file_url);
    if(file.exists())
    {
        file.open(QIODevice::ReadOnly);
        ret = file.readAll();
        file.close();
    }
    return ret;
}