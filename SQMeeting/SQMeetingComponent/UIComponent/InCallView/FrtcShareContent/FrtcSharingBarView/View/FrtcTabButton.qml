import QtQuick
import QtQuick.Window
import QtQuick.Controls

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false

    property string btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property string btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property bool isSelected: false

    property bool isNeedChangeTextColor: false

    property color clr_enter:   "#dcdcdc"
    property color clr_exit:    "#ffffff"
    property color clr_click:   "#aba9b2"
    property color clr_release: "#ffffff"

    property color color_text_selected:     "#333333"  //"black"
    property color color_text_unSelected:   "#333333" //"gray"

    //自定义点击信号
    signal mouseClicked()               //slot: user's onMouseClicked: .
    signal mouseClickedLeft()           //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()          //slot: user's onMouseClickedRight: .
    signal mouseReleased()              //slot: user's onMouseReleased: .
    signal mouseHoverEntered()          //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()           //slot: user's onMouseHoverExited: .

    width: 60
    height: 60
    radius: 4

    z: 3; //keep on the top order.

    state: "UNSELECTED"


    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; color: "#333333"} //color_text_selected: "gray"
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; color: "#333333"} //color_text_unSelected
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
        }

    }

    function setInfoText(str) {
        console.log('[TabButton.qml][TabBar]:  ', str);
    }

    function setEnable(aEnable) {
        console.log("[TabButton.qml][setEnable aEnable: " + aEnable + ")");
        icon_button_rec.enabled = aEnable

        if (aEnable) {
            opacity = 1
        } else {
            opacity = 0.5
        }
    }


    Image {
        id: button_image
        width: 28
        height: 28
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

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton


        //mouse pressed.
        onPressed: {
            //console.log("[TabButton.qml][onPressed:]: " + isSelected?"true":"false");
            color = clr_click

            //toggleState()

            if (isStateChangeButton) {
                if (icon_button_rec.state === "UNSELECTED") {
                    console.log('[TabButton][onPressed:]: mouse state: selected.')
                    icon_button_rec.state = "SELECTED";
                    //button.text = btn_txt;
                    isSelected = true;
                } else {
                    console.log('[TabButton][onPressed:]: mouse state: unSelected.')
                    icon_button_rec.state = "UNSELECTED";
                    isSelected = false;
                }
                console.log("[TabButton.qml][onPressed:]: set " + isSelected?"true":"false");
            }
            parent.mouseClicked()
        }

        //mouse released.
        onReleased: {
            color = clr_enter
            parent.mouseReleased()
        }

        onEntered: {
            color = clr_enter
            parent.mouseHoverEntered()
        }

        onExited: {
            color = clr_exit
            parent.mouseHoverExited()
        }

    } //end of MouseArea

    function toggleState() {
        if (icon_button_rec.state === "UNSELECTED") {
            icon_button_rec.state = "SELECTED";
            isSelected = true;
        } else {
            icon_button_rec.state = "UNSELECTED";
            isSelected = false;
        }
    }
}




