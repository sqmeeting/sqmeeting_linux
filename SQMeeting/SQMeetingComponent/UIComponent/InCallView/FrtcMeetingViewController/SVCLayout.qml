import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia 5.9

Rectangle{
    id: svc_layout_view
    width: 1024
    height: 691
    visible: true
    color: "black"

    property var screenWidth
    property var screenHeight

    property int screen_ratio: root.screen_ratio

    property int disPlayWidth: root.disPlayWidth
    property int disPlayHeight: root.disPlayHeight
    
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

    property bool isFullScreen: false;
    property bool isTraditionalLayout: true;
    property bool contentLayoutReady: false

    property bool isRemoteViewHidden: false;

    property bool isSendingContent: false;
    property bool isContent: false;


    property bool isLocalViewHiddenByUser: false;
    property string cellCustomUUID: "";
    
    //========================================
    // for layout details.
    //========================================

    property int mode: 0
    property var gSvcLayoutDetail : []
    property var gSvcLayoutDetail_videoViewDescription : []
    
    //========================================
    // for QML life cycle.
    //========================================

    Component.onCompleted: {
        svc_layout_view.peopleViewWidth = root.disPlayWidth;
        svc_layout_view.peopleViewHeight = root.disPlayHeight * 0.8;

        svc_layout_view.contentVideoViewWidth = root.disPlayWidth;
        svc_layout_view.contentVideoViewHeight = root.disPlayHeight * 0.8;
        getSvcLayoutDetail();
        for (var i = 0; i < 9; ++i) {
           createRemotePeopleVideoViewList(i);
        }

        createLocalPeopleVideoView(9);

        createRemoteContentVideoView(10);
    }

    Component.onDestruction: {
        if (undefined !== localVideoView) {
            localVideoView.clearRenderSourceID()
            localVideoView.destroy()
        }

        if (undefined !== contentVideoView) {
            contentVideoView.clearRenderSourceID()
            contentVideoView.destroy()
        }

        if (undefined !== m_remotePeopleVideoViewList) {
            for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
                var videoRenderView = m_remotePeopleVideoViewList[i]

                if (undefined !== videoRenderView) {
                    videoRenderView.clearRenderSourceID()
                    videoRenderView.destroy()
                }
            }
            m_remotePeopleVideoViewList = []
        }

    }

    function getTraditionalLayout() {
        isTraditionalLayout = root.getTraditionalLayout()
    }

    function getSvcLayoutDetail() {
        var detail = root.getSvcLayoutDetail();

        mode = detail.currentSvcLayoutMode;
        var nCountVideoView = mode + 1;
        var isSymmetical = detail.isSymmetical;
        var strRowArray = detail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)
        
        gSvcLayoutDetail_videoViewDescription = strRowArray;
    }
    
    function getCellCustomUUID() {
        var cellCustomUUID = root.getCellCustomUUID();
        return cellCustomUUID;
    }
      
    function showRemotePeopleVideoViewList() {
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            var videoRenderView = m_remotePeopleVideoViewList[i];
       }
    }
    
    function createRemotePeopleVideoViewList(windowId) {
        var component = Qt.createComponent("VideoRenderView.qml");
        if (component.status === Component.Ready) {
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.

            newVideoView.x = 0 //col * 150 + 70
            newVideoView.y = 0 //row * 120 + 70
            //newVideoView.showInfo = windowId + 1

            newVideoView.dataSourceID = "remote" //call-1_6"
            newVideoView.setDisplayName(" ")
            newVideoView.eVideoType = 0
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false

            newVideoView.showVideoview(false)

            m_remotePeopleVideoViewList.push(newVideoView);
            return true
        }


        return false
    }

    function createLocalPeopleVideoView(windowId) {
        var component = Qt.createComponent("LocalVideoRenderView.qml");
        if (component.status === Component.Ready) {
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.

            newVideoView.x = 0 //col * 150 + 70
            newVideoView.y = disPlayHeight / 12
            newVideoView.width = disPlayWidth
            newVideoView.height = disPlayHeight * 0.8

            newVideoView.setRenderSourceID("VPL_PREVIEW")
            
            newVideoView.setDisplayName(" ")
            newVideoView.eVideoType = 0 //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false

            localVideoView = newVideoView

            return true
        }


        return false
    }
    
    function createRemoteContentVideoView(windowId) {
        var component = Qt.createComponent("VideoRenderView.qml");
        if (component.status === Component.Ready) {
            var newVideoView = component.createObject(svc_layout_view, {text:windowId + 1}); //parent: svc_layout_view.

            newVideoView.x = 0
            newVideoView.y = disPlayHeight / 12
            newVideoView.width = disPlayWidth
            newVideoView.height = disPlayHeight * 0.8


            newVideoView.dataSourceID = "content"

            newVideoView.setDisplayName(" ")
            newVideoView.eVideoType = 2 //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            newVideoView.removed = false
            newVideoView.active = false
            newVideoView.maxResolution = false
            newVideoView.pin = false;

            contentVideoView = newVideoView;
            contentVideoView.setVisible(false);
            
            return true
        }
        return false
    }
    
    function hideAllVideoView() {
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            var videoRenderView = m_remotePeopleVideoViewList[i]
            videoRenderView.showVideoview(false)
        }
    }

    function showLocalPreview(aShow) {
        if (true === aShow) {
            localVideoView.color = "white"
            localVideoView.opacity = 1
        } else {
            localVideoView.color = "transparent"
            localVideoView.opacity = 0
        }
    }

    function localVideoMute(mute) {
        if (true === mute) {
            localVideoView.renderMuteImage(mute);
            localVideoView.stopRendering();
        } else {
            localVideoView.startRendering();
            localVideoView.renderMuteImage(mute);
        }

    }
    
    function setLocalVideoRect(x, y, w, h) {
        localVideoView.x = x;
        localVideoView.y = y;
        localVideoView.width = w;
        localVideoView.height = h;
        
        localVideoView.setFrameSize(x, y, width, height);

        localVideoView.setVisible(true);

    }
    
    function setContentVideoRect(x, y, w, h) {
        contentVideoView.x = x;
        contentVideoView.y = y;
        contentVideoView.width = w;
        contentVideoView.height = h;
        
        contentVideoView.setFrameSize(x, y, width, height);
        contentVideoView.showVideoview(true)
    }
    
    //remote people.
    
    function setRemoteMVVVideoViewRect(remoteMVV, x, y, w, h) {
        remoteMVV.x      = x
        remoteMVV.y      = y
        remoteMVV.width  = w
        remoteMVV.height = h
        
        remoteMVV.setFrameSize(x, y, width, height);
        remoteMVV.showVideoview(true)
    }
    


    function dealwithRecvMsgRemoteViewHiddenOrNot(arg) {
       var detail = arg;

        var viewArray = detail.viewArray;

        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            var videoRenderView = m_remotePeopleVideoViewList[i]; // [VideoRenderView.qml]:

            var bFind = false;
            for (var j = 0; j < viewArray.length; ++j) {
                var videoInfo = viewArray[j]; //SVCVideoInfo *videoInfo = viewArray[j];
                if (null !== videoRenderView.dataSourceID && undefined !== videoRenderView.dataSourceID
                    && null !== videoInfo.dataSourceID && undefined !== videoInfo.dataSourceID
                    && videoRenderView.dataSourceID === videoInfo.dataSourceID) {
                    bFind = true;
                    break;
                }
            }
            if (false === bFind ) {
                videoRenderView.showVideoview(false) //hide this videoRenderView for next remote user's video to show.
                videoRenderView.renderMuteImage(true)
                videoRenderView.stopRendering()
                videoRenderView.clearRenderSourceID()
            } else {
                videoRenderView.showVideoview(true)
                videoRenderView.renderMuteImage(false)
            }
        }
    }
        
    function dealwithRecvMsgPrepareSVCLayout(aMode, arg2) {

        mode = aMode;
        var detail = arg2;
        
        //2.for mode
        var nCountVideoView = mode + 1;
        var isSymmetical = detail.isSymmetical;
        var strRowArray = detail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)

        hideAllVideoView();
        
        for (var i = 0; i <= nCountVideoView; ++i) {
            var columnArray = strRowArray[i];
            var x = columnArray[0];
            var y = columnArray[1];
            var w = columnArray[2];
            var h = columnArray[3];

            var rowArray = [x, y, w, h];

            gSvcLayoutDetail_videoViewDescription[i] = rowArray;
        }
    }

    function dealwithRecvMsgRefreshLayoutMode(aMode, aDetail) {
        mode = aMode;
        var detail = aDetail;
        var strRowArray = aDetail.videoViewDescription; //rowCount of the array (detail.videoViewDescription)
        gSvcLayoutDetail_videoViewDescription = strRowArray;

        var viewArray = aDetail.viewArray;

        dealwithRecvMsgRemoteViewHiddenOrNot(aDetail);
        dealwithRecvMsgLayoutRemoteView(mode, aDetail);
    }
    
    function getLineNumber() {
        return parseInt(new Error().stack.split(':')[7]);
    }
    
    function dealwithRecvMsgLayoutRemoteView(arg1, arg2) {
        getTraditionalLayout()
        var videoMode = arg1;
        var detail = arg2;
        var viewArray = detail.viewArray; //layoutInfo

        for (var i = 0; i < viewArray.length; ++i) {
            var remoteMVV = null;
            var videoInfo = viewArray[i];

            //0:VIDEO_TYPE_LOCAL; 1:VIDEO_TYPE_REMOTE; 2:VIDEO_TYPE_CONTENT; 3:VIDEO_TYPE_INVALID.
            if (videoInfo.eVideoType === 1) { //VIDEO_TYPE_REMOTE
                remoteMVV = getVideoViewControllerByViewId(videoInfo.dataSourceID);
                remoteMVV.setDisplayName(videoInfo.strDisplayName)
                remoteMVV.uuid = videoInfo.strUUID

                var isFind = false;
                var findIndex = -1;

                for (var j = 0; j < m_remotePeopleDataSourceID.length; ++j) {
                    var sourceID = m_remotePeopleDataSourceID[j];
                    ////console.log("[SVCLayout.qml][dealwithRecvMsgLayoutRemoteView]: m_remotePeopleDataSourceID [", j, "] sourceID: ", sourceID);
                    if (null !== sourceID && undefined !== sourceID
                        && null !== videoInfo.dataSourceID && undefined !== videoInfo.dataSourceID
                        && sourceID === videoInfo.dataSourceID) {
                        findIndex = j;
                        isFind = true;
                        break;
                    }
                }

                if (isFind) {
                    if (null !== remoteMVV && undefined !== remoteMVV) {

                        remoteMVV.startRendering();
                        remoteMVV.showVideoview(true);
                    }
                }
            }
            
            var x = 0;
            var y = 0;
            var width = 0;
            var height = 0;

            if (true === isFullScreen && i === 0) { //1.full screen and is [0].
                if (true === isTraditionalLayout) { //1x5

                } else {

               }
                
            } else {
                if (true === isFullScreen) { //2.1.full screen and not [0]
                    if (true === isTraditionalLayout) {

                    } else {
                        if (videoInfo.eVideoType === 0) { //0: VIDEO_TYPE_LOCAL

                        } else {

                        }
                    }
                } else { //2.2.not full screen.
                    var rowArray = gSvcLayoutDetail_videoViewDescription[i];

                    x       = rowArray[0] * root.disPlayWidth;
                    y       = rowArray[1] * root.disPlayHeight;
                    width   = rowArray[2] * root.disPlayWidth;
                    height  = rowArray[3] * root.disPlayHeight;
                 }
            }
            

            if (videoInfo.eVideoType === 0) { //0: VIDEO_TYPE_LOCAL
                if (viewArray.length === 1) {
                   if (true === contentLayoutReady) {
                        setLocalVideoRect(0, 0, 320 * screen_ratio, 180 * screen_ratio);
                    } else {
                        if (true === isFullScreen) {
                        } else {
                            setLocalVideoRect(0, disPlayHeight / 12, disPlayWidth, disPlayHeight * 0.8);
                        }
                    }
                } else { //1.2.layoutInfo.count != 1
                    setLocalVideoRect(x, y, width, height);
                }

            } else if (videoInfo.eVideoType === 2) { //2: VIDEO_TYPE_CONTENT
                setContentVideoRect(x, y, width, height);
                contentVideoView.setDisplayName(videoInfo.strDisplayName)
            } else if (videoInfo.eVideoType === 1) { //1: VIDEO_TYPE_REMOTE

                    if (i !== 0) {
                        if (true === isFullScreen) {

                        }
                    }
                    if (contentLayoutReady) {
                       setRemoteMVVVideoViewRect(remoteMVV, 0, 0, 320 * screen_ratio, 180 * screen_ratio);
                    } else {
                        remoteMVV.uuid = videoInfo.strUUID;
                        remoteMVV.setDisplayName(videoInfo.strDisplayName);
      
                        remoteMVV.setRenderSourceID(videoInfo.dataSourceID);
                        remoteMVV.stopRendering();
                        
                        setRemoteMVVVideoViewRect(remoteMVV, x, y, width, height);

                        remoteMVV.startRendering();

                    }
            }

            remoteMVV.setUserPin(videoInfo.pin)

            // [macOS code]: == -2;
            // [on UOS / macOS]: actually, server data is resolution_width : -1.
            if (null !== remoteMVV && undefined !== remoteMVV) {
                if (videoInfo.eVideoType === 1 && videoInfo.resolution_width === -1) { //1: VIDEO_TYPE_REMOTE
                    remoteMVV.renderMuteImage(true) //[remoteMVV renderMuteImage:YES];
                    remoteMVV.stopRendering(); //[remoteMVV stopRendering];
                }
            }
           
           if (true === isRemoteViewHidden) {
                if (i !== 0) {
                    remoteMVV.showVideoview(false);
                }
                localVideoView.setVisible(false);
            } else {
                if (null !== remoteMVV && undefined !== remoteMVV) {
                   remoteMVV.showVideoview(true);
                }

                if (false === isLocalViewHiddenByUser) {
                    localVideoView.setVisible(true);
                }
            }
           
           if (null !== remoteMVV && undefined !== remoteMVV) {
               if (true === isContent) { //now it is receiving remote content.
                  if (videoInfo.active) {
                       remoteMVV.setAppearanceWithActive(true);
                   } else {
                      remoteMVV.setAppearanceWithActive(false);
                   }
               } else {
                   if (isSendingContent) { //now local is sending content to remote.
                      if (videoInfo.active) {
                          remoteMVV.setAppearanceWithActive(true);
                       } else {
                          remoteMVV.setAppearanceWithActive(false);
                       }
                   } else {
                       if (isTraditionalLayout) {
                              remoteMVV.setAppearanceWithActive(false);
                       } else {
                           if(viewArray.length === 2) {
                                remoteMVV.setAppearanceWithActive(false);
                            } else {
                               if (videoInfo.active) {
                                   remoteMVV.setAppearanceWithActive(true);
                               } else {
                                   remoteMVV.setAppearanceWithActive(false);
                               }
                           }
                       }
                   }
               }
           }
   
           svc_layout_view.cellCustomUUID = getCellCustomUUID()


           if (null !== remoteMVV && undefined !== remoteMVV) {
                if (null !== svc_layout_view.cellCustomUUID && undefined !== svc_layout_view.cellCustomUUID && svc_layout_view.cellCustomUUID !== "") {
                    if (true === videoInfo.active && true === videoInfo.pin) {
                      remoteMVV.setAppearanceWithActive(false);
                    } else {
                        if (true === videoInfo.active) {
                           remoteMVV.setAppearanceWithActive(true);
                        }
                    }
                }
           }
        }
    }
    
    
    function getVideoViewControllerByViewId(dataSourceID) {
        var videoRenderView = null;
        for (var i = 0; i < m_remotePeopleVideoViewList.length; ++i) {
            videoRenderView = m_remotePeopleVideoViewList[i];
            if (null !== videoRenderView.dataSourceID && undefined !== videoRenderView.dataSourceID
                && null !== dataSourceID && undefined !== dataSourceID
                && videoRenderView.dataSourceID === dataSourceID) {
                return videoRenderView;
            }
        }
        
        for (var index = 0; index < m_remotePeopleVideoViewList.length; ++index) {
            videoRenderView = m_remotePeopleVideoViewList[index];
            if (false === videoRenderView.isShow) {
                 videoRenderView.setRenderSourceID(dataSourceID);
                return videoRenderView;
            }
        }
        return null;
    }
    
    
    function dealwithRecvMsgRemoteVideoReceived(arg) {
        var detail = arg;
        var dataSourceID = detail.dataSourceID;
        var isFind = false;
        for (var i = 0; i < m_remotePeopleDataSourceID.length; ++i) {
            var sourceID = m_remotePeopleDataSourceID[i];
            if (null !== sourceID && undefined !== sourceID
                && null !== dataSourceID && undefined !== dataSourceID
                && sourceID === dataSourceID) {
                
                isFind = true;
                break;
            }
        }
        
        if (false === isFind) {
            m_remotePeopleDataSourceID.push(dataSourceID);
        }
    
        if (-1 !== dataSourceID.indexOf("VCR-")) {
            contentVideoView.setRenderSourceID(dataSourceID);
            contentVideoView.startRendering();
            
        } else {
            var videoView = getVideoViewControllerByViewId(dataSourceID);

            if (videoView === null || videoView === undefined) {

            } else {
                videoView.renderMuteImage(false);
                videoView.startRendering();
                videoView.showVideoview(true);
            }
        }
    }
    
    function dealwithRecvMsgRemoteContentVideoViewRenderMuteImage(mute) {
        contentVideoView.renderMuteImage(mute);
    }
    
    function dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden) {
        contentVideoView.visible = !hidden;
        isContent = !hidden
    }
    
    function dealwithRecvMsgRemoteContentVideoViewStartRendering() {
       contentVideoView.startRendering();
    }
    
    function dealwithRecvMsgRemoteContentVideoViewStopRendering() {
        console.log("[SVCLayout.qml][dealwithRecvMsgRemoteContentVideoViewStopRendering]: -> call contentVideoView.stopRendering()");
        contentVideoView.stopRendering();
    }
    
    //callBack: FMeetingWindowControllerObject call this one.
    function dealwithContentStateChangedCallBack(isSending) {
        if (isSending && isSendingContent || !isSending && !isSendingContent) {
            return
        }

        isSendingContent = isSending
        if (isSending) {
            contentLayoutReady = true;
        } else {
            contentLayoutReady = false;
        }
    }

    //Use roster list to syn every remote-user's mute states of Mic & Camera.
    function dealwithUpdateRosterList(rosterListObject) {
        var detail = rosterListObject;

        var rosterArray = detail.rosterListJsonArray;

        for (var i = 0; i < rosterArray.length; ++i) {
            var rosterInfo = rosterArray[i];

            rosterInfo.people = true;


            if (undefined !== rosterInfo) {
                //1.for remote people video view.
                for (var j = 0; j < m_remotePeopleVideoViewList.length; ++j) {
                    var videoRenderView = m_remotePeopleVideoViewList[j] // [VideoRenderView.qml]

                    if (true === videoRenderView.isShow) {
                        if (null !== videoRenderView.uuid && undefined !== videoRenderView.uuid
                            && null !== rosterInfo.uuid && undefined !== rosterInfo.uuid
                            && videoRenderView.uuid === rosterInfo.uuid) {
                            
                            var displayName = rosterInfo.display_name
                            videoRenderView.setDisplayName(displayName)

                            var muteAudio = rosterInfo.audio_mute


                            videoRenderView.setMicMuteState(muteAudio)
                        }
                    }
                }
                if (true === contentVideoView.isShow) {
                    if (null !== contentVideoView.strDisplayName && undefined !== contentVideoView.strDisplayName
                        && null !== rosterInfo.display_name && undefined !== rosterInfo.display_name
                        && contentVideoView.strDisplayName === rosterInfo.display_name) {
                        
                       var mutePeopleAudio = rosterInfo.audio_mute

                       if (mutePeopleAudio) {
                           contentVideoView.setMicMuteState(true)
                       } else {
                           contentVideoView.setMicMuteState(false)
                       }
                   }
                }

            }

        }

    }

}
