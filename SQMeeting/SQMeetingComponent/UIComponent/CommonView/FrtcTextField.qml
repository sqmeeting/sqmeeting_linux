import QtQuick 2.15
import QtQuick.Controls 2.15


Rectangle {

    height: parent.height
    color: "white"
    radius: 8
    border.width: 1
    border.color: '#cccccc'
    clip: true

    property alias  text: textInput.text
    property alias  textFont: textInput.font.pixelSize
    property string leftIcon: ''
    property string rightIcon: ''
    property bool   isShowLeftImg: false
    property bool   isShowRightImg: false
    property alias  readOnly: textInput.readOnly
    property string placeholderText: qsTr('请输入')
    property bool   isPasswordMode: false

    signal textInputChanged(string newText)
    signal clickRightIcon()
    signal clickLeftIcon()

    Image {
        id:left_icon
        x: 10
        source: leftIcon
        visible: isShowLeftImg
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: clickLeftIcon()
        }
    }

    Image {
        id:right_icon
        anchors.right: parent.right
        anchors.rightMargin: 10
        source: rightIcon
        visible: isShowRightImg
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: clickRightIcon()
        }
    }


    TextInput {
        id: textInput
        anchors.left: isShowLeftImg ? left_icon.right : parent.left
        anchors.right: isShowRightImg ? right_icon.left : parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: textFont
        clip: true
        color: "#333333"
        padding: 10
        echoMode: isPasswordMode ? TextInput.Password : TextInput.Normal
        onTextChanged: {
            placeholderLabelText.visible = textInput.text.length === 0
            //var inputText = textInput.text
            textInputChanged(text)
        }
    }

    Text {
        id: placeholderLabelText
        anchors.left: textInput.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        text: placeholderText
        color: "#999999"
        font.pixelSize: 12
        padding: 10
        visible: textInput.text.length === 0
        z: 1
    }

}
