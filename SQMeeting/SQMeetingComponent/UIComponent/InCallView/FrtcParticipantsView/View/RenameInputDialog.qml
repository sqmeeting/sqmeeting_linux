import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import com.frtc.FrtcApiManager 1.0
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp
import SDKUserDefaultObject 1.0

Window {
    id: renameInputDialog
    width: 240
    height: 156
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // 去除标题栏，使窗口外观简单
    modality: Qt.ApplicationModal

    property string rowData
    property bool authority
    property string client_id

    function open(text, client_id, authority) {
        console.log('open the uuid_client id is ', client_id)
        rowData = text
        nameInput.text = rowData
        visible = true;
        renameInputDialog.client_id = client_id
        renameInputDialog.authority = authiority;
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        Text {
            id:changeText
            text: "改名"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            color: "black"
        }

        TextField {
            id: nameInput
            width: 200
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: changeText.bottom
            anchors.topMargin: 13

            text:rowData

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                border.width:1
                color: control.palette.base
                border.color: "#CCCCCC"
            }

            font.pixelSize: 14
        }

        Rectangle {
            id:line
            width: renameInputDialog.width
            height: 1
            color: "#DEDEDE"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: nameInput.bottom
            anchors.topMargin: 16 // 与输入框的距离
        }

        // 添加竖直灰色直线
        Rectangle {
            width: 1
            height: 43
            color: "#DEDEDE"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: line.bottom
            anchors.topMargin: 1 // 与水平线的距离
        }

        Row {
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: line.bottom
            anchors.topMargin: 0

            Button {
                text: "取消"
                font.pixelSize: 14
                font.bold: true

                width: 120
                height: 48

                background: Rectangle {
                    color: "transparent"
                    border.color: "transparent" // 没有边框
                }

                contentItem: Item {
                    anchors.fill: parent // 填满整个按钮区域
                    Text {
                        text: "取消"
                        color: "#666666"
                        font.pixelSize: 14
                        font.bold: true
                        anchors.centerIn: parent // 确保文本在按钮内居中
                    }
                }
                onClicked:{
                    renameInputDialog.close();
                }
            }

            Button {
                text: "确定"
                font.pixelSize: 14
                font.bold: true

                width: 120
                height: 48

                background: Rectangle {
                    color: "transparent"
                    border.color: "transparent" // 没有边框
                }

                contentItem: Item {
                    anchors.fill: parent // 填满整个按钮区域
                    Text {
                        text: "确定"
                        color: "#026FFE"
                        font.pixelSize: 14
                        font.bold: true
                        anchors.centerIn: parent // 确保文本在按钮内居中
                    }
                }
                onClicked: {
                    console.log("新名字: " + nameInput.text);
                    if(authority) {
                        var userToken = SDKUserDefaultObject.getUserToken()
                        FrtcApiManager.login_change_name(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber(),nameInput.text, client_id)
                    } else {
                        FrtcApiManager.change_name(FMeetingWindowControllerObject.onQmlGetMeetingNumber(),nameInput.text)
                    }
                    renameInputDialog.close(); // 执行保存操作后关闭窗口
                }
            }
        }
    }
}

