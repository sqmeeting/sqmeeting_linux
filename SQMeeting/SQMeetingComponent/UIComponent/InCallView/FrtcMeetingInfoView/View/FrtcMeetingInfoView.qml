import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Message box: will automatically hide after 5 seconds.
//========================================

Rectangle {
    property alias messageString: meeting_id_text_view.text
    property int timerCounter: 0
    property int timerDuration: 3
    width: 240
    height: 150 //default 3 seconds.
    radius: 4

    color: "#f8f9fa"

    function setMeetingInfoData(conferenceName, meetingID, ownerName, meetingPasscode) {
        console.log("[UI][FrtcMeetingInfoView.qml][setMeetingInfoData:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        meetinginfo_conference_name_text_view.text = conferenceName
        meeting_id_text_view.text = meetingID
        meeting_ownername_text_view.text = ownerName
        meeting_passcode_text_view.text = meetingPasscode
    }

    function showMeetingInfoView(conferenceName, meetingID, ownerName, meetingPasscode) {
        console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        meetinginfo_conference_name_text_view.text = conferenceName
        //TODO: test
        //meetinginfo_conference_name_text_view.text = "conferenceName long meeting name so we need minize the font size to fit it ."

        meeting_id_text_view.text = meetingID
        meeting_ownername_text_view.text = ownerName
        meeting_passcode_text_view.text = meetingPasscode
        //console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: -> set prompt_message_box_view.visible = true")
        visible = true

        //Timer.
        //console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: -> set prompt_message_box_view.start()")
        //prompt_message_box_view_timer.start()
    }

    /*
    function hideMeetingInfoView() {
        console.log("[UI][FrtcMeetingInfoView.qml][hideMeetingInfoView]")
        visible = false
    }
*/
    Text {
        id: meetinginfo_conference_name_text_view
        //width: 200
        height: 24 // 15

        anchors.top: parent.top
        anchors.topMargin: 10 //40
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.horizontalCenter: parent.horizontalCenter

        text: "conference name"
        fontSizeMode: Text.Fit
        font.pixelSize: 24
        minimumPixelSize: 8

        horizontalAlignment: Text.AlignHCenter
        color: "black"
    }

    //1.meetingID
    Text {
        id: meeting_id_title_view
        width: 120
        height: 15

        anchors.top: meetinginfo_conference_name_text_view.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: qsTr("会议号: ") //Meeting ID
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: meeting_id_text_view
        width: 100
        height: 15
        anchors.top: meeting_id_title_view.top
        anchors.left: meeting_id_title_view.right
        anchors.leftMargin: 2
        text: "1"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //2.ownerName
    Text {
        id: meeting_ownername_title_view
        width: 120
        height: 15
        anchors.top: meeting_id_text_view.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: qsTr("主持人: ") //qsTr("Chairperson.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: meeting_ownername_text_view
        width: 100
        height: 15
        anchors.top: meeting_ownername_title_view.top
        anchors.left: meeting_ownername_title_view.right
        anchors.leftMargin: 2
        text: "2";
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //3.passcode
    Text {
        id: meeting_passcode_title_view
        width: 120
        height: 15
        anchors.top: meeting_ownername_title_view.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: qsTr("会议密码: ") //qsTr("Meeting Passcode.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: meeting_passcode_text_view
        width: 100
        height: 15
        anchors.top: meeting_passcode_title_view.top
        anchors.left: meeting_passcode_title_view.right
        anchors.leftMargin: 2
        text: "3"; //qsTr("demo.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Timer {
        id: prompt_message_box_view_timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: timerCounter: " + prompt_message_box_view.timerCounter)
            if (timerDuration <= prompt_message_box_view.timerCounter) {
                console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: -> set prompt_message_box_view.visible = false")
                visible = false
                console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: -> call timer stop()")
                stop()
                prompt_message_box_view.timerCounter = 0
            } else {
                ++prompt_message_box_view.timerCounter
            }
        }
    }

}




