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

    property bool isSelected: false

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
        console.log('[TabButtonDropCall.qml][TabBar]:  ', str);
    }

    function setEnable(aEnable) {
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
        font.pointSize: 8

        z: 3; //keep on the top order.
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
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




