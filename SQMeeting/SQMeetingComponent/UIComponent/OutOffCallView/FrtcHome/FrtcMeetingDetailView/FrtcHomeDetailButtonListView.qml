import QtQuick 2.15
import "../../../CommonView"

Rectangle {

    property alias cancelMeetingHidden: cancelMeeting_btn.visible

    signal clickJoinMeeting()
    signal clickCopyInfo()
    signal clickCancelMeeting()

    Column {

        spacing: 15
        anchors.fill: parent
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 15

        FrtcButton {
            id: joinMeeting_btn
            height: 40
            anchors.left: parent.left
            anchors.right: parent.right
            buttonText: qsTr('进入会议')
            onMouseClicked: clickJoinMeeting()
        }

        FrtcButton {
            id: copyMeeting_btn
            height: joinMeeting_btn.height
            anchors.left: parent.left
            anchors.right: parent.right
            borderColor: "#cccccc"
            backgroundColor: "white"
            textColor: "#026FFE"
            hoverColor: "#eeeeee"
            buttonText: qsTr('复制邀请')
            onMouseClicked: clickCopyInfo()
        }

        FrtcButton {
            id: cancelMeeting_btn
            height: joinMeeting_btn.height
            anchors.left: parent.left
            anchors.right: parent.right
            visible: cancelMeetingHidden
            borderColor: "#cccccc"
            backgroundColor: "white"
            hoverColor: "#eeeeee"
            textColor: "red"
            buttonText: qsTr('取消会议')
            onMouseClicked: clickCancelMeeting()
        }

    }
}
