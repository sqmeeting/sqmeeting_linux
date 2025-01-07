//
//  SVCLayout.qml
//  Rectangle SVCLayout.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2022/07/25.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia


Rectangle{
    id: svc_layout_view
    width: 1024
    height: 691
    visible: true
    color: "black"

    property var screenWidth
    property var screenHeight

    property var screen_ratio: root.screen_ratio

    property int disPlayWidth: root.disPlayWidth
    property int disPlayHeight: root.disPlayHeight
    
    //property int disPlayWidth: width
    //property int disPlayHeight: height
    
    property var localVideoView
    property int peopleViewWidth: width // - 34 -34
    property int peopleViewHeight: height
    property int peopleMarginLeft: 0 //34
    property int peopleMarginTop: -44 //34
    
    property var contentVideoView
    property int contentVideoViewWidth: width // - 34 -34
    property int contentVideoViewHeight: height
    property int contentMarginLeft : 0
    property int contentMarginTop : 0;
    
    property var m_remotePeopleVideoViewList: []
    property var m_remotePeopleDataSourceID: []
    //property var m_remotePeopleVideoViewList: new Array();
    //property var m_remotePeopleDataSourceID: new Array();

    property var isFullScreen: false;
    property var isTraditionalLayout: true; //traditionalLayout
    property var isContentLayoutReady: false;

    property var isRemoteViewHidden: false; //exitFullScreen, then set remoteViewHidden = false.

    property var isSendingContent: false; //sendingContent
    property var isContent: false; //content
    //property var isMuteCamera: false; //muteCamera
    //property var isMuteMicrophone: false; //muteMicrophone
    //property var isCurrentGridMode: false; //currentGridMode
    
    property var isLocalViewHiddenByUser: false; //- (void)hiddenLocalView:(BOOL)hide, then set localViewHiddenByUser = hide;
    
    property var cellCustomUUID: "";
    
    //========================================
    // for layout details.
    //========================================

    property var mode: 0
    property var gSvcLayoutDetail : []
    property var gSvcLayoutDetail_videoViewDescription : []
    property var contentLayoutReady: false
    
    function getSvcLayoutDetail() {
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: -> call root.getSvcLayoutDetail()");

        var detail = root.getSvcLayoutDetail();
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: -> detail: ", detail);
        
        //2.for mode
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: ---------- 3 mode ----------  ----------  ---------- ")
        //console.log("svc detail.svcLayoutType: ", detail.svcLayoutType);
        //console.log("svc detail.isFullScreen: ", detail.isFullScreen);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: svc detail.videoViewDescription: ", detail.videoViewDescription);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: ---------- 3 mode ----------  ----------  ---------- ")

        mode = detail.currentSvcLayoutMode;
        var nCountVideoView = mode + 1;
        var isSymmetical = detail.isSymmetical;
        var strRowArray = detail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)
        
        console.log("^^^ ^^^ [SVCLayout.qml][getSvcLayoutDetail]: svc detail, currentSvcLayoutMode: ", mode);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: +++ svc detail, nCountVideoView: ", nCountVideoView);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: svc detail, isSymmetical: ", isSymmetical);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: svc detail, strRowArray: ",  strRowArray);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: ---------- 3 ----------  ----------  ---------- ")
        
        //hide all at first.
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: -> call hideAllVideoView() ??? ??? ???")
        //hideAllVideoView();
        
        console.log("+++ [SVCLayout.qml][getSvcLayoutDetail]: gSvcLayoutDetail_videoViewDescription = strRowArray");
        gSvcLayoutDetail_videoViewDescription = strRowArray;
        
        for (var i = 0; i < strRowArray.length; ++i) {
            console.log("+++ [SVCLayout.qml][getSvcLayoutDetail]: gSvcLayoutDetail_videoViewDescription[" + i + "]: ", gSvcLayoutDetail_videoViewDescription[i]);
            console.log("+++ [SVCLayout.qml][getSvcLayoutDetail] mode: ", mode, ", gSvcLayoutDetail_videoViewDescription.length: ", gSvcLayoutDetail_videoViewDescription.length);
        }
    }
    
    function getCellCustomUUID() {
        console.log("[SVCLayout.qml][getCellCustomUUID]: -> call root.getCellCustomUUID()");
        var cellCustomUUID = root.getCellCustomUUID();
        console.log("[SVCLayout.qml][getCellCustomUUID]: -> call root.getCellCustomUUID(), set cellCustomUUID: " + cellCustomUUID);
        return cellCustomUUID;
    }
    
    Component.onCompleted: {
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> call currentSize()");
        /*
        var sizeObj = currentSize();
        root.disPlayWidth = sizeObj.width;
        root.disPlayHeight = sizeObj.height;
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> set [disPlayWidth, disPlayHeight] : ", sizeObj.width, ", ", sizeObj.height);
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> set [disPlayWidth , disPlayHeight] : ", disPlayWidth, ", ", disPlayHeight);
        */
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> set [root.disPlayWidth , root.disPlayHeight] : ", root.disPlayWidth, ", ", root.disPlayHeight);

        svc_layout_view.peopleViewWidth = root.disPlayWidth;
        svc_layout_view.peopleViewHeight = root.disPlayHeight * 0.8;
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> set svc_layout_view.peopleViewWidth: ", svc_layout_view.peopleViewWidth, ", svc_layout_view.peopleViewHeight: ", svc_layout_view.peopleViewHeight);

        svc_layout_view.contentVideoViewWidth = root.disPlayWidth;
        svc_layout_view.contentVideoViewHeight = root.disPlayHeight * 0.8;
        console.log("[SVCLayout.qml][Component.onCompleted:]: -> set svc_layout_view.contentVideoViewWidth: ", svc_layout_view.contentVideoViewWidth, ", svc_layout_view.contentVideoViewHeight: ", svc_layout_view.contentVideoViewHeight);

        //console.log("[SVCLayout.qml][Component.onCompleted:]: -> call getSvcLayoutDetail()");
        getSvcLayoutDetail();
        
        //create remote people video views.
        for (var i = 0; i < 9; ++i) {
            //console.log("[SVCLayout.qml][Component.onCompleted:]: m_remotePeopleVideoViewList [", i, "] add new videoRenderView of [VideoRenderView.qml].");
            createRemotePeopleVideoViewList(i);
        }
        
        //create local people video views.
        createLocalPeopleVideoView(9);
        
        //create remote content video views.
        createRemoteContentVideoView(10);
    }
    
    function showRemotePeopleVideoViewList() {
        console.log("||| ||| [SVCLayout.qml][showRemotePeopleVideoViewList]: ", this.toString(), this, objectName);
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            var videoRenderView = m_remotePeopleVideoViewList[i];
            console.log("||| ||| [SVCLayout.qml][showRemotePeopleVideoViewList]: -> get m_remotePeopleDataSourceID [", i, "] videoRenderView of VideoRenderView.qml.")
            console.log("||| ||| [SVCLayout.qml][showRemotePeopleVideoViewList]: videoRenderView.strDisplayName: " + videoRenderView.strDisplayName + ", videoRenderView.dataSourceID: " + videoRenderView.dataSourceID);
            console.log("||| ||| [SVCLayout.qml][showRemotePeopleVideoViewList]: videoRenderView rect[" + videoRenderView.x + ", " + videoRenderView.y + ", " + videoRenderView.width + ", " + videoRenderView.height + "]");
        }
    }
    
    function createRemotePeopleVideoViewList(windowId) {
        var component = Qt.createComponent("VideoRenderView.qml");
        if (component.status === Component.Ready) {
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.
            //for test init.
            //var row = Math.floor(windowId /12)
            //var col = windowId - row * 12
            newVideoView.x = 0 //col * 150 + 70
            newVideoView.y = 0 //row * 120 + 70
            //newVideoView.showInfo = windowId + 1

            newVideoView.dataSourceID = "remote" //call-1_6"
            newVideoView.strDisplayName = " "
            newVideoView.eVideoType = 0
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false

            m_remotePeopleVideoViewList.push(newVideoView);
            return true
        }
        return false
    }

    function createLocalPeopleVideoView(windowId) {
        var component = Qt.createComponent("VideoRenderView.qml");
        if (component.status === Component.Ready) {
            // localRect = CGRectMake(0, [self disPlayHeight] / 12, [self disPlayWidth], [self disPlayHeight] * 0.8);
            // self.localVideoView = [[MetalVideoView alloc] initWithFrame:localRect dataSouceID:sourceID];
            // [self.localVideoView setRenderPixelType:RTCSDK::SAMPLE_TYPE_I420];
            
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.
            //for test init.
            //var row = Math.floor(windowId /12)
            //var col = windowId - row * 12
            newVideoView.x = 0 //col * 150 + 70
            newVideoView.y = disPlayHeight / 12
            newVideoView.width = disPlayWidth
            newVideoView.height = disPlayHeight * 0.8
            //newVideoView.showInfo = windowId + 1
            
            console.log("[SVCLayout.qml][createLocalPeopleVideoView]: root.disPlayWidth: ", root.disPlayWidth, ", root.disPlayHeight: ", root.disPlayHeight);
            console.log("[SVCLayout.qml][createLocalPeopleVideoView]: disPlayWidth: ", disPlayWidth, ", disPlayHeight:", disPlayHeight);
            console.log("[SVCLayout.qml][createLocalPeopleVideoView]: disPlayWidth: ", disPlayWidth, ", disPlayHeight  * 0.8 :", disPlayHeight  * 0.8);
            console.log("[SVCLayout.qml][createLocalPeopleVideoView]: newVideoView([x: ", newVideoView.x, ", y: ", newVideoView.y, ", w:", newVideoView.width, ", h: ", newVideoView.height, "])");

            //newVideoView.dataSourceID = "_VPL_PREVIEW"
            newVideoView.setRenderSourceID("_VPL_PREVIEW");
            
            newVideoView.strDisplayName = " "
            newVideoView.eVideoType = 0 //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false

            localVideoView = newVideoView
            console.log("[SVCLayout.qml][createLocalPeopleVideoView]: localVideoView([x: ", localVideoView.x, ", y: ", localVideoView.y, ", w:", localVideoView.width, ", h: ", localVideoView.height, "])");
            return true
        }
        return false
    }
    
    function createRemoteContentVideoView(windowId) {
        var component = Qt.createComponent("VideoRenderView.qml");
        if (component.status === Component.Ready) {
            //CGRect localRect = CGRectMake(0, [self disPlayHeight] / 12, [self disPlayWidth], [self disPlayHeight] * 0.8);
            //localRect = CGRectMake( 0, 0, [self disPlayWidth], [self disPlayHeight] * 0.8);
            //self.contentVideoView = [[MetalVideoView alloc] initWithFrame:localRect dataSouceID:@"content"];
            //[self.contentVideoView  setRenderPixelType:RTCSDK::SAMPLE_TYPE_I420];
            //[self.videoViewContainer addSubview:self.contentVideoView];
            
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.
            //for test init.
            //var row = Math.floor(windowId /12)
            //var col = windowId - row * 12
            newVideoView.x = 0
            newVideoView.y = disPlayHeight / 12
            newVideoView.width = disPlayWidth
            newVideoView.height = disPlayHeight * 0.8
            //newVideoView.showInfo = windowId + 1

            newVideoView.dataSourceID = "content"
            //remoteMVV.dataSourceID("content");

            newVideoView.strDisplayName = " "
            newVideoView.eVideoType = 2 //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false;

            contentVideoView = newVideoView;
            //contentVideoView.visible = false;
            console.log("[SVCLayout.qml][createRemoteContentVideoView]: -> call [VideoRenderView.qml] contentVideoView.setVisible(false)");
            contentVideoView.setVisible(false);
            
            return true
        }
        return false
    }
    
    function hideAllVideoView() {
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            console.log("[SVCLayout.qml][hideAllVideoView]: m_remotePeopleVideoViewList [", i, "] videoRenderView of VideoRenderView.qml.")
            var videoRenderView = m_remotePeopleVideoViewList[i];
            //VideoRenderView.qml, VideoRender.cpp
            //MetalVideoView *view = _remotePeopleVideoViewList[i]; (-> MetalVideoViewRender.cpp)
            //console.log("[SVCLayout.qml][hideAllVideoView]: m_remotePeopleVideoViewList [", i, "] -> call [VideoRenderView.qml] videoRenderView.visible = false.")
            //videoRenderView.visible = false;
            
            console.log("[SVCLayout.qml][hideAllVideoView]: m_remotePeopleVideoViewList [", i, "] -> call [VideoRenderView.qml] videoRenderView.setVisible(false), dataSourceID: ", videoRenderView.dataSourceID);
            videoRenderView.setVisible(false);
        }
    }
    
    function setVideoViewInfo(index, aVideoRenderView) {
        console.log("[SVCLayout.qml][setVideoViewInfo]: -------- viewArray index [", index, "] ----------  ----------  ---------- ")
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.dataSourceID: ", aVideoRenderView.dataSourceID);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.strDisplayName: ", aVideoRenderView.strDisplayName);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.eVideoType: ", aVideoRenderView.eVideoType);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.removed: ", aVideoRenderView.removed);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.active: ", aVideoRenderView.active);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.maxResolution: ", aVideoRenderView.maxResolution);
        console.log("[SVCLayout.qml][setVideoViewInfo]: svc aVideoRenderView.pin: ", aVideoRenderView.pin);
        
        //if (aVideoRenderView.dataSourceID !== "_VPL_PREVIEW") {
            console.log("[SVCLayout.qml][setVideoViewInfo]: index: ", index, " is remote view, sourceID : ", aVideoRenderView.dataSourceID);
            var videoRenderView = m_remotePeopleVideoViewList[index];
            //VideoRenderView.qml, VideoRender.cpp
            //MetalVideoView *view = _remotePeopleVideoViewList[i]; (-> MetalVideoViewRender.cpp)
            
            //[Note]: will call [VideoRender.cpp]: onDataSourceIDChanged:{}
            console.log("[SVCLayout.qml][setVideoViewInfo]: m_remotePeopleVideoViewList [", i, "] -> set [VideoRenderView.qml] videoRenderView.dataSourceID = aVideoRenderView.dataSourceID: ", aVideoRenderView.dataSourceID);
            console.log("[SVCLayout.qml][setVideoViewInfo]: m_remotePeopleVideoViewList [", i, "] -> set [VideoRenderView.qml] videoRenderView.strDisplayName = aVideoRenderView.strDisplayName: ", aVideoRenderView.strDisplayName);
            console.log("[SVCLayout.qml][setVideoViewInfo]: m_remotePeopleVideoViewList [", i, "] -> set [VideoRenderView.qml] videoRenderView.uuid = aVideoRenderView.strUUID: ", aVideoRenderView.strUUID);

            videoRenderView.dataSourceID = aVideoRenderView.dataSourceID;
            videoRenderView.strDisplayName = aVideoRenderView.strDisplayName;
            videoRenderView.uuid = aVideoRenderView.strUUID;
            
            console.log("[SVCLayout.qml][setVideoViewInfo]: m_remotePeopleVideoViewList [", i, "] -> set [VideoRenderView.qml] videoRenderView.visible = true.")
            //videoRenderView.visible = true;
            
