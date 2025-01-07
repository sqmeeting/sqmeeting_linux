//
//  FMeetingView.qml
//  class FMeetingView.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2023/01/30.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


import "./" // for SVCLayout.qml.



//import model which has been registed.
//import com.frtc.FMeetingViewControllerObject 1.0 //class FMeetingViewController.cpp

//for TabButtons.
//import FrtcCallBarViewObject 1.0 //class FrtcCallBarView.cpp


//Window {


//========================================
// 3.[UI] Video
//========================================

//----------------------------------------
// 3.1.[UI] Local people Video
//----------------------------------------


//----------------------------------------
// 3.2.[UI] Remote Content Video
//----------------------------------------


//----------------------------------------
// 3.3.[UI] Remote people Video
//----------------------------------------

//16:9
//[macOS version]: [3070/2, 1710/2] = [1538, 865]
Rectangle {
    //id: rectangle_main_view
    x: 0
    y: 0 //60 //91
    //width: 1538
    //height: 865 //1042 //865
    z: 0;

    //anchors.top: rectangle_menu_bar.bottom
    anchors.top: parent.top
    anchors.topMargin: 0; //40
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 0

//        gradient: Gradient {
//            GradientStop {
//                position: 0
//                color: "#0000ff"
//            }
//            GradientStop {
//                position: 1
//                color: "#ffffff"
//            }
//        }

    //border.color: "#060606"
    color: "black"
    //color: "green"


        signal signalShowLocalPreview(var aShow)

        function showLocalPreview(aShow) {
            //remote_video_svclayout_views.signalShowLocalPreview(aShow)

            console.log("[FMeetingView.qml][showLocalPreview][Rectangle id: rectangle_main_view]: -> call remote_video_svclayout_views.showLocalPreview(aShow: " + aShow + ")");
            remote_video_svclayout_views.showLocalPreview(aShow)
        }


        Component.onCompleted: {
 //           console.log("[FMeetingView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: ");
            /*
            let childs = rectangle_main_view.children;
            for (let i = 0; i < childs.length; ++i) {
                console.log("[FMeetingView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: child UI: rectangle_main_view Component.onCompleted:");
            }
            */
            //console.log("[FMeetingView.qml][Component.onCompleted:][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views]: signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())");
            //signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())
        }
        
        function localVideoMute(mute) {
            console.log("[FMeetingView.qml][localVideoMute]: mute: " + mute?"true":"false");
            remote_video_svclayout_views.localVideoMute(mute);
        }

        function dealwithRecvMsgPrepareSVCLayout(mode, value) {
            console.log("[FMeetingView.qml][dealwithRecvMsgPrepareSVCLayout]: mode: " + mode + ", value: " + value);
            remote_video_svclayout_views.dealwithRecvMsgPrepareSVCLayout(mode, value)
        }

        function dealwithRecvMsgRemoteViewHiddenOrNot(value) {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: value: " + value);
            remote_video_svclayout_views.dealwithRecvMsgRemoteViewHiddenOrNot(value)
        }

        function dealwithRecvMsgRefreshLayoutMode(mode, value) {
            console.log("[FMeetingView.qml][dealwithRecvMsgRefreshLayoutMode]: mode: " + mode + ", value: " + value);
            remote_video_svclayout_views.dealwithRecvMsgRefreshLayoutMode(mode, value)
        }

        function dealwithRecvMsgLayoutRemoteView(arg1, arg2) {
            console.log("[FMeetingView.qml][dealwithRecvMsgLayoutRemoteView]: arg1: " + arg1 + ", arg2: " + arg2);
            remote_video_svclayout_views.dealwithRecvMsgLayoutRemoteView(arg1, arg2)
        }

        function dealwithRecvMsgRemoteVideoReceived(arg) {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteVideoReceived]: arg: " + arg);
            remote_video_svclayout_views.dealwithRecvMsgRemoteVideoReceived(arg)
        }

        function dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute) {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteContentVideoViewRenderMuteImage]: mute: " + mute);
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute)
        }

        function dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden) {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteContentVideoViewSetHidden]: hidden: " + hidden);
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden)
        }

        function dealwithRecvMsgRemoteContentVideoViewStartRendering() {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteContentVideoViewStartRendering]");
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStartRendering()
        }

        function dealwithRecvMsgRemoteContentVideoViewStopRendering() {
            console.log("[FMeetingView.qml][dealwithRecvMsgRemoteContentVideoViewStopRendering]");
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStopRendering()
        }


        SVCLayout {
            id: remote_video_svclayout_views
            //x: 200
            //y: 200
            //color: "yellow"

            width: parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 0; //10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0
            
//            Component.onCompleted: {
//                console.log("[FMeetingViewController.qml][Component.onCompleted:][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views]: ");
//                /*
//                let childs = remote_video_svclayout_views.children;
//                for (let i = 0; i < childs.length; ++i) {
//                    console.log("[FMeetingViewController.qml][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views][Component.onCompleted:]: sub compolent ");
//                }
//                */
//            }
        }

} // end of 3.[UI] Video.

//}
