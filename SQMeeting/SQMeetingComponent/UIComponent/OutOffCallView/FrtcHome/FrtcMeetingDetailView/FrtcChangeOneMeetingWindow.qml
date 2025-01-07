import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Controls.Material
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import "../../../CommonView"
import "../../FrtcHome"

Window {
    id: updateOnMeetingWindow
    width: 380
    height: 660
    minimumHeight: 660
    minimumWidth: 380
    maximumHeight: 660
    maximumWidth: 380
    color: 'white'

    visible: true
    title: "预约会议"

    property var detailMeetingData
    property var recurrenceListData  //接口获取
    property var currenteMeetingData //接口获取

    property var minDate
    property var maxDate

    signal updateMieetngFinishCompleted()

    property alias startDate: startTimeField.text
    property alias stopDate: stopTimeFiled.text
    property alias startTime: startDateField.text
    property alias stopTime: stopDateField.text
    property alias recurrenceInterval_result: meetingDes.text
    property var currentTimestamp: new Date().getTime();


    property var userToken: SDKUserDefaultObject.getUserToken()


    function updateCurrenceScheduleMeetingData() {

        var startTimestamp =  FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime)
        var stopTimestamp  =  FrtcTool.dateStringToTimestampYMDWHM(stopDate+" "+stopTime)

        if (FrtcTool.compareTimestamps(currentTimestamp,startTimestamp) === 1) {
            toast.showText("开始时间不能早于当前时间")
            return
        }

        if (FrtcTool.compareTimestamps(startTimestamp,stopTimestamp) === 1) {
            toast.showText("结束时间不能早于开始时间")
            return
        }

        var meetingData = {};
        meetingData.schedule_end_time = stopTimestamp
        meetingData.schedule_start_time = startTimestamp

        meetingData.guest_dial_in = currenteMeetingData.guest_dial_in
        meetingData.meeting_name = currenteMeetingData.meeting_name
        meetingData.meeting_type = currenteMeetingData.meeting_type
        meetingData.mute_upon_entry = currenteMeetingData.mute_upon_entry
        meetingData.time_to_join = currenteMeetingData.time_to_join
        meetingData.call_rate_type = currenteMeetingData.call_rate_type
        meetingData.watermark = currenteMeetingData.watermark
        meetingData.watermark_type = currenteMeetingData.watermark_type

        var inviteds = []
        if (currenteMeetingData.invited_users_details.length > 0) {
            for (var i = 0 ; i < currenteMeetingData.invited_users_details.length ; i ++) {
                var item = currenteMeetingData.invited_users_details[i]
                inviteds.push(item.user_id)
            }
        }
        meetingData.invited_users = inviteds

        if (currenteMeetingData.meeting_room_id) {
            meetingData.meeting_room_id = currenteMeetingData.meeting_room_id
        }

        meetingData.meeting_password = currenteMeetingData.meeting_password ? currenteMeetingData.meeting_password : ""

        console.log("修改本次会议的 Meeting Data as JSON:", JSON.stringify(meetingData, null, 4));
        //FrtcApiManager.createMeeting(userToken,meetingData)
        FrtcApiManager.updateNoRecurrenceMeeting(userToken,detailMeetingData.reservation_id,meetingData)
    }

    function getMaxMinDate() {

        var meetingList = recurrenceListData.meeting_schedules;

        for (var i = 0; i < meetingList.length; i++) {
            var item = meetingList[i];
            if (detailMeetingData.reservation_id === item.reservation_id) {
                if (i === 0) {
                    minDate = FrtcTool.getNextDayOrQuarterHour(currentTimestamp)
                    if (meetingList.length > 1) {
                        var nextModel1 = meetingList[i + 1];
                        maxDate = FrtcTool.getPreviousDayOrQuarterHour(nextModel1.schedule_start_time)
                    } else {
                        maxDate = FrtcTool.getPreviousDayOrQuarterHour(detailMeetingData.schedule_start_time)
                    }
                } else if (i === meetingList.length - 1) {
                    var previousModel1 = meetingList[i - 1];
                    minDate = FrtcTool.getNextDayOrQuarterHour(previousModel1.schedule_end_time)
                    maxDate = detailMeetingData.schedule_end_time;
                } else {
                    var previousModel = meetingList[i - 1];
                    var nextModel = meetingList[i + 1];
                    minDate = FrtcTool.getNextDayOrQuarterHour(previousModel.schedule_end_time)
                    maxDate = FrtcTool.getPreviousDayOrQuarterHour(nextModel.schedule_start_time)
                }
            }
        }

        console.log("最小时间时间戳: ",minDate)
        console.log("最大时间时间戳: ",maxDate)
        console.log("最小时间: ",FrtcTool.formatTimestamp(minDate))
        console.log("最大时间: ",FrtcTool.formatTimestamp(maxDate))
    }

    function getRecurrenceList() {
        //获取周期会议列表
        FrtcApiManager.getRecurrenceMeetingGroupByPage(userToken,detailMeetingData.recurrence_gid,"frtc_getRecurrenceMeetingOne_list")
        //获取当前会议详情
        FrtcApiManager.getScheduledMeetingDetail(userToken,detailMeetingData.reservation_id)
    }

    Component.onCompleted: {
        getRecurrenceList()
        minDate = detailMeetingData.schedule_start_time
        maxDate = detailMeetingData.schedule_end_time
    }

    Flickable {
        id: flickable
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        contentHeight: columnLayout.implicitHeight
        clip: true

        ColumnLayout {
            id:columnLayout
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 10

            Rectangle {

                height: 40

                Text {
                    text: qsTr("修改会议预约")
                    font.pixelSize: 30
                    font.weight: Font.DemiBold
                }
            }

            RowLayout {

                spacing: 10

                Text {
                    id: meetingDes
                    color: "#3EC76E"
                    font.weight: Font.DemiBold
                    font.pixelSize:  14
                }

                Text {
                    id: meetingStopTime
                    color: "#222222"
                    font.weight: Font.DemiBold
                    font.pixelSize:  14
                }
            }

            ColumnLayout {
                id: startTimeLayout
                spacing: 10

                Text {
                    text: qsTr("开始时间")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                RowLayout {

                    spacing: 10

                    FrtcTextField {
                        id: startTimeField
                        width: (updateOnMeetingWindow.width - 35 ) * 0.65
                        height: 35
                        isShowRightImg: true
                        readOnly: true
                        text: FrtcTool.formatDateYMDW(detailMeetingData.schedule_start_time)
                        textFont: 14
                        rightIcon: 'qrc:/Images/Home/frtc_calendar@2x.png'

                        onClickRightIcon: {
                            var globalPosition = startTimeField.mapToItem(flickable, 0, startTimeField.height)
                            var adjustedY = globalPosition.y + flickable.contentY
                            scheduleStartTimeloader.sourceComponent = scheduStartCalendarView
                            scheduleStartTimeloader.visible = true
                            scheduleStartTimeloader.x = globalPosition.x
                            scheduleStartTimeloader.y = adjustedY + 5
                            if (scheduleStartTimeloader.item) {
                                scheduleStartTimeloader.item.open()
                            }
                        }
                    }

                    FrtcTextField {
                        id: startDateField
                        width: (updateOnMeetingWindow.width - 35 ) - startTimeField.width - 10
                        height: 35
                        isShowRightImg: true
                        text: FrtcTool.getCurrentTimeHM(detailMeetingData.schedule_start_time,true)
                        textFont: 14
                        rightIcon: 'qrc:/Images/Home/frtc_schedule_time@2x.png'

                        onClickRightIcon: {
                            var globalPosition = startDateField.mapToItem(flickable, 0, startDateField.height)
                            var adjustedY = globalPosition.y + flickable.contentY
                            startTimePopupView.x = globalPosition.x - 10
                            startTimePopupView.y = adjustedY
                            startTimePopupView.open()
                        }
                    }
                }
            }

            Item {
                height: 5
            }

            ColumnLayout {

                spacing: 10

                Text {
                    text: qsTr("结束时间")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                RowLayout {

                    spacing: 10

                    FrtcTextField {
                        id: stopTimeFiled
                        width: (updateOnMeetingWindow.width - 35 ) * 0.65
                        height: 35
                        readOnly: true
                        isShowRightImg: true
                        rightIcon: 'qrc:/Images/Home/frtc_calendar@2x.png'
                        text: FrtcTool.formatDateYMDW(detailMeetingData.schedule_end_time)
                        textFont: 14

                        onClickRightIcon: {
                            var globalPosition = stopTimeFiled.mapToItem(flickable, 0, stopTimeFiled.height)
                            var adjustedY = globalPosition.y + flickable.contentY
                            scheduleStopTimeloader.sourceComponent = scheduStopCalendarView
                            scheduleStopTimeloader.visible = true
                            scheduleStopTimeloader.x = globalPosition.x
                            scheduleStopTimeloader.y = adjustedY + 5
                            if (scheduleStopTimeloader.item) {
                                scheduleStopTimeloader.item.open()
                            }
                        }
                    }

                    FrtcTextField {
                        id: stopDateField
                        width: (updateOnMeetingWindow.width - 35 ) - startTimeField.width - 10
                        height: 35
                        isShowRightImg: true
                        text: FrtcTool.getHalfHourLater(startDateField.text)
                        rightIcon: 'qrc:/Images/Home/frtc_schedule_time@2x.png'
                        textFont: 14

                        onClickRightIcon: {
                            var globalPosition = stopDateField.mapToItem(flickable, 0, stopDateField.height)
                            var adjustedY = globalPosition.y + flickable.contentY
                            stopTimePopup.x = globalPosition.x - 10
                            stopTimePopup.y = adjustedY
                            stopTimePopup.open()
                        }
                    }
                }
            }

            Loader {
                id:scheduleStartTimeloader
                visible: false
                parent: flickable.contentItem
            }

            Component {
                id: scheduStartCalendarView
                FrtcCalendar {
                    noDefaultSelection: true
                    minSelectableTimestamp: minDate
                    maxSelectableTimestamp: maxDate

                    onCloseCalendar: function(selectedDayText) {
                        scheduleStartTimeloader.sourceComponent = null
                        console.log("select day +++++++++ --- :" ,selectedDayText)
                        var dayOfWeek = FrtcTool.getDayOfWeek(selectedDayText)
                        startTimeField.text = selectedDayText + " " + dayOfWeek
                        stopTimeFiled.text = selectedDayText + " " + dayOfWeek
                        //calculateRecurrenceMeetingEndTime()
                    }

                    onClosed: {
                        scheduleStartTimeloader.sourceComponent = null
                    }
                }
            }

            Loader {
                id:scheduleStopTimeloader
                visible: false
                parent: flickable.contentItem
            }

            Component {
                id: scheduStopCalendarView
                FrtcCalendar {
                    maxSelectableTimestamp: maxDate
                    minSelectableTimestamp: minDate
                    noDefaultSelection: true
                    onCloseCalendar: function(selectedDayText) {
                        scheduleStopTimeloader.sourceComponent = null
                        console.log("select day --- :" ,selectedDayText)
                        var dayOfWeek = FrtcTool.getDayOfWeek(selectedDayText)
                        stopTimeFiled.text = selectedDayText + " " + dayOfWeek
                    }

                    onClosed: {
                        scheduleStartTimeloader.sourceComponent = null
                    }
                }
            }

            FrtcTimeListView {
                id: startTimePopupView
                minTime: FrtcTool.isSameDay(FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime) , currentTimestamp) ?
                             FrtcTool.getCurrentTimeHM(currentTimestamp,true) : "00:00"

                onSelectTimeBlock: function(time) {
                    startDateField.text = time
                    stopDateField.text = FrtcTool.getHalfHourLater(time)
                }
            }

            FrtcTimeListView {
                id: stopTimePopup
                minTime: FrtcTool.getHalfHourLater(startDateField.text)

                onSelectTimeBlock: function(time) {
                    stopDateField.text = time
                }
            }

        }
    }

    FrtcButton {
        id: btn
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: 350
        height: 45
        buttonText: qsTr('保存修改')
        onMouseClicked: {
            updateCurrenceScheduleMeetingData()
        }
    }

    FrtcToastView {
        id: toast
    }

    Connections {
        target: FrtcApiManager

        function onDetailScheduleMeetingCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            console.log('修改周期会议,单个会议详情----', "success:", success,jsonData);
            if (success) {
                currenteMeetingData = json
            }
        }

        function onUpdateNoRecurrenceMeetingCompleted(success, json) {
            if (success) {
                updateMieetngFinishCompleted()
                //updateOnMeetingWindow.destroy()
                FrtcTool.refreshHomeMeetingList()
                toast.showText("会议修改成功")
            }else{
                toast.showText("更新非周期会议失败")
            }
        }

        function onRecurrenceMeetingListOneCompleted(success, json) {
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

                if (json.recurrenceType === "DAILY") {
                    recurrenceInterval_result = FrtcTool.everyNumberDays(json.recurrenceInterval);
                }else if (json.recurrenceType === "WEEKLY") {
                    recurrenceInterval_result = FrtcTool.everyNumberWeeks(json.recurrenceInterval);
                }else if (json.recurrenceType === "MONTHLY"){
                    recurrenceInterval_result = FrtcTool.everyNumberMonths(json.recurrenceInterval);
                }

                recurrenceListData = json
                getMaxMinDate()
                meetingStopTime.text = qsTr("结束于") + FrtcTool.formatTimestamp(json.recurrenceEndDay,"yyyy-MM-dd",true) + qsTr("  剩余") + recurrenceListData.total_size + qsTr("场会议")

            }
        }
    }
}
