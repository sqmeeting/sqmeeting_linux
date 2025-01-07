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

    id: recurrenceMeetingListWindow
    minimumWidth: 380
    minimumHeight: 660
    maximumHeight: 660
    maximumWidth: 380
    visible: true
    x:(screen.width - width)/2
    y:(screen.height - height)/2
    title: qsTr("周期会议")

    signal windowLoaded()

    property var detailMeetingData
    property var recurrenceListData

    property var shareMeetingInfoDialog
    property var changeOneMeetingDialog
    property var subPopupScheduleViewControllerQML

    property var currentModelData

    property var userToken: SDKUserDefaultObject.getUserToken()
    property bool isAllMeeting: false

    function showShareMeetingInfoDialog() {
        if (null !== shareMeetingInfoDialog && undefined !== shareMeetingInfoDialog) {
            shareMeetingInfoDialog.destroy();
        }

        var detailWindow = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/CommonView/FrtcShareMeetingInfoWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "meetingInfo": detailMeetingData
            }

            shareMeetingInfoDialog = detailWindow.createObject(recurrenceMeetingListWindow,subParams);
            shareMeetingInfoDialog.show();
        }
    }

    function showChangeOneMeetingDialog() {
        if (null !== changeOneMeetingDialog && undefined !== changeOneMeetingDialog) {
            changeOneMeetingDialog.destroy();
        }

        var detailWindow = Qt.createComponent("./FrtcChangeOneMeetingWindow.qml");
        if (detailWindow.status === Component.Ready) {
            var subParams = {
                "detailMeetingData": currentModelData,
            }
            changeOneMeetingDialog = detailWindow.createObject(recurrenceMeetingListWindow,subParams);
            changeOneMeetingDialog.updateMieetngFinishCompleted.connect(function(){
                getRecurrenceList()
            })
            changeOneMeetingDialog.show();
        }
    }

    function  getRecurrenceDaysData() {
        var recurrenceDays = "";
        if (detailMeetingData.recurrence_type === "WEEKLY") {
            recurrenceDays = " " + FrtcTool.weekRecurrenceDate(FrtcTool.convertToChineseWeekday(detailMeetingData.recurrenceDaysOfWeek)) + " ";
        } else if (detailMeetingData.recurrence_type === "MONTHLY") {
            recurrenceDays = " " + FrtcTool.monthRecurrenceDate(detailMeetingData.recurrenceDaysOfMonth) + " ";
        }
        return recurrenceDays
    }

    function showCancelMeetingAlertView(modelData,isRecurrece) {
        isAllMeeting = isRecurrece
        AlertManager.showAlertView(qsTr("取消会议"),
                                   qsTr("取消会议后,其他成员将无法入会"),
                                   FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                   function(result) {
                                       if (result === 0) {
                                           console.log("User clicked OK");
                                       } else if (result === 1) {
                                           console.log("User clicked Cancel");
                                           FrtcApiManager.deleteMeeting(userToken,modelData.reservation_id,isRecurrece,"frtc_deleteMeeting_list")
                                       }
                                   },
                                   "取消会议",
                                   "再想想"
                                   );
    }

    function initScheduleWindowUI() {

        if (null !== subPopupScheduleViewControllerQML && undefined !== subPopupScheduleViewControllerQML) {
            subPopupScheduleViewControllerQML.destroy();
        }

        var component = Qt.createComponent("../FrtcScheduleMeeting/FrtcHomeScheduleWindow.qml");

        if (component.status === Component.Ready) {
            var subParams = {
                "editDetailModelData":  detailMeetingData,
            }
            subPopupScheduleViewControllerQML = component.createObject(main_Window,subParams);
            subPopupScheduleViewControllerQML.show();
            recurrenceMeetingListWindow.visible = false
        } else {
            console.log("[UI][main.qml][initSettingUI]: not show window, for it is not ready: FrtcSettingViewController.qml")
        }
    }

    function getRecurrenceList() {
        //获取周期会议列表
        FrtcApiManager.getRecurrenceMeetingGroupByPage(userToken,detailMeetingData.recurrence_gid)
    }

    Component.onCompleted: {
        currentModelData = detailMeetingData
        getRecurrenceList()
    }

    Rectangle {
        id: meetingTitleView
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 70
        clip: true
        color: "white"

        Text {
            id: meetingTitleText
            color: "#222222"
            font.weight: Font.DemiBold
            font.pixelSize: 25
            anchors.centerIn: parent
            text: detailMeetingData.meeting_name
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: parent.width - 5
        }
    }

    Rectangle {

        id: currenceMeetingDesView
        color: "#f9f9f9"
        anchors.top: meetingTitleView.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 350

        Rectangle {
            id: meetingTimeInfo
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 50
            clip: true
            color: "#f9f9f9"

            ColumnLayout {

                spacing: 10

                RowLayout {
                    spacing: 5

                    Text {
                        id: meetingDes
                        color: "#3EC76E"
                        font.weight: Font.DemiBold
                        font.pixelSize:  14
                        text: detailMeetingData.recurrenceInterval_result
                    }

                    Text {
                        id: meetingRecurrenecDes
                        color: "#222222"
                        elide: Text.ElideMiddle
                        font.weight: Font.DemiBold
                        font.pixelSize:  14
                        text: qsTr("会议将于") + detailMeetingData.recurrenceInterval_result + getRecurrenceDaysData() +qsTr("重复")
                    }
                }

                Text {
                    id: meetingStopTime
                    color: "#222222"
                    font.weight: Font.DemiBold
                    font.pixelSize:  14
                }
            }
        }

        ListView {
            id: recurrenceListView
            anchors.top: meetingTimeInfo.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 280
            clip: true
            model: recurrenceListData.meeting_schedules

            delegate: Rectangle {

                id: cellView
                width: recurrenceListView.width
                height: 40
                radius: 2
                color : (index % 2 === 0) ? "white" : "#f9f9f9"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        cellView.color = '#E4EFFF'
                        cellText.color = "#026FFE"
                        rightMoreRectangle.visible = detailMeetingData.yourSelf ? true : false
                    }
                    onExited: {
                        rightMoreRectangle.visible = false
                        cellView.color = (index % 2 === 0) ? "white" : "#f9f9f9"
                        cellText.color = "#222"
                    }
                    onClicked: {
                        console.log("schedulelistCell")
                        //windowLoaded()
                    }
                }

                RowLayout {

                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        id: cellText
                        color: "#222"
                        font.pixelSize: 14
                        text: FrtcTool.formatDateYMDW(modelData.schedule_start_time) + " " + FrtcTool.formatTimestamp(modelData.schedule_start_time,"HH:mm", true) + "-" + " " + FrtcTool.formatTimestamp(modelData.schedule_end_time,"HH:mm", true)
                    }

                    Item {
                        width: 10
                    }

                    Text {
                        color: modelData.meeting_statusStrColor
                        font.pixelSize: 14
                        text: modelData.meeting_statusStr
                    }
                }

                Rectangle {
                    id: rightMoreRectangle
                    width: 30
                    height: 20
                    visible: false
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: "#026FFE"
                    border.width: 1
                    radius: 4
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        color: "#026FFE"
                        font.pixelSize: 10
                        text: "···"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentModelData =  modelData
                            moreMenu.toggleVisibility()
                        }
                    }
                }

                Popup {

                    id: moreMenu
                    y: rightMoreRectangle.height + rightMoreRectangle.y + 15
                    x: rightMoreRectangle.x + rightMoreRectangle.width - width + 25
                    width: 80
                    height: contentList.count * 30 + 8
                    padding: 4
                    opacity: visible ? 1 : 0
                    enter: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                    }
                    exit: Transition {
                        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
                    }
                    background: FrtcPopupTriangleView{}

                    contentItem: ListView {
                        id: contentList
                        width: parent.width
                        height: parent.height
                        model: ListModel {
                            ListElement { text: "修改会议"; itemId: "modifyMeeting" }
                            ListElement { text: "取消会议"; itemId: "cancleMeeting" }
                        }

                        delegate: Item {
                            width: parent.width
                            height: 30
                            Rectangle {
                                width: parent.width
                                height: parent.height
                                color: mouseArea.containsMouse ? "#EEE" : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.text
                                    color: (model.index === contentList.model.count - 1) ? "red" : "#222222"
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        moreMenu.restoreState()
                                        if (model.itemId === "modifyMeeting") {
                                            console.log("选中行的开始时间: ",FrtcTool.formatTimestamp(currentModelData.schedule_start_time))
                                            showChangeOneMeetingDialog()
                                        }else if (model.itemId === "cancleMeeting"){
                                            showCancelMeetingAlertView(currentModelData,false)
                                        }
                                    }
                                }
                            }

                        }

                    }

                    function toggleVisibility() {
                        visible = !visible
                    }

                    function restoreState() {
                        visible = false
                    }
                }
            }
        }
    }

    Rectangle {

        id: bottomButtonsView
        //anchors.top: currenceMeetingDesView.bottom
        anchors.bottom: parent.bottom
        width: currenceMeetingDesView.width
        height: 200

        Column {

            spacing: 15
            anchors.fill: parent
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 15

            FrtcButton {
                id: joinMeeting_btn
                height: 40
                anchors.left: parent.left
                anchors.right: parent.right
                buttonText: qsTr('进入会议')
                onMouseClicked: {
                    let user_name  =  SDKUserDefaultObject.getUserInfo().real_name
                    FrtcCallInterface.makeCall(user_name, detailMeetingData.meeting_number, true, true, false, detailMeetingData.meeting_password ? detailMeetingData.meeting_password : "")
                    recurrenceMeetingListWindow.destroy()
                }
            }

            FrtcButton {
                id: copyMeeting_btn
                height: joinMeeting_btn.height
                anchors.left: parent.left
                anchors.right: parent.right
                borderColor: "#cccccc"
                backgroundColor: "white"
                textColor: "#026FFE"
                hoverColor: "#eeeeee"
                buttonText: qsTr('复制邀请')
                visible: !detailMeetingData.yourSelf
                onMouseClicked: {
                    showShareMeetingInfoDialog()
                }
            }

            FrtcButton {
                id: changeMeeting_btn
                height: joinMeeting_btn.height
                anchors.left: parent.left
                anchors.right: parent.right
                visible: detailMeetingData.yourSelf
                borderColor: "#cccccc"
                backgroundColor: "white"
                textColor: "#026FFE"
                hoverColor: "#eeeeee"
                buttonText: qsTr('修改周期性会议')
                onMouseClicked: initScheduleWindowUI()
            }

            FrtcButton {
                id: cancelMeeting_btn
                height: joinMeeting_btn.height
                anchors.left: parent.left
                anchors.right: parent.right
                visible: detailMeetingData.yourSelf
                borderColor: "#cccccc"
                backgroundColor: "white"
                hoverColor: "#eeeeee"
                textColor: "red"
                buttonText: qsTr('取消周期性会议')
                onMouseClicked: {
                    showCancelMeetingAlertView(detailMeetingData,true)
                }
            }

        }
    }

    Connections {
        target: FrtcApiManager
        function onDeleteMeetingListCompleted(success, json) {
            console.log('删除列表中的会议回调', "success:", success);
            if (isAllMeeting) {
                meetingDetailWindow.destroy()
                FrtcTool.refreshHomeMeetingList()
            }else{
                getRecurrenceList()
            }
        }

        function onRecurrenceMeetingListCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            if (success) {
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
                meetingStopTime.text = qsTr("结束于") + FrtcTool.formatTimestamp(detailMeetingData.recurrenceEndDay,"yyyy-MM-dd",true) + qsTr("  剩余") + recurrenceListData.total_size + qsTr("场会议")
            }
        }

    }
}
