import QtQuick 2.12
import QtQuick.Controls 2.14


//========================================
// 3.Tab bar
//========================================

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false
    
    property url btn_img_src_unselected: button_image.source
    property url btn_img_src_selected: button_image.source

//    property alias img_src: button_image.source
//    property alias img_src_checked: button_image.source //button_image.sourceChecked

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

    width: 32
    height: 32
    radius: 4

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

    Image {
        id: button_image
        //anchors.fill: parent
        width: 24 //32
        height: 24 //32
        
        //source: "../../../Image/FrtcMeeting/Images/MainView/icon-setting@2x.png"
        source: btn_img_src_unselected
        fillMode: Image.PreserveAspectFit
        //clip: true
//        anchors.top: parent.top
//        anchors.right: parent.right
//        anchors.left: parent.left
//        anchors.margins: 4
        anchors.centerIn: parent
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
                //console.log("[ImageButton.qml] mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[ImageButton.qml] mouse: Right button clicked.")
            }
        }

        //mouse pressed.
        onPressed: {
            color = clr_click

            if (isStateChangeButton) {
                if (icon_button_rec.state === "UNSELECTED") {
                    console.log('[ImageButton.qml]: mouse state: selected.')
                    icon_button_rec.state = "SELECTED"

                } else {
                    console.log('[ImageButton.qml]: mouse state: unSelected.')
                    icon_button_rec.state = "UNSELECTED"
                }
            }
            parent.mouseClicked()
        }

        //mouse released.
        onReleased: {
            //console.log("[ImageButton.qml]: Release")
            color = clr_enter
            parent.mouseReleased()
        }

        //mouse hover entered.
        onEntered: {
            //console.log("[ImageButton.qml]: mouse hover entered.")
            color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            //console.log("[ImageButton.qml]: mouse hover exited.")
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

    function setState(aFlag) {
        if (true === aFlag) {
            state = "SELECTED"
        } else {
            state = "UNSELECTED"
        }
    }

}




