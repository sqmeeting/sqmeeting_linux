import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material
import "./" //for ./DialogBottomButton.qml, InputPasscodeIconLabel.qml.

Window {
    id: root
    width: 280
    height: 172

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    color: "#00000000"

    //为了实现以下功能，需要往Window中添加一些属性：
    property string content: "ask content."      //dialog content string.
    property string yesButtonString: "yes"       //yes button title.
    property string noButtonString: "no"         //no button title.
    property string contentBackgroundImage: ""   //content box's background image.
    property string buttonBarBackgroundImage: "" //button box background image.
    property bool checked: false                 //select box background image.

    //因为我们需要实现自定义的标题栏，所以加上这个属性可以忽略系统自带的标题栏：
    //flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowStaysOnTopHint
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint


    // A modal window prevents other windows from receiving input events. Possible values are Qt.NonModal (the default), Qt.WindowModal, and Qt.ApplicationModal.
    //modality: Qt.ApplicationModal
    modality: Qt.WindowModal;

    // custom signal
    // 1.accept: yes button clicked.
    // 2.reject：no button clicked.
    // 3.checkAndAccept: select box and yes button clicked.

    signal accept(var password);
    signal reject();
    signal checkAndAccept();


    function getInputPassword() {
       return dialog_buttons_rec.inputPassword
    }

    function clearInputPassword() {
        dialog_buttons_rec.clearInputPassword()
    }

    function promptPasscodeInvalid(bShow) {
       dialog_buttons_rec.showPromptPasscodeInvalid(bShow)
    }

    function showDialogWithPromptInvalidePasscode(wrongPassCode) {
        root.show();
        root.promptPasscodeInvalid(wrongPassCode)
    }


    Rectangle {
        id: dialog_buttons_rec

        anchors.fill: parent


        border.color: "lightgray";
        border.width: 1

        radius: 8
        opacity: 1

        property var inputPassword: meetingIDTextInput.text
        property var promptMessage: textfiled_empty_prompt_label.btn_txt_selected

        function isInputTextFiledEmpty() {
            var isEmpty = true;
            if (meetingIDTextInput.text === "") {
                isEmpty = true;
            } else {
                isEmpty = false;
            }
            showInputTextFiledEmptyPrompt(isEmpty);
            return isEmpty;
        }

        function showInputTextFiledEmptyPrompt(show) {
            if (true === show) {
                textfiled_empty_prompt_label.visible = true;
                textfiled_empty_prompt_label.height = 20;
                promptMessage = qsTr("会议密码不能为空！")
            } else {
                textfiled_empty_prompt_label.visible = false;
                textfiled_empty_prompt_label.height = 0;
                promptMessage = qsTr("")
            }
        }

        function showPromptPasscodeInvalid(show) {
            if (true === show) {
                textfiled_empty_prompt_label.visible = true;
                textfiled_empty_prompt_label.height = 20;
                promptMessage = qsTr("密码错误！")
            } else {
                textfiled_empty_prompt_label.visible = false;
                textfiled_empty_prompt_label.height = 0;
                promptMessage = qsTr("")
            }
        }

        function clearInputPassword() {
            return meetingIDTextInput.text = ""
        }


        Text {
            id: titleTextField
            //x: 94
            //y: 24
            width: parent.width
            height: 40

            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter

            text: qsTr("会议密码")
        }

        //----------------------------------------
        // TextField: input password.
        //----------------------------------------


        TextField {
            id: meetingIDTextInput

            width: 250
            height: 40

            anchors.top : parent.top
            anchors.topMargin: 52
            anchors.left: parent.left
            anchors.leftMargin: 15

            color: "#000000"

            placeholderText: qsTr("请输入会议密码")
            font.pixelSize: 14
            selectByMouse: true
            focus: true
            echoMode: TextInput.Password

            background: Rectangle {
                implicitWidth: 342
                implicitHeight: 40

                border.color: "lightgray"
                radius: 4
            }

            onTextChanged: {
                if (meetingIDTextInput.text !== "") {
                    dialog_buttons_rec.showInputTextFiledEmptyPrompt(false)
                }
            }
        }

        InputPasscodeIconLabel {
            id: textfiled_empty_prompt_label

            height: 0

            anchors.top : meetingIDTextInput.bottom
            anchors.topMargin: 4
            anchors.left: meetingIDTextInput.left
            anchors.right: meetingIDTextInput.right

            btn_txt_selected: "密码错误"
            btn_img_src_selected: "qrc:/Images/MainView/icon_reminder@2x.png"

            visible: false
        }


        DialogBottomButton {
            id: cancelButton
            width: parent.width/2
            height: 48

            anchors.top: parent.bottom
            anchors.topMargin: - height
            anchors.left: parent.left
            //anchors.right: parent.right
            anchors.margins: 0

            border.width: 1
            border.color: "lightgray" //"#0465E6" //blue
            radius: 0

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "取消"
            btn_txt_selected: "取消"
            btn_txt_color_unselected: "black" //blue
            btn_txt_color_selected: "black" //blue

            onMouseClicked: {

                root.visible = false;
                meetingIDTextInput.text = ""
                reject();
            }
        }

        // right button.
        DialogBottomButton {
            id: joinMeetingButton
            width: parent.width/2
            height: 48

            anchors.top: parent.bottom
            anchors.topMargin: - height
            //anchors.left: cancelButton.right
            anchors.right: parent.right
            anchors.margins: 0

            border.width: 1
            border.color: "lightgray" //"#0465E6" //blue
            radius: 0

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "加入"
            btn_txt_selected: "加入"
            btn_txt_color_unselected: "#0465E6" //blue
            btn_txt_color_selected: "#0465E6" //blue

            onMouseClicked: {
                if (dialog_buttons_rec.isInputTextFiledEmpty()) {
                    return;
                }

                root.visible = false;

               accept(meetingIDTextInput.text);
            }
        }




    } //[1.InputPasscodeWindow Rectangle] end of Rectangle.

} //end of Window.



