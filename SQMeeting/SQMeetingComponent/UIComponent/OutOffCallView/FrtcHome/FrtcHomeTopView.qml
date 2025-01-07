import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15
import '../../CommonView'

Rectangle {
    id:home_top_view
    width: parent.width
    height: 200
    anchors.top: parent.top
    color: 'white'

    property var meeting_rooms

    signal clickSetting()
    signal clickPersonNumber()
    signal clickInstallMetting()
    signal clickJoinMetting()
    signal clickScheduleMetting()

    Row {
        id:top_left_image
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 30

        Image {
            id: home_top_icon
            source: "qrc:/Images/MainView/frtc_login_icon@2x.png"
        }

        Text {
            anchors.verticalCenter: home_top_icon.verticalCenter
            text: qsTr(' 神旗')
            color: '#222222'
            font.weight: Font.DemiBold
            font.pixelSize:  17
        }
    }

    Button {
        id:hone_top_setting
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: top_left_image.verticalCenter
        icon.source: 'qrc:/Images/MainView/icon-setting.png'
        icon.color: "transparent"

        background: Rectangle {
            border.width: 0
        }

        onClicked: {
            console.log('click setting')
            clickSetting()
        }
    }

    FrtcCustomButton {
        id:home_top_install_metting
        width: 60
        height: 85
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: top_left_image.bottom
        anchors.topMargin: 20
        layout: 'topToBottom'
        hoverColor: 'white'
        imageSource: 'qrc:/Images/Home/frtc_home_install_metting@2x.png'
        textContent: qsTr('即时会议')
        onClicked: {
            console.log('click install meeting')
            clickInstallMetting()
        }
    }

    Rectangle {
        id:home_top_personNumber
        width: 14
        height: 14
        anchors.left: home_top_install_metting.right
        anchors.bottom: home_top_install_metting.bottom
        anchors.bottomMargin: 5

        Image {
            source: 'qrc:/Images/Home/frtc_home_drop_down.png'
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: {
                console.log("[UI][FrtcCallView.qml] press canclebutton button")
                clickPersonNumber()
            }

            onEntered: {
                home_top_personNumber.color = "#F0F0F5"

            }

            onExited: {
                home_top_personNumber.color = "#F0F0F5"
            }
        }
    }

    FrtcCustomButton {
        id:home_top_join_metting
        width: home_top_install_metting.width
        height: home_top_install_metting.height
        anchors.top: home_top_install_metting.top
        anchors.horizontalCenter: parent.horizontalCenter
        layout: home_top_install_metting.layout
        hoverColor: 'white'
        imageSource: 'qrc:/Images/Home/frtc_home_join_metting@2x.png'
        textContent: qsTr('加入会议')
        onClicked: {
            console.log('click join meeting')
            clickJoinMetting()
        }
    }

    FrtcCustomButton {
        id:home_top_schedule_metting
        width: home_top_install_metting.width
        height: home_top_install_metting.height
        anchors.top: home_top_install_metting.top
        anchors.right: parent.right
        anchors.rightMargin: 20
        layout: home_top_install_metting.layout
        //isEnable: false
        hoverColor: 'white'
        imageSource: 'qrc:/Images/Home/frtc_home_schedule_metting@2x.png'
        textContent: qsTr('预约会议')
        onClicked: {
            console.log('click schedule meeting')
            clickScheduleMetting()
        }
    }

    Rectangle {
        id:top_line_view
        height: 8
        anchors.bottom: parent.bottom

        anchors.right: parent.right
        anchors.left: parent.left
        color: '#F8F9FA'
    }
}

