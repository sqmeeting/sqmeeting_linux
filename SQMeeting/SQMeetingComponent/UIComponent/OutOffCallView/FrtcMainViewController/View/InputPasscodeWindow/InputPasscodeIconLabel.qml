import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

//========================================
// IconLabel
//========================================

Rectangle {
    //id: icon_label_rec

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked

    //自定义点击信号
    signal mouseClicked()           //slot: user's onMouseClicked: .
    signal mouseClickedLeft()       //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()      //slot: user's onMouseClickedRight: .
    signal mouseReleased()          //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()       //slot: user's onMouseHoverExited: .

    width: 100
    height: 30
    y: 4
    radius: 4


    function setInfoText( str) {
        console.log('[InputPasscodeIconLabel.qml][TabBar]:  ', str);
    }

    Image {
        id: button_image

        width: 16
        height: 16

        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 6

        fillMode: Image.PreserveAspectFit
        source: "qrc:/Images/MainView/icon_reminder@2x.png"
    }

    Text {
        id: button_text

        width: 70
        height: 12

        anchors.top: button_image.top
        anchors.topMargin: -2
        anchors.left: button_image.right
        anchors.leftMargin: 6

        //text: qsTr("Text")
        text: btn_txt_selected
        font.pixelSize: 12
    }

    //load complet.
    Component.onCompleted: { }

}

