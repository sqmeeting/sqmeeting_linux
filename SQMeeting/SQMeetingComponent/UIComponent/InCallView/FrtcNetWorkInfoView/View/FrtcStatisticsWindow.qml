import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import com.frtc.FrtcMediaStaticsInstanceObject 1.0

import "./"

Window {
    id: statistics_meeting_view

    visible: true
    width: 640
    height: 480
    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height
    //    x: (screen.width - width)/2
    //    y: (screen.height - height)/2
    title: "媒体统计信息" //" "
    color: "#ffffff"
    flags: Qt.WindowStaysOnTopHint

    property var statisticsListInfo: []
    property string meeting_number: ""
    property string meeting_theme: ""
    property string meeting_rate: ""

    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    Component.onCompleted: {
        console.log("[FMeetingWindow.qml][Component.onCompleted:]");

        //        x = (screen.width - width)/2
        //        y = (screen.height - height)/2
        //        x = 100
        //        y = 100
    }

    onClosing:function(closeEvent) {
        console.log("[FMeetingWindow.qml][onClosing]");
        //destroy()
    }

    function setMeetingInfoData(conferenceName, meetingID) {
        console.log("[UI][FrtcStatisticsWindow.qml][setMeetingInfoData:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID)
        meeting_theme = conferenceName;
        meeting_number = meetingID;
        statisticsTagView.meeting_number = meetingID;
    }

    function getChannelLabelText(pipeName) {
        if (pipeName === "apr") {
            return "Audio"
        } else if (pipeName === "aps") {
            return "Audio ↑"
        } else if (pipeName === "vpr") {
            return "Video"
        } else if (pipeName === "vps") {
            return "Video ↑"
        } else if (pipeName === "vcr") {
            return "Content"
        } else if (pipeName === "vcs") {
            return "Content ↑"
        }
    }

    //-------------------------------------------------
    // subviews.
    //-------------------------------------------------

    Rectangle {
        id:statistics_background_view
        color: "#ffffff"
        anchors.fill: parent

        Text {
            id: meeting_title_view
            y:0
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40
            text: meeting_theme
            font.pixelSize: 18
            //font.weight: Font.Bold
            color: "black"
        }

        FrtcStatisticsTagView {
            id: statisticsTagView
            x:20
            width: parent.width-40
            height: 80
            anchors.top: meeting_title_view.bottom
            meeting_number: meeting_number
            meeting_rate: meeting_rate
        }

        ListView {
            anchors.top: statisticsTagView.bottom
            anchors.topMargin: 3
            x:20
            width: parent.width-40
            height: parent.height - 40 - 80
            model: statisticsListInfo

            delegate: FrtcStatisticsCell {
                color: index % 2 == 0 ? "#f6f6f6" : "#fbfbfb"
                participant: modelData.participantName
                channel: getChannelLabelText(modelData.mediaType)
                format: modelData.resolution
                rateUsed: modelData.rtp_actualBitRate
                packetLost: modelData.frameRate
                jitter: modelData.mediaType === 'apr' ? modelData.packageLost + "(" + modelData.packageLostRate + "%" + ")" + modelData.logicPacketLost + "(" + modelData.logicPacketLostRate + "%" + ")" :
                                                        modelData.packageLost + "(" + modelData.packageLostRate + "%" + ")"
                errorConcealment: modelData.jitter
            }
        }
    }

    Connections {
        target: FrtcMediaStaticsInstanceObject
        function onCppSendMsgToQMLStatisticsInfo(data) {
            //console.log("[FrtcStatisticsWindow.qml][onCppSendMsgToQMLStatisticsInfo]")
            statisticsListInfo.splice(0,statisticsListInfo.length)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.apr)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.aps)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.vcr)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.vcs)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.vpr)
            statisticsListInfo = statisticsListInfo.concat(data.media_statistics.vps)
        }

        function onCppSendMsgToQMLMediaStatisticsInfo(data) {
            //console.log("[FrtcStatisticsWindow.qml][onCppSendMsgToQMLMediaStatisticsInfo]")
            statisticsTagView.meeting_rate = data.upRate + "/" + data.downRate
        }
    }
}
