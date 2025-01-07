import QtQuick 2.12

Rectangle {
    //id: toast
    opacity: 0
    color: "black"
    anchors{
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }
    height: 50
    radius: 25
    antialiasing: true

    Text {
        id: lab
        color: "white"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 16
        anchors.centerIn: parent
    }

    SequentialAnimation on opacity {
        id: animation
        running: false
        property int msleep: 2500
        property int showTime: 800
        property int hideTime: 500

        NumberAnimation {
            to: 1
            duration: animation.showTime
        }

        PauseAnimation {
            duration: (animation.msleep - animation.showTime - animation.hideTime)
        }

        NumberAnimation {
            to: 0
            duration: animation.hideTime
        }

    }

    function showText(text) {
        showView(text,2500)
    }

    function showView(text, msleep) {
        if (!animation.running) {
            lab.text = text;
            width = lab.contentWidth + 50
            animation.msleep = msleep;
            animation.start();
        }
    }
}
