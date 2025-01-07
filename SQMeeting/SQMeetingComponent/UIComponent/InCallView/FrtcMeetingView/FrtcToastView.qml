import QtQuick 2.12
import QtQuick.Controls 2.12

Popup {
    id: toast
    width: 300
    height: 60
    padding: 10
    opacity: 0.65
    focus: true
//    focusPolicy: Qt.NoFocus
//    modality: Qt.NonModal

    contentItem: Text {
        id: message
        text: ""
        color: "white"
        font.pointSize: 18
        anchors.centerIn: parent
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    Timer {
        id: timer
        interval: 3000
        onTriggered: toast.close()
        repeat: false
    }

    function show(messageText) {
        message.text = messageText
        toast.open()
        timer.start()
    }
}
