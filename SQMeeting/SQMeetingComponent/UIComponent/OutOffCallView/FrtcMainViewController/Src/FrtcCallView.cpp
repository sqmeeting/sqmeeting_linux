#if defined (WIN32)
#include<windows.h>
#endif

#include "FrtcCallView.h"
#include "FMakeCallClient.h"
#include <SDKUserDefault.h>
#include "FrtcInfoInstance.h"

QMutex FrtcCallView::m_Mutex;
FrtcCallView * FrtcCallView::shareInstance = nullptr;

FrtcCallView* FrtcCallView::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FrtcCallView();
    }
    return shareInstance;
}

void FrtcCallView::releaseInstance() {
    qDebug("[%s][%d]: Enter", Q_FUNC_INFO, __LINE__);
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
    qDebug("[%s][%d]: Exit", Q_FUNC_INFO, __LINE__);
}

FrtcCallView::FrtcCallView(QObject *parent)
    : QObject(parent) {

}

FrtcCallView::~FrtcCallView() {

}


void FrtcCallView::onJoinVideoMeetingButtonPressed(QString userName,
                                                   QString meetingID,
                                                   bool mute_mic,
                                                   bool mute_camera,
                                                   bool audioOnlyEnable,
                                                   QString passWord)
{
    qDebug("[%s][%d]: userName: %s, meetingID: %s, mute_mic: %s, mute_camera: %s, audioOnlyEnable: %s, passWord: %s",
           Q_FUNC_INFO, __LINE__,
           userName.toStdString().data(),
           meetingID.toStdString().data(),
           mute_mic? "true" : "false",
           mute_camera? "true" : "false",
           audioOnlyEnable? "true" : "false",
           passWord.toStdString().data());
    
    
    qDebug("[%s][%d]: login: %s", Q_FUNC_INFO, __LINE__, isLogin()?"true":"false");

    int numberCallRate = 0;
    
    
    FRTCSDKCallParam callParam;
    

    callParam.call_url = SDKUserDefault::getInstance()->getServerAddressFromUserConfigFile().toStdString();
    callParam.conference_number  = meetingID.toStdString();
    callParam.client_name        = userName.toStdString();
    callParam.call_rate          = numberCallRate;
    callParam.mute_camera        = mute_camera;
    callParam.mute_microphone    = mute_mic;
    callParam.audio_call         = audioOnlyEnable;
    callParam.meeting_password   = passWord.toStdString();

    qDebug() << "callParam.meeting_password:::" << callParam.meeting_password ;

    QString layou_mode = SDKUserDefault::getInstance()->getSdkObjectForKey(SDK_DEFAULT_LAYOUT_GALLERY);

    callParam.grid_mode          = (layou_mode.compare("true", Qt::CaseInsensitive) == 0);
    
    if (this->isLogin()) {
        callParam.user_id        = this->userId.toLocal8Bit().constData();
    }
    
    if (nullptr != frtcCallWindowdelegate) {
        frtcCallWindowdelegate->makeCall(callParam);
    }
}

void FrtcCallView::onJoinVideoMeetingButtonPressedWithPasscode(QString password) {
    qDebug("[%s][%d]: [from FrtcCallView.qml] -> qmlSignalJoinVideoMeetingButtonPressedWithPasscode(password: %s) -> call frtcCallWindowdelegate->setInputPasscode(password)", Q_FUNC_INFO, __LINE__, qPrintable(password));
    frtcCallWindowdelegate->setInputPasscode(password);
}

//==================== end for QML interaction ====================

void FrtcCallView::inputPasscodeCallbackHandler(bool wrongPassCode) {
    emit cppInputPasscodeCallbackHandler(wrongPassCode);
}

void FrtcCallView::callSuccessBlockHandler() {

    bool login_state = SDKUserDefault::getInstance()->getLoginState().toBool();


    if(login_state) {
        printf("---------login_state is ture---------");
    } else {
        printf("---------login_state is false---------");
    }

    bool authority;
    bool meeting_owner;

    FrtcInCallModel *model = FrtcInfoInstance::sharedFrtcInfoInstance()->inCallModel;

    qDebug() << model->ownerID;
    qDebug() << model->ownerName;
    qDebug() << SDKUserDefault::getInstance()->getUserInfo()["user_id"].toString();

    if(login_state) {
        QStringList user_roles = SDKUserDefault::getInstance()->getUserInfo()["role"].toStringList();
        qDebug() << user_roles;
        printf("\nIt is lgoin user\n");
        if (user_roles.contains("MeetingOperator") ||user_roles.contains("SystemAdmin")) {
            authority = true;
            printf("\nThe login user have the authority\n");
        } else {
            authority = false;
            printf("\nThe login user have not the authority\n");
        }

        if(model->ownerID == SDKUserDefault::getInstance()->getUserInfo()["user_id"].toString()) {
            meeting_owner = true;
            printf("\nThe login user is the meeting_owner\n");
        } else {
            meeting_owner = false;
            printf("\nThe login user is not the meeting_owner\n");
        }
    } else {
        authority = false;
        meeting_owner = false;
    }

    emit cppCallSuccessBlockHandler(authority, meeting_owner, model->ownerName, model->conferenceName, model->conferenceNumber);
}

void FrtcCallView::callFailureBlockHandler(int reason) {
    emit cppCallFailureBlockHandler(reason);
}


