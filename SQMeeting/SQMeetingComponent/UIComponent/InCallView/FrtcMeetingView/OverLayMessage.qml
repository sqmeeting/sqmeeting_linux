import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: overLayMessageView
    width: parent.with
    height: 40
    color: "transparent"
    radius: 4
    visible: false // 控制初始隐藏状态

    property alias messageText: messageField.text
    property real animationDuration: 15000 // 动画持续时间（毫秒）
    property int cycleNumbers: 0 // 动画循环次数
    property bool isStillnessInfo: false // 是否为静态信息

    signal repeateUpdateView()

    Rectangle {
        id: gradientBackground
        anchors.fill: parent
        color: "white"
        layer.enabled: true
        layer.smooth: true

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop { position: 0.0;  color: Qt.rgba(2/255.0, 153/255.0, 254/255.0, 0.0) }
            GradientStop { position: 0.25; color: Qt.rgba(5/255.0, 129/255.0, 255/255.0, 0.38) }
            GradientStop { position: 0.51; color: "#0565FF" }
            GradientStop { position: 0.73; color: Qt.rgba(4/255.0, 106/255.0, 255/255.0, 0.38) }
            GradientStop { position: 1.0;  color: Qt.rgba(2/255.0, 111/255.0, 254/255.0, 0.0) }
        }
    }

    Text {
        id: messageField

        y: (overLayMessageView.height - height) / 2 // 手动设置垂直居中
        x: overLayMessageView.width // 初始位置（在父级右侧外）

        color: "white"
        font.pixelSize: 16
        horizontalAlignment: isStillnessInfo ? Text.AlignHCenter : Text.AlignLeft
        wrapMode: isStillnessInfo ? Text.NoWrap : Text.WordWrap
        text: "Dynamic message content"
    }

    SequentialAnimation {
        id: slideAnimation
        loops: overLayMessageView.cycleNumbers
        running: false // 初始状态下不自动运行

        onRunningChanged: {
            if (running) {
                console.log("Animation started!")
            } else {
                console.log("Animation stopped or paused.")
                if(!isStillnessInfo) {
                    overLayMessageView.visible = false
                }
            }
        }

        PropertyAnimation {
            target: messageField
            property: "x"
            from: overLayMessageView.width
            to: -messageField.width//-messageField.width - overLayMessageView.width
            duration: overLayMessageView.animationDuration
        }
    }

    // 静态布局调整
    function setupStillnessLayout() {
        messageField.y = (overLayMessageView.height - messageField.height) / 2 // 手动设置垂直居中
        messageField.x = (overLayMessageView.width - messageField.width) / 2// 初始位置（在父级右侧外）
    }

    // 启动动画
    function restart() {
        if (isStillnessInfo) {
            console.log('1111111111')
            slideAnimation.stop()
            setupStillnessLayout()
        } else {
            console.log('333333333333')

            messageField.x = 50
            console.log("Initial x:", messageField.x)


            messageField.x = overLayMessageView.width
            slideAnimation.start()
        }
    }

    // 停止动画
    function stop() {
        slideAnimation.stop()
    }


    Component.onCompleted: {
        messageField.x = 50
        console.log("Initial x:", messageField.x)
    }
}
