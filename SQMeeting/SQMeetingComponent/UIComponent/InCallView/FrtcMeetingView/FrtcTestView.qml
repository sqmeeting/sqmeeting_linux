import QtQuick 2.2
import QtQuick.Window 2.2

Window {
    id: win1
    width: 400;
    height: 200;
    visible: true;
    color: "#363636";
    title: "First Window";
    Text {
        anchors.centerIn: parent
        text: "Page 1"
    }
    MouseArea{
        anchors.fill: parent;
        onClicked: pushNewLoader.source="";
    }
}
