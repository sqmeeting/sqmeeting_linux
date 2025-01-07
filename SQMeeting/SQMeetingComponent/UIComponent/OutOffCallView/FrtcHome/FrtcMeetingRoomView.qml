import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Window

import '../../CommonView'

Rectangle {

    id: meeting_room_view
    width: 170
    height: 85
    border.width: 1
    border.color: '#EEEFF0'
    radius:8

    property alias person_room_isEnable : meeting_room_checkbox.isEnable
    property bool  checked: meeting_room_checkbox.checked
    property var   currentRoomMeeting: roomnumbercombox.currentRoomMeeting
    property bool  muteCamera : camera_checkbox.checked

    FrtcPopupTriangleView {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    FrtcCheckBoxView {
        id: camera_checkbox
        height: 40
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 8
        isStateChangeButton: true
        state: "UNSELECTED"
        checkable: true

        btn_txt_unchecked: qsTr("开启摄像头");
        btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked.png";
        btn_txt_checked: qsTr("开启摄像头");
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png";

        onMouseClicked: {
            console.log("[UI][FrtcCallView QML][onMouseClicked]: A mouse Button clicked");
        }
    }

    Rectangle {
        id:line_view
        anchors.top: camera_checkbox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: '#DEDEDE'
    }

    FrtcCheckBoxView {
        id: meeting_room_checkbox
        anchors.top: line_view.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 8

        isStateChangeButton: true
        state: "UNSELECTED"
        checkable: true

        btn_txt_unchecked: qsTr("使用我的个人会议号");
        btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked.png";
        btn_txt_checked: qsTr("使用我的个人会议号");
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png";

        onMouseClicked: {
            console.log("[UI][FrtcCallView QML][onMouseClicked]: A mouse Button clicked --- :  " + meeting_room_checkbox.checked);
            if (meeting_room_checkbox.checked) {
                meeting_room_view.height = 120
                roomnumbercombox.visible = true
            }else{
                meeting_room_view.height = 85
                roomnumbercombox.visible = false
            }
        }
    }

    FrtcMeetingRoomNumberCombox {
        id: roomnumbercombox
        width: 150
        height: 30
        anchors.top: meeting_room_checkbox.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }


}
