import QtQuick 2.15
import '../../../CommonView'

Rectangle {

    id: history_Cell

    property alias meetingNumber: meeting_number_row.text
    property alias meetingName: metting_name_text.text
    property alias meetingTime: metting_timer_text.text

    signal clickItemCell(var buttonItemId)

    Rectangle {

        id:history_cell_contentView
        color: 'white'
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin:5
        radius: 8

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: history_cell_contentView.color = '#F8F9FA'
            onExited: history_cell_contentView.color = 'white'
            onClicked: {
                console.log("detail meeting")
                clickItemCell("historylistCell")
            }
        }

        Text {
            id:meeting_number_row
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: metting_name_text.top
            anchors.bottomMargin: 5
            font.pixelSize: 11
            color: '#999999'
        }

        Text {
            id:metting_name_text
            anchors.left: meeting_number_row.left
            anchors.verticalCenter: parent.verticalCenter
            width: 230
            font.weight: Font.DemiBold
            font.pixelSize: 14
            color: '#333333'
            clip: true
        }

        Text {
            id:metting_timer_text
            anchors.left: meeting_number_row.left
            anchors.top: metting_name_text.bottom
            anchors.topMargin: 5
            font.pixelSize: 11
            color: '#999999'
        }

        FrtcButton {
            id: join_button
            width: 48
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -15
            anchors.right: parent.right
            anchors.rightMargin: 20
            buttonText: '加入'
            textFont: 11
            viewRadius: 4

            onMouseClicked: {
                console.log('join metting')
                clickItemCell("joinMeeting")
            }
        }

        FrtcButton {
            id: more_button
            width: join_button.width
            height: join_button.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 15
            anchors.right: parent.right
            anchors.rightMargin: 20
            backgroundColor: 'white'
            hoverColor: 'white'
            buttonText: '删除'
            textColor: '#222222'
            textFont: 11
            viewRadius: 4
            border.width: 1
            border.color: '#EEEFF0'

            onMouseClicked: {
                console.log('delete metting')
                clickItemCell("deleteMeetinng")
            }
        }
    }

}
