import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import com.frtc.FrtcApiManager 1.0
import com.frtc.FMeetingWindowControllerObject 1.0
import SDKUserDefaultObject 1.0

import "./../../../CommonView/"

Rectangle {
    id:mute_call_view
    width: 240
    height: 220
    color: "white"
    radius: 6.0

    border.width:1
    border.color:'#DEDEDE'

    // 标题
    Text {
        id:text_title
        text: "全体参会者静音"
        font.pixelSize: 14
        font.weight: Font.WeightSemibold
        color: "#333333"
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12
    }

    // 全体静音按钮
    Rectangle {
        id: muteAllButton
        width: 200
        height: 40
        color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1)
        radius: 4.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: text_title.bottom
        anchors.topMargin: 18 // 标题高度12+文字18+按钮垂直偏移

        Text {
            text: "全体静音"
            color: "white"
            font.pixelSize: 14
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var userToken = SDKUserDefaultObject.getUserToken()
                FrtcApiManager.mute_all(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber(), allowUnMuteCheckBox.checked)
                mute_call_view.destroy()
            }
        }
    }

    // 取消按钮
    Rectangle {
        id: cancelButton
        width: 200
        height: 40
        color: "white"
        radius: 4.0
        border.color: "#999999"
        border.width: 1.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: muteAllButton.bottom
        anchors.topMargin: 16

        Text {
            text: "取消"
            color: Qt.rgba(0x24/255.0, 0x24/255.0, 0x25/255.0, 1)
            font.pixelSize: 14
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mute_call_view.destroy()
            }
        }
    }

    Component.onCompleted: {
        console.log('Component.onCompleted:FrtcMuteAllWindow')
        visible = true
    }

    FrtcCheckBoxView {
        id:allowUnMuteCheckBox

        anchors.left: parent.left
        anchors.leftMargin: 18
       // anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: cancelButton.bottom
        anchors.topMargin: 20

        isStateChangeButton: true
        state: "UNSELECTED"
        checkable: true

        btn_txt_unchecked: qsTr("允许参会者自我解除静音")
        btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
        btn_txt_checked: qsTr("允许参会者自我解除静音")
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

        onMouseClicked: {

        }
    }
}
