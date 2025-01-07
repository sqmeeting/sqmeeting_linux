import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

Window {
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    width: currentWindowWidth
    height: currentWindowHeight


    maximumWidth  : currentWindowWidth
    maximumHeight : currentWindowHeight
    minimumWidth  : currentWindowWidth
    minimumHeight : currentWindowHeight

    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    visible: false
    color: "#FFFFFF"
    title: "选择共享内容"

    property int lineHeight: 1

    property var screenWidth: Screen.width //640
    property var screenHeight: Screen.height //480

    property var currentWindowWidth: ux_design_width
    property var currentWindowHeight: ux_design_height

    property var screen_ratio: 1

    property var ux_design_width: 680
    property var ux_design_height: 464 //374


    property int contentItemTopMargin: 16
    property int contentItemLeftMargin: 12


    Component.onCompleted: {
        screen_ratio = screenRatio()
        currentScreenSize()
    }

    function screenRatio() {
        screenWidth = Screen.width;
        screenHeight = Screen.height;
        if (screenHeight >= 1200) {
            return 1.2;
        } else if (screenHeight >= 1000 && screenHeight< 1200) {
            return 1.0;
        } else if (screenHeight >= 800 && screenHeight < 1000) {
            return 0.8;
        } else {
            return 0.64;
        }
    }

    function currentScreenSize() {
        currentWindowWidth = ux_design_width * screen_ratio
        currentWindowHeight = ux_design_height * screen_ratio
    }

    Rectangle{
        id: top_line_view
        y: 0
        color: "#e2e2e2"
        height: lineHeight // 0.5
        width: parent.width
    }

    Rectangle {
        id: id_collection_select_view

        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12

        color: "green"

        border.width: 1
        border.color: "#B6B6B6"

        ContentSelectItem {
            id: content_select_item_desktop_1
            
            anchors.top: parent.top
            anchors.topMargin: contentItemTopMargin
            anchors.left: parent.left
            anchors.leftMargin: contentItemLeftMargin

            isStateChangeButton: true

            btn_txt_unselected: "桌面 1" //qsTr("button")
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_unmute@2x.png"
            btn_txt_selected: "桌面 1"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_mute@2x.png"

            onMouseClicked: {}


        } //end of ContentSelectItem

    }

    //----------------------------------------



    //----------------------------------------

    Rectangle {
        id: id_start_share_content_button

        width: 158
        height: 34

        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        radius: 4
        color: "#026ffe"

        Text {
            id: cancelLable
            anchors.centerIn: parent
            text: qsTr("开始共享")
            font.pixelSize: 14
            color: "white"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: {
                console.log("[UI][FrtcShareContentSelectWindow QML][id_start_share_content_button][onClicked:] press id_start_share_content_button button:-> call root.onQmlStartShareScreen()");
                root.onQmlStartShareScreen()
            }

            onEntered: {
                id_start_share_content_button.color = "#1f80ff"
            }

            onExited: {
                id_start_share_content_button.color = "#026ffe"
            }
        }
    }

    Rectangle {
        id: bottom_line_view
        y: 0
        color: "#e2e2e2"
        height: lineHeight // 0.5
        width: parent.width

        anchors.top: id_start_share_content_button.top
        anchors.topMargin: -8
    }

}

