import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

Rectangle {
    id: icon_button_rec
    color: "#ffffff"

    property bool isStateChangeButton: false


    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property color clr_enter: "#e4eeff"
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

    width: 140
    height: 30 - 4
    y: 4
    radius: 4

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; color: "#333333"}
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
            PropertyChanges { target: icon_button_rec; color: "#ffffff"}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; color: "#026ff5"}
            PropertyChanges { target: button_text; text: btn_txt_selected}
            PropertyChanges { target: button_image; source: btn_img_src_selected}
            PropertyChanges { target: icon_button_rec; color: "#e4eeff"}
        }
    ]

    function setInfoText( str) {
        console.log('[SettingButton.qml][TabBar]:  ', str);
    }

    Image {
        id: button_image

        width: 16
        height: 16

        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.leftMargin: 8

        fillMode: Image.PreserveAspectFit
        source: btn_img_src_selected
        sourceSize: Qt.size(16, 16)
        cache: false
    }

    Text {
        id: button_text

        width: 80
        anchors.verticalCenter: button_image.verticalCenter
        anchors.left: button_image.right
        anchors.leftMargin: 6

        color: "#333333"
        //text: qsTr("Text")
        text: btn_txt_selected
        font.pixelSize: 14
    }


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse)=>{
            //左键点击
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
                    icon_button_rec.state = "SELECTED"
                } else {
                    icon_button_rec.state = "UNSELECTED"
                }
            }

            parent.mouseClicked()
        }

        //mouse released.
        onReleased: {
            color = clr_enter
            parent.mouseReleased()
        }



    } //end of MouseArea

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "SELECTED";
        }

    }

}



