import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Sharing Bar View: will automatically hide after 5 seconds.
//========================================

import "./"

Rectangle {
    id: expand_view
    height: 40 + 100

    anchors.top: parent.bottom
    anchors.topMargin: - height + 40
    anchors.margins: 0

    property int tabbaarButtonMarginWidth: 14

    property bool meetingOwner:false
    property bool authority:false

    width: (meetingOwner || authority) ? 650 : 458

    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    Component.onCompleted: {
        console.log("[FrtcSharingBarExpandView.qml][rectangle_tab_bar][Component.onCompleted:]: tabbar_audio_mute, set state = UNSELECTED");
        //tabbar_audio_mute_button.state = "UNSELECTED";
        //tabbar_camera_mute_button.state = "UNSELECTED";

        //console.log("[FrtcSharingBarExpandView.qml][rectangle_tab_bar][Component.onCompleted:]: -> call setLocalPreviewEnable(false)");
        //setLocalPreviewEnable(false)
    }

    function setMicMute(mute) {
        if (mute) {
            tabbar_audio_mute_button.state = "SELECTED"
        } else {
            tabbar_audio_mute_button.state = "UNSELECTED"
        }
    }

    function setCameraMute(mute) {
        if (mute) {
            tabbar_camera_mute_button.state = "SELECTED"
        } else {
            tabbar_camera_mute_button.state = "UNSELECTED"
        }
    }

    function setStrSharingContentCount(aStrSharingContentCount) {
        id_sharing_bar_shrink_view_of_expand_view.strSharingContentCount = aStrSharingContentCount
    }

    FrtcSharingBarShrinkView {
        id: id_sharing_bar_shrink_view_of_expand_view // rectangle_tab_bar

        width: 220
        height: 40

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0

        z: 4; //keep on the top order.

        textColor: "#333333"
        visible: true

        Component.onCompleted: {
            backgroundColor = "#00000000"
        }
    }

    FrtcSharingBarButtonsView {
        id: id_sharing_bar_buttons_view // rectangle_tab_bar
        authority: expand_view.authority
        meetingOwner: expand_view.meetingOwner

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: id_sharing_bar_shrink_view_of_expand_view.bottom
        anchors.topMargin: 0

        z: 4; //keep on the top order.
        visible: true

    }

}
