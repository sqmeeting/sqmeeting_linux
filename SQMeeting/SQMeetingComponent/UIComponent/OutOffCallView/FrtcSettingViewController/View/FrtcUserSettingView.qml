import QtQuick 2.0
import QtQuick.Controls
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import "../../../CommonView"

Rectangle {
    id: user_setting_view
    x:155
    width: 640-170
    height: 480
    color: "white" //"#ffffff"

    signal clickChangePsdButton()

    property var subPopupChangePasswordViewControllerQML

    function initChangePasswordWindow() {
        if (null !== subPopupChangePasswordViewControllerQML && undefined !== subPopupChangePasswordViewControllerQML) {
            subPopupChangePasswordViewControllerQML.destroy();
        }

        var detailWindow = Qt.createComponent("./FrtcChangePasswordWindow.qml");
        if (detailWindow.status === Component.Ready) {
            subPopupChangePasswordViewControllerQML = detailWindow.createObject(FrtcTool.rootWindow);
            subPopupChangePasswordViewControllerQML.show();
        }else{
            console.log("FrtcChangePasswordWindow init error")
        }
    }

    Column {

        x: 18
        y: 0
        spacing: 10

        FrtcUserSettingCell {
            id:name_cell
            width: 640-170-50
            height: 40
            titleText: qsTr("姓名")
            titleColor: "#333333"
            desText: qsTr("zhengao")
            source: "qrc:/Images/SettingView/frtc_setting_name@2x.png"
        }

        FrtcUserSettingCell {
            id:account_cell
            width: name_cell.width
            height: name_cell.height
            titleText: qsTr("账号")
            titleColor: name_cell.titleColor
            source: "qrc:/Images/SettingView/frtc_setting_account@2x.png"
        }

        FrtcUserSettingCell {
            width: name_cell.width
            height: name_cell.height
            titleText: qsTr("更改密码")
            titleColor: name_cell.titleColor
            source: "qrc:/Images/SettingView/frtc_setting_psd_off@2x.png"
            hoverSource: "qrc:/Images/SettingView/frtc_setting_psd_on@2x.png"
            hoverEnabled:true
            hoverColor: "#F6FAFF"
            onMouseClicked: {
                console.log("更改密码")
                initChangePasswordWindow()
            }
        }

        FrtcUserSettingCell {
            width: name_cell.width
            height: name_cell.height
            titleColor: name_cell.titleColor
            titleText: qsTr("退出登录")
            source: "qrc:/Images/SettingView/frtc_setting_sign_out_off@2x.png"
            hoverSource: "qrc:/Images/SettingView/frtc_setting_sign_out_on@2x.png"
            hoverEnabled:true
            hoverColor: "#FFF7F7"
            hoverTextColor: "#E32726"
            onMouseClicked: {
                console.log("退出登录")
                FrtcApiManager.sign_out(SDKUserDefaultObject.getUserToken())
            }
        }

    }

    Connections {
        target: FrtcApiManager
        function onSignOutRequestCompleted(success,json) {
            var jsonData = JSON.stringify(json)
            FrtcTool.cancleUserInfo()
            id_setting_view.visible = false
            FrtcTool.refreshMainWindow(false)
        }
    }

    Component.onCompleted: {
        var loadedData = SDKUserDefaultObject.getUserInfo()
        var username = SDKUserDefaultObject.getLoginUserName()
        name_cell.desText = loadedData.username
        account_cell.desText = username
    }

    Component.onDestruction: {
        console.log("FrtcUserSettingView onDestruction")
    }

}
