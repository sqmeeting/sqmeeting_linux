import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import FrtcTool 1.0
import AlertManager 1.0
import "../FrtcMeetingDetailView"
import "../../../CommonView"


Window {

    id: meetingDetailWindow
    minimumWidth: 380
    minimumHeight: 660
    maximumHeight: 660
    maximumWidth: 380
    visible: false
    x:(screen.width - width)/2
    y:(screen.height - height)/2 - 50
    title: qsTr("会议详情")

    property var pageData
    property var recurrenceListData
    property var shareMeetingInfoDialog
    property var subPopupRecurrenceMeetingListWindowQML
    property var userToken: SDKUserDefaultObject.getUserToken()

    signal updatHomeMeetingListCompleted()
    signal editRecurrenceMeeting()
    signal editOneMeeting()

    function showShareMeetingInfoDialog() {
        if (null !== shareMeetingInfoDialog && undefined !== shareMeetingInfoDialog) {
            shareMeetingInfoDialog.destroy();
        }

        var detailWindow = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/CommonView/FrtcShareMeetingInfoWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "meetingInfo": pageData
            }
            shareMeetingInfoDialog = detailWindow.createObject(meetingDetailWindow,subParams);
            shareMeetingInfoDialog.show();
        }
    }

    function initRecurrenceMeetingListWindow() {
        if (null !== subPopupRecurrenceMeetingListWindowQML && undefined !== subPopupRecurrenceMeetingListWindowQML) {
            subPopupRecurrenceMeetingListWindowQML.destroy();
        }

        var detailWindow = Qt.createComponent("./FrtcHomeRecurrenceMeetingListWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "detailMeetingData": pageData,
                "recurrenceListData":recurrenceListData
            }
            subPopupRecurrenceMeetingListWindowQML = detailWindow.createObject(meetingDetailWindow,subParams);
            subPopupRecurrenceMeetingListWindowQML.windowLoaded.connect(function() {
                console.log("New window loaded, destroying current window...");
                meetingDetailWindow.destroy();
            });
            subPopupRecurrenceMeetingListWindowQML.show();
        }
    }


    function showCancelMeetingAlertView() {

        AlertManager.showAlertView(qsTr("取消会议"),
                                   qsTr("取消会议后,其他成员将无法入会"),
                                   FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                   function(result) {
                                       if (result === 0) {
                                           console.log("User clicked OK");
                                       } else if (result === 1) {
                                           console.log("User clicked Cancel");
                                           deleteScheduledMeeting(false)
                                       }
                                   },
                                   "取消会议",
                                   "再想想"
                                   );
    }

    function deleteScheduledMeeting(isRecurrence) {
        //取消会议
        FrtcApiManager.deleteMeeting(userToken,pageData.reservation_id,isRecurrence)
    }

    FrtcHomeDetailRecurrenceTtitleView {
        id: recurrenceMeetingTip
        visible: pageData.isRecurrence
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 15
        contentText: "  " + pageData.recurrenceInterval_result

        onClickRecurrenceTitle: {
            meetingDetailWindow.visible = false
            initRecurrenceMeetingListWindow();
        }

        onClickEditMeeting: {
            alertRecurrenceLoader.sourceComponent = null
            alertRecurrenceLoader.sourceComponent = scheduleRecurrenceMeetingAlertComponent
            alertRecurrenceLoader.item.show()
            alertRecurrenceLoader.item.accepted.connect(function() {
                meetingDetailWindow.destroy()
                editOneMeeting()
            });

            alertRecurrenceLoader.item.rejected.connect(function() {
                meetingDetailWindow.destroy()
                editRecurrenceMeeting()
            });
        }
    }

    FrtcHomeDetailListView {
        id: detailListView
        height: 330
        anchors.top: recurrenceMeetingTip.visible ? recurrenceMeetingTip.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        meetingTitle: pageData.meeting_name
        meetingStartTime: pageData.start_time
        meetingTime: pageData.meeting_duration
        meetingOwner: pageData.owner_name
        meetingNumber: pageData.meeting_number
        meetingPassword: pageData.meeting_password
    }

    FrtcHomeDetailButtonListView {
        id: detailButtonsView
        height: 300
        anchors.top: detailListView.bottom
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.right: parent.right

        cancelMeetingHidden: pageData.yourSelf

        onClickJoinMeeting: {
            let user_name  =  SDKUserDefaultObject.getUserInfo().real_name
            FrtcCallInterface.makeCall(user_name, pageData.meeting_number, true, true, false, pageData.meeting_password ? pageData.meeting_password : "")
            meetingDetailWindow.destroy()
        }

        onClickCopyInfo: {
            showShareMeetingInfoDialog()
        }

        onClickCancelMeeting: {
            if (pageData.isRecurrence) {
                recurrenceMeetingAlertView.show()
            }else{
                showCancelMeetingAlertView()
            }
        }
    }

    FrtcCustomAlertView {
        id:recurrenceMeetingAlertView
        anchors.centerIn: parent
        checkBoxViewText: qsTr("同时取消该系列周期会议")
        checkBoxViewVisible: true
        title: qsTr("确定取消会议?")
        cancelButtonText: qsTr("再想想")
        acceptButtonText: qsTr("取消会议")

        onAccepted:  {
            console.log("取消会议",recurrenceMeetingAlertView.checkBoxChecked)
            deleteScheduledMeeting(recurrenceMeetingAlertView.checkBoxChecked)
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

    Component.onCompleted: {
        if (pageData.isRecurrence) {
            //请求周期会议的列表个数
            FrtcApiManager.getRecurrenceMeetingGroupByPage(userToken,pageData.recurrence_gid)
        }
    }

    Connections {
        target: FrtcApiManager
        function onRecurrenceMeetingListCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            if (success) {
                console.log('周期会议列表数据', "success:", success);
                let meetingSchedules = json.meeting_schedules;
                for (let i = 0 ; i < meetingSchedules.length ; i ++ ) {
                    let item = meetingSchedules[i];
                    let minutes = FrtcTool.calculateTimeDifferenceMinutes(item.schedule_start_time)
                    item.meeting_statusStr =  (minutes >= 0 && minutes <= 15) ? qsTr('即将开始') : ''
                    item.meeting_statusStrColor = 'red'
                    if (!item.meeting_statusStr) {
                        var milliseconds = new Date().getTime();
                        let statrResult =  FrtcTool.compareOneDay(milliseconds,item.schedule_start_time)
                        let endResult   =  FrtcTool.compareOneDay(milliseconds,item.schedule_end_time)
                        item.meeting_statusStr = (statrResult === 1 && endResult === -1) ? qsTr('已开始') : ''
                        item.meeting_statusStrColor = 'green'
                    }
                }
                recurrenceListData = json
                recurrenceMeetingTip.contentText = "   " + pageData.recurrenceInterval_result + " " + qsTr("剩余") + json.total_size + "场"
            }
        }

        function onDeleteMeetingCompleted(success, json) {
            console.log('删除会议回调', "success:", success);
            meetingDetailWindow.destroy()
            updatHomeMeetingListCompleted()
        }
    }
}
