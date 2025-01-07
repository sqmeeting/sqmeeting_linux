import QtQuick 2.15
import QtQuick.Window

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import SDKUserDefaultObject 1.0

Window{
    id: shareMeetingInfoWindow
    visible: true
    width: 380
    height: white_background_view.height + 70
    // maximumWidth : width
    // maximumHeight : height
    // minimumWidth : width
    // minimumHeight : height
    x: (screen.width - width)/2
    y: (screen.height - height)/2
    title: meetingInfo.meeting_name
    color: "#f8f9fa"
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    property var meetingInfo
    property var meetingInfoStr

    Component.onCompleted:  {
        meetingInfoStr = getShareInvitationInfo(meetingInfo)
        meeting_invite_view.text = meetingInfoStr
    }

    function getShareInvitationInfo(meetingInfo) {

        var meetingInfoCopy = "";

        // 获取用户名
        var userName = SDKUserDefaultObject.getLoginUserName()

        if (userName && userName !== "") {
            meetingInfoCopy += userName + " " + qsTr("邀请您参加会议") + "\n";
        }

        // 会议主题
        var meetingName = qsTr("会议主题") + ": " + meetingInfo.meeting_name + "\n";
        meetingInfoCopy += meetingName;

        // 会议开始时间
        if (meetingInfo.schedule_start_time && meetingInfo.schedule_start_time !== "0") {
            var meetingStartTime = qsTr("开始时间") + ": " + FrtcTool.formatTimestamp(meetingInfo.schedule_start_time,"yyyy-MM-dd HH:mm", true) + "\n";
            meetingInfoCopy += meetingStartTime;
        }

        // 会议结束时间
        if (meetingInfo.schedule_end_time && meetingInfo.schedule_end_time !== "0") {
            var meetingEndTime = qsTr("结束时间") + ": " + FrtcTool.formatTimestamp(meetingInfo.schedule_end_time,"yyyy-MM-dd HH:mm", true) + "\n";
            meetingInfoCopy += meetingEndTime;
        }

        // 会议编号
        var meetingNumber = qsTr("会议号") + ": " + meetingInfo.meeting_number + "\n";
        meetingInfoCopy += meetingNumber;

        // 处理周期会议
        if (meetingInfo.isRecurrence) {
            var recurrenceDays = "";
            if (meetingInfo.recurrence_type === "WEEKLY") {
                recurrenceDays = "(" + FrtcTool.weekRecurrenceDate(FrtcTool.convertToChineseWeekday(meetingInfo.recurrenceDaysOfWeek)) + ")";
            } else if (meetingInfo.recurrence_type === "MONTHLY") {
                recurrenceDays = "(" + FrtcTool.monthRecurrenceDate(meetingInfo.recurrenceDaysOfMonth) + ")";
            }

            var recurrenceStr = qsTr("周期会议") + ": " + FrtcTool.formatTimestamp(meetingInfo.recurrenceStartDay,"yyyy-MM-dd", true) + " - " +
                    FrtcTool.formatTimestamp(meetingInfo.recurrenceEndDay,"yyyy-MM-dd", true) + ", " + meetingInfo.recurrenceInterval_result + " " + recurrenceDays + "\n";
            meetingInfoCopy += recurrenceStr;
        }

        // 会议密码
        if (meetingInfo.meeting_password && meetingInfo.meeting_password !== "") {
            var meetingpsd = qsTr("密码") + ": " + meetingInfo.meeting_password + "\n";
            meetingInfoCopy += meetingpsd;
            meetingInfoCopy += "\n" + qsTr("请打开神旗APP,输入会议号、密码入会");
        } else {
            meetingInfoCopy += "\n" + qsTr("请打开神旗APP,输入会议号入会");
        }

        // 会议分享 URL
        if (meetingInfo.isRecurrence) {
            if (meetingInfo.groupMeetingUrl && meetingInfo.groupMeetingUrl !== "") {
                var meetingShareUrl = "\n" + qsTr("或点击以下链接直接加入会议:") + "\n\n" + meetingInfo.groupMeetingUrl + "\n";
                meetingInfoCopy += meetingShareUrl;
            }
        } else {
            if (meetingInfo.meeting_url && meetingInfo.meeting_url !== "") {
                var meetingShareUrl1 = "\n" + qsTr("或点击以下链接直接加入会议:") + "\n\n" + meetingInfo.meeting_url + "\n";
                meetingInfoCopy += meetingShareUrl1;
            }
        }

        return meetingInfoCopy;
    }

    Rectangle {
        id: white_background_view
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        radius: 2
        height: meeting_invite_view.contentHeight + 10

        Text {
            id: meeting_invite_view
            anchors.fill: parent
            anchors.margins: 10
            wrapMode: Text.WordWrap
            text: qsTr("邀请您参加会议")
            font.pixelSize: 14
            lineHeight: 1.4
            color: "#222222"
        }
    }

    FrtcButton {
        id: copy_meeting_info_button
        anchors.top: white_background_view.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 30
        buttonText: "复制会议信息邀请入会"

        onMouseClicked: {
            clipboard.setText(meetingInfoStr)
            toast.showText(qsTr("会议信息已复制到剪切板"))
        }
    }

    FrtcToastView {
        id: toast
    }

}
