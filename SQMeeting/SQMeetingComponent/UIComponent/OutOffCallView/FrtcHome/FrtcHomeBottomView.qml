import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Window
//import QtQuick.Controls.Material

import './FrtcHomeHistoryList'
import './FrtcHomeScheduleList'
import '../../CommonView'

Rectangle {
    id: home_bottom_view
    width: parent.width
    anchors.bottom: parent.bottom

    color: 'white'

    signal clickRefreshBtn(bool isHistory)
    signal clickScheduleListCell(var modelData , var buttonItemId)
    signal clickHistoryListCell(var modelData , var buttonItemId)

    FrtcButton {
        id: schedule_metting_btn
        width: 80
        height: 35
        anchors.left: parent.left
        anchors.leftMargin: 15


        anchors.top: parent.top
        textFont: 16
        textColor: '#222222'
        backgroundColor: 'white'
        hoverColor: 'white'
        buttonText: qsTr("预约会议")
        isTextBold: true

        onMouseClicked: {
            console.log("schedule btn")
            changeSelectedState(false)
        }
    }

    FrtcButton {
        id: history_metting_btn
        height: schedule_metting_btn.height
        width: schedule_metting_btn.width
        anchors.left: schedule_metting_btn.right
        anchors.leftMargin: 10
        anchors.top: schedule_metting_btn.top
        textFont: 14
        textColor: '#222222'
        backgroundColor: 'white'
        hoverColor: 'white'
        buttonText: qsTr("历史会议")
        isTextBold: true

        onMouseClicked: {
            FrtcTool.refreshHistoryList();
            changeSelectedState(true)
        }
    }

    Image {
        id:bottomView_select_linne
        anchors.top: schedule_metting_btn.bottom
        anchors.horizontalCenter: schedule_metting_btn.horizontalCenter
        source: 'qrc:/Images/Home/frtc_home_select_linne.png'
    }

    Image {
        id: bottomView_right_btn
        width: 25
        height: 25
        anchors.verticalCenter: schedule_metting_btn.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        // anchors.top: schedule_metting_btn.top
        source: "qrc:/Images/Home/frtc_home_refresh@2x.png";

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                clickRefreshBtn(historyListView.visible)
            }
        }

    }

    Rectangle {
        id: bottomView_line
        color: '#e2e2e2'
        height: 1
        anchors.top: bottomView_select_linne.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
    }

    FrtcHomeBottomScheduleListView {
        id:scheduleListView
        clip: true
        anchors.top:bottomView_line.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: true

        onClickCell: function (modelData ,buttonItemId) {
            clickScheduleListCell(modelData,buttonItemId)
        }
    }

    FrtcHomeBottomHistoryListView {
        id:historyListView
        clip: true
        anchors.top:scheduleListView.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false

        onClickCell: function (modelData ,buttonItemId) {
            clickHistoryListCell(modelData,buttonItemId)
        }
    }

    function changeSelectedState(historyBtn) {
        if (true === historyBtn) {
            bottomView_select_linne.anchors.horizontalCenter = history_metting_btn.horizontalCenter
            bottomView_right_btn.source = "qrc:/Images/Home/frtc_home_delete@2x.png";
            history_metting_btn.textFont = 16
            schedule_metting_btn.textFont = 14
            scheduleListView.visible = false
            historyListView.visible = true
        }else{
            bottomView_select_linne.anchors.horizontalCenter = schedule_metting_btn.horizontalCenter
            bottomView_right_btn.source = "qrc:/Images/Home/frtc_home_refresh@2x.png";
            schedule_metting_btn.textFont = 16
            history_metting_btn.textFont = 14
            scheduleListView.visible = true
            historyListView.visible = false
        }
    }

}
