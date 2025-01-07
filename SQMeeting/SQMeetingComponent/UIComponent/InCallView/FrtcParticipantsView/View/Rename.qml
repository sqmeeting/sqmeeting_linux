import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

Window {
    id: renameDialogWindow
    width: 250
    height: 200
    visible: false
    property string displayText: ""
    property string rowData
    property string client_id
    property int indexRow
    property bool authority: false
    property bool audioMute:false
    property bool isSpeaker: false
    property bool isUserPin: false
    property var onButtonClickedCallback
    property var onButtonClickedUnLectureCallback
    property var onButtonClickedMuteCallBack


    flags: Qt.Window | Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
    color: "transparent"
    modality: Qt.ApplicationModal // 设置模态窗口，阻塞其他窗口输入

    function open(text, uuid, audio_mute, index, authiority = false, is_speaker, user_pin) {
        isSpeaker = is_speaker
        indexRow    = index
        displayText = text
        rowData     = displayText
        client_id   = uuid
        visible     = true
        authority = authiority
        audioMute = audio_mute
        isUserPin = user_pin

        height = isSpeaker ? 210 : (authority ? (is_speaker ? 300 : (index === 0 ? 270 : 310)) : 200);

    }

    RenameInputDialog {
        id: renameInputDialog
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "white"
        border.color: "#cccccc"
        radius: 8
        opacity: 1

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
                    text: audioMute?'取消静音':'静音'
                    width: 200
                    height: 40
                    font.pixelSize: 14
                    font.bold: true
                    //color: "blue"
                    visible: isSpeaker ? false : true
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Item {
                        anchors.fill: parent // 填满整个按钮区域
                        Text {
                            text: audioMute?'取消静音':'静音'
                            color: "#026FFE"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent // 确保文本在按钮内居中
                        }
                    }

                    onClicked: {
                        onButtonClickedMuteCallBack(indexRow, audioMute, client_id)
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
                        renameInputDialog.open(rowData, client_id, authority);
                        renameInputDialog.raise()
                        renameDialogWindow.close();
                    }
                }

                Button {
                    text: "取消演讲者"
                    visible: isSpeaker
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
                            text: "取消演讲者"
                            color: "#026FFE"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent // 确保文本在按钮内居中
                        }
                    }

                    onClicked: {
                        onButtonClickedUnLectureCallback(client_id)
                        renameDialogWindow.close();
                    }
                }

                ListModel {
                    id: buttonNamesModel
                    ListElement { name: "设为演讲者" }
                    ListElement { name: "固定画面" }
                    ListElement { name: "移除会议室" }
                }

                Repeater {
                    model: !isSpeaker && authority ? buttonNamesModel : ListModel
                    delegate: Button {
                        visible: !(indexRow === 0 && model.index === buttonNamesModel.count - 1)
                        width: 200
                        height: 40
                        font.pixelSize: 14
                        background: Rectangle {
                            color: "transparent"
                            border.color: "#cccccc"
                            border.width: 1
                        }

                        contentItem: Item {
                            anchors.fill: parent // 填满整个按钮区域
                            Text {
                                //text: model.name
                                text: model.index === 1
                                    ? (isUserPin ? "取消固定画面" : "固定画面")
                                    : model.name
                                color: index === buttonNamesModel.count - 1 ? "red" : "#026FFE"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.centerIn: parent // 确保文本在按钮内居中
                            }
                        }

                        onClicked: {
                            onButtonClickedCallback(client_id, model.index, isUserPin)
                            renameDialogWindow.close();
                        }
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
                        renameDialogWindow.close();
                    }
                }
            }
        }
    }
}
