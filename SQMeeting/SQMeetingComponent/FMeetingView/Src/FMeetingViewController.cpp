#include "FMeetingViewController.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include "SVCLayoutManager.h"
#include "SDKItemInfo.h"
#include "SVCVideoInfo.h"
#include "UtilScreen.h"
#include "FMakeCallClient.h"
using namespace MeetingLayout;

QMutex FMeetingViewController::m_Mutex;
FMeetingViewController *FMeetingViewController::shareInstance = nullptr;

FMeetingViewController* FMeetingViewController::getInstance() {
    if (nullptr == shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        shareInstance = new FMeetingViewController();
    }
    return shareInstance;
}

void FMeetingViewController::releaseInstance() {
    if (nullptr != shareInstance) {
        QMutexLocker mutexLocker(&m_Mutex);
        delete shareInstance;
        shareInstance = nullptr;
    }
}

FMeetingViewController::FMeetingViewController(QObject *parent) :
                        QObject(parent),
                        m_timer(nullptr),
                        m_content(false)
{
    //========== ========== for SVCLayout ========== ==========
    QObject::connect(MeetingLayout::SVCLayoutManager::getInstance(), SIGNAL(signalRefreshLayoutMode(QVariant, QVariant)),
                    this, SLOT(slotRefreshLayoutMode(QVariant, QVariant)));

    QObject::connect(MeetingLayout::SVCLayoutManager::getInstance(), SIGNAL(signalRemoteViewHiddenOrNot(QVariant)),
                this, SLOT(slotRemoteViewHiddenOrNot(QVariant)));

    QObject::connect(MeetingLayout::SVCLayoutManager::getInstance(), SIGNAL(signalPrepareSVCLayout(QVariant)),
                    this, SLOT(slotPrepareSVCLayout(QVariant)));
    this->m_remotePeopleCount = 0;
    this->m_waterMask = false;


    this->m_traditionalLayout = true;

    this->m_fullScreen = false;
    this->m_contentLayoutReady = false;
    this->m_returnToFullScreen = false;
    

    this->m_sendingContent = false;

    if (this->isTraditionalLayout())
    {
        SVCLayoutManager::getInstance()->changeLayout2Tranditional(); //remote: sharing content.
    }
    else
    {
        SVCLayoutManager::getInstance()->changeLayout2ExitScreen3x3();
    }

}

FMeetingViewController::~FMeetingViewController() {}

void FMeetingViewController::onParticipantsNumReport(int participantsNum)
{
    bool isEnable = false;
    if (1 < participantsNum) {
        isEnable = true;
    } else {
        isEnable = false;
    }

    emit cppSendMsgToQMLSetLocalPreviewEnable(isEnable);
}

void FMeetingViewController::onParticipantsListReveived(std::vector<std::string> rosterList) {
    int index = 0;
    QJsonArray rosterListJsonArray;
    for (std::vector<std::string>::iterator iter = rosterList.begin(); iter < rosterList.end(); iter++)
    {
        QString qStrJsonRoster = QString::fromStdString((*iter).c_str());
        QJsonDocument qDocRoster = QJsonDocument::fromJson(qStrJsonRoster.toUtf8());
        QJsonObject qJsonRoster = qDocRoster.object();
        rosterListJsonArray.append(qJsonRoster);
    }

    QJsonObject rosterListJsonArrayObject;
    rosterListJsonArrayObject.insert("rosterListJsonArray", rosterListJsonArray);

    //Use roster list to syn every remote-user's mute states of Mic & Camera.
    QVariant qVaraintRosterListJsonArray = QVariant::fromValue(rosterListJsonArrayObject);
    emit cppSendMsgToQMLUpdateRosterList(qVaraintRosterListJsonArray);
}

//for camera devices.
void FMeetingViewController::onOpenCameraComplete(int nOpenResulte) {
    emit cppSendMsgToQMLOnOpenCameraComplete(nOpenResulte);
}

void FMeetingViewController::slotRemoteViewHiddenOrNot(const QVariant &value) {
    emit cppSendMsgToQMLRemoteViewHiddenOrNot(value);
}

void FMeetingViewController::slotRefreshLayoutMode(const QVariant &mode, const QVariant &value) {
    emit cppSendMsgToQMLRefreshLayoutMode(mode, value);
}

