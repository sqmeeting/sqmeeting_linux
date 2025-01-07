import QtQuick
import QtQuick.Window
import QtQuick.Controls

Rectangle {
    id: icon_button_rec

    property bool isStateChangeButton: false

    property var btn_txt_unselected: button.text
    property url btn_img_src_unselected: button_image.source

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    property bool isSelected: true

    property bool allowSelfUnmute: true

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

    width: 60
    height: 60
    radius: 4

    z: 3; //keep on the top order.

    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; color: "#333333"} //"gray"
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; color: "#333333"} //"black"
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
        console.log('[TabButton.qml][TabBar]:  ', str);
    }

    function handleMessage(isCancel) {
        console.log('-----------------handleMessage-------------- ');
        if(!isCancel) {
            if(icon_button_rec.state === "UNSELECTED") {
                icon_button_rec.state = "SELECTED"
            } else {
                icon_button_rec.state = "UNSELECTED"
            }

            if(isSelected === false) {
                isSelected = true
            } else {
                isSelected = false
            }
        }
    }

    function setEnable(aEnable) {
        console.log("[TabButton.qml][setEnable()]: aEnable: " + aEnable + ")");
        //icon_button_rec.enabled = aEnable

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
        text: btn_txt_unselected
        anchors.top: button_image.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: button_image.horizontalCenter
        anchors.bottom: button_image.bottom
        anchors.bottomMargin: 10
        font.pointSize: 8

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
                console.log('ceshi 1')
                if (icon_button_rec.state === "UNSELECTED") {
                    console.log('ceshi 2')
                    if(!isStateControl) {
                        console.log('ceshi 3')
                        icon_button_rec.state = "SELECTED";
                        isSelected = true;
                    }
                } else {
                    console.log('ceshi 4')
                    if(!isStateControl) {
                        console.log('ceshi 5')
                        icon_button_rec.state = "UNSELECTED";
                        isSelected = false;
                    }
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






