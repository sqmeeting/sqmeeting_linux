import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id:frtc_default_btn
    radius: viewRadius
    color:backgroundColor
    opacity: isEnable ? 1.0 : 0.5
    border.width: 1
    border.color: borderColor

    property bool    isEnable: true
    property bool    isTextBold: false
    property string  buttonText: ''
    property color   textColor: 'white'
    property int     textFont: 14
    property color   backgroundColor: '#026FFE'
    property color   hoverColor: '#1f80ff'
    property color   borderColor: "white"
    property int     viewRadius: 8

    signal mouseClicked()

    Text {
        id: button_text
        anchors.centerIn: parent
        text: qsTr(buttonText)
        color: textColor
        font.pixelSize: textFont
        //font.bold: isTextBold
        font.weight: Font.Normal
        //font.family: "Heiti SC"
    }

    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent

        onEntered: {
            frtc_default_btn.color = hoverColor
        }

        onExited: {
            frtc_default_btn.color = backgroundColor
        }

        onPressedChanged: {
            //parent.color = pressed ? pressedColor : (containsMouse ? hoverColor : backgroundColor)
        }

        onClicked: {
            if (frtc_default_btn.isEnable) {
                mouseClicked()
            }
        }
    }

}
