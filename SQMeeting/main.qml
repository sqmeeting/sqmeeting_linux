import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import SDKUserDefaultObject 1.0
import com.frtc.FrtcApiManager 1.0

import "./SQMeetingComponent/UIComponent/CommonView"
import "./SQMeetingComponent/UIComponent/OutOffCallView/FrtcHome"
import "./SQMeetingComponent/UIComponent/OutOffCallView/FrtcMainViewController/View"
import "./SQMeetingComponent/UIComponent/OutOffCallView/FrtcSettingViewController/View"
import "./SQMeetingComponent/UIComponent/OutOffCallView/FrtcAccountViewController/View"

Window {
    id: main_Window
    width: 640
    height: 480 - 40

    //fix the window size
    minimumWidth: 640
    minimumHeight: 480 - 40
    maximumWidth: 640
    maximumHeight: 480 - 40
    x: (screen.width - width) / 2
    y: (screen.height - height) / 2

    visible: true
    title: qsTr(" ")

    //define the flag for creat or destroy.
    property bool createOrdestroy: false
    property var  subPopupFrtcSettingViewControllerQML;
    property string name: ""

    //flags: Qt.FramelessWindowHint | Qt.Window
    //flags: Qt.FramelessWindowHint //hide titleBar window.
    //flags: Qt.Window | Qt.FramelessWindowHint //禁用原生态的窗口

    function showName() {
        console.log("[main.qml][function name] : " + name)
    }

    function hideMainWindow(aShow) {
        if (aShow) {
            main_Window.opacity = 0
        } else {
            main_Window.opacity = 1
        }
    }

    function initSettingUI() {
        if (null !== subPopupFrtcSettingViewControllerQML && undefined !== subPopupFrtcSettingViewControllerQML) {

            subPopupFrtcSettingViewControllerQML.destroy();
        }

        var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/OutOffCallView/FrtcSettingViewController/View/FrtcSettingViewController.qml");
        if (component.status === Component.Ready) {
            var subParams = {
                "strText":  qsTr("create object."),
                "strColor": "red"
            }
            subPopupFrtcSettingViewControllerQML = component.createObject(main_Window, subParams);
            subPopupFrtcSettingViewControllerQML.show();
        }
    }

    function updateMainWindow(isLogin) {

        if (isLogin) {
            main_Window.width = 380
            main_Window.height = 660
            main_Window.minimumHeight = 660
            main_Window.minimumWidth = 380
            main_Window.maximumHeight = 660
            main_Window.maximumWidth = 380

            homeView.visible  = true
            mainView.visible = false
        } else {

            main_Window.width = 640
            main_Window.height = 480 - 40
            main_Window.minimumWidth = 640
            main_Window.minimumHeight = 480 - 40
            main_Window.maximumWidth = 640
            main_Window.maximumHeight = 480 - 40

            homeView.visible  = false
            mainView.visible = true
        }
    }

    FrtcHomeWindow {
        id: homeView
        anchors.fill: parent
        visible: false
    }

    FrtcMainView {
        id:mainView
    }

    FrtcLoadingView {
        id: loadingView
        visible: false
    }

    Component.onCompleted: {

        var autologinState = SDKUserDefaultObject.getAutoLoginState()
        var userToken      = SDKUserDefaultObject.getUserToken()
        var userInfo       = SDKUserDefaultObject.getUserInfo()

        if (autologinState && userToken !== '') {
            console.log("auto login --- ");
            FrtcApiManager.sign_in_token(userToken)
            homeView.visible  = true
            mainView.visible = false
            updateMainWindow(true)
        } else {
            console.log("not auto login");
            SDKUserDefaultObject.onQmlSaveLoginState(false)
            homeView.visible  = false
            mainView.visible = true
            updateMainWindow(false)
        }

        FrtcTool.rootWindow = main_Window

        FrtcTool.refreshMainWindow.connect(function (isLogin) {
            updateMainWindow(isLogin)
        })

        FrtcTool.hideMainWindow.connect(function (isHide) {
            main_Window.visible = !isHide
        })

        FrtcCallInterface.makeCallStateBlock.connect(function(success, reason) {
            if (reason === -1) { // -1 为开始入会
                loadingView.visible = true
            }else {
                loadingView.visible = false
            }
        })

    }

    Connections {
        target: FrtcApiManager
        function onSignInTokenRequestCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            console.log('Main --', "success:", success, " " , "jsonData:", jsonData);
            SDKUserDefaultObject.onQmlSaveUserInfo(json)
            SDKUserDefaultObject.onQmlSaveUserToken(json.user_token)
            SDKUserDefaultObject.onQmlSaveLoginState(true)
        }

        function onSignExpiredCompleted() {
            if (!FrtcTool.isMeetingIn) {
                FrtcTool.cancleUserInfo()
                FrtcTool.refreshMainWindow(false)
            }
        }
    }

}


