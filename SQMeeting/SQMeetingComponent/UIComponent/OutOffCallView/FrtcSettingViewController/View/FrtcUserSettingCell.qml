import QtQuick
import QtQuick.Controls

Rectangle {
    id: user_setting_cell
    color: backgroundColor

    property url   source: ""
    property alias titleText: title_label.text
    property color titleColor: "#333333"
    property alias desText: des_label.text
    property bool  isShowDesLabel: true
    property bool  isEnable: true
    property color backgroundColor: '#F8F9FA'

    property alias hoverEnabled: buttonMouseArea.hoverEnabled
    property color hoverColor: '#F8F9FA'
    property color hoverTextColor: '#026FFE'
    property url   hoverSource: ""

    signal mouseClicked()

    Image {
        id: icon_image
        x: 20
        source: source
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id:title_label
        anchors.left: icon_image.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        color: titleColor
        font.pixelSize: 14
    }

    Text {
        id:des_label
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        color: "#999999"
        font.pixelSize: 13
        visible: isShowDesLabel
    }

    Component.onCompleted: {
        icon_image.source = source
    }

    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        hoverEnabled: hoverEnabled
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            color = hoverColor
            title_label.color = hoverTextColor
            icon_image.source = hoverSource
        }

        onExited: {
            color = backgroundColor
            title_label.color = titleColor
            icon_image.source = source
        }

        onPressedChanged: {
            //parent.color = pressed ? pressedColor : (containsMouse ? hoverColor : backgroundColor)
        }

        onClicked: {
            if (isEnable) {
                mouseClicked()
            }
        }
    }
}
