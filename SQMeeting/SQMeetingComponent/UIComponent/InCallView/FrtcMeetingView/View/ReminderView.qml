import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: videoRecordingReminderView
    width: 200
    height: 40
    radius: 4
    color:Qt.rgba(34/255, 34/255, 34/255, 0.8)// "#222222CC" // 设置透明度为0.8的黑色背景

    property string title: title.text
    property string imageSource: imageView.source

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        // 图标
        Image {
            id: imageView
            source: imageSource
            width: 18
            height: 12
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft
            verticalAlignment: Image.AlignTop
        }

        // 标题文本
        Text {
            id: titleText
            text: title
            font.pixelSize: 12
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            anchors.verticalCenter: imageView.verticalCenter
        }
    }
}
