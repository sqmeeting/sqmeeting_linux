import QtQuick
import QtQuick.Window
import QtQuick.Controls

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false
    property url btn_img_src_unselected: button_image.source
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property bool isSelected: true

    property color clr_enter: "#dcdcdc"
    property color clr_exit: "#ffffff"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"

    property bool isStateControl:false

    //自定义点击信号
    signal mouseClicked()           //slot: user's onMouseClicked: .
    signal mouseClickedLeft()       //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()      //slot: user's onMouseClickedRight: .
    signal mouseReleased()          //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()       //slot: user's onMouseHoverExited: .

    width: 12
    height: 60
    radius: 4

    z: 3; //keep on the top order.

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_image; source: btn_img_src_selected}
        }
    ]

    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "SELECTED";
        }
    }

    Image {
        id: button_image
        width: 8
        height: 8
        source: icon_streaming_url
        fillMode: Image.PreserveAspectFit
        clip: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 4

        z: 3; //keep on the top order.
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClickedLeft()
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
            }
        }

        //mouse pressed.
        onPressed: {
            color = clr_click
            if (isStateChangeButton) {
                if (icon_button_rec.state === "UNSELECTED") {
                    icon_button_rec.state = "SELECTED";
                    isSelected = true;
                } else {
                    icon_button_rec.state = "UNSELECTED";
                    isSelected = false;
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
}




