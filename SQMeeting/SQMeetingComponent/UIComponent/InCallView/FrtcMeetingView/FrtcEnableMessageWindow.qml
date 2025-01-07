import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.1

import "./../../CommonView/"
import "./View"

Window {
    id:root

    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    title: '启用横幅'
    width: 400
    height: 370

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    property int circleTimes: 3
    property int position: 0
    property bool scroll: true

    property int maxLength: 1024

    property var onEnableMessageCallback

    Rectangle {
        id: meetingDescriptionInput
        anchors.left: parent.left
        anchors.leftMargin: 87
        anchors.top: parent.top
        anchors.topMargin: 16
        width: 280
        height: 87
        //border.color: "#DEDEDE"
        border.color: "#CCCCCC"
        border.width: 1
        radius: 4

        ScrollView {
            id: view
            anchors.fill: parent
            anchors.margins: 3
            TextArea {
                id: text_desc
                // cursorVisible: true;
                // focusReason: Qt.MouseFocusReason
                wrapMode: TextArea.Wrap//换行
                //placeholderText: "welcome"
                font.pixelSize: 14;
                font.weight: Font.Light
                text: '欢迎'
                //focus: true;
                // textFormat: TextArea.AutoText
                // selectByMouse:true;
                // selectByKeyboard: true

                onTextChanged: {
                    if (text_desc.text.length === 0) {
                        warning_imageView.visible = true
                        textInputEmptyWarning.visible = true
                        ok_button.enabled = false
                    } else {
                        warning_imageView.visible = false
                        textInputEmptyWarning.visible = false
                        ok_button.enabled = true
                    }

                    if (text_desc.text.length > maxLength) {
                        text_desc.text = text_desc.text.substring(0, 1024); // 截取前100个字符
                    }
                }
            }
        }
    }

    Text {
        id: internalTextField

        anchors.right: meetingDescriptionInput.left
        anchors.rightMargin:5

        anchors.top: parent.top
        anchors.topMargin: 19


        text: '横幅内容'
        color: '#333333'
        font.pixelSize: 14
        font.bold: true
    }

    Image {
        id: warning_imageView
        source:  'qrc:/Images/InCall/FMeetingVC/TabBar/icon_reminder@2x.png'
        width: 12
        height: 12

        visible: false

        anchors.left: parent.left
        anchors.leftMargin: 87
        anchors.top: meetingDescriptionInput.bottom
        anchors.topMargin: 8
    }

    Text {
        id: textInputEmptyWarning
        visible: false
        anchors.left: warning_imageView.right
        anchors.leftMargin:4

        anchors.verticalCenter:warning_imageView.verticalCenter

        text: '横幅内容不能为空'
        color: '#999999'
        font.pixelSize: 12
    }

    FrtcCheckBoxView {
        id:scrolleCheckBox

        anchors.left: parent.left
        anchors.leftMargin: 87
       // anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: meetingDescriptionInput.bottom
        anchors.topMargin: 20

        isStateChangeButton: true
        state: "SELECTED"
        checked: true
        checkable: true

        btn_txt_unchecked: qsTr("")
        btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
        btn_txt_checked: qsTr("")
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

        onMouseClicked: {

        }
    }

    Text {
        id: scrollTextField

        anchors.right: scrolleCheckBox.left
        anchors.rightMargin:5

        anchors.verticalCenter: scrolleCheckBox.verticalCenter

        text: '滚动'
        color: '#333333'
        font.pixelSize: 14
        font.bold: true
        clip: true // 确保文本不超出边框显示
    }


    MessageButton {
        id: buttonDown

        anchors.left: parent.left
        anchors.leftMargin: 87
        anchors.top: scrolleCheckBox.bottom
        anchors.topMargin: 26
        buttonType: 201
        imageSource:"qrc:/Images/InCall/FMeetingVC/TabBar/icon_message_down@2x.png"
        onButtonClicked: (type) => {
            handleButtonClicked(type)
        }
    }

    TextField {
        id: caculateTextField
        anchors.left: buttonDown.right
        anchors.leftMargin: 0
        anchors.verticalCenter: buttonDown.verticalCenter
        width: 124
        height: 30
        text: "3" // 设置初始值
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
        font.bold: false
        color: "#333333" // 字体颜色
        clip: true // 限制文字内容在文本框范围内显示

        // 边框和背景设置
        background: Rectangle {
            color: "white"
            border.color: "#DEDEDE"
            border.width: 1
            radius: 4
        }

        // 禁用焦点环样式
        //focusPolicy: Qt.StrongFocus
        activeFocusOnPress: true
        onFocusChanged: {
            if (focus) {
                console.log("TextField focused")
            }
        }

        // 限制输入为整数格式
        inputMethodHints: Qt.ImhDigitsOnly

        onTextChanged: {
            // 可额外加逻辑，确保输入为有效整数
            if (!/^\d*$/.test(text)) {
                text = text.replace(/[^\d]/g, ""); // 清除非数字字符
            }

            if (parseInt(text) < 1 || parseInt(text) > 100) {
                        text = text > 100 ? "100" : "1";
                    }

            // 如果输入为空，恢复默认值
            if (text === "") {
                text = "1"; // 恢复默认值
            }
        }
    }

    MessageButton {
        id: buttonUp

        anchors.left: caculateTextField.right
        anchors.leftMargin: 0
        anchors.verticalCenter: caculateTextField.verticalCenter
        buttonType: 202
        imageSource:"qrc:/Images/InCall/FMeetingVC/TabBar/icon_message_up@2x.png"
        onButtonClicked: (type) => {
            handleButtonClicked(type)
        }
    }

    Text {
        id: caculateLabel

        anchors.right: buttonDown.left
        anchors.rightMargin:5

        anchors.verticalCenter: buttonDown.verticalCenter

        text: '播放次数'
        color: '#333333'
        font.pixelSize: 14
        font.bold: true
        clip: true // 确保文本不超出边框显示
    }

    FrtcEnableMessageBackgroundView {
        id: backgroundViewTop
        width: 88
        height: 74

        anchors.left: parent.left
        anchors.leftMargin: 87
        anchors.top: buttonDown.bottom
        anchors.topMargin: 20

        type: 0
        isSelected:true
        title: "顶部"
        imageSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_message_top@2x.png"
        selectedTagSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_selected_tag@2x.png"

        onClicked: {
            console.log("Clicked on Top View with type:", type)
            handleSelection(backgroundViewTop)
        }
    }

    FrtcEnableMessageBackgroundView {
        id: backgroundViewMiddle
        width: 88
        height: 74

        anchors.left: backgroundViewTop.right
        anchors.leftMargin: 8
        anchors.verticalCenter: backgroundViewTop.verticalCenter

        type: 1 // EnableMessageGroundViewMiddle
        title: "中部"
        imageSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_message_middle@2x.png" // 替换为实际图片路径
        selectedTagSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_selected_tag@2x.png"

        onClicked: {
            console.log("Clicked on Middle View with type:", type)
            handleSelection(backgroundViewMiddle)
        }
    }

    FrtcEnableMessageBackgroundView {
        id: backgroundViewBottom
        width: 88
        height: 74

        anchors.left: backgroundViewMiddle.right
        anchors.leftMargin: 8

        anchors.verticalCenter: backgroundViewTop.verticalCenter
        type: 2 // EnableMessageGroundViewBottom
        title: "底部"
        imageSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_message_bottom@2x.png" // 替换为实际图片路径
        selectedTagSource: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_selected_tag@2x.png"

        onClicked: {
            console.log("Clicked on Bottom View with type:", type)
            handleSelection(backgroundViewBottom)
        }
    }

    Text {
        id: messagePositonTextField

        anchors.right: backgroundViewTop.left
        anchors.rightMargin:5

        anchors.verticalCenter: backgroundViewTop.verticalCenter

        text: '横幅位置'
        color: '#333333'
        font.pixelSize: 14
        font.bold: true
        clip: true // 确保文本不超出边框显示
    }

    Rectangle {
        id: lineView
        width: parent.width
        height: 1
        color: "#DEDEDE"
        anchors.horizontalCenter: parent.horizontalCenter // 如果需要水平居中
        anchors.top: backgroundViewMiddle.bottom
        anchors.topMargin: 16
       // y: 108 // Y轴位置
    }

    Rectangle {
        id: verticalLineView
        width: 1
        height: 48
        color: "#DEDEDE"
        anchors.horizontalCenter: parent.horizontalCenter // 如果需要水平居中
        anchors.top: lineView.bottom
        anchors.topMargin: 0
       // y: 108 // Y轴位置
    }

    Button {
        text: "取消"
        width: 196
        height: 48
        font.pixelSize: 14
        //color: "#888888" // 灰色字体
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: lineView.bottom
        anchors.topMargin: 1

        background: Rectangle {
            color: "transparent"
            border.color: "transparent" // 没有边框
        }

        contentItem: Item {
            anchors.fill: parent // 填满整个按钮区域
            Text {
                text: "取消"
                color: "#888888" // 灰色字体
                font.pixelSize: 14
                anchors.centerIn: parent // 确保文本在按钮内居中
            }
        }
        onClicked: {
             root.close()
        }
    }

    Button {
        id:ok_button
        text: "确定"
        width: 196
        height: 48
        font.pixelSize: 14
        //color: "#888888" // 灰色字体
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: lineView.bottom
        anchors.topMargin: 1

        background: Rectangle {
            color: "transparent"
            border.color: "transparent" // 没有边框
        }

        contentItem: Item {
            anchors.fill: parent // 填满整个按钮区域
            Text {
                text: "确定"
                color: "#026FFE" // 灰色字体
                font.pixelSize: 14
                anchors.centerIn: parent // 确保文本在按钮内居中
            }
        }
        onClicked: {
            let dataMap = {
                    content: text_desc.text,
                    repeat: circleTimes,
                    position: position,
                    enable_scroll: scrolleCheckBox.checked
                };
            onEnableMessageCallback(dataMap)

            root.close()
        }
    }

     function handleButtonClicked(type) {
        console.log("Button clicked with type:", type);

        if(type === 201) {
            circleTimes -= 1
            if(circleTimes < 1) {
                circleTimes = 1
            }
        } else if(type === 202){
            circleTimes += 1
            console.log("Button clicked with circleTimes:", circleTimes);
        }

        caculateTextField.text = String(circleTimes)
    }

    function handleSelection(selectedView) {
             // 遍历所有控件，设置选中状态
        if(selectedView === backgroundViewBottom) {
            position = 100
        } else if(selectedView === backgroundViewMiddle) {
            position = 50
        } else {
            position = 0
        }

        [backgroundViewTop, backgroundViewMiddle, backgroundViewBottom].forEach(function(view) {
            view.messageBackgroundViewSelected(view === selectedView);
        });
    }
}
