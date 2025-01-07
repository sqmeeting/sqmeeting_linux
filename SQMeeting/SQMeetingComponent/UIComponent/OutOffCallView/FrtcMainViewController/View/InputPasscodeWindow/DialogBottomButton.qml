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
        //console.log('[DialogButton.qml]: setInfoText(str: ' + str, +')');
    }

    Text {
        id: button_text
        anchors.centerIn: parent

        width: 200
        height: 12
        text: btn_txt_selected
        color: btn_txt_color_unselected
        
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: btn_txt_font_pixelsize //12
    }

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; text: btn_txt_unselected; color: btn_txt_color_unselected; }
        },
        State {
            name: "SELECTED"
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

        onClicked: function(event) {
            // Left button click
            if (event.button === Qt.LeftButton) {
                mouseClickedLeft();
            }
            // Right button click
            else if (event.button === Qt.RightButton) {
                mouseClickedRight();
            }
        }

        //mouse pressed.
        onPressed: {

            color = clr_click

            if (isStateChangeButton) {
                if (button_rec.state === "UNSELECTED") {
                    button_rec.state = "SELECTED"
                } else {
                    button_rec.state = "UNSELECTED"
                }
            }

            parent.mouseClicked()
        }

        //mouse released.
        onReleased: {
            color = clr_enter
            parent.mouseReleased()
        }

        //mouse hover entered.
        onEntered: {
            color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
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



