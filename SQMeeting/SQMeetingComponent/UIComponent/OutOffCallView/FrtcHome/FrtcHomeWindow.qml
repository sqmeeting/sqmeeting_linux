import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import AlertManager 1.0

import "../FrtcMainViewController/View"
import "../../CommonView"

Rectangle {
    id:home_view
    // width: 380
    // height: 660
    // minimumHeight: 660
    // minimumWidth: 380
    // maximumHeight: 660
    // maximumWidth: 380
    color: 'white'

    visible: true

    signal getMeetingRoomListSuccess(var meetingRoomsiLst)

    property var  subPopupFrtcSettingViewControllerQML;
    property var  subPopupScheduleViewControllerQML
    property var  subPopupFrtcDetailMeetingControllerQML
    property var  subPopupHistoryMeetingControllerQML
    property var  subPopupRecurrenceMeetingListWindowQML
    property var  changeOneMeetingDialog
    property var  shareMeetingInfoDialog

    function onLoginSuccess() {
        var  userToken = SDKUserDefaultObject.getUserToken()
        console.log("Home userToken --- :", userToken)
        if (userToken) {
            //请求是否有个人会议号
            FrtcApiManager.getMeetingRoomList(userToken)
            //请求会议列表
            FrtcApiManager.getScheduledMeetingList(userToken)
            FrtcTool.refreshHistoryList();
        }
    }

    function initSettingUI() {

        if (null !== subPopupFrtcSettingViewControllerQML && undefined !== subPopupFrtcSettingViewControllerQML) {
            subPopupFrtcSettingViewControllerQML.destroy();
        }

        var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/OutOffCallView/FrtcSettingViewController/View/FrtcSettingViewController.qml");
        if (component.status === Component.Ready) {
            var subParams = {
                "strText":  qsTr("create object."),
                "strColor": "red"
            }
            subPopupFrtcSettingViewControllerQML = component.createObject(main_Window, subParams);
            subPopupFrtcSettingViewControllerQML.show();
        } else {
            console.log("[UI][main.qml][initSettingUI]: not show window, for it is not ready: FrtcSettingViewController.qml")
        }
    }

    function initScheduleWindowUI(modelData = null) {

        if (null !== subPopupScheduleViewControllerQML && undefined !== subPopupScheduleViewControllerQML) {
            subPopupScheduleViewControllerQML.destroy();
        }

        var component = Qt.createComponent("./FrtcScheduleMeeting/FrtcHomeScheduleWindow.qml");

        if (component.status === Component.Ready) {
            if (modelData) {
                var subParams = {
                    "editDetailModelData":  modelData,
                }
                subPopupScheduleViewControllerQML = component.createObject(main_Window,subParams);
            }else {
                subPopupScheduleViewControllerQML = component.createObject(main_Window);
            }
            subPopupScheduleViewControllerQML.createMieetngFinishCompleted.connect(function(modelData) {
                getMeetingList()
            });
            subPopupScheduleViewControllerQML.show();
        } else {
            console.log("[UI][main.qml][initSettingUI]: not show window, for it is not ready: FrtcSettingViewController.qml")
        }
    }

    function initMeetingDetailUI(data) {

        if (null !== subPopupFrtcDetailMeetingControllerQML && undefined !== subPopupFrtcDetailMeetingControllerQML) {
            subPopupFrtcDetailMeetingControllerQML.destroy();
        }

        console.log("data.isRecurrence --- ___ ", data.isRecurrence)
        var detailWindow = Qt.createComponent("./FrtcMeetingDetailView/FrtcHomeDetailWindow.qml");

        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "pageData": data
            }
            subPopupFrtcDetailMeetingControllerQML = detailWindow.createObject(main_Window, subParams);
            subPopupFrtcDetailMeetingControllerQML.updatHomeMeetingListCompleted.connect(function() {
                getMeetingList()
            });

            subPopupFrtcDetailMeetingControllerQML.editRecurrenceMeeting.connect(function () {
                initScheduleWindowUI(data)
            });

            subPopupFrtcDetailMeetingControllerQML.editOneMeeting.connect(function () {
                showChangeOneMeetingDialog(data)
            });
            subPopupFrtcDetailMeetingControllerQML.show();
        }else{
            console.log("[UI][HomeWindow.qml][initMeetingDetailUI]: not show window, for it is not ready: FrtcHomeDetailWindow.qml")
        }
    }

    function initHistoryDetailUI(data) {

        if (null !== subPopupHistoryMeetingControllerQML && undefined !== subPopupHistoryMeetingControllerQML) {
            subPopupHistoryMeetingControllerQML.destroy();
        }

        console.log("data.isRecurrence --- ___ ", data.isRecurrence)
        var detailWindow = Qt.createComponent("./FrtcMeetingDetailView/FrtcHistoryDetailWindow.qml");

        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "pageData": data
            }
            subPopupHistoryMeetingControllerQML = detailWindow.createObject(main_Window, subParams);
            subPopupHistoryMeetingControllerQML.show();
        }else{
            console.log("[UI][HomeWindow.qml][initMeetingDetailUI]: not show window, for it is not ready: FrtcHomeDetailWindow.qml")
        }
    }

    function showShareMeetingInfoDialog(pageData) {
        if (null !== shareMeetingInfoDialog && undefined !== shareMeetingInfoDialog) {
            shareMeetingInfoDialog.destroy();
        }

        var detailWindow = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/CommonView/FrtcShareMeetingInfoWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "meetingInfo": pageData
            }
            shareMeetingInfoDialog = detailWindow.createObject(main_Window,subParams);
            shareMeetingInfoDialog.show();
        }
    }

    function showCancelMeetingAlertView(modelData) {

        if (modelData.isRecurrence) {
            alertLoader.sourceComponent = null;
            alertLoader.sourceComponent = scheduleMeetingAlertComponent;
            alertLoader.item.show()
            alertLoader.item.onAccepted.connect(function() {
                console.log("Accepted signal received 333",alertLoader.item.checkBoxChecked);
                var  userToken = SDKUserDefaultObject.getUserToken()
                FrtcApiManager.deleteMeeting(userToken,modelData.reservation_id,alertLoader.item.checkBoxChecked)
            });
        }else {
            AlertManager.showAlertView(qsTr("取消会议"),
                                       qsTr("取消会议后,其他成员将无法入会"),
                                       FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                       function(result) {
                                           if (result === 0) {
                                               console.log("User clicked OK");
                                           } else if (result === 1) {
                                               console.log("User clicked Cancel");
                                               var  userToken = SDKUserDefaultObject.getUserToken()
                                               FrtcApiManager.deleteMeeting(userToken,modelData.reservation_id,false)
                                           }
                                       },
                                       "取消会议",
                                       "再想想"
                                       );
        }
    }

    function initRecurrenceMeetingListWindow(modelData) {
        if (null !== subPopupRecurrenceMeetingListWindowQML && undefined !== subPopupRecurrenceMeetingListWindowQML) {
            subPopupRecurrenceMeetingListWindowQML.destroy();
        }

        var detailWindow = Qt.createComponent("./FrtcMeetingDetailView/FrtcHomeRecurrenceMeetingListWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "detailMeetingData": modelData,
            }
            subPopupRecurrenceMeetingListWindowQML = detailWindow.createObject(main_Window,subParams);
            subPopupRecurrenceMeetingListWindowQML.windowLoaded.connect(function() {
                console.log("New window loaded, destroying current window...");
                meetingDetailWindow.destroy();
            });
            subPopupRecurrenceMeetingListWindowQML.show();
        }
    }

    function showChangeOneMeetingDialog(modelData) {
        if (null !== changeOneMeetingDialog && undefined !== changeOneMeetingDialog) {
            changeOneMeetingDialog.destroy();
        }

        var detailWindow = Qt.createComponent("./FrtcMeetingDetailView/FrtcChangeOneMeetingWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "detailMeetingData": modelData,
            }
            changeOneMeetingDialog = detailWindow.createObject(main_Window,subParams);
            changeOneMeetingDialog.show();
        }
    }

    function showCancelHistoryMeetingAlertView(modelData) {

        AlertManager.showAlertView(qsTr("删除会议"),
                                   qsTr("确定从历史会议中删除该会议吗?"),
                                   FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                   function(result) {
                                       if (result === 0) {
                                           console.log("User clicked OK");
                                       } else if (result === 1) {
                                           console.log("User clicked Cancel");
                                           FrtcTool.deleteDataByMeetingStartTime(modelData.meetingStartTime)
                                           FrtcTool.refreshHistoryList()
                                       }
                                   },
                                   "确定",
                                   "取消",
                                   );
    }

    function showCancelAllHistoryMeetingAlertView() {

        AlertManager.showAlertView(qsTr("清除记录"),
                                   qsTr("确定要清空历史会议记录吗?"),
                                   FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                   function(result) {
                                       if (result === 0) {
                                           console.log("User clicked OK");
                                       } else if (result === 1) {
                                           console.log("User clicked Cancel");
                                           FrtcTool.deleteDataByMeetingStartTime("",true)
                                           FrtcTool.refreshHistoryList()
                                       }
                                   },
                                   "确定",
                                   "取消",
                                   );
    }

    function showEditMeetingAlertView(modelData) {
        alertRecurrenceLoader.sourceComponent = null
        alertRecurrenceLoader.sourceComponent = scheduleRecurrenceMeetingAlertComponent
        alertRecurrenceLoader.item.show()
        alertRecurrenceLoader.item.accepted.connect(function() {
            showChangeOneMeetingDialog(modelData)
        });

        alertRecurrenceLoader.item.rejected.connect(function() {
            initScheduleWindowUI(modelData)
        });
    }

    function instantMeeting() {
        var user_token =  SDKUserDefaultObject.getUserToken()
        let user_name  =  SDKUserDefaultObject.getUserInfo().real_name
        FrtcApiManager.instantMeeting(user_token,user_name + "的会议")
    }

    function getMeetingList() {
        //请求会议列表
        var userToken = SDKUserDefaultObject.getUserToken()
        FrtcApiManager.getScheduledMeetingList(userToken)
    }

    function joinMeeting(meetingNumber , password , muteMic = true ,muteCamera = true ,audioOnly = false) {
        let user_name  =  SDKUserDefaultObject.getUserInfo().real_name
        SDKUserDefaultObject.onQmlSaveTempSelectMicMute(muteMic)
        SDKUserDefaultObject.onQmlSaveTempSelectCameraMute(muteCamera)
        FrtcCallInterface.makeCall(user_name, meetingNumber, muteMic, muteCamera, audioOnly, password)
    }

    FrtcHomeTopView {
        id:home_top_view
        anchors.left: parent.left
        anchors.right: parent.right

        onClickSetting: {
            initSettingUI()
        }

        onClickInstallMetting: {

            if (meeting_rooms_view.person_room_isEnable && meeting_rooms_view.checked) {
                var room_meeting_number =  meeting_rooms_view.currentRoomMeeting.meeting_number
                var room_meeting_password =  meeting_rooms_view.currentRoomMeeting.meeting_password
                joinMeeting(room_meeting_number,room_meeting_password ? room_meeting_password : "", true , !meeting_rooms_view.muteCamera)
            } else {
                instantMeeting()
            }
        }

        onClickJoinMetting: {
            homeloader.sourceComponent = homeCallView
        }

        onClickScheduleMetting: {
            initScheduleWindowUI()
        }

        onClickPersonNumber: {
            meeting_rooms_view.visible = !meeting_rooms_view.visible
        }
    }

    FrtcHomeBottomView {
        id:hone_bottom_view
        anchors.top: home_top_view.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        onClickRefreshBtn: function(isHistory) {
            console.log("isHistory isHistory isHistory",isHistory)
            if (isHistory) {
                showCancelAllHistoryMeetingAlertView()
            } else {
                loadingIndicator.visible = true
                getMeetingList()
            }
        }

        onClickScheduleListCell: function(modelData , buttonItemId) {
            console.log("周期会议:",modelData.isRecurrence,buttonItemId)
            if (buttonItemId === "schedulelistCell") {
                initMeetingDetailUI(modelData)
            } else if (buttonItemId === "cancelMeeting") {
                showCancelMeetingAlertView(modelData)
            } else if (buttonItemId === "modifyMeeting") {
                console.log("执行修改会议逻辑")
                if (modelData.isRecurrence) {
                    showEditMeetingAlertView(modelData)
                } else {
                    initScheduleWindowUI(modelData)
                }
            } else if (buttonItemId === "copyInvite") {
                showShareMeetingInfoDialog(modelData)
            } else if (buttonItemId === "viewRecurrenceMeeting") {
                console.log("执行查看周期会议")
                initRecurrenceMeetingListWindow(modelData)
            } else if (buttonItemId === "joinMeeting") {
                joinMeeting(modelData.meeting_number,modelData.meeting_password ? modelData.meeting_password : "")
            }
        }

        onClickHistoryListCell: function(modelData , buttonItemId) {
            if (buttonItemId === "historylistCell") {
                initHistoryDetailUI(modelData)
            } else if (buttonItemId === "joinMeeting") {
                joinMeeting(modelData.meetingId,modelData.meetingPassword ? modelData.meetingPassword : "")
            }  else if (buttonItemId === "deleteMeetinng") {
                console.log("执行查看周期会议")
                showCancelHistoryMeetingAlertView(modelData)
            }
        }
    }

    FrtcMeetingRoomView {
        id:meeting_rooms_view
        anchors.left: home_top_view.left
        anchors.leftMargin: 2
        anchors.top: home_top_view.bottom
        anchors.topMargin: -10
        visible: false
        person_room_isEnable: false
    }

    BusyIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
        running: true
        visible: false
    }

    Loader {
        id: alertLoader
        anchors.centerIn: parent
    }

    Component {
        id: scheduleMeetingAlertComponent
        FrtcCustomAlertView {
            id: scheduleMeetingAlertView
            anchors.centerIn: parent
            checkBoxViewText: qsTr("同时取消该系列周期会议")
            checkBoxViewVisible: true
            title: qsTr("确定取消会议?")
            cancelButtonText: qsTr("再想想")
            acceptButtonText: qsTr("取消会议")
        }
    }

    Loader {
        id: alertRecurrenceLoader
        anchors.centerIn: parent
    }

    Component {
        id: scheduleRecurrenceMeetingAlertComponent
        FrtcCustomAlertView {
            id: scheduleRecurrenceMeetingAlertView
            anchors.centerIn: parent
            title: qsTr("修改会议")
            message: qsTr("您可以修改本次会议,或修改该系列周期性会议")
            cancelButtonText: qsTr("修改周期性会议")
            acceptButtonText: qsTr("修改本次会议")
        }
    }

    Component.onCompleted:  {

        onLoginSuccess()

        FrtcTool.refreshHomeMeetingList.connect(function() {
            getMeetingList()
        });
    }

    Loader {
        id:homeloader
        anchors.centerIn: parent
    }

    Component {
        id: homeCallView
        FrtcCallView {
            isSmallWindowDisplay: true
            onDestroyCallView: {
                homeloader.sourceComponent = null
            }
        }
    }

    Connections {

        target: FrtcApiManager

        function onQueryMeetingRoomListRequestCompleted(success, json) {
            var jsonData = JSON.stringify(json) //, " " , "jsonData:", jsonData
            console.log('Home 个人会议号列表 --', "success:", success);
            if (success) {
                meeting_rooms_view.person_room_isEnable =  json.meeting_rooms.length > 0 ? true : false
                getMeetingRoomListSuccess(json.meeting_rooms)
            }else{

            }
        }

        function onDeleteMeetingCompleted(success, json) {
            console.log('首页删除会议回调', "success:", success);
            getMeetingList()
        }

        function onInstantMeetingCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            joinMeeting(json.meeting_number , json.meeting_password ? json.meeting_password : "", true , !meeting_rooms_view.muteCamera)
        }

        function onScheduledMeetingListRequestCompleted(success, json) {
            loadingIndicator.visible = false
        }

    }
}