//[Qt]:
void FMeetingViewController::slotPrepareSVCLayout(const QVariant &aSVCLayoutType)
{
    SVCLayoutModeType mode = SVCLayoutManager::getInstance()->getSvcLayoutMode();

    SVCLayoutDetail detail = SVCLayoutManager::getInstance()->gSvcLayoutDetail[mode];

    QJsonObject Obj;
    Obj.insert("videoViewNum", detail.videoViewNum);
    Obj.insert("isSymmetical", detail.isSymmetical);

    int nStrArray = mode + 1;
    //qDebug("= = = nStrArray = %d", nStrArray);

    QJsonArray rowJsonArray;
    for (int i = 0; i <= nStrArray; ++i) {
        QJsonArray columnJsonArray;

        for (int j = 0; j < 4; ++j) {
            float value = detail.videoViewDescription[i][j];
            QString str = QString::number(value , 'f', 3);
            columnJsonArray.append(str);
        }
        rowJsonArray.append(columnJsonArray);
    }

    Obj.insert("videoViewDescription", rowJsonArray);
    
    //2.send to QML UI.
    QVariant varValue = QVariant::fromValue(Obj);

    emit cppSendMsgToQMLPrepareSVCLayout(mode, varValue);
}

QVariant FMeetingViewController::getCurrentSvcLayoutDetail()
{
    SVCLayoutModeType mode = SVCLayoutManager::getInstance()->getSvcLayoutMode();

    SVCLayoutDetail detail = SVCLayoutManager::getInstance()->gSvcLayoutDetail[mode];

    QJsonObject Obj;
    Obj.insert("currentSvcLayoutMode", mode);
    Obj.insert("videoViewNum", detail.videoViewNum);
    Obj.insert("isSymmetical", detail.isSymmetical);

    int nStrArray = mode + 1;

    QJsonArray rowJsonArray;
    for (int i = 0; i <= nStrArray; ++i) {
        QJsonArray columnJsonArray;

        for (int j = 0; j < 4; ++j) {
            float value = detail.videoViewDescription[i][j];
            QString str = QString::number(value , 'f', 3);
            columnJsonArray.append(str);
        }

        rowJsonArray.append(columnJsonArray);
    }

    Obj.insert("videoViewDescription", rowJsonArray);
    
    QVariant varValue = QVariant::fromValue(Obj);
    
    return varValue;
}

//==================== begin for QML interaction ====================
// [get data]: QML call those method to get data from CPP.
//====================   ====================   ====================

bool FMeetingViewController::getTraditionalLayout() {
    return m_traditionalLayout;
}

QVariant FMeetingViewController::getSvcLayoutDetail() {
    QVariant varValue = getCurrentSvcLayoutDetail();
    return varValue;
}

QString FMeetingViewController::getCellCustomUUID() {
    QString qStrCellCustomUUID = QString::fromStdString(m_cellCustomUUID);

    return qStrCellCustomUUID;
}

void FMeetingViewController::dropCall(int callIndex)
{
    SVCLayoutModeType mode = SVCLayoutManager::getInstance()->getSvcLayoutMode();
    SVCLayoutDetail detail = SVCLayoutManager::getInstance()->gSvcLayoutDetail[mode];
}

//for timer

#define FRAME_LEN_1920 1920 * 1080 * 3 / 2

void FMeetingViewController::slotTimeOutHandler()
{
    qDebug("[%s][%d]: for m_timer's signal: timeout()", Q_FUNC_INFO, __LINE__);
    
}


#pragma mark - SVCLayoutDelegate implementation
extern SVCLayoutDetail gSvcLayoutDetail[SVC_LAYOUT_MODE_NUMBER];

//--Internal Function--
void FMeetingViewController::refreshCurrentLayout() {
    qDebug("[%s][%d]", Q_FUNC_INFO, __LINE__);
    QList<SVCVideoInfo *> *viewArray = SVCLayoutManager::getInstance()->getSvcVideoList();
    SVCLayoutModeType mode = SVCLayoutManager::getInstance()->getSvcLayoutMode();
    
    //if the remote view is empty, then create a new SVCVideoInfo for local videoInfo.
    if (0 == viewArray->size()) {
        SVCVideoInfo *newVideoInfo = new SVCVideoInfo();
        newVideoInfo->dataSourceID = "_VPL_PREVIEW";
        newVideoInfo->eVideoType = VIDEO_TYPE_LOCAL;
        viewArray->push_back(newVideoInfo);
        mode = SVC_LAYOUT_MODE_1X1;
    }
    this->refreshLayoutMode(mode, viewArray);
}

