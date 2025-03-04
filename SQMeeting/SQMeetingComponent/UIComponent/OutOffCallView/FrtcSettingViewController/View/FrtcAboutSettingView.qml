import QtQuick 2.0
import QtQuick.Controls 2.14
import "./"

Item {
    id:aboutSettingView

    Rectangle{
        id:myRectangle
        x:155

        width: 640-170
        height: 480
        color: "#ffffff"

        Loader{
            id: eula_loader
            source: "FrtcEULATextWindow.qml"
            active: false
        }

        Image{
            id:about_image
            width: 108
            height: 108
            y: 100
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/Images/SettingView/icon-logo@2x.png"
            sourceSize: Qt.size(108, 108)
            cache: false
            clip: true
        }

        Text {
            id: version_number
            anchors.top: about_image.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("版本: 3.4.1")
            clip: true
            font.pixelSize: 14
            color: "#222222"
        }

        Button{
            id:homepage_link
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: version_number.bottom
            anchors.topMargin: 5
            font.pixelSize: 1
            text: "https://shenqi.internetware.cn"
            contentItem: Text {
                color: "#026ff5"
                text: homepage_link.text
                font.pixelSize: 14
                font.underline: true
            }
            background: Rectangle{
                color: "#ffffff"
                opacity: 0
            }
            onClicked: {
                onClicked: Qt.openUrlExternally("https://shenqi.internetware.cn")
            }
        }

        Button{
            id:github_link
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: homepage_link.bottom
            anchors.topMargin: 5
            font.pixelSize: 1
            text: "https://github.com/sqmeeting"
            contentItem: Text {
                color: "#026ff5"
                text: github_link.text
                font.pixelSize: 14
                font.underline: true
            }
            background: Rectangle{
                color: "#ffffff"
                opacity: 0
            }
            onClicked: {
                onClicked: Qt.openUrlExternally("https://github.com/sqmeeting")
            }
        }

        Button{
            id:service_link
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: appCopyright.top
            anchors.bottomMargin: 8
            font.pixelSize: 1
            text: "《服务协议》"
            contentItem: Text {
                color: "#026ff5"
                text: service_link.text
                font.pixelSize: 12
            }
            background: Rectangle{
                color: "#ffffff"
                opacity: 0
            }
            onClicked: {
                eula_loader.active = true;
            }
        }

        Text {
            id:appCopyright
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 28
            text: qsTr("@2023 北京神州数码品众科技有限公司")
            font.pixelSize: 12
            color: "#999999"
        }
    }
}
