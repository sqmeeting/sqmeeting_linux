#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDateTime>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QQuickStyle>

// for init: register C++ Object for inCall QML.
#include "FMeetingWindowController.h"
#include "FrtcMediainfoManager.h"
#include "FrtcClipboard.h"
#include "FrtcMediaStaticsInstance.h"
#include "FMakeCallClient.h"

//for Out off Call UI.
#include "FrtcMainViewController.h"
#include "FrtcCallView.h"

//for In Call UI.
#include "FrtcCallBarView.h"


#include <QQmlContext>
#include <QQuickView>

//for App singleton.
#include <QDir>
#include <QLockFile>
#include "FrtcApiManager.h"
#include "SDKUserDefault.h"
#include "FrtcLogUploader.h"
#include "QMLFileHelper.h"
#include "FrtcFileManager.h"



//for FrtcParticipantsViewController.qml
#include "FrtcParticipantsViewController.h"
#include "FrtcSharingFrameWindow.h"

// for process name.
//#include <sys/prctl.h>

#include <stdio.h>
#include "FrtcContentSelectShowImage.h"

#if defined (UOS)
#include "LogHelper.h"
#elif defined (__APPLE__)
#include "LogHelper.h"
#elif defined (WIN32)
#include<windows.h>
#endif


//for sdk, conference.
#include "FMeetingViewController.h"
#include "VideoRender.h"
#include "SVCLayoutManager.h"

