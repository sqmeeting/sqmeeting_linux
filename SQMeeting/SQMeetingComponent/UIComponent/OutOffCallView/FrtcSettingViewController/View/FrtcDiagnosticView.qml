import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


import FrtcLogUploaderObj 1.0
import "./../../../CommonView/" //for MessageBox.qml.

Item {
    id:diagnosticView
    Rectangle {
        id:myRectangle
        x:155
        width: 400
        height: 480
        color: "#ffffff"

        Rectangle {
            id:imageRect
            y:40
            anchors.horizontalCenter:parent.horizontalCenter
            width: 100
            height: 100
            radius: 40
            //color: "#4285F4"

            Image {
                anchors.centerIn: parent
                source: "qrc:/Images/SettingView/icon_upload_log@2x.png"
                width: 100
                height: 100
                fillMode: Image.PreserveAspectFit
            }
        }

        Text {
            id: text_tip1
            anchors.top:imageRect.bottom
            anchors.topMargin:20
            anchors.horizontalCenter:parent.horizontalCenter
            width: parent.width - 40
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: "在使用过程中，如出现任何功能异常，请上传日志来帮助我们更好的定位和解决问题，深表感谢！"
            font.pixelSize: 14
        }

        Text {
            id: text_tip2
            anchors.top:text_tip1.bottom
            anchors.topMargin:20
            anchors.horizontalCenter:parent.horizontalCenter
            text: "请描述您遇到的问题（必填，100字以内）"
            font.pixelSize: 12
            color: "#666666"
        }

        Rectangle {
            id: textinputRext
            anchors.top:text_tip2.bottom
            anchors.topMargin:20
            anchors.horizontalCenter:parent.horizontalCenter
            width: parent.width - 40
            height: 100
            border.color: "#CCCCCC"
            border.width: 1
            radius: 4

            TextArea {
                id:text_desc
                anchors.fill: parent
                anchors.margins: 5
                wrapMode: TextArea.Wrap
                placeholderText: "请输入问题描述"
                font.pixelSize: 14
            }
        }

        Button {
            id: btn_upload
            anchors.top:textinputRext.bottom
            anchors.topMargin:20
            anchors.horizontalCenter:parent.horizontalCenter
            width: parent.width - 40
            height: 40
            text: "上传日志"
            background: Rectangle {
                id: btn_upload_bg
                color: "#4285F4"
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                console.log("点击了 上传日志 Button")

                FrtcLogUploaderObj.startUploadLogFiles(text_desc.text);

                btn_upload.enabled = false
                btn_upload_bg.color = "gray"
                btn_upload.text = "准备上传..."
            }

            Connections {
                target: FrtcLogUploaderObj
                function onLogUploadCompleted() {
                    resetButton()
                    prompt_message_box_view.showMessageBox("上传成功")
                }

                function onReportLogUploadProgress(status) {
                    btn_cancel_upload.visible = true
                    btn_upload.enabled = false
                    btn_upload_bg.color = "gray"
                    btn_upload.text = "正在上传 " + status + "%"
                }
            }
        }

        Button {
            id: btn_cancel_upload
            visible: false
            anchors.top:btn_upload.bottom
            anchors.topMargin:10
            anchors.horizontalCenter:parent.horizontalCenter
            width: 60
            height: 30
            text: "取消上传"
            focus: false
            background: Rectangle{
                color: "#ffffff"
                border.width: 0
                border.color: "transparent"
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 14
                color: "#4285F4"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.underline: true
            }
            onClicked: {
                FrtcLogUploaderObj.cancelUploadLog();
                resetButton();
            }
        }
        MouseArea{
            visible: btn_cancel_upload.visible
            anchors.fill: btn_cancel_upload
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }


        MessageBox {
            id: prompt_message_box_view
            width: 200
            height: 40
            anchors.top:btn_upload.bottom
            anchors.topMargin:10
            anchors.horizontalCenter:parent.horizontalCenter

            visible: false
            color: "gray"

            function showMessageBox(messageString) {
                console.log("[UI][FrtcSettingtingViewController.qml][prompt_message_box_view][showMessageBox:]: messageString: " + messageString);
                popMessageBox(messageString);
            }
        }
    }

    function resetButton() {
        btn_cancel_upload.visible = false
        btn_upload.enabled = true;
        btn_upload_bg.color = "#4285F4";
        btn_upload.text = "上传日志";
    }
}
