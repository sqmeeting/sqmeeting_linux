import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Dialog Button
//========================================

Rectangle {
    id: button_rec

    property bool isStateChangeButton: false

    property var btn_txt_unselected: button.text
    property var btn_txt_selected: button.text //button.textChecked

    property var btn_txt_color_unselected: button.text.color
    property var btn_txt_color_selected: button.text.color

    property var btn_txt_font_pixelsize: button.text.font.pixelSize

    property color clr_enter: "#dcdcdc"
    property color clr_exit: "#ffffff"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"

    //自定义点击信号
    signal mouseClicked()           //slot: user's onMouseClicked: .
    signal mouseClickedLeft()       //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()      //slot: user's onMouseClickedRight: .
    signal mouseReleased()          //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()       //slot: user's onMouseHoverExited: .

    width: 200
    height: 30
    radius: 4


    function setInfoText(str) {
        console.log('[DialogButton.qml]: setInfoText(str: ' + str, +')');
    }

    Text {
        id: button_text
        anchors.centerIn: parent

        text: btn_txt_selected
        topPadding: -2
        color: btn_txt_color_unselected
        
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: btn_txt_font_pixelsize //12
    }

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            //PropertyChanges { target: button; color: "gray"}
            PropertyChanges { target: button_text; text: btn_txt_unselected; color: btn_txt_color_unselected; }
        },
        State {
            name: "SELECTED"
            //PropertyChanges { target: button; color: "black"}
            PropertyChanges { target: button_text; text: btn_txt_selected; color: btn_txt_color_selected; }
        }
    ]

    MouseArea {
        id: mouseArea
        width: 200
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            //左键点击
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClickedLeft()
                //console.log("[DialogButton.qml]: " + button.text + " mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[DialogButton.qml]: " + button.text + " mouse: Right button clicked.")
            }
        }

        //mouse pressed.
        onPressed: {
            console.log("[DialogButton.qml]: btn_txt_selected : " + btn_txt_selected)
            console.log("[DialogButton.qml]: btn_txt_unselected : " + btn_txt_unselected)

            color = clr_click

            if (isStateChangeButton) {
                if (button_rec.state === "UNSELECTED") {
                    console.log("[DialogButton.qml]: mouse state: selected.")
                    button_rec.state = "SELECTED"
                } else {
                    console.log("[DialogButton.qml]: mouse state: unSelected.")
                    button_rec.state = "UNSELECTED"

                }
            }

            //parent.mouseClicked()
            console.log("[DialogButton.qml]: ----------------------------------------")
            console.log("[DialogButton.qml]: -> send signal mouseClicked()")
            console.log("[DialogButton.qml]: -> send signal mouseClicked()")

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
            //console.log(button.text + " mouse hover entered.")
            color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            //console.log(button.text + " mouse hover exited.")
            color = clr_exit
            parent.mouseHoverExited()
        }

    } //end of MouseArea

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "SELECTED";
       }

    }

}



