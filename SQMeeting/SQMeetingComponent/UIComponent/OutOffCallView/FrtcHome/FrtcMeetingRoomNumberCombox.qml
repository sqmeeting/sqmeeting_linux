import QtQuick
import QtQuick.Controls
import QtQuick.Window

Rectangle {

    property var meetingNumbers: []

    property var currentRoomMeeting

    Connections {
        target: home_view
        function onGetMeetingRoomListSuccess(meetingRoomsList) {
            //console.log("onGetMeetingRoomListSuccessonGetMeetingRoomListSuccess",meetingRoomsList[0].meeting_number )
            meetingNumbers = meetingRoomsList
            moreMenu.height = 35 * meetingNumbers.length
            if (meetingNumbers.length > 0) {
                comboxButton.text = meetingNumbers[0].meeting_number
                currentRoomMeeting = meetingNumbers[0]
            }
        }
    }

    Button {
        id: comboxButton
        anchors.left: parent.left
        anchors.right: parent.right

        onClicked: {
            moreMenu.visible = true
        }
    }

    Popup {
        id: moreMenu
        x: 0
        y: comboxButton.height - 30
        width: parent.width
        height: 35 * meetingNumbers.length
        visible: false
        background: Rectangle {
            color: "#dedede"
        }

        contentItem: Column {
            clip: true
            spacing: 1
            Repeater {
                model: meetingNumbers
                delegate: MenuItem {
                    text: modelData.meeting_number
                    onClicked: {
                        moreMenu.restoreState()
                        currentRoomMeeting = modelData
                        comboxButton.text =  modelData.meeting_number
                        console.log('click:',modelData.meeting_number)
                    }
                }
            }
        }

        function updateVisibility(show) {
            visible = show
        }

        function restoreState() {
            visible = false
        }
    }
}
