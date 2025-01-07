#ifndef SVCLAYOUTMANAGER_H
#define SVCLAYOUTMANAGER_H

#include <QObject>
#include <QtCore/QMutex>


#include "SVCVideoInfo.h"

namespace MeetingLayout
{

#define REMOTE_PEOPLE_VIDEO_NUMBER 9

typedef enum _SVCLayoutModeType {
    SVC_LAYOUT_MODE_1X1 = 0,
    SVC_LAYOUT_MODE_1X2,
    SVC_LAYOUT_MODE_1X3,
    SVC_LAYOUT_MODE_1X4,
    SVC_LAYOUT_MODE_1X5,
    SVC_LAYOUT_MODE_1X6,
    SVC_LAYOUT_MODE_1X7,
    SVC_LAYOUT_MODE_1X8,
    SVC_LAYOUT_MODE_1X9,
    SVC_LAYOUT_MODE_NUMBER
} SVCLayoutModeType;


typedef struct _SVCLayoutDetail {
    int videoViewNum;
    bool isSymmetical;
    float videoViewDescription[REMOTE_PEOPLE_VIDEO_NUMBER+2][4];  // +2 means adding local and content view
} SVCLayoutDetail;


//Q_DECLARE_METATYPE(SVCLayoutDetail)

class SVCLayoutManager : public QObject {
    Q_OBJECT
private:
    static QMutex m_Mutex;
    static SVCLayoutManager *shareInstance;
public:
    static SVCLayoutManager* getInstance();
    static void releaseInstance();
private:
    //explicit SVCLayoutManager(QObject *parent = nullptr);
    SVCLayoutManager(QObject *parent = nullptr);
    ~SVCLayoutManager();

signals:
    //[FmeetingViewController.cpp]: connect signalRefreshLayoutMode with the slot: FmeetingViewController::slotRefreshLayoutMode().
    void signalRefreshLayoutMode(const QVariant &arg1, const QVariant &arg2);
    void signalRemoteViewHiddenOrNot(const QVariant &arg);
    //[Qt]:
    void signalPrepareSVCLayout(const QVariant &aSVCLayoutType);

public:
    void prepareSVCFullScreen3x3LayoutDetail();
    void prepareSVC3x3LayoutDetail();
    void prepareSVCLayoutDetail();
    SVCLayoutDetail gSvcLayoutDetail[SVC_LAYOUT_MODE_NUMBER] = {0};
    
    void sendDataToQMLPrepareSVCLayout(std::string aSVCLayoutType);
    


public:
    //for SVCVideoInfo.
    QList<SVCVideoInfo *> * m_svcVideoList;
    QList<SVCVideoInfo *> * getSvcVideoList() {return m_svcVideoList; }
    SVCLayoutModeType m_svcLayoutMode;
    SVCLayoutModeType getSvcLayoutMode() {return m_svcLayoutMode; }
    
    bool m_gridModeLayout;
    bool isGridModeLayout () { return m_gridModeLayout; }
    
//    bool isFullScreen;
//    bool isTraditionalLayout;
    
    
public:
    void showSVCVideoInfoArray(QString strMsg, QList<SVCVideoInfo *> *videoLayoutInfo);
    void svcRefreshLayoutList(QList<SVCVideoInfo *> *videoLayoutInfo);
    void clearRemoteUserInfo();
    
    void changeLayout2FullScreen3x3();
    void changeLayout2ExitScreen3x3();
    void changeLayout2Tranditional();

    QString videoType(VideoType type);
    
    void figureOutLayoutMode_phone();
    
    //[Mac]: FMeetingViewController.m
    //[Qt]: SVCLayoutManager.cpp, for on Qt: FMeetingViewController.cpp will used by QML (UI: FMeetingViewController.qml).
    void refreshLayoutMode(SVCLayoutModeType mode, QList<SVCVideoInfo *> * viewArray);
    
};
}

#endif // SVCLAYOUTMANAGER_H
