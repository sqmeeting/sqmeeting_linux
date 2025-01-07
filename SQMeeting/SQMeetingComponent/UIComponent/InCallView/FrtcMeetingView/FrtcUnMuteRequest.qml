import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: requestUnMuteView
    width: 224
    height: 94

    x: (screen.width - width)/2
    y: (screen.height - height)/2

    radius: 4
    color: "#FFFFFF"
    visible: false
    property string nameText: "糖七七"
    property string titleText: '正在申请解除静音'
    property int nameMaxWidth: 200

    property var onRequestUnMuteCallback

    Text {
        id: nameTextField
        text: nameText
        font.pixelSize: 13
        font.bold: true
        color: "#222222"

        anchors.top: parent.top
        anchors.topMargin: 14

        // anchors.left: parent.left
        // anchors.leftMargin: 20

        anchors.horizontalCenter: parent.horizontalCenter

        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        width: Math.min(requestUnMuteView.nameMaxWidth, implicitWidth)
        height: implicitHeight
    }

    // Title Text Field
    // Text {
    //     id: titleTextField
    //     text: '正在申请解除静音'
    //     font.pixelSize: 13
    //     font.bold: true
    //     color: "#222222"
    //     horizontalAlignment: Text.AlignLeft
    //     visible: nameTextField.width >= requestUnMuteView.nameMaxWidth

    //     anchors.top: parent.top
    //     anchors.topMargin: 14

    //     anchors.left: nameTextField.right
    //     anchors.leftMargin: 4
    // }

    Rectangle {
        id: closeButton
        width: 88
        height: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14

        anchors.left: parent.left
        anchors.leftMargin: 16

        color: Qt.rgba(220/255.0, 220/255.0, 235/255.0, 1.0)
        radius: 4

        Text {
            anchors.centerIn: parent
            text: '忽略'
            font.pixelSize: 13
            color: Qt.rgba(0x24/255.0, 0x24/255.0, 0x25/255.0, 1.0)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // onStartRecordingCallback(0, true)
                // root.close()
                requestUnMuteView.visible = false
            }
        }
    }

    Rectangle {
        id: recordButton
        width: 88
        height: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14

        anchors.right: parent.right
        anchors.rightMargin: 16
        color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 1.0)

        radius: 4

        Text {
            anchors.centerIn: parent
            text: '查看'
            font.pixelSize: 13
            color: 'white'
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                onRequestUnMuteCallback()
                requestUnMuteView.visible = false
            }

        }
    }

    // 动态更新文本逻辑
    function updateRequestName(name) {
        nameTextField.text = name + titleText
    }
}
