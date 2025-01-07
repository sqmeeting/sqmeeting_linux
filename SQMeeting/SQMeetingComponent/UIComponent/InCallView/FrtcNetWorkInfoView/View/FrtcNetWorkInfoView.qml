import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import QtQml 2.12
import com.frtc.FrtcMediaStaticsInstanceObject 1.0

Rectangle {
    property int timerCounter: 0
    property int timerDuration: 2 // 5 seconds

    property bool isMouseInNetWorkInfoButtonArea: false
    property bool isMouseInNetWorkInfoArea: false

    property string currentConferenceName: ""
    property string currentMeetingID: ""

    width: 260
    height: 200
    radius: 4

    color: "#f8f9fa"

    function setMeetingInfoData(conferenceName,meetingID) {
        currentConferenceName = conferenceName;
        currentMeetingID = meetingID;
    }

    Text {
        id: id_delay_title_text_view
        height: 15
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: "延迟: " //Delay
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_delay_value_text_view
        width: 100
        height: 15
        anchors.verticalCenter: id_delay_title_text_view.verticalCenter;
        anchors.left: id_delay_title_text_view.right
        anchors.leftMargin: 5
        text: "0 ms";
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //--------------- 2.Call rate.---------------------
    Text {
        id: id_callrate_title_text_view
        height: 15

        anchors.top: id_delay_title_text_view.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: "速率: " //Call Rate
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_callrate_up_value_text_view
        height: 15
        anchors.verticalCenter: id_callrate_title_text_view.verticalCenter;
        anchors.left: id_callrate_title_text_view.right
        anchors.leftMargin: 5
        text: "↑ 0"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_callrate_down_value_text_view
        height: 15
        anchors.verticalCenter: id_callrate_title_text_view.verticalCenter;
        anchors.left: id_callrate_up_value_text_view.right
        anchors.leftMargin: 60
        text: "↓ 0"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //--------------- 3.Audio---------------
    Text {
        id: id_audio_title_view
        height: 15
        anchors.top: id_callrate_title_text_view.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: "音频: " //qsTr("demo.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_audio_up_value_text_view
        width: 100
        height: 15
        anchors.verticalCenter: id_audio_title_view.verticalCenter;
        anchors.left: id_audio_title_view.right
        anchors.leftMargin: 5
        text: "↑ 0 (0%)";
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_audio_down_value_text_view
        height: 15
        anchors.verticalCenter: id_audio_up_value_text_view.verticalCenter;
        anchors.left: id_callrate_down_value_text_view.left
        text: "↓ 0 (0%)"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //--------------- 4.Video.---------------
    Text {
        id: id_video_title_view
        height: 15
        anchors.top: id_audio_title_view.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: "视频: "; //qsTr("demo.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_video_up_text_view
        height: 15
        anchors.verticalCenter: id_video_title_view.verticalCenter;
        anchors.left: id_video_title_view.right
        anchors.leftMargin: 5
        text: "↑ 0 (0%)";
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_video_down_text_view
        height: 15
        anchors.verticalCenter: id_video_up_text_view.verticalCenter;
        anchors.left: id_callrate_down_value_text_view.left
        text: "↓ 0 (0%)"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    //--------------- 5.Content.---------------
    Text {
        id: id_content_title_view
        height: 15
        anchors.top: id_video_title_view.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 18
        text: "共享: " //qsTr("demo.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_content_up_value_text_view
        height: 15
        anchors.verticalCenter: id_content_title_view.verticalCenter;
        anchors.left: id_content_title_view.right
        anchors.leftMargin: 5
        text: "↑ 0 (%0)";
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }

    Text {
        id: id_content_down_text_view
        height: 15
        anchors.verticalCenter: id_content_up_value_text_view.verticalCenter;
        anchors.left: id_callrate_down_value_text_view.left
        text: "↓ 0 (0%)"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        color: "black"
    }




    //title button, with icon
    //--------------- 6.Statistics.---------------
    Rectangle {
        width: 120
        height: 30
        anchors.top: parent.bottom
        anchors.topMargin: -40
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: "统计信息(内测)"
            color: "#0465E6"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.showStatisticsDialog()
            }
        }
    }


    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    Connections {

        target: FrtcMediaStaticsInstanceObject

        function onCppSendMsgToQMLMediaStatisticsInfo(data)
        {
            //延迟
            id_delay_value_text_view.text = data.rttTime + "ms"
            //速率
            id_callrate_up_value_text_view.text = "↑ " + data.upRate
            id_callrate_down_value_text_view.text = "↓ " + data.downRate
            //音频
            id_audio_up_value_text_view.text = "↑ " + data.audioUpRate + " " + "(" + data.audioUpPackLost + "%" + ")"
            id_audio_down_value_text_view.text = "↓ " + data.audioDownRate + " " + "(" + data.audioDownPackLost + "%" + ")"
            //视频
            id_video_up_text_view.text = "↑ " + data.videoUpRate + " " + "(" + data.videoUpPackLost + "%" + ")"
            id_video_down_text_view.text = "↓ " + data.videoDownRate + " " + "(" + data.videoDownPackLost + "%" + ")"
            //共享
            id_content_up_value_text_view.text = "↑ " + data.contentUpRate + " " + "(" + data.contentUpPackLost + "%" + ")"
            id_content_down_text_view.text = "↓ " + data.contentdownRate + " " + "(" + data.contentdownPackLost + "%" + ")"
        }
    }
}
