//
//  FMeetingViewController.qml
//  class FMeetingViewController.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2022/06/30.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

//import "./FrtcMeeting/UIComponent/OutOffCallView/FrtcMainViewController/View"
//import "./FrtcMeeting/UIComponent/OutOffCallView/FrtcAccountViewController/View"

import "./" //for ./MenuBarView.qml, TabButton.qml, TabBarView.qml, TitleButton.qml, SVCLayout.qml.
import "./../../../../../FrtcMeeting/UIComponent/InCallView/FrtcMeetingInfoView/View/" //for FrtcMeetingInfoView.qml
import "./../../../../../FrtcMeeting/UIComponent/InCallView/FrtcNetWorkInfoView/View/" //for FrtcNetWorkInfoView.qml



//import model which has been registed.
import com.frtc.FMeetingViewControllerObject 1.0 //class FMeetingViewController.cpp

//for TabButtons.
//import FrtcCallBarViewObject 1.0 //class FrtcCallBarView.cpp


Window {

//Rectangle{
    visible: true
    //id: fMeetingViewController_Window
    id: root
    //width: 1538 //960
    //height: 1032
    width: 1024
    height: 691

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    color: "#060606"

    title: qsTr("神旗")

    signal qmlUserLeaveMeetingSignal()

    //========================================
    // for screen ratio.
    //========================================

    //property var ratio
    property var screenWidth
    property var screenHeight
    
    property var view_width: 1024
    property var view_height: 691
    property var screen_ratio: 1

    property var disPlayWidth: 1024
    property var disPlayHeight: 691

    property var isVisibleMenuBarTabBar: false
    
    //[FrtcCallView.qml]: for make call, user config.
    property var  currentMeetingID: ""
    property var  currentUserName: ""
    property var  currentMicMute: true
    property var  currentCameraMute: true
    property var  currentAudioOnly: false

    //meetingInfo
    property var conferenceName: ""
    property var meetingID: ""
    property var ownerName: ""
    property var meetingPasscode: ""

    //gallery menu Button
    property var  isGallery: false


    //=================================================
    // [UserConfig]
    //=================================================
    
    function setUserConfig(meetingID, userName, micMute, cameraMute, audioOnly) {
        currentMeetingID = meetingID
        currentUserName = userName
        currentMicMute = micMute
        currentCameraMute = cameraMute
        currentAudioOnly = audioOnly

        console.log("[FMeetingViewController.qml][showUserConfig]: "
                    + ": currentMeetingID: " + currentMeetingID
                    + ", currentUserName :" + currentUserName
                    + ", currentMicMute: " + currentMicMute
                    + ", currentCameraMute: " + currentCameraMute
                    + ", currentAudioOnly: " + currentAudioOnly);

        //update UI.
        updateUIAsLocalUserConfigFile()
    }

    function updateUIAsLocalUserConfigFile() {
        rectangle_tab_bar.setMicMute(currentMicMute);
        rectangle_tab_bar.setCameraMute(currentCameraMute);

        console.log("[FMeetingViewController.qml][updateUIAsLocalUserConfigFile()]: -> call remote_video_svclayout_views.localVideoMute(currentCameraMute: " + currentCameraMute + ")");
        remote_video_svclayout_views.localVideoMute(currentCameraMute);
    }

    //=================================================
    // 1.[MenutBar][TitleButton]
    //=================================================

    //-------------------------------------------------
    // 1.1.[MenutBar][TitleButton]: Meeting Info View.
    //-------------------------------------------------

    //[get]
    function qmlGetMeetingInfo() {
        console.log("[FMeetingViewController.qml][qmlGetMeetingInfo]: -> call FMeetingViewControllerObject.onQmlGetMeetingInfo()");
        var meetingInfo = FMeetingViewControllerObject.onQmlGetMeetingInfo();
        console.log("[FMeetingViewController.qml][qmlGetMeetingInfo]: -> meetingInfo: ", meetingInfo);

        conferenceName = meetingInfo.conferenceName
        meetingID = meetingInfo.meetingID
        ownerName = meetingInfo.ownerName
        meetingPasscode = meetingInfo.meetingPasscode

        console.log("[FMeetingViewController.qml][onQmlGetMeetingInfo]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        return meetingInfo;
    }

/*
    //for menubar title_meeting_info_button: MeetingInfoView
    function showMeetingInfoView() {
        console.log("[FMeetingViewController.qml][showMeetingInfoView()]: mouse hover entered -> call meeting_info_view.showMeetingInfoView().")
        //console.log("[UI][FMeetingViewController.qml][showMeetingInfoView()]: conferenceName: " + root.conferenceName + "meetingID: " + root.meetingID + ", ownerName: " + root.ownerName + ", meetingPasscode: " + root.meetingPasscode)
        id_mouseArea.rectangle_menu_bar_meeting_info_view.showMeetingInfoView(root.conferenceName, root.meetingID, root.ownerName, root.meetingPasscode)
    }

    function hideMeetingInfoView() {
        console.log("[UI][FrtcMeetingInfoView.qml][hideMeetingInfoView]: -> call meeting_info_view.hideMeetingInfoView()")
        id_mouseArea.rectangle_menu_bar_meeting_info_view.hideMeetingInfoView()
    }
*/


    //-------------------------------------------------
    // 1.2.[MenutBar][TitleButton]: NetWork Info View.
    //-------------------------------------------------

    function qmlGetNetWorkInfoView() {
        console.log("[FMeetingViewController.qml][initNetWorkInfoView]: -> call ");

    }

    //for menubar title_meeting_info_button: MeetingInfoView
    function showNetWorkInfoView() {
        console.log("[FMeetingViewController.qml][showNetWorkInfoView()]: mouse hover entered -> call network_info_view.showInfoView().")
        network_info_view.showInfoView()
    }

    function hideNetWorkInfoView() {
        console.log("[UI][FrtcMeetingInfoView.qml][hideNetWorkInfoView]: -> call network_info_view.hideInfoView()")
        network_info_view.hideInfoView()
    }


    //-------------------------------------------------
    // 1.3.[MenutBar][TitleButton]: Gallery Info View.
    //-------------------------------------------------

    //true: "gallery"; false: "presenter"

    function switchGridMode(bGallery) {
        console.log("[FMeetingViewController.qml][switchGridMode()]: -> call FMeetingViewControllerObject.onQmlSwitchGridMode(bGallery: " + bGallery)
        FMeetingViewControllerObject.onQmlSwitchGridMode(bGallery)
    }


    //-------------------------------------------------
    // 1.4.[MenutBar][TitleButton]: FullScreen View.
    //-------------------------------------------------



    //=================================================
    // 2.[TabBarView][TabButton]
    //=================================================

    //-------------------------------------------------
    // 2.1.[TabBarView][TabButton]: local Audio mute/unmute.
    //-------------------------------------------------

    //[set] user click the TabButton call those methods.
    // [TabBarView.qml][TabButton][tabbar_camera_mute_button][onMouseClicked:] call this method.
    function onQmlLocalAudioMute(localAudioMute) {
        console.log("[FMeetingViewController.qml][function onQmlLocalAudioMute] : localAudioMute: " + localAudioMute);

        console.log("[FMeetingViewController.qml][rectangle_tab_bar][TabButton]: Tabbar audio_mute Button clicked, -> call FMeetingViewControllerObject.onQmlLocalAudioMute(localAudioMute: " + localAudioMute + ")");
        //id_frtcCallBarViewObject.onQmlLocalAudioMute(localAudioMute);
        FMeetingViewControllerObject.onQmlLocalAudioMute(localAudioMute);
    }

    //-------------------------------------------------
    // 2.2.[TabBarView][TabButton]: local Camera mute/unmute.
    //-------------------------------------------------

    // [TabBarView.qml][TabButton][tabbar_camera_mute_button][onMouseClicked:] call this method.
    function onQmlLocalVideoMute(localVideoMute) {
        console.log("[FMeetingViewController.qml][function onQmlLocalVideoMute] : localVideoMute: " + localVideoMute);

        console.log("[FMeetingViewController.qml][rectangle_tab_bar][TabButton]: Tabbar video_mute Button clicked, -> call FMeetingViewControllerObject.onQmlLocalVideoMute(localVideoMute: " + localVideoMute + ")");
        FMeetingViewControllerObject.onQmlLocalVideoMute(localVideoMute);
    }

    //-------------------------------------------------
    // 2.3.[TabBarView][TabButton]: share content.
    //-------------------------------------------------

    //-------------------------------------------------
    // 2.4.[TabBarView][TabButton]: local preview open/close.
    //-------------------------------------------------

    //User action call this one.
    function onQmlLocalPreview(aShow) {
        //console.log("[FMeetingViewController.qml][onQmlLocalPreview]: from [TabButton]: Tabbar tabbar_local_preview_button Button clicked] -> call rectangle_main_view.signalShowLocalPreview(aShow: " + aShow + ")");
        //rectangle_main_view.signalShowLocalPreview(aShow)

        console.log("[FMeetingViewController.qml][onQmlLocalPreview]: from [TabButton]: Tabbar tabbar_local_preview_button Button clicked] -> call rectangle_main_view.showLocalPreview(aShow: " + aShow + ")");
        rectangle_main_view.showLocalPreview(aShow)
    }

    //SDK API call this one.
    function setLocalPreviewEnable(aEnable) {
        console.log("[FMeetingViewController.qml][updateUIAsLocalUserConfigFile()]: -> call rectangle_tab_bar.setLocalPreviewEnable(aEnable: " + aEnable + ")");
        rectangle_tab_bar.setLocalPreviewEnable(aEnable)
    }

    //-------------------------------------------------
    // 2.5.[TabBarView][TabButton][tabbar_invitate_button]: .
    //-------------------------------------------------

    //for tabBar button: invitation: dialog
    function showInvitationDialog() {
        console.log("[FMeetingViewController.qml][showInvitationDialog]: -> call invitation_dialog.show()");
        invitation_dialog.show();
    }

    //-------------------------------------------------
    // 2.6.[TabBarView][TabButton][tabbar_participant_button]:.
    //-------------------------------------------------

    //-------------------------------------------------
    // 2.7.[TabBarView][TabButton][tabbar_setting_button]: .
    //-------------------------------------------------



    //-------------------------------------------------
    // 2.8.[TabBarView][TabButton][tabbar_dropcall_button]: user dropCall to leave the conference.
    //-------------------------------------------------

    //for tabBar button: dropCall: dialog
    function showAskLeavMeetingDialog() {
        console.log("[FMeetingViewController.qml][showAskLeavMeetingDialog]: -> call ask_leave_meeting_dialog.show()");
        ask_leave_meeting_dialog.show();
    }




    //========================================
    // for screen change.
    //========================================
    
    function currentSize() {
        console.log("[FMeetingViewController.qml][function currentSize] : ");
        screenWidth = Screen.desktopAvailableWidth;
        screenHeight = Screen.desktopAvailableHeight;
        if (screenHeight >= 1200) {
            console.log("[FMeetingViewController.qml][function currentSize()]: [1536, 1037]");
            return {width: 1536, height: 1037};
        } else if (screenHeight >= 1000 && screenHeight < 1200) {
            console.log("[FMeetingViewController.qml][function currentSize()]: [1280, 864]");
            return {width: 1280, height: 864};
        } else if (screenHeight >= 800 && screenHeight < 1000) {
            console.log("[FMeetingViewController.qml][function currentSize()]: [1024, 691]");
            return {width: 1024, height: 691};
        } else {
            console.log("[FMeetingViewController.qml][function currentSize()]: [819, 551]");
            return {width: 819, height: 551};
        }
    }

    function screenRatio() {
        console.log("[FMeetingViewController.qml][function screenRatio] : ");
        screenWidth = Screen.desktopAvailableWidth;
        screenHeight = Screen.desktopAvailableHeight;
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
    
    function getSvcLayoutDetail() {
        console.log("[FMeetingViewController.qml][getSvcLayoutDetail]: -> call FMeetingViewControllerObject.getSvcLayoutDetail()");
        var detail = FMeetingViewControllerObject.getSvcLayoutDetail();
        console.log("[FMeetingViewController.qml][getSvcLayoutDetail]: -> detail: ", detail);
        return detail;
    }
    
    function getCellCustomUUID() {
        console.log("[FMeetingViewController.qml][getCellCustomUUID]: -> call FMeetingViewControllerObject.getCellCustomUUID()");
        var cellCustomUUID = FMeetingViewControllerObject.getCellCustomUUID();
        return cellCustomUUID;
    }

    //========================================
    // for QML life cycle.
    //========================================

    Component.onCompleted: {
        console.log("[FMeetingViewController.qml][Component.onCompleted:]: [user config][from FrtcCallView.qml initInCallUI()] "
                    + ": currentMeetingID: " + currentMeetingID
                    + ", currentUserName :" + currentUserName
                    + ", currentMicMute: " + currentMicMute
                    + ", currentCameraMute: " + currentCameraMute
                    + ", currentAudioOnly: " + currentAudioOnly);

        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> call currentSize()");
        var sizeObj = currentSize();
        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> set current window size [width, height] : ", sizeObj.width, ", ", sizeObj.height);

        root.width = sizeObj.width;
        root.height = sizeObj.height;

        root.maximumWidth = root.width
        root.maximumHeight = root.height
        root.minimumWidth = root.width
        root.minimumHeight = root.height

        root.disPlayWidth = sizeObj.width;
        root.disPlayHeight = sizeObj.height;

        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> call screenRatio()");
        screen_ratio = screenRatio()
        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> screen_ratio : ", screen_ratio);

        rectangle_main_view.width = root.disPlayWidth
        rectangle_main_view.height = root.disPlayHeight

        console.log("[FMeetingViewController.qml][Component.onCompleted:][for dropCall]: -> root.qmlUserLeaveMeetingSignal.connect(FMeetingViewControllerObject.onQmlUserLeaveMeeting)");
        //connect(root,  signal(qmlUserLeaveMeetingSignal()), FMeetingViewControllerObject, slot(onQmlUserLeaveMeeting()));
        root.qmlUserLeaveMeetingSignal.connect(FMeetingViewControllerObject.onQmlUserLeaveMeeting);
        
        
        let childs = rectangle_main_view.children;
        for (let i = 0; i < childs.length; ++i) {
            console.log("[FMeetingViewController.qml][Component.onCompleted:]: child UI: rectangle_main_view Component.onCompleted:");
        }

        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> call qmlGetMeetingInfo(), then call FMeetingViewControllerObject.onQmlGetMeetingInfo");
        qmlGetMeetingInfo()
    }

    Component.onDestruction: {
        console.log("[FMeetingViewController.qml][Component.onCompleted:]: -> Destruction Beginning!");

    }

    //========================================
    // 0.[CPP Object]: FMeetingViewControllerObject
    //========================================

    Connections {
        target: FMeetingViewControllerObject; //created by function main().
        //    id: FMeetingViewControllerObject

        //[FMeetingViewController.cpp]: slotPrepareSVCLayout(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLPrepareSVCLayout(mode, value);
        onCppSendMsgToQMLPrepareSVCLayout: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLPrepareSVCLayout]: ");

            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLPrepareSVCLayout]: value from cpp FMeetingViewControllerObject， mode: " + mode + ", varValue" + value);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLPrepareSVCLayout]: -> call remote_video_svclayout_views.dealwithRecvMsgPrepareSVCLayout(mode: " + mode + ", value: " + value + ")");
            remote_video_svclayout_views.dealwithRecvMsgPrepareSVCLayout(mode, value)
        }
        
        //[FMeetingViewController.cpp]: slotRemoteViewHiddenOrNot(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLRemoteViewHiddenOrNot(mode, value);
        onCppSendMsgToQMLRemoteViewHiddenOrNot: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteViewHiddenOrNot]: value from cpp FMeetingViewControllerObject，varValue: " + value);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteViewHiddenOrNot]: -> call remote_video_svclayout_views.dealwithRecvMsgRemoteViewHiddenOrNot(view: " + value + ")");
            remote_video_svclayout_views.dealwithRecvMsgRemoteViewHiddenOrNot(value)
        }

        //[FMeetingViewController.cpp]: slotRefreshLayoutMode(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLRefreshLayoutMode(mode, value);
        onCppSendMsgToQMLRefreshLayoutMode: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: value from cpp FMeetingViewControllerObject， mode: " + mode + ", varValue" + value);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: -> call remote_video_svclayout_views.dealwithRecvMsgRefreshLayoutMode(mode: " + mode + ", view: " + value + ")");
            
            //Test ---------- show data ---------- ---------- ----------
            var videoViewNum = value.videoViewNum;
            var isSymmetical = value.isSymmetical;
            var strRowArray = value.videoViewDescription;
            
            //console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: gSvcLayoutDetail_videoViewDescription = strRowArray");
            //gSvcLayoutDetail_videoViewDescription = strRowArray;
            console.log("+++ [FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode] mode: ", mode, ", strRowArray.length: ", strRowArray.length);
            for (var i = 0; i < strRowArray.length; ++i) {
                console.log("+++ [FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: detail.videoViewDescription[" + i + "]: ", strRowArray[i]);
            }
            
            //Test ---------- show data ---------- ---------- ----------
            var viewArray = value.viewArray;
            console.log("svc viewArray: ", viewArray);
            console.log("svc viewArray.length: ", viewArray.length);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo: mode: " + mode + ", viewArray.length: ", viewArray.length);
            for (var i = 0; i < viewArray.length; ++i) {
                var videoInfo = viewArray[i];
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo ---------- [i: " + i + "] ----------");
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.dataSourceID: ", videoInfo.dataSourceID);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.strDisplayName: ", videoInfo.strDisplayName);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.strUUID: ", videoInfo.strUUID);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.eVideoType: ", videoInfo.eVideoType);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.removed: ", videoInfo.removed);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.active: ", videoInfo.active);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.maxResolution: ", videoInfo.maxResolution);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.pin: ", videoInfo.pin);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.resolution_width: ", videoInfo.resolution_width);
                console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: svc videoInfo.resolution_height: ", videoInfo.resolution_height);
            }
            //Test ---------- show data ---------- ---------- ----------
            
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRefreshLayoutMode]: -> call remote_video_svclayout_views.dealwithRecvMsgRefreshLayoutMode(mode, value)");
            remote_video_svclayout_views.dealwithRecvMsgRefreshLayoutMode(mode, value)
        }

        onCppSendMsgToQMLLayoutRemoteView: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLLayoutRemoteView]: value from cpp FMeetingViewControllerObject， mode: " + mode + ", varValue" + value);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLLayoutRemoteView]: -> call remote_video_svclayout_views.dealwithRecvMsgLayoutRemoteView(mode: " + mode + ", view: " + value + ")");
            remote_video_svclayout_views.dealwithRecvMsgLayoutRemoteView(mode, value)
        }

        //[FMeetingViewController.cpp]: cppSendMsgToQMLRemoteVideoReceived.
        onCppSendMsgToQMLRemoteVideoReceived: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteVideoReceived]: value from cpp FMeetingViewControllerObject，datasourceid" + datasourceid);
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteVideoReceived]: -> call remote_video_svclayout_views.dealwithRecvMsgRemoteVideoReceived(datasourceid:  " + datasourceid + ")");
            remote_video_svclayout_views.dealwithRecvMsgRemoteVideoReceived(datasourceid);
        }
        
        //for remote content.
        
        onCppSendMsgToQMLRemoteContentVideoViewSetHidden: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewSetHidden]: value from cpp FMeetingViewControllerObject: cppSendMsgToQMLRemoteContentVideoViewSetHidden(hidden: " + hidden + ")");
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewSetHidden]: -> call remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden:  " + hidden + ")");
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden);
        }
        
        onCppSendMsgToQMLRemoteContentVideoViewStartRendering: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewStartRendering]: value from cpp FMeetingViewControllerObject: cppSendMsgToQMLRemoteContentVideoViewStartRendering()");
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewStartRendering]: -> call remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStartRendering()");
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStartRendering();
        }
        
        onCppSendMsgToQMLRemoteContentVideoViewStopRendering: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewStopRendering]: value from cpp FMeetingViewControllerObject: cppSendMsgToQMLRemoteContentVideoViewStopRendering()");
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLRemoteContentVideoViewStopRendering]: -> call remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStopRendering()");
            remote_video_svclayout_views.dealwithRecvMsgRemoteContentVideoViewStopRendering();
        }
        
        onCppSendMsgToQMLSetLocalPreviewEnable: {
            console.log("[FMeetingViewController.qml][onCppSendMsgToQMLSetLocalPreviewEnable]: -> call setLocalPreviewEnable(aEnable: " + aEnable + ")");
            setLocalPreviewEnable(aEnable);
        }
    }




    //========================================
    // 1.[UI][Window close] pop dialog, dropCall?
    //========================================

    //----------------------------------------
    // 1.1.[UI] Window Close Button
    //----------------------------------------

    property bool isShowLeaveMeetingDialog : false;
    property bool isLeaveMeeting : false;

    onClosing: function(closeevent) {
        console.log("[FMeetingViewController.qml][onClosing]");
        //set CloseEvent's property accepted to: false, then it will be ignored.
        if (isLeaveMeeting) {
            console.log("[FMeetingViewController.qml][onClosing]: isLeaveMeeting: " + isLeaveMeeting + __LINE__);
            closeevent.accepted = true;
        } else {
            console.log("[FMeetingViewController.qml][onClosing]: isLeaveMeeting: " + isLeaveMeeting);
            closeevent.accepted = false;

            console.log("[FMeetingViewController.qml][onClosing]: -> call showAskLeavMeetingDialog() -> call ask_leave_meeting_dialog.show()");
            showAskLeavMeetingDialog();
        }
    }

    //----------------------------------------
    // 2.[UI] [FrtcDropCallWindow] Ask user: leaving meeting or not?
    //----------------------------------------

    FrtcDropCallWindow {
        id: ask_leave_meeting_dialog
        width: 250
        height: 160

        //anchors.centerIn: parent

        //color: "gray"

        visible: false

        onAccept: {
           console.log("[FMeetingViewController.qml][FrtcDropCallWindow][onAccept:] : the accept Button clicked, the user want to leave meeting.");

           //console.log("[FMeetingViewController.qml][Dialog][onAccept:] : -> call FMeetingViewControllerObject.onQmlUserLeaveMeeting()");
           //FMeetingViewControllerObject.onQmlUserLeaveMeeting(); //call methos which is marked by Q_INVOKABLE.

           console.log("[FMeetingViewController.qml][FrtcDropCallWindow][onAccept:] : -> call qml's signal qmlUserLeaveMeetingSignal() -> FMeetingViewControllerObject::onQmlUserLeaveMeeting()");
           root.qmlUserLeaveMeetingSignal()

           root.destroy();
        }

        onReject:  {
            console.log("[FMeetingViewController.qml][FrtcDropCallWindow][onAccept:] : the cancel Button clicked.");

         }

        //load complet.
        Component.onCompleted: {
            console.log("[FMeetingViewController.qml][FrtcDropCallWindow][Component.onCompleted:]: Component.onCompleted.")

        }

    } //end of 1.[FrtcDropCallWindow] Ask user: leaving meeting or not?



    //----------------------------------------
    // 2.[UI] [FrtcDropCallWindow] Ask user: leaving meeting or not?
    //----------------------------------------




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
        id: rectangle_main_view
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

            console.log("[FMeetingViewController.qml][showLocalPreview][Rectangle id: rectangle_main_view]: -> call remote_video_svclayout_views.showLocalPreview(aShow: " + aShow + ")");
            remote_video_svclayout_views.showLocalPreview(aShow)
        }

        Component.onCompleted: {
            console.log("[FMeetingViewController.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: ");
            /*
            let childs = rectangle_main_view.children;
            for (let i = 0; i < childs.length; ++i) {
                console.log("[FMeetingViewController.qml][Component.onCompleted:][Rectangle id: rectangle_main_view]: child UI: rectangle_main_view Component.onCompleted:");
            }
            */
            //console.log("[FMeetingViewController.qml][Component.onCompleted:][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views]: signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())");
            //signalShowLocalPreview.connect(remote_video_svclayout_views.showLocalPreview())
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
            
            Component.onCompleted: {
                console.log("[FMeetingViewController.qml][Component.onCompleted:][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views]: ");
                /*
                let childs = remote_video_svclayout_views.children;
                for (let i = 0; i < childs.length; ++i) {
                    console.log("[FMeetingViewController.qml][Rectangle id: rectangle_main_view][SVCLayout id: remote_video_svclayout_views][Component.onCompleted:]: sub compolent ");
                }
                */
            }
        }

    } // end of 3.[UI] Video.



    //========================================
    // 4.SubViews for MenuBar Buttons.
    //========================================

    //MenuBarView.qml


    //========================================
    // for screen Mouse Event.
    //========================================

    property bool isWhowGridModeDetail: false

    function setIsShowGridModeDetail(aShow) {
        console.log("[FMeetingViewController.qml][setIsShowGridModeDetail]: -> set isWhowGridModeDetail = aShow: " + aShow +")")
        isWhowGridModeDetail = aShow
    }

    MouseArea {
        id: id_mouseArea
        anchors.fill: parent
        hoverEnabled: true
        //propagateComposedEvents: true

        onEntered: {
            //console.log("[FMeetingViewController.qml][MouseArea onEntered:][id_mouseArea]: Mouse hover entered: [x, y]: " + mouseX + ", " + mouseY);
            if (false === isVisibleMenuBarTabBar) {
                //console.log("[FMeetingViewController.qml][MouseArea onEntered:][id_mouseArea]: Mouse hover entered, current true === id_mouseArea.containsMouse && false === isVisibleMenuBarTabBar, so show menuBar and tabBar.");
                rectangle_menu_bar.showOrHideMenuBarView(true)
                rectangle_tab_bar.visible = true
                isVisibleMenuBarTabBar = true
            }
        }

        onExited: {
            //console.log("[FMeetingViewController.qml][MouseArea onExited:][id_mouseArea]: Mouse hover exited: [x, y]: " + mouseX + ", " + mouseY);
            if (isWhowGridModeDetail) {
                console.log("[FMeetingViewController.qml]MouseArea onExited:][id_mouseArea]: isWhowGridModeDetail : true, so not hide the tabBar and menuBar")
                return
            }

            if (true === isVisibleMenuBarTabBar) {
                //console.log("[FMeetingViewController.qml][MouseArea onEntered:][id_mouseArea]: Mouse hover entered, current false === id_mouseArea.containsMouse && true === isVisibleMenuBarTabBar, so hide menuBar and tabBar.");
                rectangle_menu_bar.showOrHideMenuBarView(false)

                rectangle_tab_bar.visible = false;
                isVisibleMenuBarTabBar = false;
            }
        }

        /*
        onMouseXChanged: {
            console.log("[FMeetingViewController.qml][MouseArea onMouseXChanged:][id_mouseArea]: Mouse: [x, y]: " + mouseX + ", " + mouseY);
        }

        onMouseYChanged: {
            console.log("[FMeetingViewController.qml][MouseArea onMouseYChanged:][id_mouseArea]: Mouse: [x, y]: " + mouseX + ", " + mouseY);
        }

        onContainsMouseChanged: {
            console.log("[FMeetingViewController.qml][MouseArea onContainsMouseChanged:][id_mouseArea]: Mouse: [x, y]: " + mouseX + ", " + mouseY);
        }
        */




        //========================================
        // 2.[UI][MenuBarView][title bar] Top menu
        //========================================

        //property var rectangle_menu_bar_bottom: rectangle_menu_bar.bottom
        //property var rectangle_menu_bar_meeting_info_view: rectangle_menu_bar.meeting_info_view_and_button_view
        //property var rectangle_menu_bar_network_info_view_visible: rectangle_menu_bar.network_info_view_and_button_view



        MenuBarView {
            id: rectangle_menu_bar
            //x: 0
            //y: 0
            //width: 1538
            //height: 240 - 6
            height: 40 - 6
            z: 3; //keep on the top order.

            color: "#00000000"
            //opacity: 0

            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0

            MouseArea {
                id: mouseArea_menu_bar
                //anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true

                //onEntered: {}
                //onExited: {}
                //onClicked: {}
            } //end of MouseArea

        } //end of 2.[UI][title bar] Top menu



        //========================================
        // 4.[UI][TabBarView][CallView] Tab bar
        //========================================

        TabBarView {
            id: rectangle_tab_bar
            //x: 0
            //y: 972
            //width: 1538
            height: 60
            z: 3; //keep on the top order.
            //color: "blue"

            anchors.top: parent.bottom
            anchors.topMargin: - height
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.margins: 0

            MouseArea {
                id: mouseArea_tab_bar
                //anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true

                /*
                onEntered: {
                    console.log("[FMeetingViewController.qml][MouseArea onEntered:][rectangle_tab_bar]: Mouse hover entered: [x, y]: " + mouseX + ", " + mouseY);
                    //parent.mouseHoverEntered();
                }

                onExited: {
                    console.log("[FMeetingViewController.qml][MouseArea onExited:][rectangle_tab_bar]: Mouse hover exited: [x, y]: " + mouseX + ", " + mouseY);
                    //parent.mouseHoverExited();
                }
                 */

            } //end of MouseArea

        } //end of 4.[UI][CallView] Tab bar.


    } //end of MouseArea


}


