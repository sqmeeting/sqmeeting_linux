import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import com.frtc.FrtcApiManager 1.0
import com.frtc.FMeetingWindowControllerObject 1.0
import SDKUserDefaultObject 1.0

import "./../../../CommonView/"

Rectangle {
    id:un_mute_call_view
    width: 240
    height: 184
    color: "white"
    radius: 6.0

    border.width:1
    border.color:'#DEDEDE'

    // 标题
    Text {
        id:text_title
        text: "取消全体参会者静音"
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
            text: "取消全体静音"
            color: "white"
            font.pixelSize: 14
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var userToken = SDKUserDefaultObject.getUserToken()
                FrtcApiManager.un_mute_all(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
                un_mute_call_view.destroy()
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
                un_mute_call_view.destroy()
            }
        }
    }

    Component.onCompleted: {
        console.log('Component.onCompleted:FrtcMuteAllWindow')
        visible = true
    }
}
