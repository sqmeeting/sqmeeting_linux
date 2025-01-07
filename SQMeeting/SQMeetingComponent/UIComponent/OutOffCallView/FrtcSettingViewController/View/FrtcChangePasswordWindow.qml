import QtQuick 2.0
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import "../../../CommonView"

Window {
    id: changePasswordWindow
    width: 380
    height: 455
    minimumWidth: 380
    minimumHeight: 455
    maximumHeight: 455
    maximumWidth:  380

    function validatePasswords() {

        if (oldPsdField.text === "" || newPsdField.text === "" || confirmPsdField.text === "") {
            console.log("密码不能为空");
            toastView.showText("密码不能为空")
            return;
        }

        if (newPsdField.text !== confirmPsdField.text) {
            console.log("两次密码不一致");
            toastView.showText("两次密码不一致")
            return;
        }

        //patternText = "^[a-zA-Z0-9!@#$%*()\\[\\]_+^&}{:;?.]{6,48}$";

        var newPattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{6,48}$";
        var regex = new RegExp(newPattern);
        if (!regex.test(confirmPsdField.text)) {
            console.log("新密码不符合密码复杂度规则");
            toastView.showText("新密码不符合密码复杂度规则")
            return;
        }
        console.log("密码验证通过！");

        var  userToken = SDKUserDefaultObject.getUserToken()
        FrtcApiManager.modifyPassword(userToken,oldPsdField.text,confirmPsdField.text)
    }

    Component.onCompleted: {

    }

    Rectangle {

        anchors.fill:parent

        ColumnLayout {
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 10

            RowLayout {

                spacing: 10

                Text {
                    text: "旧密码"
                }

                FrtcTextField {
                    id: oldPsdField
                    width: changePasswordWindow.width * 0.60
                    height: 35
                    isShowRightImg: true
                    textFont: 14
                    placeholderText: "旧密码"
                    isPasswordMode: true
                    rightIcon: 'qrc:/Images/SettingView/frtc-icon-password@2x.png'
                    property bool isOldPasswordVisible: false

                    onClickRightIcon: {
                        if (isOldPasswordVisible) {
                            isOldPasswordVisible = false
                            oldPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icon-password@2x.png'
                            oldPsdField.isPasswordMode = true
                        } else {
                            isOldPasswordVisible = true
                            oldPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icom-passcode-show@2x.png'
                            oldPsdField.isPasswordMode = false
                        }

                    }
                }
            }

            RowLayout {

                spacing: 10

                Text {
                    text: "新密码"
                }

                FrtcTextField {
                    id: newPsdField
                    width: changePasswordWindow.width * 0.60
                    height: 35
                    isShowRightImg: true
                    textFont: 14
                    isPasswordMode: true
                    placeholderText: "新密码"
                    rightIcon: 'qrc:/Images/SettingView/frtc-icon-password@2x.png'

                    property bool isNewPasswordVisible: false

                    onClickRightIcon: {

                        if (isNewPasswordVisible) {
                            isNewPasswordVisible = false
                            newPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icon-password@2x.png'
                            newPsdField.isPasswordMode = true
                        } else {
                            isNewPasswordVisible = true
                            newPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icom-passcode-show@2x.png'
                            newPsdField.isPasswordMode = false
                        }
                    }
                }
            }

            Text {
                text: "                6-48位，由大、小写字母、数字、特殊字符组成"
                color: "#666"
                font.pixelSize: 11
            }

            RowLayout {

                spacing: 10

                Text {
                    text: "确认    "
                }

                FrtcTextField {
                    id: confirmPsdField
                    width: changePasswordWindow.width * 0.60
                    height: 35
                    isShowRightImg: true
                    textFont: 14
                    isPasswordMode: true
                    placeholderText: "确认新密码"
                    rightIcon: 'qrc:/Images/SettingView/frtc-icon-password@2x.png'
                    property bool isConfirmPasswordVisible: false

                    onClickRightIcon: {
                        if (isConfirmPasswordVisible) {
                            isConfirmPasswordVisible = false
                            confirmPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icon-password@2x.png'
                            confirmPsdField.isPasswordMode = true
                        } else {
                            isConfirmPasswordVisible = true
                            confirmPsdField.rightIcon = 'qrc:/Images/SettingView/frtc-icom-passcode-show@2x.png'
                            confirmPsdField.isPasswordMode = false
                        }
                    }
                }
            }

            Item {
                height: 8
            }

            RowLayout {

                spacing: 10

                FrtcButton {
                    id: join_meeting_btn
                    width: 135
                    height: 35
                    textColor: '#222'
                    backgroundColor: '#f0f0f0'
                    hoverColor: '#cae1ff'
                    buttonText: qsTr('取消')
                    onMouseClicked: {
                        changePasswordWindow.destroy()
                    }
                }

                FrtcButton {
                    id: login_btn
                    width: join_meeting_btn.width
                    height: join_meeting_btn.height

                    textColor: 'white'
                    buttonText: qsTr('保存')

                    onMouseClicked: {
                        validatePasswords()
                    }

                }
            }
        }
    }

    FrtcToastView {
        id: toastView
    }

    Connections {
        target: FrtcApiManager
        function onModifyPasswordCompleted(success) {
            if (success) {
                console.log("修改密码成功了")
                AlertManager.showAlertView(qsTr("密码已修改"),
                                           qsTr("您的密码已修改,请重新登录"),
                                           FrtcAlertView.OkButton,
                                           function(result) {
                                               FrtcApiManager.sign_out(SDKUserDefaultObject.getUserToken())
                                               changePasswordWindow.destroy()
                                           },
                                           "确定",
                                           );
            }else {
                console.log("修改密码出错,请检查密码")
                toastView.showText("修改密码出错,请检查密码")
            }
        }
    }
}