//            m_remotePeopleVideoViewList[index].dataSourceID = aVideoRenderView.dataSourceID
//            m_remotePeopleVideoViewList[index].strDisplayName = aVideoRenderView.strDisplayName
        //} else {
            console.log("[SVCLayout.qml][setVideoViewInfo]: index: ", index, " is local view, sourceID : _VPL_PREVIEW")

        //}
    }
    
    function showLocalPreview(aShow) {
        console.log("[SVCLayout.qml][showLocalPreview]: aShow: " + aShow?"true":"false");
        if (true === aShow) {
            //localVideoView.color = "white"
            //localVideoView.z = 0
            localVideoView.opacity = 1
        } else {
            //localVideoView.color = "transparent"
            //localVideoView.z = 4
            localVideoView.opacity = 0
        }

    }

    function localVideoMute(mute) {
        console.log("[SVCLayout.qml][localVideoMute]: mute: " + mute?"true":"false");
        
        if (true === mute) {
            localVideoView.renderMuteImage(mute);
            localVideoView.stopRendering();
        } else {
            localVideoView.startRendering();
            localVideoView.renderMuteImage(mute);
        }

    }
    
    function setLocalVideoRect(x, y, w, h) {
        console.log("[SVCLayout.qml][setLocalVideoRect]: [VideoRenderView.qml]: localVideoView[", x, ", ", y, ", ", w, ", ", h, "]")
        localVideoView.x = x;
        localVideoView.y = y;
        localVideoView.width = w;
        localVideoView.height = h;
        
        localVideoView.setFrameSize(x, y, width, height);

        //console.log("[SVCLayout.qml][setLocalVideoRect]: -> call [VideoRenderView.qml]: set localVideoView.visible = true, -> call localVideoView.startRendering() : [x: ", x, ", y: ", y, ", w:", w, ", h: ", h, "])");
        //localVideoView.visible = true;
        
        console.log("[SVCLayout.qml][setLocalVideoRect]: -> call [VideoRenderView.qml] localVideoView.setVisible(true), dataSourceID: " + localVideoView.dataSourceID);
        localVideoView.setVisible(true);
        localVideoView.startRendering(); //[VideoRenderView.qml]: localVideoView
        
        console.log("[SVCLayout.qml][setLocalVideoRect]: -> call localVideoView.renderMuteImage(mute: false)");
        localVideoView.renderMuteImage(false);
        //localVideoView.color = "yellow";
    }
    
    function setContentVideoRect(x, y, w, h) {
        console.log("[SVCLayout.qml][setContentVideoRect]: [VideoRenderView.qml]: contentVideoView[", x, ", ", y, ", ", w, ", ", h, "]")
        contentVideoView.x = x;
        contentVideoView.y = y;
        contentVideoView.width = w;
        contentVideoView.height = h;
        
        contentVideoView.setFrameSize(x, y, width, height);

        //contentVideoView.visible = true;
        
        console.log("[SVCLayout.qml][setContentVideoRect]: -> call [VideoRenderView.qml] contentVideoView.setVisible(true), dataSourceID: " + contentVideoView.dataSourceID);
        contentVideoView.setVisible(true);

        console.log("[SVCLayout.qml][setContentVideoRect]: -> call [VideoRenderView.qml]: set contentVideoView.visible = true, set renderMuteImage(false), then -> call contentVideoView.startRendering() : [x: ", x, ", y: ", y, ", w:", w, ", h: ", h, "])");
        contentVideoView.renderMuteImage(false);
        contentVideoView.startRendering();
    }
    
    //remote people.
    
    function setRemoteMVVVideoViewRect(remoteMVV, x, y, w, h) {
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: remoteMVV: ", remoteMVV)
        remoteMVV.x      = x;
        remoteMVV.y      = y;
        remoteMVV.width  = w;
        remoteMVV.height = h;
        
        remoteMVV.setFrameSize(x, y, width, height);
        
        //remoteMVV.visible = true;
        remoteMVV.setVisible(true);
        
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: -> call remoteMVV.renderMuteImage(mute: false)");
        remoteMVV.renderMuteImage(false);
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: -> call remoteMVV.startRendering(): dataSourceID: " + remoteMVV.dataSourceID);
        remoteMVV.startRendering();
        
        /*
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: remoteMVV.strDisplayName: " + remoteMVV.strDisplayName + ", remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: remoteMVV rect[" + remoteMVV.x + ", " + remoteMVV.y + ", " + remoteMVV.width + ", " + remoteMVV.height + "]");
        console.log("[SVCLayout.qml][setRemoteMVVVideoViewRect]: remoteMVV visible : " + remoteMVV.visible);
         */
    }
    
    function showRemoteMVVVideoViewRect(functionName, remoteMVV) {
        //m_remotePeopleVideoViewList[]
        console.log("[SVCLayout.qml][" + functionName + "]: [VideoRenderView.qml]: remoteMVV: ", remoteMVV);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.strDisplayName: " + remoteMVV.strDisplayName + ", remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV rect[" + remoteMVV.x + ", " + remoteMVV.y + ", " + remoteMVV.width + ", " + remoteMVV.height + "]");
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV visible : " + remoteMVV.visible);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.eVideoType: ", remoteMVV.eVideoType);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.removed: ", remoteMVV.removed);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.active: ", remoteMVV.active);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.maxResolution: ", remoteMVV.maxResolution);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.pin: ", remoteMVV.pin);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.resolution_width: ", remoteMVV.resolution_width);
        console.log("[SVCLayout.qml][" + functionName + "]: remoteMVV.resolution_height: ", remoteMVV.resolution_height);
    }
    
    function showRemoteViewArray(functionName, viewArray) {
        console.log("^^^ ^^^ ^^^[SVCLayout.qml][" + functionName + "]: svc videoInfo, svc viewArray.length: ", viewArray.length);
        for (var index = 0; index < viewArray.length; ++index) {
            console.log("---------- 1 viewArray data [", index, "] ----------  ----------  ---------- ")
            var video = viewArray[index]; //SVCVideoInfo.cpp class
            console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: svc videoInfo ---------- [i: " + index + "] ----------");
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.dataSourceID: ", video.dataSourceID);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.strDisplayName: ", video.strDisplayName);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.strUUID: ", video.strUUID);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.eVideoType: ", video.eVideoType);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.removed: ", video.removed);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.active: ", video.active);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.maxResolution: ", video.maxResolution);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.pin: ", video.pin);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.resolution_width: ", video.resolution_width);
            console.log("[SVCLayout.qml][" + functionName + "]: svc videoInfo.resolution_height: ", video.resolution_height);
        }
    }

    function dealwithRecvMsgRemoteViewHiddenOrNot(arg) {
        console.log("---------- ---------- [SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: Enter: qml slot runing ----------  ---------- ")
        var detail = arg;
        console.log("svc detail.viewArray: ", detail.viewArray);

        //1.for viewArray

        //[Note]: detail.viewArray[]
        // 1.1.detail.viewArray[?]: _VPL_PREVIEW
        // 1.2.detail.viewArray[other]: remote video (people or content).
        var viewArray = detail.viewArray;
        console.log("svc viewArray: ", viewArray);
        console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: svc videoInfo, svc viewArray.length: ", viewArray.length);
        console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: -> call showRemoteViewArray()");
        showRemoteViewArray("dealwithRecvMsgRemoteViewHiddenOrNot", viewArray);
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: ****************Begin to dump remoteViewHiddenOrNot:(NSMutableArray *)viewArray*************** \n");
        console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: svc m_remotePeopleVideoViewList.length: ", m_remotePeopleVideoViewList.length);

        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            var videoRenderView = m_remotePeopleVideoViewList[i]; // [VideoRenderView.qml]:
            
            console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: -> get m_remotePeopleDataSourceID [", i, "] videoRenderView of VideoRenderView.qml. videoRenderView.strDisplayName: " + videoRenderView.strDisplayName + ", dataSourceID: " + videoRenderView.dataSourceID + ", visible: " + videoRenderView.visible);

            //VideoRenderView.qml, VideoRender.cpp
            //MetalVideoView *videoRenderView = _remotePeopleVideoViewList[i]; (-> MetalVideoViewRender.cpp)
            var bFind = false;
            for (var j = 0; j < viewArray.length; ++j) {
                var videoInfo = viewArray[j]; //SVCVideoInfo *videoInfo = viewArray[j];
                if (-1 !== videoRenderView.dataSourceID.indexOf(videoInfo.dataSourceID)) {
                    bFind = true;
                    break;
                }
            }
            if (false === bFind) {
                console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: There can't find video view is view.dataSourceID: ", videoRenderView.dataSourceID, ", so set [VideoRenderView.qml] videoRenderView.visible = false, then set videoRenderView.provider_videoview.m_visible = false.");
                
                //videoRenderView.visible = false;
                
                console.log("[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: m_remotePeopleVideoViewList [", i, "] -> call [VideoRenderView.qml] videoRenderView.setVisible(false), dataSourceID: ", videoRenderView.dataSourceID);
                videoRenderView.setVisible(false);
                
                console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: -> call videoRenderView.renderMuteImage(true)");
                videoRenderView.renderMuteImage(true);
                
                console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: -> call videoRenderView.stopRendering(): videoRenderView.dataSourceID: ", videoRenderView.dataSourceID);
                videoRenderView.stopRendering();
            } else {
                console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: The can find video view is %s, so set provider_videoview.m_visible = true, and set videoRenderView.provider_videoview.m_visible = true, dataSourceID: ", videoRenderView.dataSourceID);
                //videoRenderView.visible = true;
                
                console.log("[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: m_remotePeopleVideoViewList [", i, "] -> call [VideoRenderView.qml] videoRenderView.setVisible(false), dataSourceID: ", videoRenderView.dataSourceID);
                videoRenderView.setVisible(true);
                //videoRenderView.provider_videoview.m_visible = true;
                console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: -> call videoRenderView.startRendering(): videoRenderView.dataSourceID: ", videoRenderView.dataSourceID);
                videoRenderView.startRendering();
                videoRenderView.renderMuteImage(false);
            }
        }
        console.log("---------- ---------- [SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: Exit ----------  ---------- ")
    }
        
    //[macOS][FMeetingViewController.m]:
    function dealwithRecvMsgPrepareSVCLayout(aMode, arg2) {
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: ---------- 3 ---------- [SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: qml slot runing ----------  ---------- ")

        mode = aMode;
        var detail = arg2;
        
        //2.for mode
        var nCountVideoView = mode + 1;
        var isSymmetical = detail.isSymmetical;
        var strRowArray = detail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)
        
        /*
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: svc detail.videoViewDescription: ", detail.videoViewDescription);
        console.log("[SVCLayout.qml][getSvcLayoutDetail]: svc detail, currentSvcLayoutMode: ", mode);
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: svc detail, nCountVideoView: ", nCountVideoView);
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: svc detail, isSymmetical: ", isSymmetical);
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: svc detail, strRowArray: ",  strRowArray);
        */
        
        //hide all at first.
        console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: -> call hideAllVideoView() ??? ??? ???")
        hideAllVideoView();
        
        for (var i = 0; i <= nCountVideoView; ++i) {
            //var strRow = strRowArray_1[i].toString();
            //var strRow = strRowArray[i];
            console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: [", i + "]");

            var columnArray = strRowArray[i];
            console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: svc detail, columnArray[i]: ", columnArray);
            
            var x = columnArray[0];
            var y = columnArray[1];
            var w = columnArray[2];
            var h = columnArray[3];
            console.log("+++ [SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: [" + i + "]: [" + x + ", " + y + ", " + w + ", " + h + "]");

            var rowArray = [x, y, w, h];
            console.log("+++ [SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout] -> rowArray [" + i + "]: [" + rowArray[0] + ", " + rowArray[1] + ", " + rowArray[2] + ", " + rowArray[3] + "]");

            
            gSvcLayoutDetail_videoViewDescription[i] = rowArray;
            console.log("+++ [SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: gSvcLayoutDetail_videoViewDescription[" + i + "]: ", gSvcLayoutDetail_videoViewDescription[i]);

            /*
            gSvcLayoutDetail_videoViewDescription[i][0] = x;
            gSvcLayoutDetail_videoViewDescription[i][1] = y;
            gSvcLayoutDetail_videoViewDescription[i][2] = w;
            gSvcLayoutDetail_videoViewDescription[i][3] = h;
            */
            
            console.log("[SVCLayout.qml][dealwithRecvMsgPrepareSVCLayout]: |---------- ----------  ----------  ---------- |")
        }
    }

    function dealwithRecvMsgRefreshLayoutMode(aMode, aDetail) {
        console.log("[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: qml slot runing")
        
        mode = aMode;
        var detail = aDetail;
        var strRowArray = aDetail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)
        gSvcLayoutDetail_videoViewDescription = strRowArray;
        console.log("[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: value from cpp FMeetingViewControllerObject， mode: " + mode + ", detail" + detail);
        for (var i = 0; i < strRowArray.length; ++i) {
            console.log("+++ +++ 1 [SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: gSvcLayoutDetail_videoViewDescription[" + i + "]: ", gSvcLayoutDetail_videoViewDescription[i]);
        }
        
        /*
        //Test ---------- show data ---------- ---------- ----------
         var viewArray = aDetail.viewArray;
         console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: svc videoInfo, svc viewArray.length: ", viewArray.length);
         console.log("^^^ ^^^ ^^^[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: -> call showRemoteViewArray()");
         showRemoteViewArray("dealwithRecvMsgRefreshLayoutMode", viewArray);
        //Test ---------- show data ---------- ---------- ----------
         */
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: -> call dealwithRecvMsgRemoteViewHiddenOrNot(arg2)", aDetail)
        //[FMeetingViewController.m]: RefreshLayoutMode:
        dealwithRecvMsgRemoteViewHiddenOrNot(aDetail);
        
        //[SVCLayout.qml]: function dealwithRecvMsgRefreshLayoutMode(mode, aDetail)
        console.log("[SVCLayout.qml][dealwithRecvMsgRefreshLayoutMode]: -> call dealwithRecvMsgLayoutRemoteView(mode: " + mode + ", arg2: " + aDetail + ")")
        dealwithRecvMsgLayoutRemoteView(mode, aDetail);
    }
    
    function getLineNumber() {
        return parseInt(new Error().stack.split(':')[7]);
    }
    
    function dealwithRecvMsgLayoutRemoteView(arg1, arg2) {
        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: Enter");
        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: qml slot runing ----------  ---------- ");
        var videoMode = arg1;
        var detail = arg2;
        
        //1.for viewArray
        //[Note]: detail.viewArray[]
        // 1.1.detail.viewArray[?]: _VPL_PREVIEW
        // 1.2.detail.viewArray[other]: remote video (people or content).

        var viewArray = detail.viewArray; //layoutInfo
        console.log("svc viewArray: ", viewArray);
        console.log("svc viewArray.length: ", viewArray.length);
        
        //---------- ---------- end ---------- ----------
        //- (void)layoutRemoteView:(NSMutableArray *)layoutInfo layoutMode:(SVCLayoutModeType)mode
        //---------- ---------- begin ---------- ----------
        
        console.log("--- [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ", this.toString(), this, objectName);
        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo: videoMode: " + videoMode + ", viewArray.length: ", viewArray.length);

        for (var i = 0; i < viewArray.length; ++i) {
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ---------- ---------- viewArray [" + i + "] : begin ---------- ---------- ");
            var videoInfo = viewArray[i];
            /*
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo ---------- [i: " + i + "] ----------");
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.dataSourceID: ", video.dataSourceID);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.strDisplayName: ", video.strDisplayName);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.strUUID: ", video.strUUID);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.eVideoType: ", video.eVideoType);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.removed: ", video.removed);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.active: ", video.active);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.maxResolution: ", video.maxResolution);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.pin: ", video.pin);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.x: ", video.resolution_width);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.y: ", video.resolution_height);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.resolution_width: ", video.resolution_width);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.resolution_height: ", video.resolution_height);
            */
            
            //[macOS]: MetalVideoView  *remoteMVV;
            //[Qt]: videoRenderView of VideoRenderView.qml.
            var remoteMVV = null;
            //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            if (videoInfo.eVideoType === 1) { //VIDEO_TYPE_REMOTE
                
                if (videoInfo.resolution_width === -1) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.eVideoType === 1 (VIDEO_TYPE_REMOTE), and ideoInfo.resolution_width === -1, so do nothing, for the dataSourceID: " + videoInfo.dataSourceID + ")");

                } else if (videoInfo.resolution_width !== -1) { //VIDEO_TYPE_REMOTE
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.eVideoType !== 1 (VIDEO_TYPE_REMOTE) -> call remoteMVV = getVideoViewControllerByViewId(videoInfo.dataSourceID: " + videoInfo.dataSourceID + ")");
                    console.log(" ### ### [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: m_remotePeopleDataSourceID.length : ", m_remotePeopleDataSourceID.length);
                    remoteMVV = getVideoViewControllerByViewId(videoInfo.dataSourceID);
                    
                    var isFind = false;
                    var findIndex = -1;
                    for (var j = 0; j < m_remotePeopleDataSourceID.length; ++j) {
                        var sourceID = m_remotePeopleDataSourceID[j];
                        //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: m_remotePeopleDataSourceID [", j, "] sourceID: ", sourceID);
                        if (-1 !== sourceID.indexOf(videoInfo.dataSourceID)) {
                            findIndex = j;
                            isFind = true;
                            break;
                        }
                    }

                    if (isFind) {
                        if (null !== remoteMVV && undefined !== remoteMVV) {
                            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: isFind, sourceID: " + sourceID + ", m_remotePeopleVideoViewList[findIndex: " + findIndex + "] of  [VideoRenderView.qml].");

                            //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: In layoutRemoteView:(NSMutableArray *)layoutInfo, start remote, sourceID: ", sourceID);
                            //showRemoteMVVVideoViewRect("dealwithRecvMsgLayoutRemoteView", remoteMVV); //findIndex
                            
                            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.provider_videoview.startRendering(), and set remoteMVV.visible = true, dataSourceID: " + remoteMVV.dataSourceID);
                            remoteMVV.renderMuteImage(false);
                            remoteMVV.startRendering();
                            //remoteMVV.visible = true;
                            
                            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteViewHiddenOrNot]: m_remotePeopleVideoViewList [", i, "] -> call [VideoRenderView.qml] videoRenderView.setVisible(true), dataSourceID: " + remoteMVV.dataSourceID);
                            remoteMVV.setVisible(true);
                        } else {
                            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView][Info]: isFind, sourceID: " + sourceID + ", m_remotePeopleVideoViewList[findIndex: " + findIndex + "] of  [VideoRenderView.qml], but it's not remote people, videoInfo.eVideoType: " + videoInfo.eVideoType);

                        }
                    } else {
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: _remotePeopleDataSourceID can not containsObject about videoInfo.dataSourceID", videoInfo.dataSourceID, "the name is: ", videoInfo.strDisplayName);
                    }
                    
                }
            }
            
            var x = 0;
            var y = 0;
            var width = 0;
            var height = 0;
            
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [x, y, width, height] : ", x, y, width, height);

            if (true === isFullScreen && i === 0) { //1.full screen and is [0].
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]:true === isFullScreen && i === 0)");
                if (true === isTraditionalLayout) { //1x5
                      console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]:true === isFullScreen && i === 0), and true === isTraditionalLayout: 1x5");
