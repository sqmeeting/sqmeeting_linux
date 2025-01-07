import QtQuick 2.12
import QtQuick.Controls 2.14

Rectangle {
    //id: icon_label_rec

    property var btn_txt_selected: button.text //button.textChecked
    property url btn_img_src_selected: button_image.source //button_image.sourceChecked


    //自定义点击信号
    signal mouseClicked()               //slot: user's onMouseClicked: .
    signal mouseClickedLeft()           //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight()          //slot: user's onMouseClickedRight: .
    signal mouseReleased()              //slot: user's onMouseReleased: .
    signal mouseHoverEntered()          //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()           //slot: user's onMouseHoverExited: .

    width: 100
    height: 30
    y: 5
    radius: 4


    function setInfoText( str) {
        console.log('[IconLabel.qml][TabBar]:  ', str);
    }

    Image {
        id: button_image
        x: 8
        y: 6
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: btn_img_src_selected
    }

    Text {
        id: button_text
        x: 30
        y: 8
        width: 70
        height: 12
        //text: qsTr("Text")
        text: btn_txt_selected
        font.pixelSize: 12
    }

    //load complet.
    Component.onCompleted: {

    }

}

