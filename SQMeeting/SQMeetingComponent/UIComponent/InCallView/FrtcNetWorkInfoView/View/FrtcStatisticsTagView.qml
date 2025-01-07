import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.1

Rectangle {
    id:statisticsHeaderView
    width: parent.width
    height: 81
    color: "white"

    property string meeting_number: meeting_number_text_view.text
    property string meeting_rate: meeting_rate_text_view.text

    Rectangle{
        id:top_line_view
        y:0
        color: "#e2e2e2"
        height: 0.5
        width: parent.width
    }

    Rectangle{
        id:callTypeView
        width: parent.width
        anchors.top: top_line_view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 40
        color: "white"

        Text {
            id: meetingNumberView
            x:180
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            //font.weight: Font.Bold
            color: "#222222"
            text: "会议号: "
        }

        Text {
            id: meeting_number_text_view
            anchors.verticalCenter: meetingNumberView.verticalCenter
            anchors.left: meetingNumberView.right
            anchors.leftMargin: 5
            text: meeting_number
            font.pixelSize: 14
            color: "#0465E6"
        }

        Text {
            id: meetingrateView
            anchors.left: meeting_number_text_view.right
            anchors.leftMargin: 15
            anchors.verticalCenter: meetingNumberView.verticalCenter
            font.pixelSize: 16
            //font.weight: Font.Bold
            color: "#222222"
            text: "呼叫速率: "
        }

        Text {
            id: meeting_rate_text_view
            anchors.left: meetingrateView.right
            anchors.leftMargin: 5
            anchors.verticalCenter: meetingNumberView.verticalCenter
            text: meeting_rate
            font.pixelSize: 14
            color: "#0465E6"
        }

    }

    Rectangle{
        id:bottom_line_view
        color: "#e2e2e2"
        height: 1
        y:39
        width: parent.width
    }

    RowLayout{
        Layout.alignment: Qt.AlignVCenter
        anchors.top: bottom_line_view.bottom
        anchors.left: parent.left
        height: 40
        spacing: 5

        Text {
            text: "参会者"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 150
        }

        Text {
            text: "媒体"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 90
        }

        Text {
            text: "格式"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 90
        }

        Text {
            text: "实际速率"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 70
        }

        Text {
            text: "帧率"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 50
        }

        Text {
            text: "丢包"
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 80
        }

        Text {
            text: "抖动"
            color: "#222222"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 50
        }
    }
}