//                    x       = ([self screenSize].width - self.fullScreenSize.width) / 2;
//                    y       = ([self screenSize].height - self.fullScreenSize.height) / 2;
//                    width   = self.fullScreenSize.width;
//                    height  = self.fullScreenSize.height;
                } else {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]:true === isFullScreen && i === 0), and true != isTraditionalLayout: 3x3");
//                    x       = gSvcLayoutDetail[mode].videoViewDescription[i][0] * (self.fullScreenSize.width) + ([self screenSize].width - self.fullScreenSize.width)/2;
//                    y       = gSvcLayoutDetail[mode].videoViewDescription[i][1] * (self.fullScreenSize.height) + ([self screenSize].height - self.fullScreenSize.height) / 2;
//                    width   = gSvcLayoutDetail[mode].videoViewDescription[i][2] * (self.fullScreenSize.width);
//                    height  = gSvcLayoutDetail[mode].videoViewDescription[i][3] * (self.fullScreenSize.height);
               }
                
            } else { //2.full screen and not [0]; or not full screen.
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true !== isFullScreen || i != 0), that are: 2.full screen but not [0]; or not full screen.");

                if (true === isFullScreen) { //2.1.full screen and not [0]
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === isFullScreen), 2.1.full screen but not [0].");
                    if (true === isTraditionalLayout) {
//                        x = gSvcLayoutDetail[mode].videoViewDescription[i][0] * ([self disPlayWidth]) + ([self screenSize].width - [self disPlayWidth])/2;
//                        y = 0;//[self screenSize].height - gSvcLayoutDetail[mode].videoViewDescription[i][3] * ([self disPlayHeight]);
//                        width  = gSvcLayoutDetail[mode].videoViewDescription[i][2] * ([self disPlayWidth]);
//                        height = gSvcLayoutDetail[mode].videoViewDescription[i][3] * ([self disPlayHeight]);
                    } else {
                        if (videoInfo.eVideoType === 0) { //0: VIDEO_TYPE_LOCAL
//                            x = [self screenSize].width -gSvcLayoutDetail[mode].videoViewDescription[i][2] * ([self disPlayWidth]);
//                            y = 0;// [self screenSize].height - gSvcLayoutDetail[mode].videoViewDescription[i][3] * ([self disPlayHeight]);
                            
//                            width  = gSvcLayoutDetail[mode].videoViewDescription[i][2] * ([self disPlayWidth]);
//                            height = gSvcLayoutDetail[mode].videoViewDescription[i][3] * ([self disPlayHeight]);
                        } else {
//                            x       = gSvcLayoutDetail[mode].videoViewDescription[i][0] * (self.fullScreenSize.width) + ([self screenSize].width - self.fullScreenSize.width)/2;
//                            y       = gSvcLayoutDetail[mode].videoViewDescription[i][1] * (self.fullScreenSize.height) + ([self screenSize].height - self.fullScreenSize.height) / 2;
//                            width   = gSvcLayoutDetail[mode].videoViewDescription[i][2] * (self.fullScreenSize.width);
//                            height  = gSvcLayoutDetail[mode].videoViewDescription[i][3] * (self.fullScreenSize.height);
                        }
                    }
                    
                } else { //2.2.not full screen.
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: 2.2.not full screen.");
                    console.log("+++ 222 +++[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] videoMode: ", videoMode, ", gSvcLayoutDetail_videoViewDescription.length: ", gSvcLayoutDetail_videoViewDescription.length);

                    //[Qt]: [Note]: gSvcLayoutDetail_videoViewDescription[] not for content; only for remote and local people position, to caculate their rect.
                    var rowArray = gSvcLayoutDetail_videoViewDescription[i];
                    console.log("+++ 222 +++[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> gSvcLayoutDetail_videoViewDescription [" + i + "]: rowArray: ", rowArray);
                    console.log("+++ 222 +++[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> gSvcLayoutDetail_videoViewDescription [" + i + "]: rowArray: [" + rowArray[0] + ", " + rowArray[1] + ", " + rowArray[2] + ", " + rowArray[3] + "]");

                    x       = rowArray[0] * root.disPlayWidth;
                    y       = rowArray[1] * root.disPlayHeight;
                    width   = rowArray[2] * root.disPlayWidth;
                    height  = rowArray[3] * root.disPlayHeight;
                    console.log("+++ 203 +++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> [" + i + "]: [" + x + ", " + y + ", " + width + ", " + height + "]");
                }
            }
            
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ========= 1 ========= 1 ========= 1 ========= ========= ========= ");
            
            //rect = CGRectMake(x, y, width, height);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: rect: [x, y, width, height] : ", x, y, width, height);

            //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            if (videoInfo.eVideoType === 0) { //0: VIDEO_TYPE_LOCAL
                
                //1.local people video view.
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: eVideoType === VIDEO_TYPE_LOCAL");
                if (viewArray.length === 1) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: viewArray.length === 1, that is : layoutInfo only local video vieo info.");
                    if (true === isContentLayoutReady) {
                          console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call setLocalVideoRect(0, 0, ", 320 * screen_ratio, 180 * screen_ratio, ")");
                          setLocalVideoRect(0, 0, 320 * screen_ratio, 180 * screen_ratio);
                    } else {
                        if (true === isFullScreen) {
                            
//                           [self.localVideoView setFrame:CGRectMake(([self screenSize].width - self.fullScreenSize.width) / 2, ([self screenSize].height - self.fullScreenSize.height) / 2, self.fullScreenSize.width, self.fullScreenSize.height)];
                            //setLocalVideoRect([self screenSize].width - self.fullScreenSize.width) / 2, ([self screenSize].height - self.fullScreenSize.height) / 2, self.fullScreenSize.width, self.fullScreenSize.height);
                        } else {
                            console.log("+++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> call setLocalVideoRect([" + 0 + ", " + disPlayHeight / 12 + ", " + disPlayWidth + ", " + disPlayHeight * 0.8 + "]");
                            setLocalVideoRect(0, disPlayHeight / 12, disPlayWidth, disPlayHeight * 0.8);
                        }
                    }
                } else { //1.2.layoutInfo.count != 1
                    console.log("+++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] layoutInfo.count != 1, -> call setLocalVideoRect([" + x + ", " + y + ", " + width + ", " + height + "]");
                    setLocalVideoRect(x, y, width, height);
                }

            } else if (videoInfo.eVideoType === 2) { //2: VIDEO_TYPE_CONTENT
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: eVideoType === VIDEO_TYPE_CONTENT");
                setContentVideoRect(x, y, width, height);
            } else if (videoInfo.eVideoType === 1) { //1: VIDEO_TYPE_REMOTE
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: eVideoType === VIDEO_TYPE_REMOTE");
                if (videoInfo.resolution_width === -1) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.eVideoType === 1 (VIDEO_TYPE_REMOTE), and ideoInfo.resolution_width === -1, so do nothing, for the dataSourceID: " + videoInfo.dataSourceID + ")");

                } else if (videoInfo.resolution_width !== -1) { //VIDEO_TYPE_REMOTE
                    console.log(" ### ### [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: m_remotePeopleDataSourceID.length : ", m_remotePeopleDataSourceID.length);
                    remoteMVV = getVideoViewControllerByViewId(videoInfo.dataSourceID);
                    if (i !== 0) {
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: eVideoType === VIDEO_TYPE_REMOTE: i !== 0");
                        if (true === isFullScreen) {
                            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: eVideoType === VIDEO_TYPE_REMOTE: i !== 0 and true === isFullScreen");
                            console.log("+++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> [" + i + "]: [" + remoteMVV.x + ", " + remoteMVV.y + ", " + remoteMVV.width + ", " + remoteMVV.height+ "]");
                            console.log("+++ +++ +++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: remoteMVV.visible: " + remoteMVV.visible);
                            
    //                        [remoteMVV removeFromSuperview];
    //                        [self.videoViewContainer addSubview:remoteMVV];
                        }
                    }
                    if (contentLayoutReady) {
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.eVideoType === 1, VIDEO_TYPE_REMOTE and contentLayoutReady");
                        
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.stopRendering(): remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
                        remoteMVV.stopRendering();
                        
                        console.log("+++ [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView] -> call setRemoteMVVVideoViewRect(remoteMVV rect: [" + i + "]: [" + 0 + ", " + 0 + ", " + 320 * screen_ratio + ", " + 180 * screen_ratio + "])");
                        setRemoteMVVVideoViewRect(remoteMVV, 0, 0, 320 * screen_ratio, 180 * screen_ratio);
                    } else {
                        //[macOS]: MetalVideoView  *remoteMVV;
                        //[Qt]: videoRenderView of VideoRenderView.qml.
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.eVideoType === 1, VIDEO_TYPE_REMOTE and not contentLayoutReady, that is : VIDEO_TYPE_REMOTE people");

                        //setVideoViewInfo(i, videoInfo);
                        
                        //TODO: -yingyong.Mao -2022-11-14
                        //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setRenderSourceID(videoInfo.dataSourceID: ", videoInfo.dataSourceID);
                        //remoteMVV.setRenderSourceID(videoInfo.dataSourceID);
                        //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> set remoteMVV.dataSourceID = videoInfo.dataSourceID: ", videoInfo.dataSourceID);
                        //remoteMVV.dataSourceID = videoInfo.dataSourceID;
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> call remoteMVV.setRenderSourceID(videoInfo.dataSourceID: ", videoInfo.dataSourceID + ")");
                        remoteMVV.setRenderSourceID(videoInfo.dataSourceID);
      
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> set remoteMVV.strDisplayName = " + videoInfo.strDisplayName);
                        //remoteMVV.nameLabel.stringValue = [NSString stringWithFormat:@" %@", videoInfo.strDisplayName];
                        remoteMVV.strDisplayName = videoInfo.strDisplayName;

                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> set remoteMVV.uuid = " + videoInfo.strUUID);
                        remoteMVV.uuid = videoInfo.strUUID;
      
                        //[macOS]: MetalVideoView  *remoteMVV;
                        //[Qt]: videoRenderView of VideoRenderView.qml.
                        
                        //remoteMVV.nameCardView.nameLabel.stringValue = [NSString stringWithFormat:@" %@", videoInfo.strDisplayName];
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.stopRendering(): remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
                        remoteMVV.stopRendering();
                        
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call setRemoteMVVVideoViewRect(remoteMVV rect: [x, y, width, height] : ", x, y, width, height, ", remoteMVV.dataSourceID: ", remoteMVV.dataSourceID);
                        setRemoteMVVVideoViewRect(remoteMVV, x, y, width, height);

                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.startRendering(): remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
                        remoteMVV.startRendering();
                        //console.log("||| ||| [SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: isFind -> call showRemotePeopleVideoViewList().");
                        //showRemotePeopleVideoViewList();
                    }
                }
            }
            
        
            //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> set remoteMVV.strDisplayName = " + videoInfo.strDisplayName);
            //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> remoteMVV : " + remoteMVV);

            //remoteMVV.nameLabel.stringValue = [NSString stringWithFormat:@" %@", videoInfo.strDisplayName];
            //remoteMVV.strDisplayName = videoInfo.strDisplayName;
            

            //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: [" + i + "]: -> set remoteMVV.uuid = " + videoInfo.strUUID);
            //remoteMVV.uuid = videoInfo.strUUID;
            
            /*
            //[macOS]: MetalVideoView  *remoteMVV;
            //[Qt]: videoRenderView of VideoRenderView.qml.
            
            //remoteMVV.nameCardView.nameLabel.stringValue = [NSString stringWithFormat:@" %@", videoInfo.strDisplayName];
           
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: set remoteMVV.strDisplayName = " + videoInfo.strDisplayName);
            //remoteMVV.nameLabel.stringValue = [NSString stringWithFormat:@" %@", videoInfo.strDisplayName];
            remoteMVV.strDisplayName = videoInfo.strDisplayName;

            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: set remoteMVV.uuid = " + videoInfo.strUUID);
            remoteMVV.uuid = videoInfo.strUUID;

            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: now remoteMVV.dataSourceID : " + remoteMVV.dataSourceID + ", videoInfo.dataSourceID: " + videoInfo.dataSourceID);
             
             */
            
            //TODO: -yingyong.Mao -2022-11-8
            //for roast list.
        /*
            for(NSString *str in _rosterListArray) {
                NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&err];
                if (!err) {
                    for(int i = 0; i < _remotePeopleVideoViewList.count; i++) {
                        MetalVideoView *view = _remotePeopleVideoViewList[i];
                        if (!view.isHidden && [view.uuid isEqualToString:dic[@"UUID"]]) {
                            BOOL mute;
                            
                            if ([dic[@"muteAudio"] isEqualToString:@"true"]) {
                                mute = YES;
                                [view updateLayoutSiteNameView:YES];
                            } else {
                                [view updateLayoutSiteNameView:NO];
                                mute = NO;
                            }
                            
                            if (!self.contentVideoView.hidden && [self.contentVideoView.nameCardView.nameLabel.stringValue isEqualToString:view.nameCardView.nameLabel.stringValue]) {
                                [self.contentVideoView updateLayoutSiteNameView:mute];
                            }
                        }
                    }
                }
            }
            [remoteMVV.nameCardView configNewNameCardView:videoInfo.isPin];
            */
        
