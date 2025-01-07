import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


 //import com.frtc.FMeetingViewControllerObject 1.0 //class FMeetingViewController


//========================================
// 3.Tab bar
//========================================

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false

    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property bool isSelected: false

    property bool isNeedChangeTextColor: false

    property color clr_enter:   "#dcdcdc"
    property color clr_exit:    "#ffffff"
    property color clr_click:   "#aba9b2"
    property color clr_release: "#ffffff"

    //now our UX is the same text color, for select and unselect.
    property color color_text_selected: "red"  //"black", "#333333"
    property color color_text_unSelected: "red" //"gray", "#333333"

    //自定义点击信号
    signal mouseClicked()         //slot: user's onMouseClicked: .
    signal mouseClickedLeft()   //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight() //slot: user's onMouseClickedRight: .
    signal mouseReleased()        //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()        //slot: user's onMouseHoverExited: .

    width: 60
    height: 60
    radius: 4

    z: 3; //keep on the top order.

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; color: "red"} //"gray", #333333"
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; color: "red"} //"black", #333333"
            PropertyChanges { target: button_text; text: btn_txt_selected}
            PropertyChanges { target: button_image; source: btn_img_src_selected}
        }
    ]

    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "SELECTED";
        }

    }

    function setInfoText(str) {
        console.log('[FrtcTabButtonDropCall.qml][TabBar]:  ', str);
    }

    function setEnable(aEnable) {
        console.log("[FrtcTabButtonDropCall.qml][setEnable()]: aEnable: " + aEnable + ")");
        icon_button_rec.enabled = aEnable

        if (aEnable) {
            opacity = 1
        } else {
            opacity = 0.5
        }
    }

    Image {
        id: button_image
        width: 32 - 2
        height: 32 - 2
        source: btn_img_src_unselected
        fillMode: Image.PreserveAspectFit
        clip: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 4

        z: 3; //keep on the top order.
    }

    Text {
        id: button_text
        //text: qsTr("button")
        text: btn_txt_unselected
        anchors.top: button_image.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: button_image.horizontalCenter
        anchors.bottom: button_image.bottom
        anchors.bottomMargin: 10

        //font.bold: true
        font.pixelSize: 10

        z: 3; //keep on the top order.
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true


        /*
        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClickedLeft()
                //console.log("[FrtcTabButtonDropCall.qml] mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[FrtcTabButtonDropCall.qml] mouse: Right button clicked.")
            }
        }

        //mouse pressed.
        onPressed: {
            //console.log("[FrtcTabButtonDropCall.qml][onPressed:]: " + isSelected?"true":"false");

            //console.log("btn_txt_selected : " + btn_txt_selected)
            //console.log("btn_txt_unselected : " + btn_txt_unselected)

            color = clr_click

            if (isStateChangeButton) {
                if (icon_button_rec.state === "UNSELECTED") {
                    console.log('[FrtcTabButtonDropCall.qml][onPressed:]: mouse state: selected.')
                    icon_button_rec.state = "SELECTED";
                    //button.text = btn_txt;
                    isSelected = true;
                } else {
                    console.log('[FrtcTabButtonDropCall.qml][onPressed:]: mouse state: unSelected.')
                    icon_button_rec.state = "UNSELECTED";
                    //button.text = btn_txt_checked;
                    isSelected = false;
                }
                console.log("[FrtcTabButtonDropCall.qml][onPressed:]: set " + isSelected?"true":"false");
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
            console.log("[FrtcTabButtonDropCall.qml][MouseArea onEntered:] mouse hover entered.")
            color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            console.log("[FrtcTabButtonDropCall.qml][MouseArea onExited:] mouse hover exited.")
            color = clr_exit
            parent.mouseHoverExited()
        }

        */



        onClicked: {
            //parent.color = "red"
            parent.mouseClicked()
        }

        onEntered: {
            color = clr_enter
        }

        onExited: {
            color = clr_exit
        }
    } //end of MouseArea
}




