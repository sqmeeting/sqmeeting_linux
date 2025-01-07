import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Window
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import FrtcTool 1.0
import "../FrtcMeetingDetailView"

Rectangle {
    id: schedule_List_view

    property var scheduleListModel: []

    signal clickCell(var modelData , var buttonItemId)

    ListView {
        id: listView
        anchors.fill: parent
        model: scheduleListModel
        delegate: FrtcHomeScheduleListCell {
            width: listView.width
            height: 90
            color: "white"
            meetingNumber: qsTr("会议号") + ": "+ modelData.meeting_number
            meetingName: modelData.meeting_name
            meetingTimer: modelData.start_time + " - "  + modelData.end_time
            meetingStateText: modelData.meeting_statusStr
            meetingStateTextColor: modelData.meeting_statusStrColor
            isShowInvited: (modelData.yourSelf || modelData.joinYourself) ? false : true
            isShowRecurrence: modelData.isRecurrence
            meetingOwner: modelData.yourSelf

            onClickedCell: function (buttonItemId) {
                clickCell(modelData, buttonItemId)
            }
        }
    }

    Image {
        anchors.centerIn: parent
        source: "qrc:/Images/Home/frtc-home-noSchedule@2x.png";
        visible: scheduleListModel.length > 0 ? false : true
    }

    Connections {
        target: FrtcApiManager
        function onScheduledMeetingListRequestCompleted(success, json) {
            var jsonData = JSON.stringify(json)
            if (success) {
                scheduleListModel = FrtcTool.getMeetingDetailData(json)
            }
        }
    }
}
