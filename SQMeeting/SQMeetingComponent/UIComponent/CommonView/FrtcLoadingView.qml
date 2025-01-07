import QtQuick 2.15

Rectangle {
    id: overlay
    color: "black"
    opacity: 0.5
    anchors.fill: parent
    visible: false
    z: 3

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Rectangle clicked")
        }

        propagateComposedEvents: false
    }

    // 菊花旋转图标
    Image {
        id: spinner
        source: "qrc:/Images/MainView/icon_joining_progress@2x.png"
        anchors.centerIn: parent
        width: 50
        height: 50

        RotationAnimation on rotation {
            from: 0
            to: 360
            loops: Animation.Infinite
            running: overlay.visible
            duration: 1000 // 菊花旋转一圈的时间
        }
    }
}
