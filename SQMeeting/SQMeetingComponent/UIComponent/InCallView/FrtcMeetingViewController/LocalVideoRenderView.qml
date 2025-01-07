//
//  LocalVideoRenderView.qml
//  Rectangle LocalVideoRenderView.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2023/03/13.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick
import QtQuick.Window
import QtQuick.Controls

//for receied remote video render.
import VideoRenderObject 1.0 //class VideoRender

import QtMultimedia



Rectangle {
    id: id_local_video_render_view
    width: 0 //100
    height: 0 //100
    radius: 10
    //color: "#004696"
    color: "black" // "gray"
    //visible: false
    
    //border.width: 2  //borderWidth
    //border.color: "green" //borderColor

    property string type : "videoView"
    property var viewInfo
    property var dataSourceID
    property var strDisplayName
    property var uuid
    property var eVideoType
    property var removed
    property var active
    property var maxResolution
    property var pin
    //for active speaker appearance.
    property int borderWidth: 0; //2
    property string borderColor: "black";
    property bool isActiveSpeaker: false;
    

    //========================================
    // for QML life cycle.
    //========================================

    Component.onDestruction: {
        ////console.log("[LocalVideoRenderView.qml][id_local_video_render_view][Component.onDestruction:]");
        //clear all windows and views.

    }

    //========================================
    // functions.
    //========================================

    //[SVCLayout.qml] set videoViewInfo.dataSourceID = aVideoInfo.dataSourceID, then -> onDataSourceIDChanged().
    onDataSourceIDChanged: {
        ////console.log("[LocalVideoRenderView.qml][onDataSourceIDChanged]: now id_local_video_render_view.dataSourceID: " , id_local_video_render_view.dataSourceID);
        ////console.log("[LocalVideoRenderView.qml][onDataSourceIDChanged]: set provider_videoview.videoUrl = dataSourceID : " , dataSourceID);
        provider_videoview.videoUrl = dataSourceID;
    }
    
//    onStrDisplayNameChanged: {
//        ////console.log("[LocalVideoRenderView.qml][onStrDisplayNameChanged]: set nameLabel.text = strDisplayName : " , strDisplayName);
//        nameLabel.text = strDisplayName;
//    }

    function setDisplayName(aDisplayName) {
        ////console.log("[LocalVideoRenderView.qml][setDisplayName]: set nameLabel.text = strDisplayName : " , aDisplayName);
        nameLabel.text = aDisplayName;
    }

    function setVideoMuteImage(aDataSourceID) {
        //console.log("[LocalVideoRenderView.qml][setVideoMuteImage]: -> call provider_videoview.setRenderSourceID(aDataSourceID: " + aDataSourceID + ")");
        if (-1 !== aDataSourceID.indexOf("VPL_PREVIEW")) {
            //console.log("[LocalVideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", is local camera video.");
            muteImageView.source = "qrc:/Images/frtc_sdk_bundle_images/local_preview_off.png"
        } else if (-1 !== aDataSourceID.indexOf("VCR-")) {
            ////console.log("[LocalVideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", include C_R, is remote content video.")
        } else { //remote video
            ////console.log("[LocalVideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", is remote people video.");
            muteImageView.source = "qrc:/Image/frtc_sdk_bundle_images/call_camera_off.png"
        }
    }

    function setRenderSourceID(aDataSourceID) {
        //console.log("[LocalVideoRenderView.qml][setRenderSourceID]: -> call provider_videoview.setRenderSourceID(aDataSourceID: " + aDataSourceID + ")");
        provider_videoview.setRenderSourceID(aDataSourceID);
        id_local_video_render_view.dataSourceID = aDataSourceID;
        //provider_videoview.videoUrl = aDataSourceID;

        setVideoMuteImage(aDataSourceID)
    }
    
    function clearRenderSourceID() {
        ////console.log("[VideoRenderView.qml][setRenderSourceID]: -> call provider_videoview.setRenderSourceID(' '), set id_videoview.dataSourceID = ' ', ");
        //provider_videoview.setRenderSourceID("")
        //id_local_video_render_view.dataSourceID = ""

        provider_videoview.videoUrl = ""
    }

    function setFrameSize() {
        //console.log("[LocalVideoRenderView.qml][startRendering]: -> call provider_videoview.setFrameSize(" + x + ", " + y + ", " + width + ", " + height + ", " + "), current dataSourceID: " , dataSourceID);
        provider_videoview.setFrameSize(x, y, width, height);
    }
    
    function startRendering() {
        //console.log("[LocalVideoRenderView.qml][startRendering]: -> call provider_videoview.startRendering(), current dataSourceID: " , dataSourceID);
        //clearRenderSourceID()
        //setRenderSourceID("_VPL_PREVIEW")
        provider_videoview.startRendering();
    }

    function stopRendering() {
        ////console.log("[LocalVideoRenderView.qml][stopRendering]: -> call provider_videoview.stopRendering(), current dataSourceID: " , dataSourceID);
        provider_videoview.stopRendering();
        clearRenderSourceID()
    }

    function renderMuteImage(mute) {
        //console.log("[LocalVideoRenderView.qml][renderMuteImage]: -> call provider_videoview.renderMuteImage(mute: " + mute + "), dataSourceID: " + dataSourceID);
        //provider_videoview.renderMuteImage(mute);
        
        if (true === mute) {
            //console.log("[LocalVideoRenderView.qml][renderMuteImage]: true === mute");
            //console.log("[LocalVideoRenderView.qml][renderMuteImage]: -> muteImageView.visible = true");
            
            if (-1 !== dataSourceID.indexOf("VPL_PREVIEW")) {
                //console.log("[LocalVideoRenderView.qml][renderMuteImage]: -> set muteImageView.visible = true, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                muteImageView.visible = true;
                //nameLabel.visible = true;
            }
        } else {
            //console.log("[LocalVideoRenderView.qml][renderMuteImage]: -> set muteImageView.visible = false, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
            //nameLabel.visible = false;
            //muteImageView.visible = false
            //console.log("[LocalVideoRenderView.qml][renderMuteImage]: -> call id_delay_hide_mute_view_timer.start()")
            id_delay_hide_mute_view_timer.start()
        }
         
    }
    
    function setVisible(visible) {
        id_local_video_render_view.visible = visible;
        
        if (false === visible) {
            //console.log("[LocalVideoRenderView.qml][setVisible]: false === visible -> set id_local_video_render_view [width, height] = [0,0,0,0], dataSourceID : " + dataSourceID);
            id_local_video_render_view.x = 0;
            id_local_video_render_view.y = 0;
            id_local_video_render_view.width = 0;
            id_local_video_render_view.height = 0;
        }
    }

    function showVideoview(aShow) {
        ////console.log("[LocalVideoRenderView.qml][showVideoview()]: aShow: " + aShow?"true":"false" + ", id_local_video_render_view.dataSourceID: " + id_local_video_render_view.dataSourceID);
        if (true === aShow) {
            id_local_video_render_view.opacity = 1
        } else {
            id_local_video_render_view.opacity = 0
        }
    }


    function setAppearanceWithActive(isActiveSpeaker) {
        ////console.log("[LocalVideoRenderView.qml][setVisible]: -> call id_activespeaker_appearance.setAppearanceWithActive(isActiveSpeaker: " + isActiveSpeaker + "), dataSourceID : " + dataSourceID);
        id_local_video_render_view.isActiveSpeaker = isActiveSpeaker;
        id_activespeaker_appearance.setAppearanceWithActive(isActiveSpeaker);
    }
    
    //========== ========== ==========

    property int timerCounter: 0
    property int timerDuration: 2

    Timer {
        id: id_delay_hide_mute_view_timer
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            ////console.log("[LocalVideoRenderView.qml][Timer][onTriggered:]: -> set muteImageView.visible = false")
            muteImageView.visible = false
        }
    }
    
    //========== ========== ==========
    
    VideoRenderObject {
       id: provider_videoview
       //videoUrl: "rtsp://xxx.xxx.xxx/channel=0"
       videoUrl: "" //dataSourceID //"call-1_6"
       videoSink: id_video_output.videoSink

       //onCppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage: { }
    }

    VideoOutput {
        id: id_video_output
        //source: provider_videoview
        
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        
    }

    Text {
        id: nameLabel;
        text: "";
        font.pixelSize: 20;
        x: 0;
        y: parent.height - 30;
        color: "white"
    }
    
    Image {
        id: muteImageView
        anchors.fill: parent

        source: "qrc:/Images/frtc_sdk_bundle_images/local_preview_off.png"
    }

    //for active speaker.
    Rectangle {
        id: id_activespeaker_appearance;
        color: "#00000000" //为窗口透明
        visible: false;
        border.width: 0; //root.borderWidth
        border.color: "black"; //root.borderColor

        anchors.fill: parent
        
        function setAppearanceWithActive(isActiveSpeaker) {
            if (false === isActiveSpeaker) {
                ////console.log("[LocalVideoRenderView.qml][setAppearanceWithActive]: false === isActiveSpeaker -> set border.width = 0, border.color  = black, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                visible = false;
                border.width = 0;
                border.color = "black";
            } else {
                ////console.log("[LocalVideoRenderView.qml][setAppearanceWithActive]: true === isActiveSpeaker -> set border.width = 2, border.color  = green, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                visible = true;
                border.width = 4;
                border.color = "#1ADC5D" //"green";
            }
        }
    }

    //========== ========== ==========

}
