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

    id: meetingHistoryDetailWindow
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

    function showCancelMeetingAlertView() {

        AlertManager.showAlertView(qsTr("删除会议"),
                                   qsTr("确定从历史会议中删除该会议吗?"),
                                   FrtcAlertView.OkButton | FrtcAlertView.CancelButton,
                                   function(result) {
                                       if (result === 0) {
                                           console.log("User clicked OK");
                                       } else if (result === 1) {
                                           console.log("User clicked Cancel");
                                           FrtcTool.deleteDataByMeetingStartTime(pageData.meetingStartTime)
                                           FrtcTool.refreshHistoryList()
                                           meetingHistoryDetailWindow.destroy()
                                       }
                                   },
                                   "确定",
                                   "取消",
                                   );
    }

    function deleteScheduledMeeting(isRecurrence) {
        //取消会议
    }

    FrtcHomeDetailListView {
        id: detailListView
        height: 330
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        meetingTitle: pageData.meetingName
        meetingStartTime: FrtcTool.formatTimestamp(pageData.meetingStartTime)
        meetingTime: FrtcTool.formatTimestamp(pageData.meetingStopTime)
        meetingOwner: pageData.meetingOwnerName
        meetingNumber: pageData.meetingId
        meetingPassword: pageData.meetingPassword
    }

    FrtcButton {
        id: joinMeeting_btn
        height: 40
        anchors.top: detailListView.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        borderColor: "#cccccc"
        backgroundColor: "white"
        textColor: "#026FFE"
        hoverColor: "#eeeeee"
        buttonText: qsTr('加入')
        onMouseClicked: clickCopyInfo()
    }

    FrtcButton {
        id: cancelMeeting_btn
        height: 40
        anchors.top: joinMeeting_btn.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        borderColor: "#cccccc"
        backgroundColor: "white"
        hoverColor: "#eeeeee"
        textColor: "red"
        buttonText: qsTr('删除')
        onMouseClicked: {
            showCancelMeetingAlertView()
        }
    }
}
