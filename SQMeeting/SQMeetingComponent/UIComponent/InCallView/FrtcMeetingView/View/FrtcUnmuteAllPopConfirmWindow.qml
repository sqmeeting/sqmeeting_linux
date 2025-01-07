import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import "./"

//========================================
// InputPasscodeWindow: for input password to join a meeting.
//========================================

Window {
    id: id_root_unmute_all_dialog
    width: 240 + 1 //plus 1: for the middle_line_view.
    height: 128

    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height

    color: "#00000000"

    property string content: "ask content."      //dialog content string.
    property string yesButtonString: "yes"       //yes button title.
    property string noButtonString: "no"         //no button title.
    property string contentBackgroundImage: ""   //content box's background image.
    property string buttonBarBackgroundImage: "" //button box background image.
    property bool checked: false                 //select box background image.

    //custom title bar, so ignore default title bar.
    //flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowStaysOnTopHint
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint


    // A modal window prevents other windows from receiving input events. Possible values are Qt.NonModal (the default), Qt.WindowModal, and Qt.ApplicationModal.
    //modality: Qt.ApplicationModal
    modality: Qt.WindowModal

    // custom signal
    // 1.accept: yes button clicked.
    // 2.reject：no button clicked.
    // 3.checkAndAccept: select box and yes button clicked.

    signal accept() //for accept unmuteAll and will umute local audio.
    signal reject()
    signal checkAndAccept()

    property int lineHeight: 1 //0.5
    property int bottomRectHeight: 45
    property int bottonRectHeight: 40
    property int bottonRectWidth: 120


    Rectangle {
        id: dialog_buttons_rec
        anchors.fill: parent

        border.color: "lightgray";
        border.width: 1

        radius: 8
        opacity: 1

        Component.onDestruction: {}

        Text {
            id: id_title_text
            width: parent.width
            height: 18
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            color: "black"
            font.family: "Microsoft YaHei"
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter

            text: qsTr("解除静音")
        }

        Text {
            id: id_message_text
            width: parent.width
            height: 18
            anchors.top: id_title_text.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter

            color: "#444444"
            font.family: "Microsoft YaHei"
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter

            text: qsTr("会议主持人邀请您打开麦克风。")
        }


    Rectangle {
        id: id_buttons_rect
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 45 //height of the button
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: top_line_view
            color: "#e2e2e2"
            height: lineHeight // 0.5
            width: parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 0
        }

        Rectangle {
            id: middle_line_view
            color: "#e2e2e2"
            height: 45 //lineHeight // 0.5
            width: lineHeight
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        PopDialogBottomButton {
            id: id_cancel_button
            width: bottonRectWidth //parent.width/2
            height: bottonRectHeight

            anchors.top: parent.bottom
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.margins: 0
            radius: 0

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "保持静音"
            btn_txt_selected: "保持静音"
            btn_txt_color_unselected: "black" //blue
            btn_txt_color_selected: "black" //blue

            onMouseClicked: {
                reject()
            }
        }

        // right button.
        PopDialogBottomButton {
            id: id_accept_button
            width: bottonRectWidth //parent.width/2
            height: bottonRectHeight

            anchors.top: parent.bottom
            anchors.topMargin: 1
            anchors.right: parent.right
            anchors.margins: 0

            radius: 0

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "打开麦克风"
            btn_txt_selected: "打开麦克风"
            btn_txt_color_unselected: "#0465E6" //blue
            btn_txt_color_selected: "#0465E6" //blue

            onMouseClicked: {
                accept()
            }
        }

    }


    } //[Rectangle] end of Rectangle.

} //end of Window.



