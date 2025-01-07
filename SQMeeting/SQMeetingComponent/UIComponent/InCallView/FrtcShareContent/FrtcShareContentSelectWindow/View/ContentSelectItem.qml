import QtQuick
import QtQuick.Window
import QtQuick.Controls

Rectangle {
    id: id_content_icon_button_rec

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



    property int contentItemWidth: 152
    property int contentItemHeight: 120

    property int contentItemImageWidth: 113
    property int contentItemImageHeight: 70

    property int contentItemImageTopMargin: 12
    property int contentItemImageLeftMargin: 19

    property string color_border_mouse_enter: "#026ffe" //blue
    property string color_border_mouse_exit: "#d7dadd"

    property string color_border: color_border_mouse_exit

    width: contentItemWidth
    height: contentItemHeight

    radius: 4

    z: 3; //keep on the top order.

    border.width: 1
    border.color: color_border



    state: "SELECTED"

    states: [
        State {
            name: "UNSELECTED"
            PropertyChanges { target: button_text; color: "gray"}
            PropertyChanges { target: button_text; text: btn_txt_unselected}
            PropertyChanges { target: button_image; source: btn_img_src_unselected}
        },
        State {
            name: "SELECTED"
            PropertyChanges { target: button_text; color: "black"}
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
        showImageObject.onQMLGetScreenSnapShot()
    }

    function setInfoText(str) {
        console.log("[ContentSelectItem.qml][setInfoText]:  " + str);
    }

    function setEnable(aEnable) {
        icon_button_rec.enabled = aEnable
    }


    //-------------------------------------------------
    // subviews.
    //-------------------------------------------------

    Image {
        id: button_image
        width: 113
        height: 70
        //source: "../../../Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_unmute@2x.png"
        source: btn_img_src_unselected
        fillMode: Image.PreserveAspectFit
        clip: true

        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4

        z: 3; //keep on the top order.
    }

    Connections {
        target: showImageObject
        onCallQmlRefeshImg:{
            button_image.source = ""
            button_image.source = "image://showImageObjectImgProvider"
        }
    }

    Text {
        id: button_text
        //text: qsTr("button")
        text: btn_txt_unselected
        anchors.top: button_image.bottom
        anchors.topMargin: 6
        anchors.horizontalCenter: button_image.horizontalCenter

        //font.bold: true
        font.pixelSize: 12

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
                parent.mouseClickedLeft()
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
            }
        }

        onPressed: {

        }

        onReleased: {
            parent.mouseReleased()
        }

        onEntered: {
            color_border = color_border_mouse_enter
        }

        onExited: {
            color_border = color_border_mouse_exit
        }

    } //end of MouseArea
}




