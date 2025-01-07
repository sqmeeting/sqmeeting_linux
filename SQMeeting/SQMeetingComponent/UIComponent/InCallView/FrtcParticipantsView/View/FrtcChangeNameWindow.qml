import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15

import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp

Rectangle {
    id: changeNameView
    width: 250
    height: 200
    visible: false
    property string displayText: ""
    property string rowData

    color: "white"
    radius: 6.0

    border.width:1
    border.color:'#DEDEDE'


    RenameInputDialog {
        id: renameInputDialog
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "white"
        border.color: "#cccccc"
        // radius: 8
        // opacity: 1

        Column {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5

            Item {
                width: parent.width
                height: 50 // 足够的高度以容纳 Text 元素和间距
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 5

                Text {
                    text: renameDialogWindow.displayText
                    font.pixelSize: 16
                    color: "#333333"
                    horizontalAlignment: Text.AlignLeft // 左对齐
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter // 垂直居中
                }
            }


            Rectangle {
                width: parent.width
                height: 20
                color: "transparent" // 透明颜色，用于分隔
            }

            Column {
                spacing: 0

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                Button {
                    text: "解除静音"
                    width: 200
                    height: 40
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: "transparent"
                        border.color: "#cccccc"
                        border.width: 1
                        //radius: 5
                    }

                    contentItem: Item {
                        anchors.fill: parent // 填满整个按钮区域
                        Text {
                            text: "解除静音"
                            color: "#026FFE"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent // 确保文本在按钮内居中
                        }
                    }
                    onClicked: {
                        console.log("解除静音 clicked");
                        renameDialogWindow.close();
                    }
                }

                Button {
                    text: "改名"
                    width: 200
                    height: 40
                    font.pixelSize: 14
                    font.bold: true
                    //color: "blue"
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Item {
                        anchors.fill: parent // 填满整个按钮区域
                        Text {
                            text: "改名"
                            color: "#026FFE"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent // 确保文本在按钮内居中
                        }
                    }

                    onClicked: {
                        renameInputDialog.open(rowData);
                        renameInputDialog.raise()
                        renameDialogWindow.close();
                    }
                }

                Button {
                    text: "取消"
                    width: 200
                    height: 40
                    font.pixelSize: 14
                    //color: "#888888" // 灰色字体
                    background: Rectangle {
                        color: "transparent"
                        border.color: "transparent" // 没有边框
                    }

                    contentItem: Item {
                        anchors.fill: parent // 填满整个按钮区域
                        Text {
                            text: "取消"
                            color: "#888888" // 灰色字体
                            font.pixelSize: 14
                            anchors.centerIn: parent // 确保文本在按钮内居中
                        }
                    }
                    onClicked: {
                        console.log("取消 clicked");
                        // 可以在这里添加改名的逻辑
                        renameDialogWindow.close();
                    }
                }
            }
        }
    }
}