/*
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ================================================================================");
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: |                                                 ");
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.dataSourceID: ", videoInfo.dataSourceID);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.strDisplayName: ", videoInfo.strDisplayName);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.strUUID: ", videoInfo.strUUID);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.eVideoType: ", videoInfo.eVideoType);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.removed: ", videoInfo.removed);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.active: ", videoInfo.active);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.maxResolution: ", videoInfo.maxResolution);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.pin: ", videoInfo.pin);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.x: ", videoInfo.resolution_width);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.y: ", videoInfo.resolution_height);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.resolution_width: ", videoInfo.resolution_width);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: svc videoInfo.resolution_height: ", videoInfo.resolution_height);
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: |                                                 ");
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ================================================================================");
        */

            // [Note]:
            // [macOS code]: == -2;
            // [on UOS / macOS]: actually, server data is resolution_width : -1.
            if (null !== remoteMVV && undefined !== remoteMVV) {
                //if (videoInfo.resolution_width == -2) { // [macOS verson]
                if (remoteMVV.eVideoType === 1 && remoteMVV.resolution_width === -1) { //1: VIDEO_TYPE_REMOTE
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.strDisplayName: " + remoteMVV.strDisplayName + ": Video Info width == -1");
                 
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.renderMuteImage(mute: " + true + ")");
                    remoteMVV.renderMuteImage(true); //[remoteMVV renderMuteImage:YES];
                    
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: videoInfo.resolution_width === -1, so -> call remoteMVV.stopRendering(): remoteMVV.dataSourceID: " + remoteMVV.dataSourceID);
                    remoteMVV.stopRendering(); //[remoteMVV stopRendering];
                }
            }
           
           if (true === isRemoteViewHidden) {
                if (i !== 0) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === this->isRemoteViewHidden && i !== 0, so -> call remoteMVV.setVisible(true): dataSourceID: " + remoteMVV.dataSourceID);
                    remoteMVV.setVisible(false);
                }
                console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === this->isRemoteViewHidden && i !== 0, so -> call localVideoView.setVisible(true): dataSourceID: " + localVideoView.dataSourceID);
                localVideoView.setVisible(false);
            } else {
                if (null !== remoteMVV && undefined !== remoteMVV) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === this->isRemoteViewHidden && i !== 0, so -> call remoteMVV.setVisible(true)");
                    remoteMVV.setVisible(true);
                }

                if (false === isLocalViewHiddenByUser) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === this->isRemoteViewHidden && i !== 0, so -> call localVideoView.setVisible(true): dataSourceID: " + localVideoView.dataSourceID);
                    localVideoView.setVisible(true);
                }
            }
           
           if (null !== remoteMVV && undefined !== remoteMVV) {
               if (true === isContent) {
                   console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: true === isContent, for dataSourceID: " + remoteMVV.dataSourceID);
                   if (videoInfo.active) {
                       console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(true), for dataSourceID: " + remoteMVV.dataSourceID);
                       remoteMVV.setAppearanceWithActive(true);
                   } else {
                       console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(false), for dataSourceID: " + remoteMVV.dataSourceID);
                       remoteMVV.setAppearanceWithActive(false);
                   }
               } else {
                   if (isSendingContent) {
                       if (videoInfo.active) {
                           console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(true), for dataSourceID: " + remoteMVV.dataSourceID);
                           remoteMVV.setAppearanceWithActive(true);
                       } else {
                           console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(false), for dataSourceID: " + remoteMVV.dataSourceID);
                           remoteMVV.setAppearanceWithActive(false);
                       }
                   } else {
                       if (isTraditionalLayout) {
                               console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(false), for dataSourceID: " + remoteMVV.dataSourceID);
                               remoteMVV.setAppearanceWithActive(false);
                       } else {
                           if (videoInfo.active) {
                               console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(true), for dataSourceID: " + remoteMVV.dataSourceID);
                               remoteMVV.setAppearanceWithActive(true);
                           } else {
                               console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(false), for dataSourceID: " + remoteMVV.dataSourceID);
                               remoteMVV.setAppearanceWithActive(false);
                           }
                       }
                   }
               }
           }
   
            //FMeetingViewController.cpp
            // FMeetingViewController::remoteLayoutChanged(SDKLayoutInfo buffer)
            // this->cellCustomUUID = buffer.cellCustomUUID;
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call getCellCustomUUID(), actualy call and get FMeetingViewController.cpp: this->cellCustomUUID");
            svc_layout_view.cellCustomUUID = getCellCustomUUID()
            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> show FMeetingViewController.cpp: this->cellCustomUUID: " + cellCustomUUID);
           
           if (null !== remoteMVV && undefined !== remoteMVV) {
                if (-1 === svc_layout_view.cellCustomUUID.indexOf("")) {
                    if (true === videoInfo.active && true === videoInfo.pin) {
                        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(false), for dataSourceID: " + remoteMVV.dataSourceID);
                        remoteMVV.setAppearanceWithActive(false);
                    } else {
                        if (true === videoInfo.active) {
                            console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> call remoteMVV.setAppearanceWithActive(true), for dataSourceID: " + remoteMVV.dataSourceID);
                            remoteMVV.setAppearanceWithActive(true);
                        }
                    }
                }
           }
           console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: ---------- ---------- viewArray [" + i + "] : end ---------- ---------- ");
        }
        
        /*
        if (self.isFullScreen) {
            [self.localVideoView removeFromSuperview];
            [self.videoViewContainer addSubview:self.localVideoView];
        }
        */

        
        //---------- ---------- end ---------- ----------
        //- (void)layoutRemoteView:(NSMutableArray *)layoutInfo layoutMode:(SVCLayoutModeType)mode
        //---------- ---------- end ---------- ----------
        
        console.log("---------- 4 ----------  ----------  ---------- ")
        console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: Exit");
    }
    
    
    function getVideoViewControllerByViewId(dataSourceID) {
        var videoRenderView = null;
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            videoRenderView = m_remotePeopleVideoViewList[i];
            //VideoRenderView.qml, VideoRender.cpp
            //MetalvideoRenderView *view = _remotePeoplevideoRenderViewList[i]; (-> MetalvideoRenderViewRender.cpp)
            console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: -> get m_remotePeopleDataSourceID [", i, "] videoRenderView of VideoRenderView.qml. videoRenderView.strDisplayName: " + videoRenderView.strDisplayName + ", dataSourceID: " + videoRenderView.dataSourceID + ", visible: " + videoRenderView.visible);
            
            if (-1 !== videoRenderView.dataSourceID.indexOf(dataSourceID)) {
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: find the videoRenderView.dataSourceID === dataSourceID, is m_remotePeopleVideoViewList[i: " + i + "]");
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: videoRenderView.dataSourceID = dataSourceID: ", dataSourceID);
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: videoRenderView.strDisplayName: " + videoRenderView.strDisplayName + ", set videoRenderView.dataSourceID: " + dataSourceID);
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: videoRenderView rect[" + videoRenderView.x + ", " + videoRenderView.y + ", " + videoRenderView.width + ", " + videoRenderView.height + "]");
                //console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: set videoRenderView.visible = true");
                //videoRenderView.visible = true;
                return videoRenderView;
            }
        }
        
        console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: not find dataSourceID: " + dataSourceID + ", in m_remotePeopleVideoViewList[]");
        
        for (var index = 0; index < m_remotePeopleVideoViewList.length; ++index) {
            videoRenderView = m_remotePeopleVideoViewList[index];
            //VideoRenderView.qml, VideoRender.cpp
            //MetalvideoRenderView *view = _remotePeoplevideoRenderViewList[i]; (-> MetalvideoRenderViewRender.cpp)
            if (false === videoRenderView.visible) { //[macOS]: MetalvideoRenderView *view, view.hidden
                //console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: -> get  [VideoRenderView.qml]: m_remotePeopleDataSourceID [", i, "]: set videoRenderView.dataSourceID = dataSourceID: ", dataSourceID);
                //videoRenderView.dataSourceID = dataSourceID;
                
                //console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: -> get [VideoRenderView.qml]: m_remotePeopleDataSourceID [", i, "]: -> call  videoRenderView.setRenderSourceID(dataSourceID: " + dataSourceID + ")");
                //videoRenderView.setRenderSourceID(dataSourceID);
                
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: not find dataSourceID: " + dataSourceID + ", so will set one false === videoRenderView.visible, in m_remotePeopleVideoViewList[i: " + i + "]");
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: -> set videoRenderView.dataSourceID = dataSourceID: ", dataSourceID);
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: videoRenderView.strDisplayName: " + videoRenderView.strDisplayName + ", set videoRenderView.dataSourceID: " + dataSourceID);
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: videoRenderView rect[" + videoRenderView.x + ", " + videoRenderView.y + ", " + videoRenderView.width + ", " + videoRenderView.height + "]");
                
                //videoRenderView.dataSourceID = dataSourceID;
                console.log("[SVCLayout.qml][getVideoViewControllerByViewId]: [" + i + "]: -> call remoteMVV.setRenderSourceID(dataSourceID: ", dataSourceID + ")");
                videoRenderView.setRenderSourceID(dataSourceID);
                return videoRenderView;
            }
        }
        return null;
    }
    
    //[macOS]: - (void)remoteVideoReceived:(NSString *)dataSourceID {}
    
    function dealwithRecvMsgRemoteVideoReceived(arg) {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: Enter")
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: called by FMeetingViewController.qml: onCppSendMsgToQMLRemoteVideoReceived() -> remote_video_svclayout_views.dealwithRecvMsgRemoteVideoReceived(datasourceid).")
        var detail = arg;
        var dataSourceID = detail.dataSourceID;
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: svc dataSourceID = detail.dataSourceID: ", detail.dataSourceID);
    
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: m_remotePeopleDataSourceID.length: ", m_remotePeopleDataSourceID.length);

        //[FMeetingViewController.m]: - (void)remoteVideoReceived:(NSString *)dataSourceID
        var isFind = false;
        for (var i = 0; i < m_remotePeopleDataSourceID.length; ++i) {
            var sourceID = m_remotePeopleDataSourceID[i];
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: m_remotePeopleDataSourceID [" + i + "] sourceID: " + sourceID)
            if (-1 !== sourceID.indexOf(dataSourceID)) {
                isFind = true;
                break;
            }
        }
        
        if (false === isFind) {
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: false === isFind, so -> call m_remotePeopleDataSourceID.push(dataSourceID: ", dataSourceID);
            m_remotePeopleDataSourceID.push(dataSourceID);
        }
    
        if (-1 !== dataSourceID.indexOf("C_R")) {
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: 1. dataSourceID: " + dataSourceID + ", include C_R, is remote content video.");
            
            //TODO: -yingyong.Mao -2022-11-13
            
            //[Note]: will call [VideoRender.cpp]: onDataSourceIDChanged:{}
            
            //console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: set contentVideoView.dataSourceID = dataSourceID: ", dataSourceID);
            //[self.contentVideoView setRenderSourceID:dataSourceID];
            //contentVideoView.dataSourceID = dataSourceID;
            //console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: -> call contentVideoView.setRenderSourceID(dataSourceID: ", dataSourceID, ")");
            //contentVideoView.setRenderSourceID(dataSourceID);
            
            //console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: -> set contentVideoView.dataSourceID = dataSourceID: ", dataSourceID);
            //contentVideoView.dataSourceID = dataSourceID;
            
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: [" + i + "]: -> call remoteMVV.setRenderSourceID(dataSourceID: ", dataSourceID + ")");
            contentVideoView.setRenderSourceID(dataSourceID);

            //contentVideoView.strDisplayName = strDisplayName
            
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: -> call contentVideoView.startRendering(): dataSourceID: " + dataSourceID);
            contentVideoView.startRendering();
            contentVideoView.renderMuteImage(false);

            /*
            if (self.isWaterMask) {
                [self.contentVideoView configContentWaterMask:self.callName];
            }
            */
            

            
        } else {
            console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: 2. dataSourceID: " + dataSourceID + ", not include C_R, not remote content, is remote people video.");
            
            //if (videoInfo.resolution_width === -1) {
            //    console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: videoInfo.eVideoType === 1 (VIDEO_TYPE_REMOTE), and ideoInfo.resolution_width === -1, so do nothing, for the dataSourceID: " + videoInfo.dataSourceID + ")");

            //} else if (videoInfo.resolution_width !== -1) { //VIDEO_TYPE_REMOTE
                console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: VIDEO_TYPE_REMOTE: remote people vodeo. -> call videoView = getVideoViewControllerByViewId(dataSourceID: " + dataSourceID + ")");

                var videoView = getVideoViewControllerByViewId(dataSourceID);
                console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: videoView.strDisplayName: " + videoView.strDisplayName + ", videoView.dataSourceID: " + videoView.dataSourceID);
                console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: videoView rect[" + videoView.x + ", " + videoView.y + ", " + videoView.width + ", " + videoView.height + "]");
                
                if (videoView === null || videoView === undefined) {
                    console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: FMeeting View Controller remote Video Received == null");

                } else {
                    //console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: -> call showRemoteMVVVideoViewRect(remoteMVV) ");
                    //showRemoteMVVVideoViewRect("dealwithRecvMsgRemoteVideoReceived", videoView); //findIndex
                    
                    //console.log("||| ||| [SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: -> call showRemotePeopleVideoViewList().");
                    //showRemotePeopleVideoViewList();

                    videoView.renderMuteImage(false); //[view renderMuteImage:NO];
                    
                    console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: -> call videoView.startRendering(): dataSourceID: " + videoView.dataSourceID);
                    videoView.startRendering(); //[view startRendering];
                    //videoView.visible = true;
                    videoView.setVisible(true);
                }
            //}
        }
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteVideoReceived]: Exit")
    }
    
    function dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute) {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewRenderMuteImage]: called by FMeetingViewController.qml: onCppSendMsgToQMLRemoteContentVideoViewRenderMuteImage() -> remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute).")
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewRenderMuteImage]: -> call contentVideoView.renderMuteImage(mute: " + mute + ")");
        contentVideoView.renderMuteImage(mute);
    }
    
    function dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden) {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewSetHidden]: called by FMeetingViewController.qml: dealwithRecvMsgRemoteContentVideoViewSetHidden() -> remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden).")
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewSetHidden]: -> call contentVideoView.visible = !hidden: " + !hidden + ")");
        contentVideoView.visible = !hidden;
    }
    
    function dealwithRecvMsgRemoteContentVideoViewStartRendering() {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewStartRendering]: called by FMeetingViewController.qml: onCppSendMsgToQMLRemoteContentVideoViewStartRendering() -> remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute).")
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewStartRendering]: -> call contentVideoView.startRendering()");
        contentVideoView.startRendering();
    }
    
    function dealwithRecvMsgRemoteContentVideoViewStopRendering() {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewStopRendering]: called by FMeetingViewController.qml: onCppSendMsgToQMLRemoteContentVideoViewStopRendering() -> remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute).")
        
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewStopRendering]: -> call contentVideoView.stopRendering()");
        contentVideoView.stopRendering();
    }
    
}
