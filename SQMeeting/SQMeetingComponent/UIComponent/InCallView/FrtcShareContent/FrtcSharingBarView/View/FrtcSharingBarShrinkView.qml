import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp

import "./"

Rectangle {

    width: 220
    height: 40
    color: backgroundColor

    property int tabbaarButtonMarginWidth: 100

    property string backgroundColor: "gray"
    property var textColor: button_text.color


    Component.onCompleted: {}

    Connections {
        target: FMeetingWindowControllerObject; //created by function main().

        onCppSendMsgToQMLMeetingDuration: {
            button_text.text = dural
        }
    }

    //-------------------------------------------------
    // MouseArea.
    //-------------------------------------------------

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        enabled: true
        hoverEnabled: true


        onClicked: {
            FMeetingWindowControllerObject.onQmlShowStatisticsDialog()
        }

        onEntered: {
            id_sharingbar_window.showSharingBarExpandView()
        }

        onExited: {}

    }


    Image {
        id: button_image
        width: 20
        height: 20
        source: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_network_info@2x.png"
        fillMode: Image.PreserveAspectFit
        clip: true

        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 70
    }


    function setStrSharingContentCount(aStrSharingContentCount) {
        //strSharingContentCount = aStrSharingContentCount
    }

    Text {
        id: button_text
        //text: qsTr("button")
        text: "00:00" //strSharingContentCount
       // anchors.top: parent.top
        //anchors.topMargin: 4
       // anchors.horizontalCenter: button_image.horizontalCenter

        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 100
        color: textColor
        //font.bold: true
        font.pixelSize: 14
    }
} //end of 4.[UI][CallView] Tab bar.
