import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: cell
    width: 448
    height: 40

    property string name: "Default Name"
    property string status: "Default Status"
    signal agreeUnmuteClicked

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#FFFFFF"
        //border.color: "#CCCCCC"
        radius: 0
    }

    // 图片
    Image {
        id: peopleImageView
        source:  'qrc:/Images/InCall/FMeetingVC/TabBar/icon_unmute_people@2x.png'
        width: 20
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
    }

    // 名称
    Text {
        id: nameLabel
        text: name
        font.pixelSize: 13
        color: "#222222"
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: peopleImageView.right
        anchors.leftMargin: 8
        width: 216
    }

    // 状态
    Text {
        id: statusLabel
        text: '申请解除静音'
        font.pixelSize: 13
        color: "#222222"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: nameLabel.right
        anchors.leftMargin: 8
        width: 84
    }

    Rectangle {
        id: allAgreeButton
        width: 48
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16

        //color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)
        color: 'white'
        border.color: "#026FFE"

        radius: 4

        Text {
            anchors.centerIn: parent
            text: '同意'
            font.pixelSize: 14
            color: "#026FFE"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                agreeUnmuteClicked()
            }

        }
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
