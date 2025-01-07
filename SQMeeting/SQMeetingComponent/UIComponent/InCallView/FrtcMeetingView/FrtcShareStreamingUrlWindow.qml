import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import "./"
import "./../../CommonView/"

Window {
    id: share_streaming_url_window
    visible: true

    width: 348
    height: 256

    maximumWidth : width
    maximumHeight : height

    minimumWidth : width
    minimumHeight : height

    x: (screen.width - width)/2
    y: (screen.height - height)/2

    title: '分享会议直播'
    color: "#f8f9fa"
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    //property string linkUrl: "https://www.baidu.com"

    function setStreamingInfo(userName, meetingID, url, password) {
        console.log("[UI][FrtcInviteToJoinView.qml][setMeetingInfoData:]: userName: " + userName + ", meetingID: " + meetingID + ", url: " + url + ", password: " + password)
        share_invite_text.text = userName + '邀请您观看' + meetingID + '的会议直播'
        streaming_password.text = password
        hyperlinkLabel.linkUrl = url
    }

    Rectangle {
        id: white_background_view
        color: "#ffffff"

        anchors.top: parent.top
        anchors.topMargin: 20

        anchors.horizontalCenter: parent.horizontalCenter

        width: 316
        height: 172

        Text {
            id: share_invite_text
            width: 185
            height: 15

            anchors.top: parent.top
            anchors.topMargin: 12

            anchors.left: parent.left
            anchors.leftMargin: 16
            text: '亚飞3邀请您观看333的会议直播'
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            color: '#333333'
        }


        Text {
            id: streaming_url_text_field_tips
            width: 185
            height: 15

            anchors.top: share_invite_text.bottom
            anchors.topMargin: 20

            anchors.left: parent.left
            anchors.leftMargin: 16

            text: '请点击以下链接观看：'
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            color: "#333333"
        }

        Rectangle {
            id: hyperlinkLabel
            width: 300
            //height: 50

            anchors.top: streaming_url_text_field_tips.bottom
            anchors.topMargin: 12

            anchors.left: parent.left
            anchors.leftMargin: 16

            height: streaming_url_text.paintedHeight

            color: "transparent"

            property string linkUrl:''

            Text {
                id: streaming_url_text

                text: hyperlinkLabel.linkUrl
                color: "#026FFE"
                font.pixelSize: 14

                // 将 Text 对齐到左上角
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 0
                        width: parent.width  // 文本宽度与父级一致

                font.family: "System"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.openUrlExternally(hyperlinkLabel.linkUrl);
                }
            }
        }

        Text {
            id: streaming_password_tips
            width: 70
            height: 15

            anchors.top: hyperlinkLabel.bottom
            anchors.topMargin: 20

            anchors.left: parent.left
            anchors.leftMargin: 16
            text: '直播密码：'
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            color: "#333333"
        }

        Text {
            id: streaming_password
            width: 120
            height: 15

            anchors.top: hyperlinkLabel.bottom
            anchors.topMargin: 20

            anchors.left: streaming_password_tips.right
            anchors.leftMargin: 0
            text: '258345'
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            color: "#333333"
        }
    }

    Rectangle {
        id: cancelButton
        width: 154
        height: 32
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        anchors.left: parent.left
        anchors.leftMargin: 16

        color: Qt.rgba(220/255.0, 220/255.0, 235/255.0, 1.0)
        radius: 4

        Text {
            anchors.centerIn: parent
            text: '取消'
            font.pixelSize: 14
            color: Qt.rgba(0x24/255.0, 0x24/255.0, 0x25/255.0, 1.0)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                share_streaming_url_window.close()
            }
        }
    }

    Rectangle {
        id: recordButton
        width: 154
        height: 32
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        anchors.right: parent.right
        anchors.rightMargin: 16
        color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

        radius: 4

        Text {
            anchors.centerIn: parent
            text: '复制直播信息'
            font.pixelSize: 14
            color: 'white'
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                console.log("[UI][FrtcInviteToJoinView.qml][copy_meeting_info_button]")

                clipboard.setText(share_invite_text.text + '\n' + '\n' + streaming_url_text_field_tips.text + '\n' + '\n' + hyperlinkLabel.linkUrl + '\n'
                                  + '直播密码:' + streaming_password.text)
                //toast.show("会议信息已复制到剪切板")
                share_streaming_url_window.close()
            }

        }
    }

    FrtcToastView {
        id: toast
    }


}
