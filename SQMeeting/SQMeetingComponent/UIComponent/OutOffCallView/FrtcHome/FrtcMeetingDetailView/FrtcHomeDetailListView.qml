import QtQuick 2.15

Rectangle { 

    color: "white"
    property alias meetingTitle: meetingTitleText.text
    property alias meetingStartTime: meetingStartTimeText.text
    property alias meetingTime: meetingTimeText.text
    property alias meetingOwner: meetingOwnerText.text
    property alias meetingNumber: meetingnumberText.text
    property alias meetingPassword: meetingpasswordText.text

    Rectangle {
        id: meetingTitleView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 80
        clip: true

        Text {
            id: meetingTitleText
            color: "#222222"
            font.weight: Font.DemiBold
            font.pixelSize: 25
            anchors.centerIn: parent
            text: meetingTitle
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: parent.width - 5  // 限制宽度
        }
    }


    Rectangle {
        id: meetingTopLine
        color: "#EEEFF0"
        height: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: meetingTitleView.bottom
    }

    Rectangle {

        id:starttime_view
        height: 50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: meetingTopLine.bottom

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "#666666"
            text: qsTr("开始时间")
        }

        Text {
            id: meetingStartTimeText
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: meetingStartTime
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: "#EEEFF0"
            height: 1
        }
    }

    Rectangle {

        id:meetingtime_view
        height: starttime_view.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: starttime_view.bottom

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "#666666"
            text: qsTr("会议时长")
        }

        Text {
            id: meetingTimeText
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: meetingTime
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: "#EEEFF0"
            height: 1
        }
    }

    Rectangle {

        id:meetingOwner_view
        height: starttime_view.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: meetingtime_view.bottom

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "#666666"
            text: qsTr("发起人")
        }

        Text {
            id: meetingOwnerText
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: meetingSponsor
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: "#EEEFF0"
            height: 1
        }

    }

    Rectangle {

        id:meetingnumber_view
        height: starttime_view.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: meetingOwner_view.bottom

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "#666666"
            text: qsTr("会议号码")
        }

        Text {
            id: meetingnumberText
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: meetingNumber
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: "#EEEFF0"
            height: 1
        }
    }

    Rectangle {
        id:meetingpassword_view
        height: starttime_view.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: meetingnumber_view.bottom

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "#666666"
            text: qsTr("会议密码")
        }

        Text {
            id: meetingpasswordText
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            text: meetingPassword
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: "#EEEFF0"
            height: 1
        }
    }


}
