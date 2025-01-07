import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Controls.Material
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import "../../../CommonView"
import "../../FrtcHome"


Window {
    id: scheduleWindow
    width: 380
    height: 660
    minimumHeight: 660
    minimumWidth: 380
    maximumHeight: 660
    maximumWidth: 380
    x: (screen.width - width)/2
    y: (screen.height - height)/2
    color: 'white'

    visible: true
    title: "预约会议"

    property var  editDetailModelData
    property var  subInviteUserViewWindowQML
    property var  inviteUserIdList : []

    property alias meetingName: meeting_theme_field.text
    property alias startDate: startTimeField.text
    property alias stopDate: stopTimeFiled.text
    property alias startTime: startDateField.text
    property alias stopTime: stopDateField.text
    property alias rateType: rate_comboBox.currentText
    property alias guestIn: meeting_guest_join_checkbox.checked
    property alias meetingPassword: password_view.checked
    property var   meetingType
    property alias muteEntry: meeting_muteJoin_checkbox.checked
    property alias watermark: meeting_watermark_checkbox.checked
    property alias meetingRoomId: roomnumbercombox.currentText

    property var userToken: SDKUserDefaultObject.getUserToken()
    property var recurrenceDayDataList: []
    property var recurrenceWeekDataList: []

    property int defaultSelectedWeekIndex: new Date(FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime)).getDay();
    property int defaultSelectedMonthIndex: new Date(FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime)).getDate();

    property var selectedWeekList: []
    property var selectedMonthList: []

    signal createMieetngFinishCompleted(var modelData)

    property var joinTimeData: [
        {
            "joimTime": "30 分钟",
            "joimTimeData": 30,
        },
        {
            "joimTime": "任意时间",
            "joimTimeData": -1,
        }
    ]

    onDefaultSelectedWeekIndexChanged: {
        if (selectedWeekList.indexOf(defaultSelectedWeekIndex) === -1) {
            selectedWeekList.push(defaultSelectedWeekIndex);
        }
    }

    onDefaultSelectedMonthIndexChanged: {
        if (selectedMonthList.indexOf(defaultSelectedMonthIndex) === -1) {
            selectedMonthList.push(defaultSelectedMonthIndex);
        }
    }

    function editMeeting() {
        meetingName = editDetailModelData.meeting_name
        startDate = FrtcTool.formatDateYMDW(editDetailModelData.schedule_start_time)
        startTime = FrtcTool.getCurrentTimeHM(editDetailModelData.schedule_start_time,true)
        stopDate = FrtcTool.formatDateYMDW(editDetailModelData.schedule_end_time)
        stopTime = FrtcTool.getCurrentTimeHM(editDetailModelData.schedule_end_time,true)

        let index = rate_comboBox.model.indexOf(editDetailModelData.call_rate_type);
        if (index !== -1) {
            rate_comboBox.currentIndex = index;
        }

        if (editDetailModelData.invited_users_details.length > 0) {
            inviteUserText.visible = true
            for (var i = 0 ; i < editDetailModelData.invited_users_details.length ; i ++) {
                var item = editDetailModelData.invited_users_details[i]
                inviteUserIdList.push(item.user_id)
            }
            inviteUserText.text = inviteUserIdList.length + qsTr('人')
        }else{
            inviteUserText.visible = false
        }

        join_time_comboBox.currentIndex = (editDetailModelData.time_to_join === 30) ? 0 : 1 ;
        meeting_muteJoin_checkbox.setStateChecked((editDetailModelData.mute_upon_entry === "ENABLE") ? true : false)
        meeting_guest_join_checkbox.setStateChecked(editDetailModelData.guest_dial_in)
        meeting_watermark_checkbox.setStateChecked(editDetailModelData.watermark)

        if (editDetailModelData.meeting_room_id) {
            //meeting_rooms_view.isEnable = true
            meeting_rooms_view.setStateChecked(true)
            roomnumbercombox.visible = true
        } else {
            //meeting_rooms_view.isEnable = false
            //meeting_rooms_view.checkable = false
            meeting_rooms_view.setStateChecked(false)
            roomnumbercombox.visible = false

            password_view.setStateChecked(editDetailModelData.meeting_password ? true : false)
        }

        //周期会议
        if (editDetailModelData.meeting_type === "recurrence") {
            recurrence_comboBox.enabled = true
            var recurrenceType = qsTr("每天")
            if (editDetailModelData.recurrence_type === "DAILY") {
                recurrenceDayComboBox.model = recurrenceDayDataList
            }else if (editDetailModelData.recurrence_type === "WEEKLY") {
                recurrenceType = qsTr("每周")
                recurrenceDayComboBox.model = recurrenceDayDataList
                const decrementArray = arr => arr.map(value => value - 1);
                selectedWeekList = decrementArray(editDetailModelData.recurrenceDaysOfWeek)
            }else if (editDetailModelData.recurrence_type === "MONTHLY"){
                recurrenceType = qsTr("每月")
                recurrenceDayComboBox.model = recurrenceDayDataList
                selectedMonthList = editDetailModelData.recurrenceDaysOfMonth
            }

            recurrenceDayComboBox.currentIndex = editDetailModelData.recurrenceInterval - 1
            let recurrenceIndex = recurrence_comboBox.model.indexOf(recurrenceType);
            if (recurrenceIndex !== -1) {
                recurrence_comboBox.currentIndex = recurrenceIndex;
            }

            recurrenceStopTimeField.text = FrtcTool.formatDateYMDW(editDetailModelData.recurrenceEndDay)
        } else {
            recurrence_comboBox.enabled = false
        }
    }

    function initInviteUserWindow() {

        if (null !== subInviteUserViewWindowQML && undefined !== subInviteUserViewWindowQML) {
            subInviteUserViewWindowQML.destroy();
        }

        var component = Qt.createComponent("./FrtcInviteUserViewWindow.qml");
        if (component.status === Component.Ready) {
            var subParams = {
                "selectListUsersArray":  inviteUserIdList,
            }
            subInviteUserViewWindowQML = component.createObject(scheduleWindow,subParams);
            subInviteUserViewWindowQML.onClickFinishButtonBlock.connect(function(selectListModel) {
                if (selectListModel.length > 0) {
                    inviteUserText.visible = true
                    inviteUserText.text = selectListModel.length + qsTr('人')
                }else {
                    inviteUserText.visible = false
                }

                inviteUserIdList = []
                for (var i = 0 ; i < selectListModel.length ; i ++) {
                    var item1 = selectListModel[i]
                    inviteUserIdList.push(item1)
                }
            });
            subInviteUserViewWindowQML.show();
        } else {
            console.log("[UI][main.qml][InviteUserViewWindow]: not show window, for it is not ready: FrtcInviteUserViewWindow.qml")
        }
    }

    function createMieetng() {
        processScheduleMeetingData()
    }

    function processScheduleMeetingData() {

        var startTimestamp =  FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime)
        var stopTimestamp  =  FrtcTool.dateStringToTimestampYMDWHM(stopDate+" "+stopTime)
        var currentTimestamp = new Date().getTime();

        if (FrtcTool.compareTimestamps(currentTimestamp,startTimestamp) === 1) {
            toast.showText("开始时间不能早于当前时间")
            return
        }

        if (FrtcTool.compareTimestamps(startTimestamp,stopTimestamp) === 1) {
            toast.showText("结束时间不能早于开始时间")
            return
        }

        var meetingData = {};
        meetingData.guest_dial_in = guestIn ? true : false
        meetingData.invited_users = inviteUserIdList
        meetingData.meeting_name = meetingName
        meetingData.meeting_type = "reservation"
        meetingData.mute_upon_entry = muteEntry ? "ENABLE" : "DISABLE"
        meetingData.schedule_end_time = stopTimestamp
        meetingData.schedule_start_time = startTimestamp
        meetingData.time_to_join = joinTimeData[join_time_comboBox.currentIndex].joimTimeData
        meetingData.watermark = watermark ? true : false
        meetingData.watermark_type = "single"

        if (meeting_rooms_view.checked) {
            var selectedMeetingRoom = roomnumbercombox.model.get(roomnumbercombox.currentIndex);
            var selectedMeetingRoomId = selectedMeetingRoom.meeting_room_id;
            meetingData.meeting_room_id = selectedMeetingRoomId
        }else{
            meetingData.call_rate_type = rateType
            //1. 无密码：meeting_password 传"";
            //2. 有指定的密码：meeting_password="123456"
            //3. 让服务器自动生成密码meeting_password 字段不传，或者传null
            meetingData.meeting_password = meetingPassword ? null : ""
        }

        //处理周期性会议数据
        var isRecurrence = (recurrence_comboBox.currentIndex !== 0)
        if (isRecurrence) {
            var typeIndex = recurrence_comboBox.currentIndex;
            var recurrenceperiodLength = recurrenceDayComboBox.currentIndex + 1;

            meetingData.meeting_type = "recurrence"
            meetingData.recurrence_type = typeIndex === 1 ? "DAILY" : (typeIndex === 2 ? "WEEKLY" : "MONTHLY")
            meetingData.recurrenceInterval = recurrenceperiodLength

            if (typeIndex === 2) {
                meetingData.recurrenceDaysOfWeek = selectedWeekList.map(value => value + 1);

            }else if (typeIndex === 3) {
                meetingData.recurrenceDaysOfMonth = selectedMonthList
            }

            meetingData.recurrenceStartTime = startTimestamp
            meetingData.recurrenceEndTime = stopTimestamp
            meetingData.recurrenceStartDay = startTimestamp
            meetingData.recurrenceEndDay = FrtcTool.dateStringToTimestampYMDWHM(recurrenceStopTimeField.text+" "+"23:45")
        }

        console.log("Meeting Data as JSON:", JSON.stringify(meetingData, null, 4));

        //如果是编辑会议,需要单独处理下密码
        if (editDetailModelData) {

            if (meetingPassword && editDetailModelData.meeting_password) {
                meetingData.meeting_password = editDetailModelData.meeting_password
            }

            if (meetingPassword && !editDetailModelData.meeting_password ) {
                var arcNumber = Math.floor(Math.random() * 100000);
                var arcpassword = arcNumber.toString().padStart(6, '0');
                meetingData.meeting_password = arcpassword;
            }

            //更新会议
            if (isRecurrence) {
                FrtcApiManager.updateRecurrenceMeeting(userToken,editDetailModelData.reservation_id,meetingData)
            }else {
                FrtcApiManager.updateNoRecurrenceMeeting(userToken,editDetailModelData.reservation_id,meetingData)
            }

        } else {
            //创建会议
            FrtcApiManager.createMeeting(userToken,meetingData)
        }

    }

    function calculateRecurrenceMeetingEndTime() {
        var isRecurrence = (recurrence_comboBox.currentIndex !== 0)
        if (isRecurrence) {
            var startTimestamp =  FrtcTool.dateStringToTimestampYMDWHM(startDate+" "+startTime)
            var recurrenceType = recurrence_comboBox.currentIndex;
            var recurrenceperiodLength = recurrenceDayComboBox.currentIndex + 1;
            var periodType = recurrenceType === 1 ? "day" : (recurrenceType === 2 ? "week" : "month")
            var stopTime = FrtcTool.calculateEndDate(startTimestamp,periodType,recurrenceperiodLength)
            recurrenceStopTimeField.text = FrtcTool.formatDateYMDW(stopTime)
        }
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

            ColumnLayout {

                spacing: 10

                Text {
                    text: "会议主题"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                FrtcTextField {
                    id: meeting_theme_field
                    width: scheduleWindow.width - 35
                    height: 35
                    textFont: 14
                }
            }

            Item {
                height: 5
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
                        width: (scheduleWindow.width - 35 ) * 0.65
                        height: 35
                        isShowRightImg: true
                        readOnly: true
                        text: FrtcTool.formatDateYMDW()
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
                        width: (scheduleWindow.width - 35 ) - startTimeField.width - 10
                        height: 35
                        isShowRightImg: true
                        text: FrtcTool.getCurrentTimeHM()
                        textFont: 14
                        rightIcon: 'qrc:/Images/Home/frtc_schedule_time@2x.png'

                        onTextChanged: {
                            var filteredText = startDateField.text.replace(/[^0-9:]/g, "");
                            if (filteredText !== startDateField.text) {
                                startDateField.text = filteredText;
                            }
                        }

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
                        width: (scheduleWindow.width - 35 ) * 0.65
                        height: 35
                        readOnly: true
                        isShowRightImg: true
                        rightIcon: 'qrc:/Images/Home/frtc_calendar@2x.png'
                        text: FrtcTool.formatDateYMDW()
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
                        width: (scheduleWindow.width - 35 ) - startTimeField.width - 10
                        height: 35
                        isShowRightImg: true
                        //text: FrtcTool.getHalfHourLater(startDateField.text)
                        rightIcon: 'qrc:/Images/Home/frtc_schedule_time@2x.png'
                        textFont: 14

                        onTextChanged: {
                            var filteredText = stopDateField.text.replace(/[^0-9:]/g, "");
                            if (filteredText !== stopDateField.text) {
                                stopDateField.text = filteredText;
                            }
                        }

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

            Item {
                height: 5
            }

            ColumnLayout {

                spacing: 10

                Text {
                    text: qsTr("时区")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                FrtcTextField {
                    width: scheduleWindow.width - 40
                    height: 40
                    readOnly: true
                    placeholderText: qsTr('(GMT+08:00) 中国标准时间 - 北京')
                    textFont: 14
                }

            }

            Item {
                height: 5
            }

            ColumnLayout {

                spacing: 10

                Text {
                    text: qsTr("周期性会议")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                RowLayout {

                    spacing: 50
                    Text {
                        text: qsTr("重复")
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    ComboBox {
                        id: recurrence_comboBox
                        model: ["不重复", "每天", "每周", "每月"]

                        onActivated: {
                            if(recurrence_comboBox.currentIndex !== 0) {
                                if (recurrence_comboBox.currentIndex === 1) {
                                    recurrenceDayComboBox.model = recurrenceDayDataList
                                }else{
                                    recurrenceDayComboBox.model = recurrenceWeekDataList
                                }
                                calculateRecurrenceMeetingEndTime()
                            }
                        }
                    }
                }
            }

            ColumnLayout {

                spacing: 3
                visible: recurrence_comboBox.currentIndex === 0 ? false : true

                RowLayout {

                    spacing: 0

                    Text {
                        text: qsTr("频率")
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Item {
                        width: 50
                    }

                    ComboBox {
                        id: recurrenceDayComboBox
                        model: recurrenceWeekDataList
                        onActivated: {
                            console.log("Selected:", recurrenceDayComboBox.currentText,recurrenceDayComboBox.currentIndex);
                            calculateRecurrenceMeetingEndTime()
                        }
                    }

                    Text {
                        text:recurrence_comboBox.currentIndex === 1 ? qsTr("天") : (recurrence_comboBox.currentIndex === 2 ? qsTr("周") :  qsTr("月") )
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }

                RowLayout {

                    id: weekRepeaterRowLayout
                    visible: recurrence_comboBox.currentIndex === 2 ? true : false
                    spacing: 2

                    Item{
                        width: 80
                    }

                    Repeater {

                        id: weekRepeater

                        model: ["日", "一", "二", "三", "四", "五", "六"]

                        FrtcDateButton {
                            implicitWidth: 35
                            implicitHeight: 35
                            index: model.index
                            text: modelData
                            radius: 8
                            defaultSelected: (index === defaultSelectedWeekIndex)
                            selected: selectedWeekList.indexOf(index) !== -1

                            onClicked: {
                                if (selectedWeekList.indexOf(index) !== -1) {
                                    if (index !== defaultSelectedWeekIndex) {
                                        selectedWeekList = selectedWeekList.filter(function(i) { return i !== index; });
                                    }
                                } else {
                                    selectedWeekList.push(index);
                                }
                                selected = selectedWeekList.indexOf(index) !== -1;
                            }
                        }
                    }
                }

                RowLayout {

                    id: monthRepeaterRowLayout
                    visible: recurrence_comboBox.currentIndex === 3 ? true : false

                    Item {
                        width: 77
                    }

                    Rectangle {

                        border.color: "#ddd"
                        border.width: 1
                        radius: 8
                        color: "white"
                        width: 245 + 10
                        height: 175 + 10
                        clip: true

                        GridLayout {
                            id: monthGrid
                            columns: 7
                            columnSpacing: 1
                            anchors.fill: parent
                            anchors.margins: 5

                            Repeater {

                                id: monthRepeater
                                model: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
                                clip: true

                                FrtcDateButton {
                                    text: modelData + 1
                                    implicitWidth: 30
                                    implicitHeight: 30
                                    index: model.index + 1
                                    radius: 15
                                    customColor: true
                                    defaultSelected: (index === defaultSelectedMonthIndex)
                                    selected: selectedMonthList.indexOf(index) !== -1

                                    onClicked: {
                                        if (selectedMonthList.indexOf(index) !== -1) {
                                            if (index !== defaultSelectedMonthIndex) {
                                                selectedMonthList = selectedMonthList.filter(function(i) { return i !== index; });
                                            }
                                        } else {
                                            selectedMonthList.push(index);
                                        }
                                        selected = selectedMonthList.indexOf(index) !== -1;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {

                id: recurrenceStopTimeLayout
                visible: recurrence_comboBox.currentIndex === 0 ? false : true

                Text {
                    text: qsTr("结束于")
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Item {
                    width: 32
                }

                RowLayout {
                    spacing: 10
                    FrtcTextField {
                        id: recurrenceStopTimeField
                        width: (scheduleWindow.width - 40 ) * 0.65
                        height: 35
                        isShowRightImg: true
                        readOnly: true
                        text: FrtcTool.formatDateYMDW()
                        rightIcon: 'qrc:/Images/Home/frtc_calendar@2x.png'
                        textFont: 14

                        onClickRightIcon: {
                            var globalPosition = recurrenceStopTimeField.mapToItem(flickable, 0, recurrenceStopTimeField.height)
                            var adjustedY = globalPosition.y + flickable.contentY
                            recurrenceStopTimeloader.sourceComponent = recurrenceStopTimeCalendarView
                            recurrenceStopTimeloader.visible = true
                            recurrenceStopTimeloader.x = globalPosition.x
                            recurrenceStopTimeloader.y = adjustedY + 5
                            if (recurrenceStopTimeloader.item) {
                                recurrenceStopTimeloader.item.open()
                            }
                        }
                    }
                }
            }

            RowLayout {

                id: meeting_rooms_rowlayout
                spacing: 30

                FrtcCheckBoxView {

                    id:meeting_rooms_view
                    btn_txt_unchecked: qsTr("使用个人会议号")
                    btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                    btn_txt_checked: qsTr("使用个人会议号")
                    btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                    isStateChangeButton: true
                    checked: false
                    isEnable: true

                    onMouseClicked: {
                        if (meeting_rooms_view.checked === false) {
                            console.log(" false");
                            roomnumbercombox.visible = false
                        } else {
                            console.log(" true");
                            roomnumbercombox.visible = true
                        }
                    }
                }

                ComboBox {
                    id: roomnumbercombox
                    visible: false
                    model: ListModel {}
                    textRole: "meeting_number"
                    onActivated: {
                        if (currentIndex >= 0) {
                            var selectedMeetingRoom = roomnumbercombox.model.get(currentIndex);
                            var selectedMeetingRoomId = selectedMeetingRoom.meeting_room_id;
                            console.log("Meeting Room ID to upload:", selectedMeetingRoomId);
                        }
                    }
                }
            }

            FrtcCheckBoxView {

                id:password_view
                visible: !roomnumbercombox.visible
                btn_txt_unchecked: qsTr("开启会议密码")
                btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                btn_txt_checked: qsTr("开启会议密码")
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                isStateChangeButton: true
                checked: false

                onMouseClicked: {
                    console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : false");
                }

            }

            RowLayout {

                id:invite_user_rowLayout
                spacing: 20

                Text {
                    text: qsTr("受邀用户")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#222222"
                }

                Text {
                    id:inviteUserText
                    font.pixelSize: 15
                    visible: true
                    color: "#222222"
                }

                FrtcButton {
                    width: 100
                    height: 30
                    buttonText: " + 添加用户 "
                    textColor: '#026FFE'
                    backgroundColor: "white"
                    hoverColor: "white"
                    borderColor: "#026FFE"

                    onMouseClicked: {
                        initInviteUserWindow()
                    }
                }
            }

            RowLayout {

                id: rate_rowlayout
                spacing: 20
                visible: !roomnumbercombox.visible

                Text {
                    id:rateText
                    text: qsTr("速率")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#222222"
                }

                ComboBox {
                    id: rate_comboBox
                    width: 300
                    height: 20
                    currentIndex: 3
                    model: ["128K", "512K", "1024K", "2048K", "2560K", "3072K", "4096K"]

                    onActivated: {
                        console.log("Selected:", rate_comboBox.currentText);
                    }
                }
            }

            RowLayout {

                id: join_time_rowlayout
                spacing: 20
                visible: !roomnumbercombox.visible

                Text {
                    id: meeting_time_text
                    text: qsTr("提前入会时间")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#222222"
                }

                ComboBox {

                    id: join_time_comboBox
                    width: 200
                    height: 20
                    model: joinTimeData
                    textRole: "joimTime"
                    onActivated: {
                        console.log("Selected:", join_time_comboBox.currentText);
                    }
                }

            }

            FrtcCheckBoxView {
                id: meeting_muteJoin_checkbox
                btn_txt_unchecked: qsTr("入会静音")
                btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                btn_txt_checked: qsTr("入会静音")
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                isStateChangeButton: true
                checked: false

                onMouseClicked: {
                    console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : false");
                }

            }

            FrtcCheckBoxView {
                id: meeting_guest_join_checkbox
                visible: !roomnumbercombox.visible
                btn_txt_unchecked: qsTr("允许访客拨入")
                btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                btn_txt_checked: qsTr("允许访客拨入")
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                isStateChangeButton: true
                checked: true
                isEnable: !meeting_watermark_checkbox.checked

                onMouseClicked: {
                    console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : false");
                }

            }

            FrtcCheckBoxView {
                id: meeting_watermark_checkbox
                visible: !roomnumbercombox.visible
                btn_txt_unchecked: qsTr("共享屏幕水印")
                btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                btn_txt_checked: qsTr("共享屏幕水印")
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                isStateChangeButton: true
                checked: false
                isEnable: !meeting_guest_join_checkbox.checked

                onMouseClicked: {
                    console.log("[UI][FrtcCallView.qml][onMouseClicked]: press micphoneOnOffCheckBox button, checked : false");
                }

            }

            Rectangle {
                width: parent.width
                height: 100
                color: "red"
            }

            Loader {
                id:scheduleStartTimeloader
                visible: false
                parent: flickable.contentItem
            }

            Component {
                id: scheduStartCalendarView
                FrtcCalendar {
                    onCloseCalendar: function(selectedDayText) {
                        scheduleStartTimeloader.sourceComponent = null
                        console.log("select day +++++++++ --- :" ,selectedDayText)
                        var dayOfWeek = FrtcTool.getDayOfWeek(selectedDayText)
                        startTimeField.text = selectedDayText + " " + dayOfWeek
                        stopTimeFiled.text = selectedDayText + " " + dayOfWeek
                        calculateRecurrenceMeetingEndTime()
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
                    maxSelectableTimestamp: FrtcTool.add24Hours(FrtcTool.dateToTimestampRW(startTimeField.text))
                    minSelectableTimestamp: FrtcTool.dateToTimestampRW(startTimeField.text)
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

            Loader {
                id:recurrenceStopTimeloader
                visible: false
                parent: flickable.contentItem
            }

            Component {
                id: recurrenceStopTimeCalendarView
                FrtcCalendar {
                    // maxSelectableTimestamp: FrtcTool.add24Hours(FrtcTool.dateToTimestampRW(startTimeField.text))
                    // minSelectableTimestamp: FrtcTool.dateToTimestampRW(startTimeField.text)
                    noDefaultSelection: true
                    onCloseCalendar: function(selectedDayText) {
                        recurrenceStopTimeloader.sourceComponent = null
                        console.log("select day --- :" ,selectedDayText)
                        var dayOfWeek = FrtcTool.getDayOfWeek(selectedDayText)
                        recurrenceStopTimeField.text = selectedDayText + " " + dayOfWeek
                    }

                    onClosed: {
                        recurrenceStopTimeloader.sourceComponent = null
                    }
                }
            }

            FrtcTimeListView {
                id: startTimePopupView
                minTime: FrtcTool.getCurrentTimeHM()

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
        buttonText: editDetailModelData ? qsTr("保持修改") : qsTr('预约')
        onMouseClicked: {
            createMieetng()
        }
    }

    FrtcToastView {
        id: toast
    }

    Component.onCompleted:  {

        for (var i = 1; i <= 99; i++) {
            recurrenceDayDataList.push("每" + i);
        }
        //recurrenceDayComboBox.model = recurrenceDayDataList

        for (var j = 1; j <= 12; j++) {
            recurrenceWeekDataList.push("每" + j);
        }

        let userRealName  =  SDKUserDefaultObject.getUserInfo().real_name
        meetingName = userRealName + qsTr('的预约会议')
        if (userToken) {
            //请求是否有个人会议号
            FrtcApiManager.getMeetingRoomList(userToken)
            //如果是编辑会议先去请求会议详情接口
            if (editDetailModelData) {
                FrtcApiManager.getScheduledMeetingDetail(userToken,editDetailModelData.reservation_id)
            }
        }

        var startDateStr = startDateField.text
        stopDateField.text = FrtcTool.getHalfHourLater(startDateStr);

    }

    Connections {
        target: FrtcApiManager
        function onQueryMeetingRoomListRequestCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            console.log('Schedule 个人会议号列表 --', "success:", success);
            if (success) {
                meeting_rooms_view.isEnable = json.meeting_rooms.length > 0 ? true : false
                roomnumbercombox.model.clear();
                for (var i = 0; i < json.meeting_rooms.length; i++) {
                    roomnumbercombox.model.append({
                                                      meeting_number: json.meeting_rooms[i].meeting_number,
                                                      meeting_room_id: json.meeting_rooms[i].meeting_room_id
                                                  });
                }
                if (json.meeting_rooms.length > 0) {
                    //编辑的时候需要判断 meetingRoomId 再确定显示的index
                    roomnumbercombox.currentIndex = 0;
                }
            }
        }

        function onCreatMeetingCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            console.log('预约非周期会议 --', "success:", success,jsonData);
            if (success) {
                createMieetngFinishCompleted(json)
                scheduleWindow.destroy()
            }else{
                toast.showText("预约会议失败")
            }
        }

        function onDetailScheduleMeetingCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            console.log('获取会议详情----', "success:", success);
            if (success) {
                editDetailModelData = json
                editMeeting()
            }
        }

        function onUpdateNoRecurrenceMeetingCompleted(success, json) {
            if (success) {
                FrtcTool.refreshHomeMeetingList()
                scheduleWindow.destroy()
            }else{
                toast.showText("更新非周期会议失败")
            }
        }

        function onUpdateRecurrenceMeetingCompleted(success, json) {
            if (success) {
                FrtcTool.refreshHomeMeetingList()
                scheduleWindow.destroy()
            }else{
                toast.showText("更新周期会议失败")
            }
        }

    }
}
