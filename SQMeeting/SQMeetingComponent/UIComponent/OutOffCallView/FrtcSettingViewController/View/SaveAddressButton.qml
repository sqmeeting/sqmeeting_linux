import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false

    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property color clr_enter: "#0465E6" //blue.
    property color clr_exit: "#ffffff"
    property color clr_click: "#0465E6" //blue.
    property color clr_release: "#ffffff"

    //自定义点击信号
    signal mouseClicked()               //slot: user's onMouseClicked: .
    signal mouseClickedLeft()           //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()          //slot: user's onMouseClickedRight: .
    signal mouseReleased()              //slot: user's onMouseReleased: .
    signal mouseHoverEntered()          //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()           //slot: user's onMouseHoverExited: .

    width: 100
    height: 30

    radius: 4

    border.width: 1
    border.color: "#0465E6" //blue.


    function setInfoText( str) {
        console.log('[TitleButton.qml][TabBar]:  ', str);
    }

    Image {
        id: button_image
        //x: 8
        //y: 6
        width: 16
        height: 16
        visible: false

        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.leftMargin: 8

        fillMode: Image.PreserveAspectFit
        //source: "Image/FMeetingVC/titlebar/in_conference_menubar_meeting_info@2x.png"
        source: btn_img_src_selected
        sourceSize: Qt.size(16, 16)
        cache: false
    }

    Text {
        id: button_text

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        text: btn_txt_selected
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        color: "#0465E6" //blue.
    }

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; text: btn_txt_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; text: btn_txt_selected}
        }
    ]

    MouseArea {
        id: mouseArea
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
                if (icon_button_rec.state === "UNSELECTED") {
                    icon_button_rec.state = "SELECTED"
                } else {
                    icon_button_rec.state = "UNSELECTED"
                }
            }

            parent.mouseClicked()
        }

        onReleased: {
            color = clr_enter
            parent.mouseReleased()
        }

        onEntered: {
            color = clr_enter
            parent.mouseHoverEntered()
            button_text.color = "white"
        }

        onExited: {
            color = clr_exit
            parent.mouseHoverExited()
            button_text.color = "#0465E6" //blue.
        }

    } //end of MouseArea

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "SELECTED";
        }

    }

}