void FMeetingViewController::refreshLayoutMode(SVCLayoutModeType mode, QList<SVCVideoInfo *> * viewArray) {  
    this->remoteViewHiddenOrNot(viewArray);
    this->layoutRemoteView(mode, viewArray);
}

//当前，在 [SVCLayout.qml]: function dealwithRecvMsgRemoteViewHiddenOrNot(arg) {

void FMeetingViewController::remoteViewHiddenOrNot(QList<SVCVideoInfo *> * viewArray) {
    QJsonObject ObjHideOrNot;
    QJsonArray videoViewJsonArrayObjHideOrNot;
    for (QList<SVCVideoInfo *>::iterator iter = viewArray->begin(); iter != viewArray->end(); ++iter) {
        SVCVideoInfo *item = (SVCVideoInfo *)*iter;

        QString qStrUUID = QString::fromStdString(item->strUUID);
        QString qStrDisplayName = QString::fromLocal8Bit(item->strDisplayName.c_str());
        QString qStrDataSourceID = QString::fromStdString(item->dataSourceID);

        QJsonObject Obj;
        Obj.insert("strUUID", qStrUUID);
        Obj.insert("strDisplayName", qStrDisplayName);
        Obj.insert("eVideoType", (int)item->eVideoType);
        Obj.insert("dataSourceID", qStrDataSourceID);
        Obj.insert("removed", item->isRemoved());
        Obj.insert("active", item->isActive());
        Obj.insert("maxResolution", item->isMaxResolution());
        Obj.insert("pin", item->isPin ());
        videoViewJsonArrayObjHideOrNot.append(Obj);
    }
    ObjHideOrNot.insert("viewArray", videoViewJsonArrayObjHideOrNot);
    
    //[Qt]: impl in SVCLayoutManager.cpp
    
    //2.send to QML UI.
    QVariant varValueHiddenOrNot = QVariant::fromValue(ObjHideOrNot);
    qDebug("[%s][%d]: -> call emit cppSendMsgToQMLRemoteViewHiddenOrNot(varValueHiddenOrNot)", Q_FUNC_INFO, __LINE__);
    emit cppSendMsgToQMLRemoteViewHiddenOrNot(varValueHiddenOrNot);
}

void FMeetingViewController::layoutRemoteView(SVCLayoutModeType mode, QList<SVCVideoInfo *> * viewArray)
{
    SVCLayoutDetail detail = SVCLayoutManager::getInstance()->gSvcLayoutDetail[mode];

    QJsonObject Obj;
    Obj.insert("videoViewNum", detail.videoViewNum);
    Obj.insert("isSymmetical", detail.isSymmetical);

    int nStrArray = mode + 1;
    qDebug("= = = nStrArray = %d", nStrArray);

    QJsonArray rowJsonArray;
    for (int i = 0; i <= nStrArray; ++i) {
        QJsonArray columnJsonArray;

        for (int j = 0; j < 4; ++j) {
            float value = detail.videoViewDescription[i][j];
            QString str = QString::number(value , 'f', 3);
            columnJsonArray.append(str);
        }

        rowJsonArray.append(columnJsonArray);
    }


    Obj.insert("videoViewDescription", rowJsonArray);
    
    //2.for viewArray
    QJsonArray videoViewJsonArray;
    for (QList<SVCVideoInfo *>::iterator iter = viewArray->begin(); iter != viewArray->end(); ++iter) {
        SVCVideoInfo *item = (SVCVideoInfo *)*iter;

        QString qStrUUID = QString::fromStdString(item->strUUID);
        QString qStrDisplayName = QString::fromLocal8Bit(item->strDisplayName.c_str());
        QString qStrDataSourceID = QString::fromStdString(item->dataSourceID);

        QJsonObject Obj;
        Obj.insert("strUUID", qStrUUID);
        Obj.insert("strDisplayName", qStrDisplayName);
        Obj.insert("eVideoType", (int)item->eVideoType);
        Obj.insert("dataSourceID", qStrDataSourceID);
        Obj.insert("removed", item->isRemoved());
        Obj.insert("active", item->isActive());
        Obj.insert("maxResolution", item->isMaxResolution());
        Obj.insert("pin", item->isPin ());
        videoViewJsonArray.append(Obj);
    }
    Obj.insert("viewArray", videoViewJsonArray);
    
    //3.send to QML UI.
    QVariant varValue = QVariant::fromValue(Obj);
    emit cppSendMsgToQMLLayoutRemoteView(mode, varValue);
}

