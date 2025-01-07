import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: frtcEnableMessageBackgroundView

    property string title: titleTextField.text
    property string imageSource: imageView.source
    property string selectedTagSource: selectedTagImageView.source

    width: 200
    height: 100

    property bool isSelected: false // 是否选中
    property int type: 0 // 模拟 EnableMessageGroundViewType
    signal clicked(int type) // 模拟委托回调
    signal updateBKColorRequested(bool flag) // 更新背景色信号

    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        color: isSelected ? "#FFFFFF" : "#FFFFFF" // 默认背景色
        border.color: isSelected ? "#026FFE" : "#DEDEDE"
        border.width: 1
    }

    // 图片
    Image {
        id: imageView
        source: imageSource
        width: 72
        height: 44
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 8
    }

    // 标题文本
    Text {
        id: titleTextField
        text: title
        color: "#666666"
        font.pixelSize: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imageView.bottom
        anchors.topMargin: 2
    }

    // 选中标记
    Image {
        id: selectedTagImageView
        source: isSelected ? selectedTagSource : ""
        width: 19
        height: 19
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        visible: isSelected
    }

    // 鼠标事件处理
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            background.border.color = "#026FFE"
        }
        onExited: {
            if (!isSelected) {
                background.border.color = "#DEDEDE"
            }
        }
        onClicked: {
            isSelected = !isSelected
            frtcEnableMessageBackgroundView.clicked(type)
        }
    }

    // 方法：更新背景颜色
    function updateBKColor(flag) {
        background.border.color = flag ? "#026FFE" : "#DEDEDE"
    }

    // 方法：设置选中状态
    function messageBackgroundViewSelected(selected) {
        isSelected = selected
        background.border.color = selected ? "#026FFE" : "#DEDEDE"
        selectedTagImageView.visible = selected
    }
}
