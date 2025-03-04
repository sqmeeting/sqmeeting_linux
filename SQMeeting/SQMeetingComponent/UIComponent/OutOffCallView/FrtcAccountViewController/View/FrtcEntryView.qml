import QtQuick 2.15
import QtQuick.Controls 2.15

import "./../../../CommonView/"

Rectangle {

    id: main_window_bgview
    width: parent.width
    height: parent.height
    color: 'transparent'
    anchors.centerIn: parent

    signal clickJoinMeeting()
    signal clickLoginButton()

    Image {
        id:app_logo_icon
        width: 100
        height: 100
        source: "qrc:/Images/MainView/icon-logo.png"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id:app_name
        text: qsTr("神旗")
        font.pixelSize: 18
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: app_logo_icon.bottom
        anchors.topMargin: 10
    }

    FrtcButton {
        id: join_meeting_btn
        width: 240
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: app_name.bottom
        anchors.topMargin: 60
        textColor: 'white'
        buttonText: qsTr('加入会议')
        onMouseClicked: {
            console.log(join_meeting_btn.buttonText)
            clickJoinMeeting()
        }
    }

    FrtcButton {
        id: login_btn
        width: join_meeting_btn.width
        height: join_meeting_btn.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: join_meeting_btn.bottom
        anchors.topMargin: 15

        textColor: '#222222'
        backgroundColor: 'white'
        hoverColor: '#cae1ff'
        buttonText: qsTr('登录')

        border.color: '#666666'
        border.width: 1

        onMouseClicked: {
            console.log(login_btn.buttonText)
            clickLoginButton()
        }

    }

    Text {
        id: version_text
        text: '3.4.1'
        color: '#666666'

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
    }

}
