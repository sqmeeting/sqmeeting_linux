import QtQuick
import QtQuick.Window
import QtQuick.Controls

Rectangle {
    id: icon_button_rec

    property bool isEnable: true                //for audio only and cameraMute.
    onIsEnableChanged: {
        button_text.color = isEnable ? "black" : "gray";
        mouseArea.enabled = isEnable;
    }

    property bool isStateChangeButton: false

    property var btn_txt_unchecked: button_text.text
    property url btn_img_src_unchecked: icon.source

    property var btn_txt_checked: button_text.text //button.textChecked
    property url btn_img_src_checked: icon.source //icon.sourceChecked

    property color clr_enter: "#dcdcdc"
    property color clr_exit: "#ffffff"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"

    property bool checked: false                 //选择框是否确认
    property bool checkable: true                //选择框是否可以选中

    //自定义点击信号
    signal mouseClicked()               //slot: user's onMouseClicked: .
    signal mouseClickedLeft()           //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()          //slot: user's onMouseClickedRight: .
    signal mouseReleased()              //slot: user's onMouseReleased: .
    signal mouseHoverEntered()          //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()           //slot: user's onMouseHoverExited: .

    width: button_text.contentWidth + 25
    height: 30

    anchors.topMargin: 5
    anchors.leftMargin: 0
    radius: 4

    function setInfoText(str) {
        console.log('[IconCheckBox.qml][TabBar]:  ', str);
    }

    Image {
        id: icon
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        source: btn_img_src_unchecked
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: button_text
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.leftMargin: 5
        text: btn_txt_checked
        font.pixelSize: 14
        color: isEnable ? "black" : "gray"
    }

    state: "CHECKED"

    states: [
        State {
            name: "UNCHECKED"
            PropertyChanges { target: button_text; text: btn_txt_unchecked; }
            PropertyChanges { target: icon; source: btn_img_src_unchecked; }
        },
        State {
            name: "CHECKED"
            PropertyChanges { target: button_text; text: btn_txt_checked; }
            PropertyChanges { target: icon; source: btn_img_src_checked; }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (false === isEnable) {
                return;
            }

            if (checkable) {
                checked = !checked
                icon_button_rec.state = checked ? "CHECKED" : "UNCHECKED"
                parent.mouseClicked()
            }
        }
    }

    //load complet.
    Component.onCompleted: {
        if (false === isStateChangeButton) {
            state = "CHECKED";
        } else {
            state = checked ? "CHECKED" : "UNCHECKED"
        }
    }

    function setStateChecked(bChecked) {
        checked = bChecked;
        state = bChecked ? "CHECKED" : "UNCHECKED";
    }
}
