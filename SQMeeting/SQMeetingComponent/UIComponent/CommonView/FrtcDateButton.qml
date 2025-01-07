import QtQuick 2.15
import QtQuick.Controls 2.15

Item {

    id: dateButton
    property alias text: contentTitle.text
    property alias radius: buttonBackground.radius

    property int index: 0
    property bool defaultSelected: false
    property bool selected: false
    property bool customColor: false

    signal clicked()

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        radius: 4
        color: defaultSelected ? "#87CEEB" : selected ? "#026FFE" : (customColor ? "white" : "#bbc3ce")

        MouseArea {
            anchors.fill: parent
            onClicked: dateButton.clicked()
        }
    }

    Text {
        id: contentTitle
        anchors.centerIn: parent
        text: text
        color: customColor ? ((selected || defaultSelected) ? "white" : "#222") : "white"
    }
}
