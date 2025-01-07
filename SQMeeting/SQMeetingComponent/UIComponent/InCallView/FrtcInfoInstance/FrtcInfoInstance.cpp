#include "FrtcInfoInstance.h"
#include "QtCore/qjsondocument.h"
#include "FrtcUUID.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <FrtcParticipantsViewController.h>

QMutex FrtcInfoInstance::m_Mutex;
FrtcInfoInstance * FrtcInfoInstance::shareInstance = nullptr;

FrtcInfoInstance* FrtcInfoInstance::sharedFrtcInfoInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcInfoInstance();
    }
    return shareInstance;
}

void FrtcInfoInstance::releaseInstance() {
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

FrtcInfoInstance::FrtcInfoInstance() {
    
}

int FrtcInfoInstance::getRosterNumber() {
    return this->rosterNumber;
}

std::vector<std::string> FrtcInfoInstance::getRosterList() {
    if(this->rosterList.empty())
    {
        qDebug() << "-----std::vector<std::string> FrtcInfoInstance::getRosterList()------" ;
        QJsonObject json_obj;
        json_obj["audio_mute"]      = this->inCallModel->muteMicrophone;
        json_obj["display_name"]    = this->inCallModel->clientName;
        json_obj["user_id"]         = QString::fromStdString(FrtcUUID::getApplicationUUID());
        json_obj["uuid"]            = QString::fromStdString(FrtcUUID::getApplicationUUID());
        json_obj["video_mute"]      = this->inCallModel->muteCamera;
        json_obj["user_pin"]        = false;
        qDebug()<< this->inCallModel->clientName;

        QJsonDocument json_doc(json_obj);

        // 将 JSON 文档转换为 std::string
        std::string jsonString = json_doc.toJson(QJsonDocument::Compact).toStdString();

        rosterList.insert(rosterList.begin(), jsonString);
    }


    return this->rosterList;
}

void FrtcInfoInstance::updateRosterNumber(int rosterNumber) {
    this->rosterNumber = rosterNumber;
    FrtcParticipantsViewController::getInstance()->updateRosterNumber(rosterNumber);
}

void FrtcInfoInstance::udateRosterList(std::vector<std::string> rosterList) {
    this->rosterList = rosterList;
    FrtcParticipantsViewController::getInstance()->udateRosterList(rosterList);
}
