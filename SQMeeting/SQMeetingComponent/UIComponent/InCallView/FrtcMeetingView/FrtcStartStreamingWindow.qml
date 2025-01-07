import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import "./../../CommonView/"
import "./View"

Window {
    id: root
    width: 380
    height: 243

    x: (screen.width - width)/2
    y: (screen.height - height)/2

    visible: true

    property string streamingPassword: ''
    property var onStartStreamingCallback


    // 设置窗口类型，移除标题栏和控制按钮
    flags: Qt.FramelessWindowHint

    modality: Qt.ApplicationModal

    color: "transparent"

    function randomPassword() {
        let strArr = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

        let getStr = "";
        for (let i = 0; i < 6; i++) {
            let index = Math.floor(Math.random() * strArr.length); // 获取随机下标
            getStr += strArr[index];
        }

        return getStr
    }

    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"
        radius: 10

        Text {
            id: titleTextField
            text: '开始直播？'
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
        }

        Text {
            id: descriptionTextField
            text: '开始后，将直播会议中音频、视频画面、共享屏幕内容，并告知所有参会成员。'
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

        FrtcCheckBoxView {
            id:scrolleCheckBox

            anchors.left: parent.left
            anchors.leftMargin: 26
           // anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: descriptionTextField.bottom
            anchors.topMargin: 15

            isStateChangeButton: true
            state: "SELECTED"
            checked: true
            checkable: true

            btn_txt_unchecked: qsTr("开启密码保护")
            btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
            btn_txt_checked: qsTr("开启密码保护")
            btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

            onMouseClicked: {

            }
        }

        Text {
            id: detailTextField
            text: '开启密码保护，让您的会议直播更安全'
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            font.weight: Font.Normal
            color: "#999999"
            //horizontalAlignment: Text.AlignHCenter

            anchors.left: parent.left
            anchors.leftMargin: 26
           // anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: scrolleCheckBox.bottom
            anchors.topMargin: 8
            width: 429 // 固定宽度
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
                    onStartStreamingCallback(0, true, streamingPassword)
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
                text: '开始直播'
                font.pixelSize: 14
                color: 'white'
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(scrolleCheckBox.checked) {
                        streamingPassword = randomPassword()
                    }
                    onStartStreamingCallback(0, false, streamingPassword)

                    root.close()
                }

            }
        }
    }
}
