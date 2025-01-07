import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.1

Rectangle {
    id:statisticsCell
    width: parent.width
    height: 40
    color: "#f0f0f0"

    property string participant: ""      //参会者
    property string channel: ""          //媒体
    property string format: ""           //格式
    property string rateUsed: ""         //实际速率
    property string packetLost: ""       //帧率
    property string jitter: ""           //丢包
    property string errorConcealment: "" //抖动

    RowLayout{
        anchors.fill: parent
        spacing: 5

        Label {
            text: participant //参会者
            color: "#222222"
            font.pixelSize: 13
            verticalAlignment: Qt.AlignCenter
            Layout.preferredWidth: 150
        }

        Label {
            id:channelLabel
            text: channel //媒体
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 90
        }

        Label {
            text: format //格式
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 90
        }

        Label {
            text: rateUsed //实际速率
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 70
        }

        Label {
            text: packetLost //帧率
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 50
        }

        Label {
            text: jitter //丢包
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 80
        }

        Label {
            text: errorConcealment //抖动
            color: "#222222"
            font.pixelSize: 13
            Layout.preferredWidth: 50
            horizontalAlignment: Text.AlignHCenter
            padding: -5
        }
    }
}
