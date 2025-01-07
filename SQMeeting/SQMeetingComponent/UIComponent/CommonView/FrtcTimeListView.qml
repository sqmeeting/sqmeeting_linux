import QtQuick
import QtQuick.Controls

Popup {
    id: timePopup
    width: 100
    height: 300
    modal: false
    focus: true

    background: FrtcPopupTriangleView { }

    property string minTime: "00:00" // 最小可选时间
    property string maxTime: "23:45" // 最大可选时间，默认设置为 23:45

    signal selectTimeBlock(var time)

    ListView {
        id: timeListView
        anchors.fill: parent
        model: timeModel
        interactive: true
        clip: true

        delegate: Rectangle {
            width: timeListView.width
            height: 40
            color: "white"

            property bool isDisabled: model.time < timePopup.minTime || model.time > timePopup.maxTime  // 判断是否早于 minTime 或晚于 maxTime

            MouseArea {
                id: timeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !isDisabled  // 早于 minTime 或晚于 maxTime 的时间段不可点击
                onClicked: {
                    console.log("Selected time: " + model.time)
                    selectTimeBlock(model.time)
                    timePopup.close()  // 点击后关闭弹窗
                }

                Rectangle {
                    anchors.fill: parent
                    color: timeMouseArea.containsMouse && !isDisabled ? "#EEE" : "transparent"  // 鼠标滑过效果
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    text: model.time
                    font.pixelSize: 16
                    color: isDisabled ? "#999" : "#222"  // 灰色表示不可点击项
                }
            }
        }
    }

    ListModel {
        id: timeModel
        Component.onCompleted: {
            reloadTimeModel();
        }
    }

    function reloadTimeModel() {
        timeModel.clear();
        var hours = 0;
        var minutes = 0;
        var targetIndex = -1;

        while (hours < 24) {
            var timeString = (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes);
            timeModel.append({"time": timeString});

            if (targetIndex === -1 && timeString >= minTime && timeString <= maxTime) {
                targetIndex = timeModel.count - 1;  // 记录第一个可点击的时间的索引
            }

            minutes += 15;
            if (minutes >= 60) {
                minutes = 0;
                hours += 1;
            }
        }

        if (targetIndex !== -1) {
            // 滚动到选中时间并将其置于视图中间，如果不能居中则尽量靠近顶部显示
            if (targetIndex === 0 || targetIndex === 1) {
                timeListView.positionViewAtIndex(targetIndex, ListView.Beginning);
            } else {
                timeListView.positionViewAtIndex(targetIndex, ListView.Center);
            }
        }
    }

    onOpened: {
        reloadTimeModel();
    }
}
