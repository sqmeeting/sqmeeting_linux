import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


import "./"
import "./View"
import "./../FrtcMeetingViewController"
import "./../FrtcParticipantsView/View/"
import "./../FrtcNetWorkInfoView/View/"
import "./../FrtcShareContent/FrtcShareContentSelectWindow/View/"
import "./../../CommonView/"

//import model which has been registed.
import com.frtc.FMeetingViewControllerObject 1.0 //class FMeetingViewController.cpp
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FrtcApiManager 1.0


Window {
    visible: true
    id: root

    width: windowWidth
    height: windowHeight

    maximumWidth : windowWidth
    maximumHeight : windowHeight
    minimumWidth : windowWidth
    minimumHeight : windowHeight

    color: "#060606"

    title: qsTr("神旗")

    signal qmlUserLeaveMeetingSignal()

    signal dynamicLoaded()

    //========================================
    // for screen ratio.
    //========================================

    //property var ratio
    property var screenWidth
    property var screenHeight

    property int windowWidth: 1024
    property int windowHeight: 691

    property int view_width: 1024
    property int view_height: 691
    property int screen_ratio: 1

    property int disPlayWidth: 1024
    property int disPlayHeight: 691

    property bool isVisibleMenuBarTabBar: false

    //[FrtcCallView.qml]: for make call, user config.
    property string  currentMeetingID: ""
    property string  currentUserName: ""
    property bool    currentMicMute: true
    property bool    currentCameraMute: true
    property bool    currentAudioOnly: false

    property bool authiority: false
    property bool meetingOwner:false

    property string lectureUUID: ''

    //meetingInfo
    property string conferenceName: ""
    property string meetingID: ""
    property string ownerName: ""
    property string meetingPasscode: ""

    property string streaming_live_url:''
    property string streaming_live_password: ''
    property string pin_speaker_uuid: ''

    //gallery menu Button
    property bool  isGallery: false

    property bool isRecording: false
    property bool isStreaming: false

    property int window_animation_duration: 200

    property int sharecontent_orignal_x : 100
    property int sharecontent_orignal_y : 100
    property int sharecontent_orignal_width : 640
    property int sharecontent_orignal_height : 480

    property int sharecontent_new_x : 400
    property int sharecontent_new_y : 300
    property int sharecontent_new_width : 320
    property int sharecontent_new_height : 180

    property bool isSenddingLocalContent: false

    property var invite_join_view
    property var inCall_setting_view
    property var enable_message_view
    property var enable_recording_view
    property var enable_streaming_view
    property var diable_streaming_view
    property var disable_recording_view
    property var un_mute_request_window
    property var share_meeting_url_window
    property var statistics_view
    property var ask_leave_meeting_dialog
    property var participant_dialog
    property var unmute_all_confirm_dialog
    property var ask_for_unmute_dialog
    property var allowed_self_unmute_dialog
    property var stop_meeting_dialog

    property var id_share_content_select_window

    property bool isShowLeaveMeetingDialog : false;
    property bool isLeaveMeeting : false;
    property bool isAuthiority: false

    //property var dictionary:{}
    property var dictionary: ({})
    property var nameArray: []
    property var uuidArray: []



    function setUserConfig(authiority, meetingOwner, audioMute, videoMute) {
        authiority = authiority
        meetingOwner = meetingOwner

        isAuthiority = authiority | meetingOwner

        currentMicMute = audioMute
        currentCameraMute = videoMute

        FMeetingWindowControllerObject.onQmlSetUserAuthority(authiority, meetingOwner)

        updateUIAsLocalUserConfigFile()
    }

    function updateUIAsLocalUserConfigFile() {
        rectangle_tab_bar.setMicMute(currentMicMute);
        rectangle_tab_bar.setCameraMute(currentCameraMute);
        if (currentAudioOnly) {
            rectangle_tab_bar.audioOnlyJoin()
        }

        rectangle_main_view.localVideoMute(currentCameraMute);
    }


    function qmlGetMeetingInfo() {
        var meetingInfo = FMeetingWindowControllerObject.onQmlGetMeetingInfo();

        conferenceName = meetingInfo.conferenceName
        meetingID = meetingInfo.meetingID
        currentMeetingID = meetingInfo.meetingID
        ownerName = meetingInfo.ownerName
        meetingPasscode = meetingInfo.meetingPasscode

        return meetingInfo;
    }

    function qmlGetNetWorkInfoView() {}

    //for menubar title_meeting_info_button: MeetingInfoView
    function showNetWorkInfoView() {
        network_info_view.showInfoView()
    }

    function hideNetWorkInfoView() {
       network_info_view.hideInfoView()
    }

    function popupStreamingUrlView() {
        popupStreamingUrlView.togglePopup()
    }

    //true: "gallery"; false: "presenter"

    function switchGridMode(bGallery) {
        FMeetingWindowControllerObject.onQmlSwitchGridMode(bGallery)
    }


    function onQmlLocalAudioMute(localAudioMute) {
        currentMicMute = localAudioMute
        FMeetingWindowControllerObject.onQmlLocalAudioMute(localAudioMute);
    }

    function enableOverlayMessage(data) {
        var userToken = SDKUserDefaultObject.getUserToken()
        FrtcApiManager.start_overlay_message(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber(), data)
    }

    function muteByParticipantDialog(muted) {
         rectangle_tab_bar.setMicMute(muted)
    }

    function handleUnMuteRequest() {
        if (un_mute_request_window) {
            un_mute_request_window.destroy();
            un_mute_request_window = null; // 释放对象引用
            console.log('Destroyed previous un_mute_request_window');
        }

            // 创建新的窗口对象
        un_mute_request_window = Qt.createQmlObject('FrtcUnMuteRequestWindow {}', root);
        console.log('Created new un_mute_request_window');

        // 设置回调函数
        un_mute_request_window.onRequestUnMuteCallback = requestUnMuteCallBackHandler;

        // 传递数组数据
        un_mute_request_window.nameArray = root.nameArray;
        un_mute_request_window.uuidArray = root.uuidArray;

        // 显示窗口
        un_mute_request_window.show();
    }

    function handleRecordingState(tag, isCancel) {
        //rectangle_tab_bar.handleButtonState(0, isCancel)

        var userToken = SDKUserDefaultObject.getUserToken()
        if(tag === 0) {
            if(!isCancel) {
                FrtcApiManager.start_recording(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
            }
        } else {
            if(!isCancel) {
                FrtcApiManager.stop_recording(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
            }
        }
    }

    function requestUnMuteCallBackHandler(array) {
        var userToken = SDKUserDefaultObject.getUserToken()

        FrtcApiManager.allow_user_un_mute(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber(), array)
    }

    function streamingHandlerCallBack(tag, isCancel, password) {
        console.log('the streaming password is ', password)

        //rectangle_tab_bar.handleButtonState(1, isCancel)
        var userToken = SDKUserDefaultObject.getUserToken()

        if(tag === 0) {
            if(!isCancel) {
                FrtcApiManager.start_streaming(userToken, password, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
            }
        } else {
            if(!isCancel) {
                FrtcApiManager.stop_streaming(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
            }
        }
    }

    function showStopMeetingDialog() {
        if (undefined === stop_meeting_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/View/GeneralDialog.qml");
            if (component.status === Component.Ready) {
               var newQmlObject = component.createObject(root) //parent: here is root.

                stop_meeting_dialog = newQmlObject

                stop_meeting_dialog.titleText       = "您要结束此会议吗"
                stop_meeting_dialog.messageText     = "结束会议，全体参会者将被解散"
                stop_meeting_dialog.leftButtonText  = "取消"
                stop_meeting_dialog.rightButtonText = "确定"

                stop_meeting_dialog.accept.connect(function() {
                     var userToken = SDKUserDefaultObject.getUserToken()
                    //owner_stop_meeting(const QString &user_token, const QString meeting_number)
                    FrtcApiManager.owner_stop_meeting(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())

                    stop_meeting_dialog.destroy()
                    stop_meeting_dialog = undefined
                })
                stop_meeting_dialog.reject.connect(function() {
                    stop_meeting_dialog.destroy()
                    stop_meeting_dialog = undefined
                })
            }
        }
        stop_meeting_dialog.show();
    }

    function showAskForUnmuteDialog() {
        if (undefined === ask_for_unmute_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/View/GeneralDialog.qml");
            if (component.status === Component.Ready) {
               var newQmlObject = component.createObject(root) //parent: here is root.

                ask_for_unmute_dialog = newQmlObject

                ask_for_unmute_dialog.titleText = "您已静音"
                ask_for_unmute_dialog.messageText = "主持人不允许解除静音，您可以向主持人申请"
                ask_for_unmute_dialog.leftButtonText = "取消"
                ask_for_unmute_dialog.rightButtonText = "申请解除静音"

                ask_for_unmute_dialog.accept.connect(function() {
                    var userToken = SDKUserDefaultObject.getUserToken()
                    FrtcApiManager.request_un_mute(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())

                    ask_for_unmute_dialog.destroy()
                    ask_for_unmute_dialog = undefined
                })
                ask_for_unmute_dialog.reject.connect(function() {
                    ask_for_unmute_dialog.destroy()
                    ask_for_unmute_dialog = undefined
                })
            }
        }
        ask_for_unmute_dialog.show();
    }

    function showAllowedSelfRequestUnmuteDialog() {
        if (undefined === allowed_self_unmute_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/View/GeneralDialog.qml");
            if (component.status === Component.Ready) {
               var newQmlObject = component.createObject(root) //parent: here is root.

                allowed_self_unmute_dialog = newQmlObject

                allowed_self_unmute_dialog.titleText = "主持人同意申请"
                allowed_self_unmute_dialog.messageText = "主持人已同意您的解除静音申请"
                allowed_self_unmute_dialog.leftButtonText = "保持静音"
                allowed_self_unmute_dialog.rightButtonText = "解除静音"

                allowed_self_unmute_dialog.accept.connect(function() {
                    //onQmlLocalVideoMute(false)
                    rectangle_tab_bar.setAllowSelfUnmute(true)
                    rectangle_tab_bar.setMicMute(false)

                    allowed_self_unmute_dialog.destroy()
                    allowed_self_unmute_dialog = undefined
                })
                allowed_self_unmute_dialog.reject.connect(function() {
                    allowed_self_unmute_dialog.destroy()
                    allowed_self_unmute_dialog = undefined
                })
            }
        }
        allowed_self_unmute_dialog.show();
    }

    function muteLocalAudio() {
        currentMicMute = !currentMicMute
        FMeetingWindowControllerObject.onQmlLocalAudioMute(currentMicMute);
        rectangle_tab_bar.setMicMute(currentMicMute);
        SDKUserDefaultObject.onQmlSaveTempSelectMicMute(currentMicMute)
    }


    function onQmlLocalVideoMute(localVideoMute) {
        FMeetingWindowControllerObject.onQmlLocalVideoMute(localVideoMute)

        if (true === localVideoMute) {
            rectangle_main_view.localVideoMute(true)
            currentCameraMute = true
        } else {
            rectangle_main_view.localVideoMute(false)
            currentCameraMute = false
        }
    }

    function muteLocalVideo() {
        rectangle_tab_bar.setCameraMute(!currentCameraMute)

    }


    function onQmlShowContentSelectWindow() {
        if (undefined === id_share_content_select_window) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcShareContent/FrtcShareContentSelectWindow/View/FrtcShareContentSelectWindow.qml");
            if (component.status === Component.Ready) {
                var newQmlObject = component.createObject(root) //parent: here is root.
                root.id_share_content_select_window = newQmlObject
            }
        }

        root.id_share_content_select_window.show()
    }

    function onQmlStartShareScreen() {
        id_share_content_select_window.close()
        FMeetingWindowControllerObject.onQmlStartShareScreen();
    }

    function onQmlStopShareScreen() {
        FMeetingWindowControllerObject.onQmlStopShareScreen();
    }

    //callBack: FMeetingWindowControllerObject call this one.
    function dealwithContentStateChangedCallBack(isWantToSendingContent) {
        if (isWantToSendingContent) {
            isSenddingLocalContent = true

            miniWindowSizeStartSharingContent()

            id_mouseArea.enabled = false
            rectangle_menu_bar.visible = false
            rectangle_tab_bar.visible = false
        } else {
            maxWindowSizeStopSharingContent();

            id_mouseArea.enabled = true
            rectangle_menu_bar.visible = true
            rectangle_tab_bar.visible = true
            FMeetingWindowControllerObject.onQmlCloseSharingBarWindow()
            isSenddingLocalContent = false
        }
    }

    function onQmlLocalPreview(aShow) {
        rectangle_main_view.showLocalPreview(aShow)
    }

    //SDK API call this one.
    function setLocalPreviewEnable(aEnable) {
        rectangle_tab_bar.setLocalPreviewEnable(aEnable)
    }


    function showInvitationDialog() {
       if (undefined === invite_join_view) {
            invite_join_view = Qt.createQmlObject('FrtcInviteToJoinView {}', root);
        }

        invite_join_view.setMeetingInfoData(root.conferenceName, root.meetingID, root.ownerName, root.meetingPasscode)
        invite_join_view.show();
    }

    function showShareStreamingUrl() {
        if (undefined === share_meeting_url_window) {
             share_meeting_url_window = Qt.createQmlObject('FrtcShareStreamingUrlWindow {}', root);
         }

         share_meeting_url_window.setStreamingInfo(ownerName, meetingID, streaming_live_url, streaming_live_password)
         share_meeting_url_window.show();
    }


    function showRecordingWindow() {
        console.log('showRecordingWindow')
        if (undefined === enable_recording_view) {
            enable_recording_view = Qt.createQmlObject('FrtcRecordingWindow {}', root);
             enable_recording_view.onStartRecordingCallback = handleRecordingState
            console.log('undefined === enable_recording_view')
        }

        enable_recording_view.show();
    }

    function showStreamingWindow() {
        if (undefined === enable_streaming_view) {
            enable_streaming_view = Qt.createQmlObject('FrtcStartStreamingWindow {}', root);
             enable_streaming_view.onStartStreamingCallback = streamingHandlerCallBack
            console.log('undefined === enable_streaming_view')
        }

        enable_streaming_view.show();
    }

    function showStopStreamingWindow() {
        if (undefined === diable_streaming_view) {
            diable_streaming_view = Qt.createQmlObject('FrtcStopStreamingWindow {}', root);
            diable_streaming_view.onStartStreamingCallback = streamingHandlerCallBack
            console.log('undefined === diable_streaming_view')
        }

        diable_streaming_view.show();
    }

    function showStopRecordingWindow() {
        if (undefined === disable_recording_view) {
            disable_recording_view = Qt.createQmlObject('FrtcStopRecordingWindow {}', root);
            disable_recording_view.onStartRecordingCallback = handleRecordingState
            console.log('undefined === disable_recording_view')
        }

        disable_recording_view.show();
    }

    function showParticipantDialog() {
        if (undefined === participant_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcParticipantsView/View/FrtcParticipantsWindow.qml");
            if (component.status === Component.Ready) {
                var subParams = {
                     "authiority":  authiority,
                     "meetingOwner": meetingOwner,
                     "lectureUUID":lectureUUID,
                     "pinUUID":pin_speaker_uuid
                 }
                var newQmlObject = component.createObject(root, subParams)
                
                // 添加关闭信号处理
                // newQmlObject.dialogClosed.connect(function() {
                //     console.log("Dialog is closing, cleaning up...")
                //     if (participant_dialog) {
                //         participant_dialog = null
                //     }
                // })
                
                participant_dialog = newQmlObject
            }
        }

        if (participant_dialog) {
            participant_dialog.conferenceName = root.conferenceName
            participant_dialog.meetingID = root.meetingID
            participant_dialog.ownerName = root.ownerName
            participant_dialog.meetingPasscode = root.meetingPasscode
            participant_dialog.onMuteSelfCallback = muteByParticipantDialog

            participant_dialog.show()
        }
    }

    function showSettingDialog() {
        if (undefined === inCall_setting_view) {
            inCall_setting_view = Qt.createQmlObject('FrtcMettingSettingView {}', root);
        }
        inCall_setting_view.show();
    }

    function showEnableMessageDialog() {//enable_message_view
        console.log('showEnableMessageDialog')
        if (undefined === enable_message_view) {
            console.log('showEnableMessageDialog')
            enable_message_view = Qt.createQmlObject('FrtcEnableMessageWindow {}', root);
            enable_message_view.onEnableMessageCallback = enableOverlayMessage
         }

        enable_message_view.show();
    }

    function stopMessageOverlay() {
        var userToken = SDKUserDefaultObject.getUserToken()
        FrtcApiManager.stop_overlay_message(userToken, FMeetingWindowControllerObject.onQmlGetMeetingNumber())
    }

    function showAskLeaveMeetingDialog() {
        if (undefined === ask_leave_meeting_dialog) {
            ask_leave_meeting_dialog = Qt.createQmlObject('FrtcDropCallWindow {authority:root.isAuthiority}', root)
            if (undefined !== ask_leave_meeting_dialog) {
                ask_leave_meeting_dialog.onStopButtonClickedCallback = showStopMeetingDialog
                ask_leave_meeting_dialog.qmlUserDropCallButtonSignal.connect(root.qmlUserLeaveMeetingSignal)
                ask_leave_meeting_dialog.qmlUserDropCallButtonSignal.connect(root.handleAskLeaveMeetingDialogAcceptedEvent)
            }
        }

        ask_leave_meeting_dialog.show()
    }

    function handleAskLeaveMeetingDialogAcceptedEvent() {
        if (isSenddingLocalContent) {
            FMeetingWindowControllerObject.onQmlStopShareScreen();
        }

        root.destroy()
    }

    function showStatisticsDialog() {
        if (undefined === statistics_view) {
          var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcNetWorkInfoView/View/FrtcStatisticsWindow.qml");
            if (component.status === Component.Ready) {
                var newQmlObject = component.createObject(root) //parent: here is root.
                statistics_view = newQmlObject
            }
        }

        statistics_view.setMeetingInfoData(root.conferenceName, root.currentMeetingID);
        statistics_view.show();
    }

    function showUnmuteAllPopConfirmDialog() {
        if (undefined === unmute_all_confirm_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/View/FrtcUnmuteAllPopConfirmWindow.qml");
            if (component.status === Component.Ready) {
               var newQmlObject = component.createObject(root) //parent: here is root.
                unmute_all_confirm_dialog = newQmlObject

                unmute_all_confirm_dialog.accept.connect(root.handleUnmuteAllPopConfirmDialogAcceptedEvent)
                unmute_all_confirm_dialog.reject.connect(root.handleUnmuteAllPopConfirmDialogRejectEvent)
            }
        }
        unmute_all_confirm_dialog.show();
    }

    //for UnmuteAllPopConfirmWindow Dialog: accept button event handle.
    function handleUnmuteAllPopConfirmDialogAcceptedEvent() {
        rectangle_tab_bar.setMicMute(false)

        unmute_all_confirm_dialog.destroy()
        unmute_all_confirm_dialog = undefined
    }

    //for UnmuteAllPopConfirmWindow Dialog: reject button event handle.
    function handleUnmuteAllPopConfirmDialogRejectEvent() {
        unmute_all_confirm_dialog.destroy()
        unmute_all_confirm_dialog = undefined
    }


    function currentSize() {
        screenWidth = Screen.width;
        screenHeight = Screen.height;
        
        if (screenHeight >= 1200) {
            return {width: 1536, height: 1037};
        } else if (screenHeight >= 1000 && screenHeight < 1200) {
            return {width: 1280, height: 864};
        } else if (screenHeight >= 800 && screenHeight < 1000) {
            return {width: 1024, height: 691};
        } else {
            return {width: 819, height: 551};
        }
    }

    function screenRatio() {
        return 1.0;
    }

    function setWindowSize(sizeObj) {
        windowWidth = sizeObj.width
        windowHeight = sizeObj.height

        sharecontent_orignal_width  = windowWidth
        sharecontent_orignal_height  = windowHeight
        sharecontent_orignal_x = (screenWidth - windowWidth) / 2
        sharecontent_orignal_y = (screenHeight - windowHeight) / 2

        sharecontent_new_width = 320 * screen_ratio
        sharecontent_new_height = 180 * screen_ratio
        sharecontent_new_x = (screenWidth - sharecontent_new_width)
        sharecontent_new_y = (screenHeight - sharecontent_new_height)

        root.width = windowWidth;
        root.height = windowHeight;

        root.maximumWidth = windowWidth
        root.maximumHeight = windowHeight
        root.minimumWidth = windowWidth
        root.minimumHeight = windowHeight

        root.x = sharecontent_orignal_x;
        root.y = sharecontent_orignal_y;
}

    function miniWindowSizeStartSharingContent() {
        id_window_mini_size_animation_start_sharing_content.start()

        root.maximumWidth = sharecontent_new_width
        root.maximumHeight = sharecontent_new_height
        root.minimumWidth = sharecontent_new_width
        root.minimumHeight = sharecontent_new_height

        root.flags = Qt.Window | Qt.WindowCloseButtonHint //| Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint
    }

    function maxWindowSizeStopSharingContent() {
        id_window_max_size_animation_stop_sharing_content.start()

        root.maximumWidth = sharecontent_orignal_width
        root.maximumHeight = sharecontent_orignal_height
        root.minimumWidth = sharecontent_orignal_width
        root.minimumHeight = sharecontent_orignal_height

        root.flags = Qt.Window | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint //| Qt.WindowMaximizeButtonHint
    }

    // for layout.
    function getTraditionalLayout() {
        var currentTraditionalLayout = FMeetingViewControllerObject.getTraditionalLayout();
        return currentTraditionalLayout;
    }

    function getSvcLayoutDetail() {
       var detail = FMeetingViewControllerObject.getSvcLayoutDetail();
       return detail;
    }

    function getCellCustomUUID() {
        var cellCustomUUID = FMeetingViewControllerObject.getCellCustomUUID();
        return cellCustomUUID;
    }

    //========================================
    // for QML life cycle.
    //========================================

    Component.onCompleted: {
        var sizeObj = currentSize();
        screen_ratio = screenRatio()

        setWindowSize(sizeObj)

        root.disPlayWidth = sizeObj.width;
        root.disPlayHeight = sizeObj.height;

        rectangle_main_view.width = root.disPlayWidth
        rectangle_main_view.height = root.disPlayHeight

        root.qmlUserLeaveMeetingSignal.connect(FMeetingWindowControllerObject.onQmlUserLeaveMeeting);

        qmlGetMeetingInfo()

        close.connect(function() {
                    // 处理关闭事件
            if (isLeaveMeeting) {
                closeevent.accepted = true;
            } else {
                closeevent.accepted = false;
                showAskLeaveMeetingDialog();
            }
        });
    }

    Component.onDestruction: {
       FMeetingWindowControllerObject.onQmlCloseSharingBarWindow()

        if (undefined !== id_share_content_select_window) {
            id_share_content_select_window.destroy()
        }
        if (undefined !== invite_join_view) {
            invite_join_view.destroy()
        }
        if (undefined !== inCall_setting_view) {
            inCall_setting_view.destroy()
        }
        if (undefined !== statistics_view) {
            statistics_view.destroy()
        }
        if (undefined !== ask_leave_meeting_dialog) {
            ask_leave_meeting_dialog.destroy()
        }
        if (undefined !== participant_dialog) {
            participant_dialog.destroy()
        }
    }

    Connections {
        target: FrtcApiManager

        function onStartOverlayMessageCompleted(success) {
            id_toast.showText("横幅已启用")
        }

        function onStopOverlayMessageCompleted(success) {
            id_toast.showText("横幅已停止")
        }

        function onStartRecordingCompleted(success) {
            recording_success_view.visible = true
            id_toast.showText("录制已开始")
        }

        function onStopRecordingCompleted(success) {
            recording_success_view.visible = false
            id_toast.showText("录制已结束")
        }

        function onStartStreamingingCompleted(success) {
            id_toast.showText("直播已开始")
        }

        function onStopStreamingCompleted(boolsuccess) {
            id_toast.showText("直播已结束")
        }
    }

    Connections {
        target: FMeetingViewControllerObject; //created by FrtcCall::init().

        //[FMeetingViewController.cpp]: slotPrepareSVCLayout(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLPrepareSVCLayout(mode, value);
        onCppSendMsgToQMLPrepareSVCLayout: {
            rectangle_main_view.dealwithRecvMsgPrepareSVCLayout(mode, value)
        }

        //[FMeetingViewController.cpp]: slotRemoteViewHiddenOrNot(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLRemoteViewHiddenOrNot(mode, value);
        onCppSendMsgToQMLRemoteViewHiddenOrNot: {
            rectangle_main_view.dealwithRecvMsgRemoteViewHiddenOrNot(value)
        }

        //[FMeetingViewController.cpp]: slotRefreshLayoutMode(const QVariant &mode, const QVariant &value)
        // -> emit cppSendMsgToQMLRefreshLayoutMode(mode, value);
        onCppSendMsgToQMLRefreshLayoutMode: {
            var videoViewNum = value.videoViewNum;
            var isSymmetical = value.isSymmetical;
            var strRowArray = value.videoViewDescription;
            rectangle_main_view.dealwithRecvMsgRefreshLayoutMode(mode, value)
        }

        onCppSendMsgToQMLLayoutRemoteView: {
            rectangle_main_view.dealwithRecvMsgLayoutRemoteView(mode, value)
        }

        onCppSendMsgToQMLRemoteVideoReceived: {
            rectangle_main_view.dealwithRecvMsgRemoteVideoReceived(datasourceid);
        }

        //for remote content.

        onCppSendMsgToQMLRemoteContentVideoViewSetHidden: {
            rectangle_main_view.dealwithRecvMsgRemoteContentVideoViewSetHidden(hidden);
        }

        onCppSendMsgToQMLRemoteContentVideoViewStartRendering: {
            rectangle_main_view.dealwithRecvMsgRemoteContentVideoViewStartRendering();
        }

        onCppSendMsgToQMLRemoteContentVideoViewStopRendering: {
            rectangle_main_view.dealwithRecvMsgRemoteContentVideoViewStopRendering();
        }

        onCppSendMsgToQMLSetLocalPreviewEnable: {
           setLocalPreviewEnable(aEnable);
        }

        onCppSendMsgToQMLContentStateChangedCallBack: {
            root.dealwithContentStateChangedCallBack(isSending);
            rectangle_main_view.dealwithContentStateChangedCallBack(isSending);
            handleContentStateCallBack(isSending)
        }
        
        onCppSendMsgToQMLOnOpenCameraComplete: {
           if (0 === nOpenResulte) {
                currentCameraMute = false
                rectangle_main_view.localVideoMute(false)
            } else {
                id_toast.showText("未检测到可用摄像头，请插入设备后重试")
                
                FMeetingViewControllerObject.onOpenCameraFailedSetCameraMuteButtonState()
            }

        }
    }

    //------------------------------------------------
    // 0.1.[CPP Object]: FMeetingViewControllerObject
    //------------------------------------------------

    Connections {
        target: FMeetingWindowControllerObject; //created by function main().
        onCppSendMsgToQMLMuteLocalAudio: {
            root.muteLocalAudio();
        }
        onCppSendMsgToQMLMuteLocalVideo: {
            root.muteLocalVideo();
        }
        onCppSendMsgToQMLShowInvitationDialog: {
            root.showInvitationDialog();
        }
        onCppSendMsgToQMLShowParticipantsDialog: {
            root.showParticipantDialog();
        }
        onCppSendMsgToQMLShowSettingDialog: {
            root.showSettingDialog();
        }
        onCppSendMsgToQMLShowStatisticsDialog: {
           root.showStatisticsDialog();
        }

        onCppSendMsgToQMLShowOverlayMessageDialog:{
            root.showEnableMessageDialog()
        }

        onCppSendMsgToQMLStopOverlayMessage:{
            root.stopMessageOverlay()
        }

        onCppSendMsgToQMLShowRecordingDialog:{
            root.showRecordingWindow()
        }

        onCppSendMsgToQMLShowStopRecordingDialog:{
            root.showStopRecordingWindow()
        }

        onCppSendMsgToQMLShowStreamingDialog: {
            root.showStreamingWindow();
        }

        onCppSendMsgToQMLShowStopStreamingDialog:{
            root.showStopStreamingWindow();
        }

        onCppSendMsgToQMLMeetingDuration: {
            rectangle_menu_bar.meetingDuration = dural;
        }
	
        onCppSendMsgToQMLOnMuteLockedCallBack:handleMuteAll(muted, allowSelfUnmute)

        onCppSendMsgToQMLOnUnMuteReqeustAllowedCallBack:{
            showAllowedSelfRequestUnmuteDialog()
        }

        onCppSendMsgToQMLOnWaterMaskCallBack:handleWaterMaskCallBack(live_meeting_url,
                                                                     live_password,
                                                                     live_status,
                                                                    recording_status)

        onCppSendMsgToQMLonMessageOverLayCallBack:handleMessageOverLayCallBack(enabled,
                                                                               vertical_position,
                                                                               display_repetition,
                                                                               display_speed,
                                                                               message_text)

        onCppSendMsgToQMLOnUnMuteRequestCallBack:handleUnMuteRequestCallBack(name, uuid)

        onCppSendMsgToQMLonMessageLayoutSettingChangedCallBack:handleLayoutSettingChangedCallBack(lecture_id, max_cell_count, is_by_setting_speaker)

        onCppSendMegToQMLOnPinSpeakerChangedCallBack:handlePinUUIDChangedCallBack(pin_uuid)

    }

    function handleLayoutSettingChangedCallBack(lecture_id, max_cell_count, is_by_setting_speaker) {
        lectureUUID = lecture_id

        if(is_by_setting_speaker) {
            id_toast.showText('您已被主持人设为演讲者')
        }
    }

    function handlePinUUIDChangedCallBack(pin_uuid) {
        pin_speaker_uuid = pin_uuid
    }

    function handleContentStateCallBack(isSending) {
        if(isSending) {
            over_lay_message_view.visible = false
        }
    }

    function handleMuteAll(muted, allowSelfUnmute) {
        rectangle_tab_bar.setAllowSelfUnmute(allowSelfUnmute)

        if (muted) {
            rectangle_tab_bar.setMicMute(true)
            id_toast.showText("已对您开启静音，如需发言可自行解除静音！")
        } else {
            if(currentMicMute) {
                root.showUnmuteAllPopConfirmDialog()
            }
        }
    }

    function handleWaterMaskCallBack(live_meeting_url, live_password, live_status, recording_status) {
        streaming_live_url = live_meeting_url
        streaming_live_password = live_password

        if(!isRecording && recording_status === 'STARTED') {
            recording_success_view.visible = true
            rectangle_tab_bar.handleButtonState(0, false)
            isRecording = true

            if(meetingOwner || authiority) {
                id_toast.showText("录制已开始")
            } else {
                id_toast.showText("主持人已开启会议录制")
            }

            recordingReminderView.visible = true

        } else if(isRecording && recording_status === 'NOT_STARTED') {
            recording_success_view.visible = false
            rectangle_tab_bar.handleButtonState(0, false)
            isRecording = false

            if(meetingOwner || authiority) {
                id_toast.showText("录制已结束")
            } else {
                id_toast.showText('主持人已结束会议录制')
            }

            recordingReminderView.visible = false
        }

        if(!isStreaming && live_status === 'STARTED') {
            rectangle_tab_bar.handleButtonState(1, false)
            isStreaming = true

            if(meetingOwner || authiority) {
                id_toast.showText("直播已开始")
                rectangle_tab_bar.handleInviteButton(true)
            } else {
                id_toast.showText("主持人已开启会议直播")
            }

            streamingReminderView.visible = true
        } else if(isStreaming && live_status === 'NOT_STARTED') {
            rectangle_tab_bar.handleButtonState(1, false)
            isStreaming = false

            if(meetingOwner || authiority) {
                id_toast.showText("直播已结束")
                rectangle_tab_bar.handleInviteButton(false)
            } else {
                id_toast.showText("主持人已结束会议直播")
            }

            streamingReminderView.visible = false
        }
    }

    function handleMessageOverLayCallBack(enabled,
                                          vertical_position,
                                          display_repetition,
                                          display_speed,
                                          message_text) {

        if (enabled) {
            over_lay_message_view.visible = true;
            over_lay_message_view.messageText = message_text;

            // 清除旧的 anchors
            over_lay_message_view.anchors.top = undefined;
            over_lay_message_view.anchors.bottom = undefined;
            over_lay_message_view.anchors.verticalCenter = undefined;

            if(display_speed === 'static') {
                over_lay_message_view.isStillnessInfo = true
                over_lay_message_view.restart()
            } else {
                over_lay_message_view.isStillnessInfo = false
                over_lay_message_view.cycleNumbers = display_repetition
                over_lay_message_view.restart()
            }

            // 根据位置动态调整布局
            if (vertical_position === 0) {
                // 顶部对齐
                over_lay_message_view.anchors.top = messageContainer.top;
                over_lay_message_view.anchors.topMargin = 40;
            } else if (vertical_position === 50) {
                // 居中对齐
                over_lay_message_view.anchors.verticalCenter = messageContainer.verticalCenter;
            } else if (vertical_position === 100) {
                // 底部对齐
                over_lay_message_view.anchors.bottom = messageContainer.bottom;
                over_lay_message_view.anchors.bottomMargin = 60;
            }
        } else {
            over_lay_message_view.visible = false;
        }
    }

    function handleUnMuteRequestCallBack(name, uuid) {

        dictionary[uuid] = name
        un_mute_request_view.visible = true
        un_mute_request_view.updateRequestName(name)
        nameArray.push(name)
        uuidArray.push(uuid)

        if (un_mute_request_window && un_mute_request_window.visible) {
            un_mute_request_window.updateModel(nameArray)
        } else {
            console.log("The window is not visible.");
        }
    }

    onClosing: function(closeevent) {
        if (isLeaveMeeting) {
            closeevent.accepted = true;
        } else {
            closeevent.accepted = false;
            showAskLeaveMeetingDialog();
        }
    }

    FMeetingViewControllerQml {
        id: rectangle_main_view
    }

    FrtcToastView {
        id: id_toast
    }


    //----------------------------------------
    // Animation change: for start/stop sharing content
    //----------------------------------------

    ParallelAnimation {
        id: id_window_mini_size_animation_start_sharing_content

        NumberAnimation {
            target: root
            property: "x"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_x
            to: sharecontent_new_x
        }
        NumberAnimation {
            target: root
            property: "y"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_y
            to: sharecontent_new_y
        }
        NumberAnimation {
            target: root
            property: "width"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_width
            to: sharecontent_new_width
        }
        NumberAnimation {
            target: root
            property: "height"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_height
            to: sharecontent_new_height
        }
    }

    ParallelAnimation {
        id: id_window_max_size_animation_stop_sharing_content

        NumberAnimation {
            target: root
            property: "x"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_x
            to: sharecontent_orignal_x
        }
        NumberAnimation {
            target: root
            property: "y"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_y
            to: sharecontent_orignal_y
        }
        NumberAnimation {
            target: root
            property: "width"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_width
            to: sharecontent_orignal_width
        }
        NumberAnimation {
            target: root
            property: "height"
            duration: window_animation_duration
            //easing.type: Easing.InOutQuad
            //from: sharecontent_orignal_height
            to: sharecontent_orignal_height
        }
    }

    property bool isWhowGridModeDetail: false

    function setIsShowGridModeDetail(aShow) {
        isWhowGridModeDetail = aShow
    }

    ReminderView {
        id: recordingReminderView
        width: 106
        height: 28

        imageSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_show_recording@2x.png"
        title: "会议录制中"

        visible: false

        anchors.left: parent.left
        anchors.leftMargin:4
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.17

    }

    ReminderView {
        id: streamingReminderView
        width: 106
        height: 28

        imageSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_streaming_tips@2x.png"
        title: "会议直播中"

        visible: false

        anchors.left: parent.left
        anchors.leftMargin:4
        anchors.top: recordingReminderView.bottom
        anchors.topMargin: 10
    }

    MouseArea {
        id: id_mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            if (false === isVisibleMenuBarTabBar) {
                rectangle_menu_bar.showOrHideMenuBarView(true)
                rectangle_tab_bar.visible = true
                isVisibleMenuBarTabBar = true
            }
        }

        onExited: {
            if (isWhowGridModeDetail) {
                return
            }

            if (true === isVisibleMenuBarTabBar) {
                if (!popupStreamingUrlView.isPopUpViewShowing) {
                    rectangle_menu_bar.showOrHideMenuBarView(false)

                    rectangle_tab_bar.visible = false;
                    isVisibleMenuBarTabBar = false;
                }
            }
        }

        onClicked: {
            popupStreamingUrlView.toggleDisappear()
        }

        MenuBarView {
            id: rectangle_menu_bar

            height: 40 - 6
            z: 3; //keep on the top order.

            color: "#00000000"

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

            } //end of MouseArea

        } //end of 2.[UI][title bar] Top menu


        TabBarView {
            id: rectangle_tab_bar

            authiority: root.authiority
            meetingOwner: root.meetingOwner

            height: 60
            z: 3; //keep on the top order.

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

            } //end of MouseArea

        } //end of 4.[UI][CallView] Tab bar.

    } //end of MouseArea

    FrtcUnMuteRequest {
        id: un_mute_request_view

        visible: false

        onRequestUnMuteCallback:handleUnMuteRequest

        anchors.bottom: id_mouseArea.bottom
        anchors.bottomMargin:65
        anchors.right: parent.right
        anchors.rightMargin: 4
    }


    FrtcVideoRecordingSuccessView {
        id: recording_success_view

        height: 170
        visible: false
        z: 3; //keep on the top order.

        anchors.bottom: id_mouseArea.bottom
        anchors.bottomMargin:65
        anchors.right: parent.right
        anchors.rightMargin: 4
    }

    FrtcPopupView {
        id: popupStreamingUrlView

        popupWidth: 127
        popupHeight: 54

        contentComponent: Component {
            Rectangle {
                width: 127
                height: 44
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

                Image {
                    id: share_url_image
                    width: 12
                    height: 12
                    source: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_invite_url@2x.png"//btn_img_src_unselected
                    fillMode: Image.PreserveAspectFit
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin:16
                }

                Text {
                    anchors.left: share_url_image.right
                    anchors.leftMargin:7
                    anchors.verticalCenter: parent.verticalCenter
                    //anchors.centerIn: parent
                    text: '分享会议直播'
                    color: 'white'
                    font.pointSize: 10
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        showShareStreamingUrl()
                        popupStreamingUrlView.toggleDisappear()
                    }
                }
            }
        }
    }

    Rectangle {
        id: messageContainer
        width: parent.width
        height: parent.height
        anchors.fill: parent
        color: "transparent"

        OverLayMessage {
            id: over_lay_message_view

            height: 40
            width: parent.width
            visible: false
            z: 3

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}