void FMeetingViewController::setLayoutMode(bool isGridLayout) {
    this->m_currentGridMode = isGridLayout;
    this->m_traditionalLayout = !isGridLayout;

    if (this->isTraditionalLayout()) {
        SVCLayoutManager::getInstance()->changeLayout2Tranditional();
    } else {
        if (this->isFullScreen()) {
            SVCLayoutManager::getInstance()->changeLayout2FullScreen3x3();
        } else {
            SVCLayoutManager::getInstance()->changeLayout2ExitScreen3x3();
        }
    }

   this->refreshCurrentLayout();
}

void FMeetingViewController::remoteLayoutChanged(MeetingLayout::SDKLayoutInfo * buffer) {
    QList<MeetingLayout::SDKItemInfo *> *layout = buffer->layout;

    this->m_remotePeopleCount = layout->count();
    bool isContent = buffer->bContent;
    if (isContent && !m_sendingContent) {
        // 1.[remote content]: buffer is remote content layout changed, and local not sharing content.
        // so, we will show the contentView, and set the Mode to : 1x5 (changeLayout2Tranditional() ).
        //printf("\n***********The content is receiveing now*************\n");
        if (false == this->m_content) {
            //printf("\n***********false == this->m_content*************\n");
            emit cppSendMsgToQMLRemoteContentVideoViewSetHidden(false);
        }

        //1.2.set the Mode to : changeLayout2Tranditional() 1x5, it means remote: sharing content:
        SVCLayoutManager::getInstance()->changeLayout2Tranditional(); //remote: sharing content.
        this->m_traditionalLayout = true; //1.true: 1x5 2.false: 3x3 (full screen or not).
                
        //1.3.if current view is not include content view, then set m_content = true, and post Msg: FMeetingContentStateChangedNotification.
        if (false == this->m_content) {
            //printf("\n***********false == this->m_content and set it is true*************\n");
            this->m_content = true;
        }
        
    } else {
        //2.1.hide the content view.
        emit cppSendMsgToQMLRemoteContentVideoViewSetHidden(true);

        if (this->m_content) {
            emit cppSendMsgToQMLRemoteContentVideoViewRenderMuteImage(true);
            emit cppSendMsgToQMLRemoteContentVideoViewStopRendering();

            emit cppSendMsgToQMLRemoteContentVideoViewSetHidden(true);
        }
        
        this->m_content = false;

        if (this->isCurrentGridMode()) {
            this->m_traditionalLayout = false; //1.true: 1x5 2.false: 3x3 (full screen or not).
            if (this->isFullScreen()) {
                SVCLayoutManager::getInstance()->changeLayout2FullScreen3x3();
            } else {
                SVCLayoutManager::getInstance()->changeLayout2ExitScreen3x3();
            }
        }
    }
    
    this->m_activeSpeakerDatasoucceID = buffer->activeSpeakerSourceId.c_str();
    this->m_cellCustomUUID = buffer->cellCustomUUID.c_str();
    
    
    //QString qStrCellCustomUUID = QString::fromStdString(m_cellCustomUUID);

    QList<SVCVideoInfo *> *svcLayoutInfo = new QList<SVCVideoInfo *>;

    //int nIndex = 0;
    for (QList<SDKItemInfo *>::iterator iter = layout->begin(); iter != layout->end(); ++iter) {
        SDKItemInfo *valueItem = (SDKItemInfo *)*iter;
        SVCVideoInfo *videoInfo = new SVCVideoInfo(); //C_R_
        
        if (valueItem->dataSourceID.rfind("VCR-", 0) != std::string::npos) {
            printf("\nThe valueItem->dataSourceID is %s\n", valueItem->dataSourceID.c_str());
            videoInfo->eVideoType        = VIDEO_TYPE_CONTENT;
            videoInfo->dataSourceID      = valueItem->dataSourceID;
            videoInfo->strDisplayName    = valueItem->strDisplayName;

            videoInfo->resolution_height = UtilScreen::disPlayWidth();
            videoInfo->resolution_width  = UtilScreen::disPlayHeight() * 0.8;
            videoInfo->maxResolution     = false;


            svcLayoutInfo->insert(0, videoInfo);
        } else {
            videoInfo->strUUID           = valueItem->strUUID.c_str();
            videoInfo->strDisplayName    = valueItem->strDisplayName.c_str();

            videoInfo->eVideoType        = VIDEO_TYPE_REMOTE;
            videoInfo->dataSourceID      = valueItem->dataSourceID.c_str();
            videoInfo->resolution_height = valueItem->resolution_height;
            videoInfo->resolution_width  = valueItem->resolution_width;
            videoInfo->removed           = false;

            videoInfo->pin               = valueItem->is_pinned;
            videoInfo->active            = valueItem->is_active;

            bool isMax;
            if (layout->begin() == iter) {
                isMax = true;
            } else {
                isMax = false;
            }
            videoInfo->maxResolution = isMax;
            //videoInfo->pin               = this->userPinStatus(valueItem->strUUID);

            svcLayoutInfo->append(videoInfo);
        }
    }
    
    //Create a new SVCVideoInfo object for local video view info.
    SVCVideoInfo *newVideoInfo  = new SVCVideoInfo();
    newVideoInfo->dataSourceID   = "_VPL_PREVIEW";
    newVideoInfo->eVideoType     = VIDEO_TYPE_LOCAL;
    if (0 == layout->count()) {
        newVideoInfo->resolution_width   = UtilScreen::disPlayWidth();
        newVideoInfo->resolution_height  = UtilScreen::disPlayHeight() * 0.8;
    } else {
        newVideoInfo->resolution_width   = 0.25 * UtilScreen::disPlayWidth();
        newVideoInfo->resolution_height  = 0.17 * UtilScreen::disPlayHeight() * 0.8;
    }
    svcLayoutInfo->append(newVideoInfo);

    SVCLayoutManager::getInstance()->svcRefreshLayoutList(svcLayoutInfo); //include local, remote people, remote content SVCVideoInfo.
}

