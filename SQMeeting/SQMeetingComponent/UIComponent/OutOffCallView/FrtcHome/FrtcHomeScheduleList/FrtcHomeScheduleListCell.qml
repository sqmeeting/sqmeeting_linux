import QtQuick 2.15
import QtQuick.Controls
import '../../../CommonView'

Rectangle {

    id: schedule_list_Cell

    property bool isShowPopmenu: true
    property alias meetingNumber: metting_number_text.text
    property alias meetingName: metting_name_text.text
    property alias meetingTimer: metting_timer_text.text
    property alias isShowInvited: invited_meeting_image.visible
    property alias isShowRecurrence: recurrence_metting.visible
    property alias meetingStateText: metting_state_text.text
    property alias meetingStateTextColor: metting_state_text.color

    property bool meetingOwner

    signal clickedCell(var itemId)

    Rectangle {

        id:schedule_cell_contentView
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
            onEntered: schedule_cell_contentView.color = '#F8F9FA'
            onExited: schedule_cell_contentView.color = 'white'
            onClicked: {
                if (!more_button.containsMouse) {
                    clickedCell("schedulelistCell")
                }
            }
        }

        Row {
            id:meeting_number_row
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: metting_name_text.top
            anchors.bottomMargin: 5
            spacing: 5

            Text {
                id:metting_number_text
                anchors.verticalCenter: parent.verticalCenter
                text: meetingNumber
                font.pixelSize: 11
                color: '#999999'
            }

            Image {
                id:invited_meeting_image
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/Images/Home/frtc_schedule_invite.png"
                visible: isShowInvited
            }

            Rectangle {
                id:recurrence_metting
                anchors.verticalCenter: parent.verticalCenter
                color: 'green'
                height: 20
                width: 30
                radius: 4
                visible: isShowRecurrence
                Text {
                    anchors.centerIn: parent
                    text: qsTr('周期')
                    color: 'white'
                    font.pixelSize: 11
                }
            }
        }

        Text {
            id:metting_name_text
            anchors.left: meeting_number_row.left
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            text: meetingName
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: '#333333'
            clip: true
        }

        Text {
            id:metting_timer_text
            anchors.left: meeting_number_row.left
            anchors.top: metting_name_text.bottom
            anchors.topMargin: 5
            text: meetingTimer
            font.pixelSize: 11
            color: '#999999'
        }

        Text {
            id:metting_state_text
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: join_button.left
            anchors.rightMargin: 10
            text: meetingStateText
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: 'green'
        }

        FrtcButton {
            id: join_button
            width: 48
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: meetingOwner ? -15 : 0
            anchors.right: parent.right
            anchors.rightMargin: 20
            buttonText: qsTr('加入')
            textFont: 11
            viewRadius: 4

            onMouseClicked: {
                clickedCell("joinMeeting")
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
            buttonText: '···'
            textColor: '#222222'
            textFont: 8
            viewRadius: 4
            border.width: 1
            border.color: '#EEEFF0'
            visible: meetingOwner

            onMouseClicked: {
                moreMenu.toggleVisibility()
            }
        }

        Popup {
            id: moreMenu
            y: more_button.height + more_button.y + 15
            x: more_button.x + more_button.width - width + 17
            width: 80
            height: contentList.count * 30 + 8
            padding: 4
            opacity: visible ? 1 : 0
            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            }
            exit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
            }
            background: FrtcPopupTriangleView{}

            contentItem: ListView {
                id: contentList
                width: parent.width
                height: parent.height
                model: ListModel {
                    ListElement { text: "复制邀请"; itemId: "copyInvite" }
                    ListElement { text: "修改会议"; itemId: "modifyMeeting" }
                    ListElement { text: "取消会议"; itemId: "cancelMeeting" }
                }

                delegate: Item {
                    width: parent.width
                    height: 30
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: mouseArea.containsMouse ? "#EEE" : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: model.text
                            color: (model.index === contentList.model.count - 1) ? "red" : "#222222"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                moreMenu.restoreState()
                                clickedCell(model.itemId)
                            }
                        }
                    }

                }

                Component.onCompleted: {
                    if (isShowRecurrence) {
                        addItem()
                    }
                }

                function addItem() {
                    model.insert(1, { text: "查看周期会议", itemId: "viewRecurrenceMeeting"})
                }

            }

            function toggleVisibility() {
                visible = !visible
            }

            function restoreState() {
                visible = false
            }
        }
    }

}
