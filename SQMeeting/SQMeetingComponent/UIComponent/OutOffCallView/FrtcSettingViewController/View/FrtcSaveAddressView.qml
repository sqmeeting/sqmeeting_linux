import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material

import SDKUserDefaultObject 1.0
import "./"
import "./../../../CommonView/"

Item {

    id:saveAddreddSettingView

    Rectangle {
        id: rectangle_setting_general_view

        x:155
        width: 640-170
        height: 480
        color: "#ffffff"

        property string currentServerAddress: ""

        Component.onCompleted: {
            currentServerAddress = SDKUserDefaultObject.getServerAddressFromUserConfigFile();
            server_address_TextInput.text = currentServerAddress;
        }

        function showServerAddressTextInputEmptyPrompt(show) {
            if (true === show) {
                meetingIDTextInput_empty_prompt_label.visible = true;
                meetingIDTextInput_empty_prompt_label.height = 20;
            } else {
                meetingIDTextInput_empty_prompt_label.visible = false;
                meetingIDTextInput_empty_prompt_label.height = 0;
            }
        }

        function onQmlSaveServerAddressToUserConfigFile(serverAddress) {
            if (serverAddress === "") {
                prompt_message_box_view.showMessageBox("地址无效");
                return;
            }

            if (null !== currentServerAddress && undefined !== currentServerAddress
                    && null !== serverAddress && undefined !== serverAddress
                    && currentServerAddress === serverAddress) {
                return;
            }

            currentServerAddress = serverAddress;
            var result = SDKUserDefaultObject.onQmlSaveServerAddressToUserConfigFile(serverAddress);
            var messageString = "Saved successfully!";
            if (true === result) {
                messageString = "您的服务器地址已修改！";
                delayTimer.start()
            } else {
                messageString = "您的服务器地址，保存出错！";
            }
            prompt_message_box_view.showMessageBox(messageString);
        }

        Text {
            id: server_address_title_text

            width: 200
            height: 15
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 16

            text: qsTr("服务器地址")
            font.pixelSize: 14
        }

        TextField {
            id: server_address_TextInput

            width: 300
            height: 40
            anchors.top: server_address_title_text.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 14

            color: "#000000"
            font.pixelSize: 14
            selectByMouse: true

            focus: true

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40

                border.color: "lightgray"
                radius: 4
            }
            onTextChanged: {
                if (server_address_TextInput.text !== "") {

                }
            }
        }

        SaveAddressButton {
            id: save_address_setting_button
            //anchors.top: server_address_TextInput.top
            anchors.verticalCenter: server_address_TextInput.verticalCenter
            //anchors.topMargin: 10
            anchors.left: server_address_TextInput.right
            anchors.leftMargin: 10

            isStateChangeButton: false
            state: "SELECTED"
            btn_txt_unselected: ""
            btn_txt_selected: "保存地址"

            onMouseClicked: {
                var serverAddress = server_address_TextInput.text;
                rectangle_setting_general_view.onQmlSaveServerAddressToUserConfigFile(serverAddress);
            }
        }

        Timer {
            id: delayTimer
            interval: 3000
            repeat: false
            onTriggered: {
                if (SDKUserDefaultObject.getLoginState()) {
                    FrtcTool.cancleUserInfo()
                    FrtcTool.refreshMainWindow(false)
                    FrtcTool.closeSettingView()
                }
            }
        }

        MessageBox {
            id: prompt_message_box_view
            width: 200
            height: 40

            x: 100
            y: 200

            visible: false
            color: "gray"

            function showMessageBox(messageString) {
                popMessageBox(messageString);
            }
        }
    }
}
