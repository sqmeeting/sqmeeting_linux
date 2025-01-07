import QtQuick 2.15
import QtQuick.Controls 2.15
import SDKUserDefaultObject 1.0
import "./../../../CommonView/"


Rectangle {

    id: login_view
    color: 'transparent'

    property alias nameFieldValue: nameTextfield.text
    property alias psdFieldValue: passwordTextfield.text

    signal clickLoginButton()

    Component.onCompleted: {
        //nameTextfield.text = "weiza"
        var username = SDKUserDefaultObject.getLoginUserName()
        nameFieldValue = username
    }

    Row {
        id: top_row
        spacing: 15
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: login_icon
            source: "qrc:/Images/MainView/frtc_login_icon@2x.png"
        }

        Text {
            text: qsTr("用户登录")
            color: '#222222'
            font.pixelSize: 18
            anchors.verticalCenter:login_icon.verticalCenter
        }
    }

    FrtcTextField {
        id: nameTextfield
        width: 280
        height: 40
        anchors.top: top_row.bottom
        anchors.topMargin: 35
        anchors.horizontalCenter: parent.horizontalCenter
        isShowLeftImg: true
        textFont: 14
        leftIcon: 'qrc:/Images/MainView/frtc_login_username@2x.png'
        placeholderText: qsTr('请输入账号')
    }

    FrtcTextField {
        id: passwordTextfield
        width: nameTextfield.width
        height: nameTextfield.height
        anchors.top: nameTextfield.bottom
        anchors.topMargin: 15
        textFont: 14
        anchors.horizontalCenter: parent.horizontalCenter
        isPasswordMode: true
        isShowLeftImg: true
        leftIcon: 'qrc:/Images/MainView/frtc_login_password@2x.png'
        placeholderText: qsTr('请输入密码')
    }

    FrtcButton {
        id: login_btn
        width: nameTextfield.width
        height: nameTextfield.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordTextfield.bottom
        anchors.topMargin: 30
        buttonText: qsTr('登录')
        onMouseClicked: {
            console.log(login_btn.buttonText + 'username:' + nameFieldValue + 'password:' + psdFieldValue)
            clickLoginButton()
        }
    }

    FrtcCheckBoxView {

        id:checkbox_view
        anchors.top: login_btn.bottom
        anchors.topMargin: 10
        anchors.left: login_btn.left

        btn_txt_unchecked: qsTr("自动登录")
        btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
        btn_txt_checked: qsTr("自动登录")
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
        isStateChangeButton: true
        checked: SDKUserDefaultObject.getAutoLoginState() ? true : false

        onMouseClicked: {
            if (checkbox_view.checked === false) {
                SDKUserDefaultObject.onQmlSaveAutoLoginState(false)
                console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : false");
            } else {
                SDKUserDefaultObject.onQmlSaveAutoLoginState(true)
                console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : true");
            }
        }

    }


}
