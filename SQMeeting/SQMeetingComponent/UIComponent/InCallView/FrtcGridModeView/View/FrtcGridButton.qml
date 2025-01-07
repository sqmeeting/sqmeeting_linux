import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

//========================================
// FrtcGridButton
//========================================

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false

    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property color grid_background_selected: clr_enter
    property color grid_background_unselected: clr_exit

    property color grid_background_board_selected: "#0465E6"
    property color grid_background_board_unselected: "lightgray" //button_image.sourceChecked

    property bool isSelected: false
    
    //    property alias img_src: button_image.source
    //    property alias btn_txt: button.text

    //    property alias img_src_checked: button_image.source //button_image.sourceChecked
    //   property alias btn_txt_checked: button.text //button.textChecked

    property color clr_enter: "#ffffff"
    property color clr_exit: "#f8f9fa"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"

    //自定义点击信号
    signal mouseClicked()               //slot: user's onMouseClicked: .
    signal mouseClickedLeft()           //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()          //slot: user's onMouseClickedRight: .
    signal mouseReleased()              //slot: user's onMouseReleased: .
    signal mouseHoverEntered()          //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()           //slot: user's onMouseHoverExited: .

    width: 100
    height: 90
    radius: 4
    color: "#f8f9fa"
    border.width: 1
    border.color: "lightgray"

    z: 3; //keep on the top order.

    state: "UNSELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: icon_button_rec; color: grid_background_unselected}
            PropertyChanges { target: icon_button_rec; border.color: grid_background_board_unselected }
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: icon_button_rec; color: grid_background_selected }//"#f8f9fa"
            PropertyChanges { target: icon_button_rec; border.color: grid_background_board_selected }
        }
    ]

    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            //state = "SELECTED";
        }

    }

    function setInfoText(str) {
    }

    function setEnable(aEnable) {
        //console.log("[FrtcGridButton.qml][setEnable aEnable: " + aEnable + ")");
        icon_button_rec.enabled = aEnable

        if (aEnable) {
            opacity = 1
        } else {
            opacity = 0.5
        }
    }

    //-------------------------------------------------
    // subviews.
    //-------------------------------------------------

    Image {
        id: button_image
        width: 80
        height: 48
        //source: "../../../Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_unmute@2x.png"
        source: btn_img_src_unselected
        fillMode: Image.PreserveAspectFit
        clip: true
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.right: parent.right
        anchors.left: parent.left
        //anchors.margins: 12

        z: 3; //keep on the top order.
    }

    Text {
        id: button_text
        width: parent.width
        height: 24
        //text: qsTr("button")
        text: btn_txt_unselected
        horizontalAlignment: Text.AlignHCenter
        anchors.top: button_image.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: button_image.horizontalCenter

        //font.bold: true
        font.pixelSize: 10
        color: "#666666"

        z: 3; //keep on the top order.
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            //左键点击
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClicked()
                //parent.mouseClickedLeft()
                //console.log("[FrtcGridButton.qml] mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[FrtcGridButton.qml] mouse: Right button clicked.")
            }
        }

        //mouse pressed.
        //        onPressed: {
        //            console.log("[FrtcGridButton.qml][onPressed:]: " + isSelected?"true":"false");

        //            //console.log("btn_txt_selected : " + btn_txt_selected)
        //            //console.log("btn_txt_unselected : " + btn_txt_unselected)

        //            color = clr_click

        //            if (isStateChangeButton) {
        //                if (icon_button_rec.state === "UNSELECTED") {
        //                    console.log('[FrtcGridButton.qml][onPressed:]: mouse state: selected.')
        //                    icon_button_rec.state = "SELECTED";
        //                    //button.text = btn_txt;
        //                    isSelected = true;
        //                } else {
        //                    console.log('[FrtcGridButton.qml][onPressed:]: mouse state: unSelected.')
        //                    icon_button_rec.state = "UNSELECTED";
        //                    //button.text = btn_txt_checked;
        //                    isSelected = false;
        //                }
        //                console.log("[FrtcGridButton.qml][onPressed:]: set " + isSelected?"true":"false");
        //            }
        //            parent.mouseClicked()
        //        }

        //mouse released.
        onReleased: {
            //console.log("Release")
            color = clr_enter
            parent.mouseReleased()
        }

        //mouse hover entered.
        onEntered: {
            console.log("[FrtcGridButton.qml][MouseArea onEntered:] mouse hover entered.")
            color = clr_enter
            border.color = "#0465E6"
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            console.log("[FrtcGridButton.qml][MouseArea onExited:] mouse hover exited.")
            color = clr_exit
            border.color = "lightgray"
            parent.mouseHoverExited()
        }

    } //end of MouseArea
}




