import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: customAlertView
    width: Math.max(rightButton.width + leftButton.width + 20 + 60, 260)
    height: 150

    property alias title: titleText.text
    property alias message: messageText.text
    property alias cancelButtonText: cancelButton.text
    property alias acceptButtonText: acceptButton.text

    property var checkBoxViewText: qsTr("默认值")
    property bool checkBoxViewVisible: false
    property bool checkBoxChecked: checkBoxView.checked

    signal accepted()
    signal rejected()

    Popup {
        id: alertPopup
        width: customAlertView.width
        height: customAlertView.height
        modal: true
        focus: false
        closePolicy: Popup.NoAutoClose
        dim: false

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "red"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 5

            Text {
                text: "X"
                color: "white"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: alertPopup.close()
            }

        }


        background: Rectangle {
            color: "#ffffff"
            radius: 8
            border.color: "#cccccc"
        }

        Column {
            id: layout
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Title
            Text {
                id: titleText
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: "#222"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            // Message
            Text {
                id: messageText
                font.pixelSize: 14
                color: "#555"
                visible: !checkBoxViewVisible
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width - 30
            }

            FrtcCheckBoxView {
                id: checkBoxView
                visible: checkBoxViewVisible
                btn_txt_unchecked: checkBoxViewText
                btn_img_src_unchecked: 'qrc:/Images/MainView/icon_checkbox_unchecked.png'
                btn_txt_checked: checkBoxViewText
                btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked.png"
                isStateChangeButton: true
                checked: false
                anchors.horizontalCenter: parent.horizontalCenter

                onMouseClicked: {
                    console.log();
                }
            }

            // Action Buttons
            RowLayout {
                id: buttonRow
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.fillWidth: true
                spacing: 20

                Rectangle {
                    id: leftButton
                    width: cancelButton.contentWidth + 30
                    height: 30
                    radius: 4
                    color: "#f0f0f0"

                    Text {
                        id: cancelButton
                        text: cancelButtonText
                        anchors.centerIn: parent
                        color: "#222"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            leftButton.color = '#f0f0f0'
                        }

                        onExited: {
                            leftButton.color = '#f0f0f0'
                        }

                        onClicked: {
                            alertPopup.close()
                            customAlertView.rejected()
                        }
                    }
                }

                Rectangle {
                    id: rightButton
                    width: acceptButton.contentWidth + 30
                    height: 30
                    radius: 4
                    color: "#026FFE"

                    Text {
                        id: acceptButton
                        text: acceptButtonText
                        color: "white"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            rightButton.color = '#1f80ff'
                        }

                        onExited: {
                            rightButton.color = "#026FFE"
                        }

                        onClicked: {
                            alertPopup.close()
                            customAlertView.accepted()
                        }
                    }
                }
            }
        }
    }

    // Function to open the alert
    function show() {
        alertPopup.open();
    }
}
