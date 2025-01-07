import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 30
    height: 30
    color: "#F8F9FA"
    radius: 4

    property string imageSource: buttonImage.source // 替代 imageView.source

    //property alias buttonType: root.data.buttonType
    property int buttonType: 0
    signal buttonClicked(int buttonType)

    Image {
        id: buttonImage
        anchors.centerIn: parent
        width: 11
        height: 11
        fillMode: Image.PreserveAspectFit
        source: imageSource
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
           root.buttonClicked(root.buttonType);
        }
    }

    Component.onCompleted: {
        console.log("MessageButton initialized with type:", buttonType);
    }
}
