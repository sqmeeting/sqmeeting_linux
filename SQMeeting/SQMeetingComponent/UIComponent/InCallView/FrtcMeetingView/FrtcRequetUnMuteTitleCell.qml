import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: cell
    width: 448
    height: 40

    //anchors.fill: parent
    color: "#FFFFFF"
    radius: 0

    // 名称
    Text {
        id: participantLabel
        text: '参会者'
        font.pixelSize: 13
        color: "#222222"
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        width: 80
    }

    // 状态
    Text {
        id: requestLabel
        text: '申请事项'
        font.pixelSize: 13
        color: "#222222"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 280
        width: 62
    }

    Text {
        id: actionLabel
        text: '操作'
        font.pixelSize: 13
        color: "#222222"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 384
        width: 48
    }
    // 分割线
    Rectangle {
        id: lineView
        height: 1
        width: parent.width
        color: "#D7DADD"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
    }
}
