import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0

import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp

import "./"
import "./InputPasscodeWindow/"
import "./../../../CommonView/"

Rectangle {
    id: root
    width: 640
    height: 480

    radius: 8
    border.width: 1  //borderWidth
    border.color: "#F0F0F5" // "gray" //borderColor
    color: Qt.rgba(0,0,0,0.35)

    //define the flag for creat or destroy.
    property bool createOrdestroy: false
    property var  subPopupFMeetingViewControllerQML;

    property string  currentMeetingID: ""
    property string  currentUserName: ""

    property string  meetingIDTextInputText: ""
    property string  nameTextInputText: ""

    property bool  currentMicMute: true
    property bool  currentCameraMute: true
    property bool  currentAudioOnly: false

    property bool  isShowInputPasscodeDialog: false

    property string inCallFailureTitle: ""
    property string inCallFailureMessage: ""

    property bool  isSmallWindowDisplay: false

    //用户保存当前会议信息
    property var currentMeetingInfo: {
        "id" : 10001
    }

    signal destroyCallView()


    Component.onCompleted: {
        if (isSmallWindowDisplay) {
            root.width = 380
            root.height = 348
            callViewChangeAppearance();
        } else {
            root.width = 640
            root.height = 480
        }

        loadUserDataFromLocalUserConfigFile();
        currentMeetingInfo = null
    }
    
    //========================================
    // [CPP Object]: FrtcCallViewObject
    //========================================

    function callViewChangeAppearance() {
        id_frtc_call_view.border.width = 1
        id_frtc_call_view.border.color = '#DEDEDE'
    }

    //Load data from useconfig.ini, which are used last time.
    function loadUserDataFromLocalUserConfigFile() {
        var userConfigData = SDKUserDefaultObject.getUserConfigFromUserConfigFile();

        currentMeetingID  = userConfigData.meetingID;
        currentUserName   = userConfigData.userName;
        currentMicMute    = true
        currentCameraMute = true
        currentAudioOnly  = false

        //update UI.
        updateUIAsLocalUserConfigFile()

        refreshUIForAudioOnly(currentAudioOnly);
    }

    function updateUIAsLocalUserConfigFile() {
        meetingIDTextInput.text = currentMeetingID;
        nameTextInput.text = currentUserName;
        micphoneOnOffCheckBox.setStateChecked(!currentMicMute);
        cameraOnOffCheckBox.setStateChecked(!currentCameraMute);
        // audioOnlyCheckBox.setStateChecked(currentAudioOnly);
    }

    function getUserConfigFromUI() {
        currentMeetingID = meetingIDTextInput.text;
        currentUserName = nameTextInput.text;
        currentMicMute = !micphoneOnOffCheckBox.checked;
        currentCameraMute = !cameraOnOffCheckBox.checked;
        //currentAudioOnly = audioOnlyCheckBox.checked;
    }

    //Save data to useconfig.ini, which are used currently.
    function saveUserDataToLocalUserConfigFile() {
        getUserConfigFromUI()
        SDKUserDefaultObject.onQmlSaveUserConfigToUserConfigFile(currentMeetingID, currentUserName, currentMicMute, currentCameraMute, currentAudioOnly);
        //temp sava
        SDKUserDefaultObject.onQmlSaveTempSelectMicMute(currentMicMute)
        SDKUserDefaultObject.onQmlSaveTempSelectCameraMute(currentCameraMute)
    }

    function refreshUIForAudioOnly(bAudioOnly) {
        if (false === bAudioOnly) {
            cameraOnOffCheckBox.isEnable = true
        } else {
            cameraOnOffCheckBox.isEnable = false
        }
    }

    function isMeetingIDTextInputEmpty() {
        var isEmpty = true;
        if (meetingIDTextInput.text === "") {
            isEmpty = true;
        } else {
            isEmpty = false;
        }
        showMeetingIDTextInputEmptyPrompt(isEmpty);
        return isEmpty;
    }
    
    function showMeetingIDTextInputEmptyPrompt(show) {
        if (true === show) {
            meetingIDTextInput_empty_prompt_label.visible = true;
            meetingIDTextInput_empty_prompt_label.height = 20;
        } else {
            meetingIDTextInput_empty_prompt_label.visible = false;
            meetingIDTextInput_empty_prompt_label.height = 0;
        }
    }

    function isNameTextInputEmpty() {
        var isEmpty = true;
        if (nameTextInput.text === "") {
            isEmpty = true;
        } else {
            isEmpty = false;
        }
        showNameTextInputEmptyPrompt(isEmpty);
        return isEmpty;
    }
    
    function showNameTextInputEmptyPrompt(show) {
        if (true === show) {
            nameTextInput_empty_prompt_label.visible = true;
            nameTextInput_empty_prompt_label.height = 20;
        } else {
            nameTextInput_empty_prompt_label.visible = false;
            nameTextInput_empty_prompt_label.height = 0;
        }
    }

    //---------- ---------- ---------- ----------
    // [UI]:
    //---------- ---------- ---------- ----------

    Rectangle {
        id: id_frtc_call_view
        anchors.centerIn: parent
        width: 380
        height: 348
        radius: 8

        Text {
            id: titleTextField
            y: 24
            height: 28
            text: qsTr("加入会议")
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter
        }

        FrtcTextField {
            id: meetingIDTextInput
            x: 20
            y: 68
            width: 342
            height: 40
            placeholderText: qsTr("请输入会议号")
            textFont: 14

            onTextInputChanged: {
                if (meetingIDTextInput.text !== "") {
                    showMeetingIDTextInputEmptyPrompt(false);
                }
            }

        }

        IconLabel {
            id: meetingIDTextInput_empty_prompt_label
            x: 20
            anchors.top : meetingIDTextInput.bottom;
            width : 200
            height: 0
            btn_txt_selected: "会议号码不能为空"
            btn_img_src_selected: "qrc:/Images/MainView/icon_reminder@2x.png"
            visible: false
        }


        FrtcTextField {
            id: nameTextInput
            anchors.left: meetingIDTextInput.left
            x: 20
            //y: 124
            anchors.top: meetingIDTextInput_empty_prompt_label.bottom
            anchors.topMargin: 12
            width: 342
            height: 40
            placeholderText: qsTr("请输入您的名字")
            textFont: 14

            onTextInputChanged: {
                if (nameTextInput.text !== "") {
                    showNameTextInputEmptyPrompt(false);
                }
            }
        }

        IconLabel {
            id: nameTextInput_empty_prompt_label
            x: 20
            anchors.top : nameTextInput.bottom;
            width : 200
            height: 0
            btn_txt_selected: "名字不能为空"
            btn_img_src_selected: "qrc:/Images/MainView/icon_reminder@2x.png"
            visible: false
        }


        Rectangle {
            id: checkbox_button_rect
            width: 380 - 2 //for border witdh
            height: 180 - 8 //for radius: 8
            anchors.top: nameTextInput_empty_prompt_label.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 10

            anchors.horizontalCenter: parent.horizontalCenter

            FrtcCheckBoxView {
                id: micphoneOnOffCheckBox

                anchors.top: parent.top
                anchors.topMargin: 6
                anchors.left: parent.left
                anchors.leftMargin: 12

                isStateChangeButton: true
                state: "UNSELECTED"
                checkable: true

                btn_txt_unchecked: qsTr("打开麦克风")
                btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
                btn_txt_checked: qsTr("打开麦克风")
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

                onMouseClicked: {
                    currentMicMute = !micphoneOnOffCheckBox.checked

                    if(currentMicMute) {
                        console.log('mute')
                    } else {
                        console.log(' not mute')
                    }
                }
            }


            FrtcCheckBoxView {
                id: cameraOnOffCheckBox
                anchors.top: micphoneOnOffCheckBox.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.leftMargin: 12

                isStateChangeButton: true
                state: "UNSELECTED"
                checkable: true

                btn_txt_unchecked: qsTr("开启摄像头");
                btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png";
                btn_txt_checked: qsTr("开启摄像头");
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png";

                onMouseClicked: {
                    currentCameraMute = !cameraOnOffCheckBox.checked

                    if(currentCameraMute) {
                        console.log('mute')
                    } else {
                        console.log('not mute')
                    }
                }
            }

            /*Rectangle {
                id:lineOnly
                height: 1
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.top: cameraOnOffCheckBox.bottom
                anchors.topMargin: 4
                color: "#EEEEF0"
            }

            FrtcCheckBoxView {
                id: audioOnlyCheckBox
                //x: 12
                anchors.top: cameraOnOffCheckBox.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 12

                isStateChangeButton: true
                state: "UNSELECTED"
                checkable: true

                btn_txt_unchecked: qsTr("仅音频");
                btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png";
                btn_txt_checked: qsTr("仅音频");
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png";

                onMouseClicked: {
                    if (audioOnlyCheckBox.checked === false) {
                        cameraOnOffCheckBox.setEnable(true);
                    } else {
                        cameraOnOffCheckBox.setStateChecked(false);
                        cameraOnOffCheckBox.setEnable(false);

                        var messageString = qsTr("语音会议，不能收发视频及屏幕共享！");
                        prompt_message_box_view.showMessageBox(messageString);
                    }
                }
            }*/

            Rectangle {
                id:canclebutton
                anchors.bottom: parent.bottom
                anchors.margins: 15
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -80
                width: 145
                height: 34
                opacity: 1
                color: "#F0F0F5"
                radius: 4

                Text {
                    id: cancelLable
                    anchors.centerIn: parent
                    text: qsTr("取消")
                    font.pixelSize: 14
                    color: "#333333"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        console.log("[UI][FrtcCallView.qml] press canclebutton button")
                        root.visible = false
                        destroyCallView()
                    }

                    onEntered: {
                        canclebutton.color = "#F7F7FB"
                    }

                    onExited: {
                        canclebutton.color = "#F0F0F5"
                    }
                }
            }

            Rectangle {
                id: joinConferenceButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 80
                //anchors.verticalCenter: canclebutton.verticalCenter
                anchors.bottom: parent.bottom
                anchors.margins: 15
                width: 145
                height: 34
                color: "#026FFE"
                radius: 4

                Text {
                    id: joinLable
                    anchors.centerIn: parent
                    text: qsTr("加入会议")
                    font.pixelSize: 14
                    color: "white"
                }

                MouseArea {
                    id: mouseArea_join
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        if (isMeetingIDTextInputEmpty()) {
                            return;
                        }

                        if (isNameTextInputEmpty()) {
                            return;
                        }

                        getUserConfigFromUI()
                        saveUserDataToLocalUserConfigFile();

                        FrtcCallInterface.makeCall(currentUserName, currentMeetingID, currentMicMute, currentCameraMute, currentAudioOnly)
                        destroyCallView()
                    }

                    onEntered: {
                        joinConferenceButton.color = "#1F80FF"
                    }

                    onExited: {
                        joinConferenceButton.color = "#026FFE"

                    }
                }

            }

        }

        MessageBox {
            id: prompt_message_box_view
            width: 320
            height: 40

            anchors.centerIn: parent;

            visible: false
            color: "gray"

            function showMessageBox(messageString) {
                popMessageBox(messageString);
            }
        }
    }
} //end of Rectangle.
