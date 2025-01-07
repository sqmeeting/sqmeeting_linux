import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


import "./" // for SVCLayout.qml.

Rectangle {
    x: 0
    y: 0
    z: 0;

    //anchors.top: rectangle_menu_bar.bottom
    anchors.top: parent.top
    anchors.topMargin: 0; //40
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 0

    color: "black"
    //color: "green"

    signal signalShowLocalPreview(var aShow)

    //========================================
    // for QML life cycle.
    //========================================

    Component.onCompleted: {
//           console.log("[FMeetingVideoView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: ");
        /*
        let childs = rectangle_main_view.children;
        for (let i = 0; i < childs.length; ++i) {
            console.log("[FMeetingVideoView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: child UI: rectangle_main_view Component.onCompleted:");
        }
        */
        //console.log("[FMeetingVideoView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views]: signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())");
        //signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())
    }

    Component.onDestruction: {
        //console.log("[SVCLayout.qml][svc_layout_view][Component.onDestruction:]");
        //clear all windows and views.

    }

    function showLocalPreview(aShow) {
        //remote_video_svclayout_views.signalShowLocalPreview(aShow)

        console.log("[FMeetingVideoView.qml][showLocalPreview][Rectangle id: rectangle_main_view]: -> call remote_video_svclayout_views.showLocalPreview(aShow: " + aShow + ")");
        remote_video_svclayout_views.showLocalPreview(aShow)
    }

    function localVideoMute(mute) {
        console.log("[FMeetingVideoView.qml][localVideoMute]: mute: " + mute?"true":"false");
        remote_video_svclayout_views.localVideoMute(mute);
    }

    function dealwithRecvMsgPrepareSVCLayout(mode, value) {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgPrepareSVCLayout]: mode: " + mode + ", value: " + value);
        remote_video_svclayout_views.dealwithRecvMsgPrepareSVCLayout(mode, value)
    }

    function dealwithRecvMsgRemoteViewHiddenOrNot(value) {
        console.log("[FMeetingView.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: value: " + value);
        remote_video_svclayout_views.dealwithRecvMsgRemoteViewHiddenOrNot(value)
    }

    function dealwithRecvMsgRefreshLayoutMode(mode, value) {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgRefreshLayoutMode]: mode: " + mode + ", value: " + value);
        remote_video_svclayout_views.dealwithRecvMsgRefreshLayoutMode(mode, value)
    }

    function dealwithRecvMsgLayoutRemoteView(arg1, arg2) {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgLayoutRemoteView]: arg1: " + arg1 + ", arg2: " + arg2);
        remote_video_svclayout_views.dealwithRecvMsgLayoutRemoteView(arg1, arg2)
    }

    function dealwithRecvMsgRemoteVideoReceived(arg) {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgRemoteVideoReceived]: arg: " + arg);
        remote_video_svclayout_views.dealwithRecvMsgRemoteVideoReceived(arg)
    }

    function dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute) {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgRemoteContentVideoViewRenderMuteImage]: mute: " + mute);
        remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute)
    }

    function dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden) {
        remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden)
    }

    function dealwithRecvMsgRemoteContentVideoViewStartRendering() {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgRemoteContentVideoViewStartRendering]");
        remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStartRendering()
    }

    function dealwithRecvMsgRemoteContentVideoViewStopRendering() {
        console.log("[FMeetingVideoView.qml][dealwithRecvMsgRemoteContentVideoViewStopRendering]");
        remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStopRendering()
    }


    SVCLayout {
        id: remote_video_svclayout_views

        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: 0; //10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 0
    }

} // end of 3.[UI] Video.

//}
