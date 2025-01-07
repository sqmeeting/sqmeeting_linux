import QtQuick
import QtQuick.Controls

Rectangle {
    color: 'white'
    border.color: '#eeeff0'
    border.width: 1
    radius: 4
    // 使用Canvas绘制三角形
    Canvas {
        width: 30
        height: 15
        anchors.top: parent.top
        anchors.topMargin: -13
        anchors.horizontalCenter: parent.horizontalCenter

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.beginPath();
            ctx.moveTo(0, 15);
            ctx.quadraticCurveTo(10, 10, 15, 0);
            ctx.quadraticCurveTo(20, 10, 30, 15);
            ctx.closePath();
            ctx.fillStyle = "white";
            ctx.fill();
            ctx.strokeStyle = "#EEEFF0";
            ctx.lineWidth = 1;
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(0, 15);
            ctx.lineTo(30, 15);
            ctx.strokeStyle = "white";
            ctx.lineWidth = 2;
            ctx.stroke();
        }
    }
}
