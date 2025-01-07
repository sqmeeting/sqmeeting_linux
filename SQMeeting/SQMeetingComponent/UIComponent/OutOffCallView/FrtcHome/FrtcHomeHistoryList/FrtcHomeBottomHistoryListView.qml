import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Window
import "../../../CommonView"


Rectangle {

    id: history_List_view

    property alias historyList: listView.model

    signal clickCell(var model , var buttonItemId)

    ListView {
        id: listView
        anchors.fill: parent
        model: FrtcTool.loadMeetigData()
        delegate: FrtcHistoryListCell {
            width: listView.width
            height: 90            
            meetingName: modelData.meetingName
            meetingNumber:  qsTr("会议号") + ": "+  modelData.meetingId
            meetingTime: FrtcTool.formatTimestamp(modelData.meetingStartTime)
            color: "white"

            onClickItemCell: function(itemId) {
                clickCell(modelData, itemId)
            }
        }
    }

    Image {
        id: noHistoryView
        anchors.centerIn: parent
        source: "qrc:/Images/Home/frtc-home-noCallHistory@2x.png";
    }

    function noHistoryViewHide() {
        historyList =  FrtcTool.loadMeetigData()
        noHistoryView.visible = historyList.length > 0 ? false : true
    }

    Component.onCompleted:  {
        noHistoryViewHide()
        FrtcTool.refreshHistoryList.connect(function() {
            noHistoryViewHide()
        });
    }
}

