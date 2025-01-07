#include "FrtcParticipantsViewController.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include "FrtcInfoInstance.h"

QMutex FrtcParticipantsViewController::m_Mutex;
FrtcParticipantsViewController *FrtcParticipantsViewController::shareInstance = nullptr;

FrtcParticipantsViewController* FrtcParticipantsViewController::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcParticipantsViewController();
    }
    return shareInstance;
}

void FrtcParticipantsViewController::releaseInstance() {
    qDebug("[%s][%d]: Enter", __func__, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

FrtcParticipantsViewController::FrtcParticipantsViewController(QObject *parent) :
QObject(parent)
{

}

FrtcParticipantsViewController::~FrtcParticipantsViewController() {

}


int FrtcParticipantsViewController::onQmlGetParticipantsNumber() {
    int rosterNumber = FrtcInfoInstance::sharedFrtcInfoInstance()->getRosterNumber();
    return rosterNumber;
}

QVariant FrtcParticipantsViewController::onQmlGetParticipantsList() {
    QVariant qVaraintRosterListJsonArray = getRosterList();
    return qVaraintRosterListJsonArray;
}

QVariant FrtcParticipantsViewController::getRosterList() {
    std::vector<std::string> rosterList = FrtcInfoInstance::sharedFrtcInfoInstance()->getRosterList();

    //int index = 0;
    QJsonArray rosterListJsonArray;

    if(rosterList.empty())
    {
        qDebug("[%s][%d]rosterList is empty()", Q_FUNC_INFO, __LINE__);
    }

    for (std::vector<std::string>::iterator iter = rosterList.begin(); iter < rosterList.end(); iter++) {
        QString qStrJsonRoster = QString::fromStdString((*iter).c_str());
        qDebug("[%s][%d][vector index]: qStrJsonRoster: %s", Q_FUNC_INFO, __LINE__, qPrintable(qStrJsonRoster));

        QJsonDocument qDocRoster = QJsonDocument::fromJson(qStrJsonRoster.toUtf8());
        QJsonObject qJsonRoster = qDocRoster.object();
        rosterListJsonArray.append(qJsonRoster);
    }

    QJsonObject rosterListJsonArrayObject;
    rosterListJsonArrayObject.insert("rosterListJsonArray", rosterListJsonArray);

    QVariant qVaraintRosterListJsonArray = QVariant::fromValue(rosterListJsonArrayObject);
    return qVaraintRosterListJsonArray;
}

void FrtcParticipantsViewController::updateRosterNumber(int rosterNumber) {
    emit cppSendMsgToQMLUpdateRosterNumber(rosterNumber);
}

void FrtcParticipantsViewController::udateRosterList(std::vector<std::string> rosterList)
{
    int index = 0;
    QJsonArray rosterListJsonArray;
    for (std::vector<std::string>::iterator iter = rosterList.begin(); iter < rosterList.end(); iter++) {
        QString qStrJsonRoster = QString::fromStdString((*iter).c_str());
        QJsonDocument qDocRoster = QJsonDocument::fromJson(qStrJsonRoster.toUtf8());
        QJsonObject qJsonRoster = qDocRoster.object();
        rosterListJsonArray.append(qJsonRoster);
    }

    QJsonObject rosterListJsonArrayObject;
    rosterListJsonArrayObject.insert("rosterListJsonArray", rosterListJsonArray);

    QVariant qVaraintRosterListJsonArray = QVariant::fromValue(rosterListJsonArrayObject);
    emit cppSendMsgToQMLUpdateRosterList(qVaraintRosterListJsonArray);
}


void FrtcParticipantsViewController::onQmlInvitate() {
    qDebug("[%s][%d]: -> call onQmlInvitate()", Q_FUNC_INFO, __LINE__);
}


//==================== end for QML interaction ====================

