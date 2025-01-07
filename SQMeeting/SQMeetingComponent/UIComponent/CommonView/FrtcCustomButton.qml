// CustomRectangleButton.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: customRectangleButton

    property alias imageSource: image.source
    property alias textContent: text.text
    property string layout: "leftToRight"  // 可选值："leftToRight", "rightToLeft", "topToBottom", "bottomToTop"
    property color backgroundColor: "white"
    property color hoverColor: "lightgray"
    property color textColor: "#222222"
    property bool isEnable: true

    width: parent.width
    height: parent.height
    color: mouseArea.containsMouse ? hoverColor : backgroundColor
    opacity: isEnable ? 1.0 : 0.5

    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (customRectangleButton.isEnable) {
                customRectangleButton.clicked()
            }
        }
    }

    Row {
        id: layoutItem
        anchors.centerIn: parent
        spacing: 5
        visible: customRectangleButton.layout === "leftToRight" || customRectangleButton.layout === "rightToLeft"

        Image {
            id: image
            visible: customRectangleButton.layout === "leftToRight" || customRectangleButton.layout === "rightToLeft"
        }

        Text {
            id: text
            color: customRectangleButton.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: customRectangleButton.layout === "leftToRight" || customRectangleButton.layout === "rightToLeft"
        }
    }

    Column {
        id: layoutItemColumn
        anchors.centerIn: parent
        spacing: 5
        visible: customRectangleButton.layout === "topToBottom" || customRectangleButton.layout === "bottomToTop"

        Image {
            id: imageColumn
            visible: customRectangleButton.layout === "topToBottom" || customRectangleButton.layout === "bottomToTop"
            source: image.source
        }

        Text {
            id: textColumn
            color: customRectangleButton.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: customRectangleButton.layout === "topToBottom" || customRectangleButton.layout === "bottomToTop"
            text: text.text
        }
    }
}
