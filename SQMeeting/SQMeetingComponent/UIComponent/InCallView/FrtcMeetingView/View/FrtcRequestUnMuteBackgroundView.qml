import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: requestUnMuteView
    width: 448
    height: 360
    color: "#FFFFFF"
    visible: true

    Image {
        id: peopleImageView
        source:  'qrc:Images/InCall/FMeetingVC/ParticipantView/mute/icon_request_unmute@2x.png'
        width: 200
        height: 132
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter:parent.horizontalCenter
    }

    Text {
        id: descriptionTextField
        text: '无参会者申请'
        font.pixelSize: 13
        font.bold: true
        color: "#999999"

        anchors.top: peopleImageView.bottom
        anchors.topMargin: 11

        anchors.horizontalCenter: parent.horizontalCenter

        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        width: Math.min(requestUnMuteView.nameMaxWidth, implicitWidth)
        height: implicitHeight
    }
}