int main(int argc, char *argv[])
{
    qDebug("==================================================");
    qDebug("=       FrtcMeeting Qt, Start...                 =");
    qDebug("==================================================");
    setbuf(stdout, NULL);

#if defined (UOS)
    InitLog();
#elif defined (__APPLE__)
    InitLog();
#elif defined (WIN32)

#endif

    InfoLog("=       SQMeeting Qt, Start...                 =");

    //----------------------------------------
    // check app is signgle instance running.
    //----------------------------------------

    QString path = QDir::temp().absoluteFilePath("FrtcMeetingAppSingle.lock");
    QLockFile lockFile(path);
    bool isLock = lockFile.isLocked();
    qDebug("[%s][%d]: FrtcMeetingAppSingle.lock isLock: %s", Q_FUNC_INFO, __LINE__, isLock? "true":"fasle");
    // tryLock: try to create and lock the file. if success, then return true; else return false.
    // if another Process of this Application is running, or the lock file has been created by other Process, then wait 100ms and return.
    qDebug("[%s][%d]: -> call lockFile.tryLock(100)", Q_FUNC_INFO, __LINE__);
    if (!lockFile.tryLock(100)) {
        qDebug("[%s][%d]: FrtcMeeting App is running..., so exit this run.", Q_FUNC_INFO, __LINE__);
        return 0;
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);    

    QGuiApplication app(argc, argv);

    // 设置默认样式为 Basic
    QQuickStyle::setStyle("Basic");

    QStringList args = app.arguments();
    if (args.count() > 1) {
        QString url = args.at(1);
        qDebug("[%s][%d] link url: %s", Q_FUNC_INFO, __LINE__, qPrintable(url));
    }

    QIcon icon(":/logo/logo.ico");
    QGuiApplication::setWindowIcon(icon);

    //[Out of call]: for FrtcSettingViewController QML, use SDKUserDefault.cpp.
    qmlRegisterSingletonInstance("SDKUserDefaultObject", 1, 0, "SDKUserDefaultObject", SDKUserDefault::getInstance());

    QString serverAddress = SDKUserDefault::getInstance()->getServerAddressFromUserConfigFile();
    qDebug("[%s][%d] serverAddress: %s", Q_FUNC_INFO, __LINE__, qPrintable(serverAddress));


    qmlRegisterSingletonInstance("FrtcLogUploaderObj", 1, 0, "FrtcLogUploaderObj", LogUploader::getInstance());
    qmlRegisterSingletonInstance("QMLFileHelperObj", 1, 0, "QMLFileHelperObj", QMLFileHelper::getInstance());

    qmlRegisterType<FrtcCallView>("CallViewObject", 1, 0, "CallViewObject");

    qmlRegisterSingletonInstance("com.frtc.FMeetingWindowControllerObject", 1, 0, "FMeetingWindowControllerObject", FMeetingWindowController::getInstance());

    // for FrtcCall::init: register C++ Object for inCall QML.
    FMakeCallClient::sharedCallClient();

    qDebug("[%s][%d]: -> call qFmlRegisterSingletonInstance(com.frtc.FrtcMediaStaticsInstanceObject, 1, 0, FrtcMediaStaticsInstanceObject, FrtcMediaStaticsInstance::sharedInstance())", Q_FUNC_INFO, __LINE__);
    qmlRegisterSingletonInstance("com.frtc.FrtcMediaStaticsInstanceObject", 1, 0, "FrtcMediaStaticsInstanceObject", FrtcMediaStaticsInstance::sharedInstance());

    qmlRegisterSingletonInstance("com.frtc.FrtcApiManager", 1, 0, "FrtcApiManager", FrtcApiManager::instance());

    //UnifiedVideoCapture::getInstance()->initCamera();


    QQmlApplicationEngine engine;

    FrtcMainViewController *mainVC = new FrtcMainViewController();
    FrtcCallView *frtcCallViewObject = FrtcCallView::getInstance(); //new FrtcCallView();
    frtcCallViewObject->frtcCallWindowdelegate = mainVC; //new FrtcMainViewController()
    engine.rootContext()->setContextProperty("frtcCallViewObject", frtcCallViewObject);

    qmlRegisterType<FrtcCallBarView>("FrtcCallBarView", 1, 0, "FrtcCallBarViewObject");

    // for FrtcParticipantsViewController.qml
    qmlRegisterSingletonInstance("com.frtc.FrtcParticipantsViewControllerObject", 1, 0, "FrtcParticipantsViewControllerObject", FrtcParticipantsViewController::getInstance());

    //FrtcMediaInfoManager mediaInfo;
    engine.rootContext()->setContextProperty("mediaInfoManager", FrtcMediaInfoManager::sharedInstance());

    FrtcClipboard clipboard;
    engine.rootContext()->setContextProperty("clipboard",&clipboard);

    FrtcFileManager fileManager;
    engine.rootContext()->setContextProperty("fileManager",&fileManager);

    //qmlRegisterType register C++ type and then QML will use it.
    //arg1: import model name.
    //arg2: main version
    //arg3: sub version
    //arg4: QML type name
    qmlRegisterType<VideoRender>("VideoRenderObject", 1, 0, "VideoRenderObject");

    //[In call]: for UI QML.
    qmlRegisterSingletonInstance("com.frtc.FMeetingViewControllerObject", 1, 0, "FMeetingViewControllerObject", FMeetingViewController::getInstance());

    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/SQMeetingComponent/UIComponent/CommonView/FrtcTool.qml")), "FrtcTool", 1, 0, "FrtcTool");
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/SQMeetingComponent/UIComponent/CommonView/AlertManager.qml")), "AlertManager", 1, 0, "AlertManager");
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/SQMeetingComponent/UIComponent/CommonView/FrtcCallInterface.qml")), "FrtcCallInterface", 1, 0, "FrtcCallInterface");


    qRegisterMetaType<MeetingLayout::SVCLayoutDetail>("SVCLayoutDetail");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);
    

    //----------------------------------------
    // for share content select.
    //----------------------------------------
    FrtcContentSelectShowImage *showImageObject = new FrtcContentSelectShowImage();
    engine.rootContext()->setContextProperty("showImageObject", showImageObject);
    engine.addImageProvider(QLatin1String("showImageObjectImgProvider"), showImageObject->m_pImgProvider);

    FrtcSharingFrameWindow::getInstance()->createSharingBarFrameWindow(engine);

    return app.exec();
}
