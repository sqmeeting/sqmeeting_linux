//
//  VideoRenderView.qml
//  Rectangle VideoView.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2022/10/16.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick
import QtQuick.Window
import QtQuick.Controls

//for receied remote video render.
import VideoRenderObject 1.0 //class VideoRender

import QtMultimedia



Rectangle {
    id: id_videoview;
    width: 0 //100
    height: 0 //100
    radius: 10
    //color: "#004696"
    color: "black" // "gray"
    //visible: false
    
    //border.width: 2  //borderWidth
    //border.color: "green" //borderColor

    property var type : "videoView"
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
    property var borderWidth: 0; //2
    property var borderColor: "black";
    property var isActiveSpeaker: false;
    
    property url videoMuteImageSource: muteImageView.source;


    //[SVCLayout.qml] set videoViewInfo.dataSourceID = aVideoInfo.dataSourceID, then -> onDataSourceIDChanged().
    onDataSourceIDChanged: {
        console.log("[VideoRenderView.qml][onDataSourceIDChanged]: now id_videoview.dataSourceID: " , id_videoview.dataSourceID);
        console.log("[VideoRenderView.qml][onDataSourceIDChanged]: set provider_videoview.videoUrl = dataSourceID : " , dataSourceID);
        provider_videoview.videoUrl = dataSourceID;
    }
    
    onStrDisplayNameChanged: {
        console.log("[VideoRenderView.qml][onStrDisplayNameChanged]: set nameLabel.text = strDisplayName : " , strDisplayName);
        nameLabel.text = strDisplayName;
    }

    function setVideoMuteImage(aDataSourceID) {
        console.log("[VideoRenderView.qml][setVideoMuteImage]: -> call provider_videoview.setRenderSourceID(aDataSourceID: " + aDataSourceID + ")");
        if (-1 !== aDataSourceID.indexOf("_VPL_PREVIEW")) {
            console.log("[VideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", is local camera video.");
            muteImageView.source = "qrc:/frtc_sdk_dist/frtc_sdk_bundle_images/local_preview_off.png"
        } else if (-1 !== aDataSourceID.indexOf("C_R")) {
            console.log("[VideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", include C_R, is remote content video.")
            //videoMuteImageSource = "qrc:/frtc_sdk_dist/frtc_sdk_bundle_images/bg-camera-off.png"
        } else {
            console.log("[VideoRenderView.qml][setVideoMuteImage]: aDataSourceID: " + aDataSourceID + ", is remote people video.");
            muteImageView.source = "qrc:/frtc_sdk_dist/frtc_sdk_bundle_images/bg-camera-off.png"
        }
    }

    function setRenderSourceID(aDataSourceID) {
        console.log("[VideoRenderView.qml][setRenderSourceID]: -> call provider_videoview.setRenderSourceID(aDataSourceID: " + aDataSourceID + ")");
        provider_videoview.setRenderSourceID(aDataSourceID);
        id_videoview.dataSourceID = aDataSourceID;
        //provider_videoview.videoUrl = aDataSourceID;

        setVideoMuteImage(aDataSourceID)
    }
    
    function setFrameSize() {
        console.log("[VideoRenderView.qml][startRendering]: -> call provider_videoview.setFrameSize(" + x + ", " + y + ", " + width + ", " + height + ", " + "), current dataSourceID: " , dataSourceID);
        provider_videoview.setFrameSize(x, y, width, height);
    }
    
    function startRendering() {
        console.log("[VideoRenderView.qml][startRendering]: -> call provider_videoview.startRendering(), current dataSourceID: " , dataSourceID);
        provider_videoview.startRendering();
    }

    function stopRendering() {
        console.log("[VideoRenderView.qml][stopRendering]: -> call provider_videoview.stopRendering(), current dataSourceID: " , dataSourceID);
        provider_videoview.stopRendering();
    }

    function renderMuteImage(mute) {
        console.log("[VideoRenderView.qml][renderMuteImage]: -> call provider_videoview.renderMuteImage(mute: " + mute + "), dataSourceID: " + dataSourceID);
        //provider_videoview.renderMuteImage(mute);
        
        if (true === mute) {
            console.log("[VideoRenderView.qml][renderMuteImage]: true === mute");
            console.log("[VideoRenderView.qml][renderMuteImage]: -> muteImageView.visible = true");
            muteImageView.visible = true; //self.muteImageView.hidden = NO;
            
            if (-1 !== dataSourceID.indexOf("VPL_PREVIEW")) {
                console.log("[VideoRenderView.qml][renderMuteImage]: -> set muteImageView.visible = true, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                muteImageView.visible = true; //self.muteImageView.hidden     = NO;
                //nameLabel.visible = true; //self.nameLabel.hidden         = NO;
                
                //TODO: -yingyong.Mao -2022-11-14
                //self.muteNameCardView.hidden  = NO;
            }
            // [macOS]: no use 2 lines.
            // self.rendering = NO;
            //  [self.videoRender stopRendering];
        } else {
            // [macOS]: no use this line.
            // self.rendering = YES;
            
            console.log("[VideoRenderView.qml][renderMuteImage]: -> set muteImageView.visible = false, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
            muteImageView.visible = false; // self.muteImageView.hidden     = YES;
            //nameLabel.visible = false; // self.nameLabel.hidden         = YES;

            //TODO: -yingyong.Mao -2022-11-14
            // self.muteNameCardView.hidden  = YES;
        }
         
    }
    
    function setVisible(visible) {
        id_videoview.visible = visible;
        
        if (false === visible) {
            console.log("[VideoRenderView.qml][setVisible]: false === visible -> set id_videoview [width, height] = [0,0,0,0], dataSourceID : " + dataSourceID);
            id_videoview.x = 0;
            id_videoview.y = 0;
            id_videoview.width = 0;
            id_videoview.height = 0;
        } else {
            console.log("[VideoRenderView.qml][setVisible]: true === visible -> set id_videoview [x, y, width, height] = ["+ x + ", " + y + ", " + width + ", " + height + ", dataSourceID : " + dataSourceID);
            
            //TODO: -yingyong.Mao -2022-12-4
            //要还原坐标和size，需要用属性保存当前的rect数据
            
        }
    }
    
    /*
     - (void)updateWaterMask {
         self.contentWaterMaskText.frame = CGRectMake(0, self.frame.size.height - 110, self.frame.size.width + 250, 110);
     }
     */
    
     
    function setAppearanceWithActive(isActiveSpeaker) {
        console.log("[VideoRenderView.qml][setVisible]: -> call id_activespeaker_appearance.setAppearanceWithActive(isActiveSpeaker: " + isActiveSpeaker + "), dataSourceID : " + dataSourceID);
        id_videoview.isActiveSpeaker = isActiveSpeaker;
        id_activespeaker_appearance.setAppearanceWithActive(isActiveSpeaker);
    }
    
    
    //========== ========== ==========
    
    VideoRenderObject {
       id: provider_videoview
       //videoUrl: "rtsp://xxx.xxx.xxx/channel=0"
       videoUrl: "" //dataSourceID //"call-1_6"
    }

    VideoOutput {
        source: provider_videoview
        //anchors.fill: parent
        //x: parent.x
        //y: parent.y
        //width: parent.width
        //height: parent.height
        //anchors.horizontalCenter: parent.horizontalCenter
        //anchors.verticalCenter: parent.verticalCenter
        
        /*
        width: 640
        height: 480
        fillMode: VideoOutput.PreserveAspectFit
         */
        
        
        //fillMode: VideoOutput.Stretch
        //fillMode: VideoOutput.PreserveAspectCrop
        
        /*
        //anchors.fill: parent
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.topMargin: 0
        width: parent.width
        height: parent.height
        fillMode: VideoOutput.PreserveAspectFit
        */
        
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        
        onWidthChanged: {
            console.log("[VideoRenderView.qml][onWidthChanged:]: width: " + width);

        }
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

        //for remote video mute.
        //source: "qrc:/frtc_sdk_dist/frtc_sdk_bundle_images/call_camera_off@3x.png"
        //for local camera video mute.
        source: "" //"qrc:/frtc_sdk_dist/frtc_sdk_bundle_images/local_preview_off.png"
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
                console.log("[VideoRenderView.qml][setAppearanceWithActive]: false === isActiveSpeaker -> set border.width = 0, border.color  = black, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                visible = false;
                border.width = 0;
                border.color = "black";
            } else {
                console.log("[VideoRenderView.qml][setAppearanceWithActive]: true === isActiveSpeaker -> set border.width = 2, border.color  = green, dataSourceID : " + dataSourceID + ", strDisplayName: " + strDisplayName);
                visible = true;
                border.width = 4;
                border.color = "#1ADC5D" //"green";
            }
        }
    }

    //========== ========== ==========

}
