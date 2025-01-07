import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 380
    height: 180
    visible: true

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    x: (screen.width - width)/2
    y: (screen.height - height)/2

    property var onStartRecordingCallback

    // 设置窗口类型，移除标题栏和控制按钮
    flags: Qt.FramelessWindowHint

    modality: Qt.ApplicationModal

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"
        radius: 10

        Text {
            id: titleTextField
            text: '结束云录制？'
            color: "#222222"
            font.pixelSize: 16
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap

            // 布局设置
            anchors.horizontalCenter: parent.horizontalCenter // 水平中心对齐
            anchors.top: parent.top
            anchors.topMargin: 24 // 顶部偏移量

            // minimumWidth: 1 // 确保宽度和高度 >= 0
            // minimumHeight: 1
        }

        Text {
            id: descriptionTextField
            text: '录制结束后，可通过“神旗系统Web管理系统”-“会议录制”查看录制文件'
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            font.weight: Font.Normal
            color: "#666666"
            //horizontalAlignment: Text.AlignHCenter

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: titleTextField.bottom
            anchors.topMargin: 10 // 顶部偏移量
            width: 332 // 固定宽度
            height: implicitHeight // 根据内容调整高度
        }

        Rectangle {
            id: closeButton
            width: 104
            height: 32
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24

            anchors.left: parent.left
            anchors.leftMargin: 78
            //color: Qt.rgba(240/255.0, 240/255.0, 245/255.0, 1.0)
            color: Qt.rgba(220/255.0, 220/255.0, 235/255.0, 1.0)
            radius: 4

            Text {
                anchors.centerIn: parent
                text: '取消'
                font.pixelSize: 14
                color: Qt.rgba(0x24/255.0, 0x24/255.0, 0x25/255.0, 1.0)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    onStartRecordingCallback(1, true)
                    root.close()
                }
            }
        }

        Rectangle {
            id: recordButton
            width: 104
            height: 32
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24

            anchors.right: parent.right
            anchors.rightMargin: 78
            color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

            radius: 4

            Text {
                anchors.centerIn: parent
                text: '结束录制'
                font.pixelSize: 14
                color: 'white'
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    onStartRecordingCallback(1, false)
                    root.close()
                }

            }
        }
    }
}
