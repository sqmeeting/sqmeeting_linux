import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material

import SDKUserDefaultObject 1.0
import "./"
import "./../../../CommonView/"

Item {

    id:recordingdSettingView

    Rectangle {
        id: rectangle_recording_setting_view

        x:155
        width: 640-170
        height: 480
        color: "#ffffff"

        // property string currentServerAddress: ""

        // Component.onCompleted: {
        //     currentServerAddress = SDKUserDefaultObject.getServerAddressFromUserConfigFile();
        //     server_address_TextInput.text = currentServerAddress;
        // }

        // function showServerAddressTextInputEmptyPrompt(show) {
        //     if (true === show) {
        //         meetingIDTextInput_empty_prompt_label.visible = true;
        //         meetingIDTextInput_empty_prompt_label.height = 20;
        //     } else {
        //         meetingIDTextInput_empty_prompt_label.visible = false;
        //         meetingIDTextInput_empty_prompt_label.height = 0;
        //     }
        // }

        // function onQmlSaveServerAddressToUserConfigFile(serverAddress) {
        //     if (serverAddress === "") {
        //         prompt_message_box_view.showMessageBox("地址无效");
        //         return;
        //     }

        //     if (null !== currentServerAddress && undefined !== currentServerAddress
        //             && null !== serverAddress && undefined !== serverAddress
        //             && currentServerAddress === serverAddress) {
        //         return;
        //     }

        //     currentServerAddress = serverAddress;
        //     var result = SDKUserDefaultObject.onQmlSaveServerAddressToUserConfigFile(serverAddress);
        //     var messageString = "Saved successfully!";
        //     if (true === result) {
        //         messageString = "您的服务器地址已修改！";
        //         delayTimer.start()
        //     } else {
        //         messageString = "您的服务器地址，保存出错！";
        //     }
        //     prompt_message_box_view.showMessageBox(messageString);
        // }

        // Text {
        //     id: titleTextField
        //     text: '开启云录制？'
        //     color: "#222222"
        //     font.pixelSize: 16
        //     font.bold: false
        //     horizontalAlignment: Text.AlignHCenter
        //     verticalAlignment: Text.AlignVCenter
        //     wrapMode: Text.Wrap

        //     // 布局设置
        //     anchors.horizontalCenter: parent.horizontalCenter // 水平中心对齐
        //     anchors.top: parent.top
        //     anchors.topMargin: 24 // 顶部偏移量

        //     // minimumWidth: 1 // 确保宽度和高度 >= 0
        //     // minimumHeight: 1
        // }

        // Text {
        //     id: descriptionTextField
        //     text: '开启后，将录制会议中音频、视频画面及共享屏幕内容，并告知所有参会成员。'
        //     wrapMode: Text.WordWrap
        //     font.pixelSize: 14
        //     font.weight: Font.Normal
        //     color: "#222222"
        //     //horizontalAlignment: Text.AlignHCenter

        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.top: titleTextField.bottom
        //     anchors.topMargin: 10 // 顶部偏移量
        //     width: 332 // 固定宽度
        //     height: implicitHeight // 根据内容调整高度
        // }

        Text {
            id: recording_title_text

            color: "#222222"
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 16

            width: 50 // 固定宽度
            height: implicitHeight // 根据内容调整高度

            text: qsTr("录制文件")
            font.pixelSize: 14
        }

        Text {
            id: recording_detail_text

            color: '#999999'
            wrapMode: Text.WordWrap
            anchors.top: recording_title_text.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 16

            width: 354 // 固定宽度
            height: implicitHeight // 根据内容调整高度

            text: qsTr("登录“神旗系统Web管理系统”，在“会议录制”中查看录制文件")
            font.pixelSize: 13
        }

        SaveAddressButton {
            id: open_recording_file_button
            //anchors.top: server_address_TextInput.top
            anchors.verticalCenter: recording_detail_text.verticalCenter
            //anchors.topMargin: 10
            anchors.left: recording_detail_text.right
            anchors.leftMargin: 8

            width: 50
            height: 28

            isStateChangeButton: false
            state: "SELECTED"
            btn_txt_unselected: ""
            btn_txt_selected: "查看"

            onMouseClicked: {
                var serverAddress = SDKUserDefaultObject.getServerAddressFromUserConfigFile()
                console.log('the server address is ', serverAddress)
                var address = 'https://' + serverAddress
                Qt.openUrlExternally(address)
            }
        }
    }
}
