import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: videoRecordingSuccessView
    width: 244
    height: 170
    radius: 4
    color: "#FFFFFF"
    visible: true

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Title Text
        Text {
            id: titleText
            text: '会议录制中'
            font.pixelSize: 16
            font.bold: true
            color: "#222222"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Description Text
        Text {
            id: descriptionText
            text: '录制结束后，可通过“神旗系统Web管理系统”-“会议录制”查看录制文件'
            font.pixelSize: 14
            font.bold: false
            color: "#666666"
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
        }

        // OK Button
        Button {
            id: okButton
            text: '知道了'
            width: 104
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            background: Rectangle {
                radius: 4
                color: "#007AFF"
            }
            contentItem: Text {
                text: okButton.text
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                videoRecordingSuccessView.visible = false
                console.log("User pressed OK button.")
                // 可以触发回调函数
            }
        }
    }
}
