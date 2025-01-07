import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Title button
//========================================

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false


    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    //    property alias img_src: button_image.source
    //    property alias btn_txt: button.text

    //    property alias img_src_checked: button_image.source //button_image.sourceChecked
    //   property alias btn_txt_checked: button.text //button.textChecked

    property color clr_enter: "#f8f9fa"
    property color clr_exit: "#ffffff"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"

    //自定义点击信号
    signal mouseClicked()         //slot: user's onMouseClicked: .
    signal mouseClickedLeft()   //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight() //slot: user's onMouseClickedRight: .
    signal mouseReleased()        //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()        //slot: user's onMouseHoverExited: .

    width: 100
    height: 30 - 4
    y: 4
    radius: 4

    border.width: 1
    border.color: "lightgray"



    function setInfoText( str) {
        console.log('[TitleButton.qml][TabBar]:  ', str);
    }

    Image {
        id: button_image
        x: 8
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        //source: "Image/FMeetingVC/titlebar/in_conference_menubar_meeting_info@2x.png"
        source: btn_img_src_selected
    }

    Text {
        id: button_text
        x: 30
        anchors.verticalCenter: parent.verticalCenter
        text: btn_txt_selected
        font.pixelSize: 13
        color: "#333333"
    }

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            //PropertyChanges { target: button; color: "gray"}
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            //PropertyChanges { target: button; color: "black"}
            PropertyChanges { target: button_text; text: btn_txt_selected}
            PropertyChanges { target: button_image; source: btn_img_src_selected}
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            //左键点击
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClickedLeft()
                //console.log("[TitleButton]" + button.text + " mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[TitleButton]" + button.text + " mouse: Right button clicked.")
            }
        }

        //mouse pressed.
        onPressed: {
            console.log("btn_txt_selected : " + btn_txt_selected)
            console.log("btn_txt_unselected : " + btn_txt_unselected)

            color = clr_click

            if (isStateChangeButton) {
                if (icon_button_rec.state === "UNSELECTED") {
                    //console.log('[TitleButton]: mouse state: selected.')
                    icon_button_rec.state = "SELECTED"


                } else {
                    //console.log('[TitleButton]: mouse state: unSelected.')
                    icon_button_rec.state = "UNSELECTED"

                }
            }

            parent.mouseClicked()
        }

        //mouse released.
        onReleased: {
            //console.log("Release")
            color = clr_enter
            parent.mouseReleased()
        }

        //mouse hover entered.
        onEntered: {
            //console.log("[TitleButton][onEntered:]: mouse hover entered.")
            color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            //console.log("[TitleButton][onEntered:]: mouse hover exited.")
            color = clr_exit
            parent.mouseHoverExited()
        }

    } //end of MouseArea

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
        }

    }

}



