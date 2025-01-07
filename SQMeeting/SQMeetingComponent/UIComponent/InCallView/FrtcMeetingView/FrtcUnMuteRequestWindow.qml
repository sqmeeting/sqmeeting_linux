import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "./View"

ApplicationWindow {
    id: mainWindow

    //flags: Qt.FramelessWindowHint
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    modality: Qt.ApplicationModal

    color: "transparent"

    property var onRequestUnMuteCallback

    width: 448
    height: 463

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    visible: true
    //title: '参会者权限申请'
    //color: 'white'

    // 动态数据数组
    property var nameArray: ["Alice", "Bob", "Charlie"]
    property var uuidArray: ["uuid1", "uuid2", "uuid3"]

    onClosing: {
        console.log("Window is closing...");
        destroy(); // 销毁窗口
    }

    function updateModel(nameArray) {
        rosterListView.model = nameArray;
    }

    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"
        radius: 10

        Text {
            id: titleTextField
            text: '参会者权限申请'
            color: "#333333"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap

            // 布局设置
            anchors.horizontalCenter: parent.horizontalCenter // 水平中心对齐
            anchors.top: parent.top
            anchors.topMargin: 9// 顶部偏移量
        }

        FrtcRequestUnMuteBackgroundView {
            id:backgroundView
            visible: false

            anchors.top: parent.top
            anchors.topMargin: 41
        }

        FrtcRequetUnMuteTitleCell {
            id:cellTitle
            visible: true
            anchors.top: parent.top
            anchors.topMargin: 41
        }

        Rectangle {
            id: listContainer
            width: parent.width
            height: 320
            //color: "#0565FF"
            color: 'white'

            anchors.top: parent.top
            anchors.topMargin: 81

            //visible: uuidArray.length > 0
            visible: true

            ListView {
                id: rosterListView
                anchors.fill: parent
                width: parent.width
                height: parent.height
                model: nameArray
                delegate: FrtcRequestUnMuteDetailCell {
                    id: cell
                    name: modelData
                    status: "Unmute"
                    onAgreeUnmuteClicked: {
                        console.log("Agreed unmute for:", name)
                        const index = nameArray.indexOf(name)
                        if (index >= 0) {

                            console.log('the uuid is ', uuidArray[index])
                            onRequestUnMuteCallback([uuidArray[index]])

                            nameArray.splice(index, 1)
                            uuidArray.splice(index, 1)
                            rosterListView.model = nameArray // 刷新模型

                            if(nameArray.length === 0) {
                                backgroundView.visible = true
                                cellTitle.visible = false
                                listContainer.visible = false
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: allAgreeButton
            width: 104
            height: 30
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16

            color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

            radius: 4

            Text {
                anchors.centerIn: parent
                text: '全部同意'
                font.pixelSize: 14
                color: 'white'
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    onRequestUnMuteCallback(uuidArray)
                    nameArray = []
                    uuidArray = []
                    rosterListView.model = nameArray

                    backgroundView.visible = true
                    cellTitle.visible = false
                    listContainer.visible = false
                    console.log("Agreed all unmute requests")
                }
            }
        }
    }
}
