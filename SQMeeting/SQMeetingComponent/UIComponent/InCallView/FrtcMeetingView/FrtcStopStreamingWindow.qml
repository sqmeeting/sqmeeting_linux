import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import "./../../CommonView/"
import "./View"

Window {
    id: root
    width: 320
    height: 150

    x: (screen.width - width)/2
    y: (screen.height - height)/2

    visible: true

    property var onStartStreamingCallback


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
            text: '观众正在观看直播，确定要结束直播？'
            color: "#666666"
            font.pixelSize: 14
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap

            // 布局设置
            anchors.horizontalCenter: parent.horizontalCenter // 水平中心对齐
            anchors.top: parent.top
            anchors.topMargin: 24 // 顶部偏移量
        }

        Rectangle {
            id: closeButton
            width: 104
            height: 32
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24

            anchors.left: parent.left
            anchors.leftMargin: 48
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
                    onStartStreamingCallback(1, true, '')
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
            anchors.rightMargin: 48
            color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

            radius: 4

            Text {
                anchors.centerIn: parent
                text: '结束直播'
                font.pixelSize: 14
                color: 'white'
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    onStartStreamingCallback(1, false, '')

                    root.close()
                }

            }
        }
    }
}
