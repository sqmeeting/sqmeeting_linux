import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import "./"
import "./../../CommonView/"

Window{
    visible: true
    width: 388
    height: 388
    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height
    x: (screen.width - width)/2
    y: (screen.height - height)/2
    title: meetinginfo_conference_name_text_view.text
    id: invite_join_meeting_view
    color: "#f8f9fa"
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    //========================================
    // for QML life cycle.
    //========================================

    /*
    Component.onCompleted: {

    }

    Component.onDestruction: {
        console.log("[UI][FrtcInviteToJoinView.qml][Component.onDestruction:]");
        //clear all windows and views.

    }
*/

    //========================================
    // functions.
    //========================================

    function setMeetingInfoData(conferenceName, meetingID, ownerName, meetingPasscode) {
        console.log("[UI][FrtcInviteToJoinView.qml][setMeetingInfoData:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        meetinginfo_conference_name_text_view.text = conferenceName
        meeting_id_text_view.text = meetingID
        meeting_ownername_text_view.text = ownerName
        meeting_passcode_text_view.text = meetingPasscode
    }

    //========================================
    // sub views.
    //========================================

    Rectangle {
        id: white_background_view
        color: "#ffffff"
        x:25
        y:25
        width: parent.width - 50
        height: parent.height - 90

        Text {
            id: meeting_invite_view
            width: 120
            height: 15

            anchors.top: parent.top
            anchors.topMargin: 15

            anchors.left: parent.left
            anchors.leftMargin: 18
            text: qsTr("邀请您参加会议")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        //1.meetingTheme
        Text {
            id: meeting_theme_title_view
            width: 120
            height: 15

            anchors.top: meeting_invite_view.bottom
            anchors.topMargin: 15

            anchors.left: parent.left
            anchors.leftMargin: 18
            text: qsTr("会议主题: ") //Meeting ID
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        Text {
            id: meetinginfo_conference_name_text_view
            height: 15
            anchors.top: meeting_theme_title_view.top
            anchors.left: meeting_theme_title_view.right
            anchors.leftMargin: 2

            text: ""
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        //1.meetingID
        Text {
            id: meeting_id_title_view
            width: 120
            height: 15

            anchors.top: meetinginfo_conference_name_text_view.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 18
            text: qsTr("会议号: ") //Meeting ID
            font.pixelSize: 12
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
            text: ""
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        //2.ownerName
        Text {
            id: meeting_ownername_title_view
            width: 120
            height: 15
            anchors.top: meeting_id_text_view.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 18
            text: qsTr("主持人: ") //qsTr("Chairperson.")
            font.pixelSize: 12
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
            text: "";
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        //3.passcode
        Text {
            id: meeting_passcode_title_view
            width: 120
            height: 15
            anchors.top: meeting_ownername_title_view.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 18
            text: qsTr("会议密码: ") //qsTr("Meeting Passcode.")
            font.pixelSize: 12
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
            text: ""; //qsTr("demo.")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }

        Text {
            id: meeting_message_text_view
            anchors.top: meeting_passcode_text_view.bottom
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 18
            text: "打开神旗客户端,输入会议号入会即可";
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            color: "black"
        }
    }

    Button {
        id: copy_meeting_info_button
        anchors.top: white_background_view.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: white_background_view.horizontalCenter
        width: 200
        height: 30
        text: "复制会议信息邀请入会"
        autoRepeat: false

        background: Rectangle{
            color: copy_meeting_info_button.down ? "#026ff5" : "white"
            border.width: 1
            border.color: "#026ff5"
        }

        contentItem: Text {
            text: copy_meeting_info_button.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 11
            color: copy_meeting_info_button.down ? "white" : "#026ff5"
        }

        onClicked: {
            console.log("[UI][FrtcInviteToJoinView.qml][copy_meeting_info_button]")
            let meetingTheme =  meetinginfo_conference_name_text_view.text
            let meetingId  = meeting_id_text_view.text
            let meetingpsd = meeting_passcode_text_view.text
            clipboard.setText("邀请您参加会议\n" + "会议主题:" + meetingTheme + "\n" + "会议号:" + meetingId + "\n"
                              + "会议密码:" + meetingpsd + "\n\n" + "打开神旗客户端，输入会议号入会即可")
            toast.showText("会议信息已复制到剪切板")
        }
    }

    FrtcToastView {
        id: toast
    }


}
