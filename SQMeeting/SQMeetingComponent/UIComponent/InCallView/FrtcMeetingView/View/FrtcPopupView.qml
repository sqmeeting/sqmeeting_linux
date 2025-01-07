import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: popupBox
    property Component contentComponent
    property int popupWidth: 127
    property int popupHeight: 54
    property bool isPopUpViewShowing: false

    //property alias isShow: false

    width: popupWidth
    height: popupHeight
    color: "white"
    border.color: "#eeeff0"
    radius: 4
    //anchors.horizontalCenter: parent.horizontalCenter + 50
    x:parent ? parent.width / 2 : 0 + 200
    y: parent ? parent.height : 0  // 默认从底部出现

    // 箭头朝下的 Canvas
    Canvas {
        width: 30
        height: 15
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -13
        anchors.horizontalCenter: parent.horizontalCenter

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.quadraticCurveTo(10, 5, 15, 15);
            ctx.quadraticCurveTo(20, 5, 30, 0);
            ctx.closePath();
            ctx.fillStyle = "white";
            ctx.fill();
            ctx.strokeStyle = "#EEEFF0";
            ctx.lineWidth = 1;
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(30, 0);
            ctx.strokeStyle = "white";
            ctx.lineWidth = 2;
            ctx.stroke();
        }
    }

    Loader {
        id: contentLoader
        width: 127
        height: 34
        //anchors.fill: parent
        anchors.centerIn: parent.Center
        //anchors.margins: 10
        sourceComponent: contentComponent

        // MouseArea {
        //     anchors.fill: parent

        //     onEntered: {
        //         console.log("Mouse entered popupBox")
        //     }

        //     onExited: {
        //         console.log("Mouse exited popupBox")
        //     }
        // }
    }

    function togglePopup() {
        if (popupBox.parent) {
            popupBox.x = 650

            popupBox.y = (popupBox.y === popupBox.parent.height)
                ? popupBox.parent.height - popupHeight - 15 - 54
                : popupBox.parent.height;

            isPopUpViewShowing = true
        }
    }

    function toggleDisappear() {
        if (popupBox.parent) {
            popupBox.y = parent.height
            isPopUpViewShowing = false
        }
    }
}