void FMeetingViewController::remoteVideoReceived(std::string dataSourceID) {
    QJsonObject Obj;
    QString qStrDataSourceID = QString::fromStdString(dataSourceID);
    Obj.insert("dataSourceID", qStrDataSourceID);
    QVariant varValue = QVariant::fromValue(Obj);
    
    emit cppSendMsgToQMLRemoteVideoReceived(varValue);
}

bool FMeetingViewController::userPinStatus(std::string userUUID) {
    bool isEqual = (strcmp(userUUID.c_str(), this->m_cellCustomUUID.c_str()) == 0);
    if (isEqual) {
        return true;
    } else {
        return false;
    }
}

void FMeetingViewController::hiddenLocalView(bool hide) {
    qDebug("[%s][%d]: hide: %d", Q_FUNC_INFO, __LINE__, hide);
    this->setLocalViewHiddenByUser(hide);
}

void FMeetingViewController::onContentStateChanged(bool isSending) {
    qDebug("[%s][%d]: isSending: %s", Q_FUNC_INFO, __LINE__, isSending?"true":"fasle");

    //1.wants to share, but current is sharing, so return.
    if (isSending && this->m_sendingContent) {
        return;
    }
    //2.wants to stop share, but current is not sharing, so return.
    if (!isSending && !this->m_sendingContent) {
        return;
    }
    //3.sharing content
    //this->m_sendingContent = isSending;
    if (isSending) {
        //3.1.local share content.
        qDebug("[%s][%d]: isSending: true, start local sharing content... -> emit cppSendMsgToQMLContentStateChangedCallBack(isSending: %s) ", Q_FUNC_INFO, __LINE__, isSending?"true":"fasle");
        emit cppSendMsgToQMLContentStateChangedCallBack(isSending);


        qDebug("[%s][%d]: isSending is true, local sharing conent -> call this->refreshCurrentLayout()", Q_FUNC_INFO, __LINE__);
        this->refreshCurrentLayout();
    }
    else {
        if(this->m_sendingContent)
        {
            FMakeCallClient::sharedCallClient()->stop_content();
            this->m_sendingContent = false;
        }
        //3.2.remote share content.
        qDebug("[%s][%d]: isSending: true, start local sharing content... -> emit cppSendMsgToQMLContentStateChangedCallBack(isSending: %s) ", Q_FUNC_INFO, __LINE__, isSending?"true":"fasle");
        emit cppSendMsgToQMLContentStateChangedCallBack(isSending);


        qDebug("[%s][%d]: isSending is false, local not sharing conent ->-> call this->refreshCurrentLayout()", Q_FUNC_INFO, __LINE__);
        this->refreshCurrentLayout();
    }

    this->m_sendingContent = isSending;
}

void FMeetingViewController::onContentWaterMaskRecevice(std::string contentWater) {
    qDebug("[%s][%d]: ", Q_FUNC_INFO, __LINE__);

}
