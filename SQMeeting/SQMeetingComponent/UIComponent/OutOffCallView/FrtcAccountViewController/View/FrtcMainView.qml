import QtQuick 2.15
import QtQuick.Controls 2.15

import com.frtc.FrtcApiManager 1.0
import QtQuick.Controls.Material 2.15
import SDKUserDefaultObject 1.0

import "../../FrtcAccountViewController/View"
import "./../../../CommonView/"
import "./../../FrtcMainViewController/View"
import "./../../FrtcHome"

Rectangle {

    x:0
    y:0
    width: 640
    height: 480 - 40

    signal loginSuccess()

    Image {
        id:backgroundImage
        anchors.bottom: parent.bottom
        source: "qrc:/Images/MainView/icon-main-background@2x.png"
    }

    IconButton {
        id: main_view_setting_button
        width: 32
        height: 32
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 18

        isStateChangeButton: false
        btn_img_src_unselected: "qrc:/Images/MainView/icon-setting@2x.png"
        btn_img_src_selected: "qrc:/Images/MainView/icon-setting@2x.png"
        onMouseClicked: {
            console.log("[IconButton]: main_view_setting Button clicked: -> call initSettingUI().")
            initSettingUI()
        }
    }

    FrtcEntryView {
        id: entry_view
        width: 400
        height: 410
        anchors.centerIn: parent

        onClickJoinMeeting: {
            callView.visible = true
        }

        onClickLoginButton: {
            console.log("[main.qml][joinButton]: press login button");
            entry_view.visible = false
            main_login_View.visible = true
            main_back_button.visible = true
        }
    }

    FrtcLoginView {
        id: main_login_View
        y: 70
        width: 400
        height: 350
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false

        onClickLoginButton: {
            console.log("main_login_view.name", main_login_View.nameFieldValue)
            console.log("main_login_view.password", main_login_View.psdFieldValue)
            if (main_login_View.nameFieldValue && main_login_View.psdFieldValue) {
                SDKUserDefaultObject.onQmlSaveLoginUserName(main_login_View.nameFieldValue)
                FrtcApiManager.sign_in(main_login_View.nameFieldValue,main_login_View.psdFieldValue)
            }else{

            }
        }

    }

    FrtcCallView {
        id: callView
        anchors.centerIn: parent
        visible: false

        onDestroyCallView: {
            callView.visible = false
        }
    }

    Button {
        id: main_back_button
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        text: qsTr('返回')
        icon.source: 'qrc:/Images/MainView/frtc_login_back@2x.png'
        icon.color: "transparent"
        visible: false

        background: Rectangle {
            color: 'transparent'
        }

        onClicked: {
            entry_view.visible  = true
            main_login_View.visible  = false
            main_back_button.visible = false
        }
    }

    FrtcToastView {
        id: toastView
    }

    Component.onCompleted: {

    }

    Connections {
        target: FrtcApiManager
        function onSignInRequestCompleted(success,json) {
            var jsonData = JSON.stringify(json)
            console.log('FrtcMainView --', "success:", success, " " , "jsonData:", jsonData);
            if (success) {
                SDKUserDefaultObject.onQmlSaveUserInfo(json)
                SDKUserDefaultObject.onQmlSaveUserToken(json.user_token)
                SDKUserDefaultObject.onQmlSaveLoginState(true)
                FrtcTool.refreshMainWindow(true)
                homeView.onLoginSuccess()
            }else {
                toastView.showText(qsTr("登录失败,请检查用户名和密码"))
            }
        }
    }

}
