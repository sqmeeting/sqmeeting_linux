import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material

//消息框
Window {
    id: control

    //宽度可以重新设置，宽度根据内容适应
    width: 260
    height: content_loader.height+headerHeight+footerHeight
    //无边框
    flags: Qt.FramelessWindowHint | Qt.Dialog
    //模态
    modality: Qt.ApplicationModal

    //默认的Text组件的文本值
    property string text: ""
    //标题
    property alias title: title_text.text
    //背景区域Rectangle
    property alias background: bg_area
    //内容区域Loader加载的组件
    property alias content: content_loader.sourceComponent
    //右上关闭按钮Image
    property alias closeImage: close_img
    //右上关闭按钮MouseArea
    property alias closeMouse: close_mouse
    //标题栏高度
    property alias headerHeight: head_area.height
    //按钮栏高度
    property alias footerHeight: foot_area.height
    //用于接收回调函数
    property var callback: null

    //按钮枚举，enum貌似是Qt6.10引入的，可替换为int来定义
    enum ButtonFlag{
        CloseButton=1   //关闭按钮
        ,CancelButton=2 //取消按钮
        ,OkButton=4     //确认按钮
    }
    //按钮枚举控制显示/隐藏
    property int buttonFlags: FrtcAlertView.OkButton

    property string okButtonText: qsTr('确定')
    property string cancelButtonText: qsTr('取消')

    signal clickCancel()
    signal clickOk()

    //适配Dialog的open()接口
    function open()
    {
        control.resetPosition();
        control.show();
        //这里还没有把按钮焦点重置
    }

    //恢复位置到屏幕中心
    function resetPosition()
    {
        control.setX((control.screen.width-control.width)/2);
        control.setY((control.screen.height-control.height)/2);
    }

    //背景
    Rectangle{
        id: bg_area
        anchors.fill: parent
        color: "white"
        // border.color: "lightGray"
        radius: 8

        //用于拖拽对话框
        MouseArea{
            id: bg_mouse
            anchors.fill: parent
            property point clickPos: Qt.point(0,0)
            property bool dragMoving: false
            onPressed: {
                dragMoving = true;
                clickPos  = Qt.point(mouseX,mouseY);
            }
            onReleased: {
                dragMoving=false;
            }
            onPositionChanged: {
                if (!dragMoving) {
                    return;
                }
                control.setX(control.x+mouseX-clickPos.x);
                control.setY(control.y+mouseY-clickPos.y);
            }
        }
    }

    //标题栏 header
    Item{
        id: head_area
        width: parent.width
        //设置标题文本后更高点
        height: title_text.text?45:25
        //预留的标题栏文本
        Text {
            id: title_text
            anchors.centerIn: parent
            color: "#444444"
            font.pixelSize: 16
            font.family: "Microsoft YaHei"
        }

        //标题栏关闭按钮
        Image {
            id: close_img
            visible: control.buttonFlags&FrtcAlertView.CloseButton
            //source: "qrc:/close_gray.png"
            anchors{
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            width: sourceSize.width
            height: sourceSize.height

            MouseArea{
                id: close_mouse
                anchors.fill: parent
                //用close自适应大小会有问题
                onClicked: control.hide()
            }
        }
    }

    //中间内容区域
    Loader{
        id: content_loader
        x: 10
        y: headerHeight
        width: parent.width - 20
        height: sourceComponent.height

        sourceComponent: Text {
            //width: content_loader.width
            color: "#666666"
            font.pixelSize: 14
            font.family: "Microsoft YaHei"
            wrapMode: Text.WrapAnywhere
            padding: 10
            text: control.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    //底部按钮区域 footer
    Item{
        id: foot_area
        width: parent.width
        //显示按钮后更高点
        height: button_row.height + 5
        anchors.bottom: parent.bottom

        // Rectangle {
        //     id:bottomLine
        //     height: 1
        //     width: parent.width
        //     anchors.top: parent.top
        //     color: 'red'
        // }

        // Rectangle {
        //     id:bottomCenterLine
        //     width: 1
        //     anchors.top: parent.top
        //     anchors.bottom: parent.bottom
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     color: 'red'
        // }

        FocusScope{
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: control.hide()

            //底部按钮行
            Row{
                id: button_row
                anchors.centerIn: parent
                spacing: 20

                //这里反正也没几个按钮，就不把Button单独定义了
                //因为可能对单个按钮设置文本或者其他样式，Repeater也不用了
                Button{
                    id: btn_cancel
                    visible: control.buttonFlags&FrtcAlertView.CancelButton
                    text: cancelButtonText
                    contentItem: Text {
                        text: parent.text
                        color: parent.focus?"white":"#666666"
                        font.pixelSize: 14
                        font.family: "Microsoft YaHei"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    background: Rectangle{
                        implicitWidth: 60
                        implicitHeight: 30
                        color: parent.focus?"#4A6FD3":"white"
                        border.color: "#D9D9D9"
                        border.width: parent.focus?0:1
                        radius: 4
                    }
                    onClicked: {
                        control.hide();
                        control.clickCancel();
                        if (callback) {
                            callback(0)
                        }
                    }
                }

                Button{
                    id: btn_ok
                    text: okButtonText
                    visible: control.buttonFlags&FrtcAlertView.OkButton
                    //默认焦点为确认
                    focus: true
                    contentItem: Text {
                        text: parent.text
                        color: parent.focus?"white":"#666666"
                        font.pixelSize: 14
                        font.family: "Microsoft YaHei"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    background: Rectangle{
                        implicitWidth: 60
                        implicitHeight: 30
                        color: parent.focus?"#026FFE":"white"
                        border.color: "#D9D9D9"
                        border.width: parent.focus?0:1
                        radius: 4
                    }
                    onClicked: {
                        control.hide()
                        control.clickOk()
                        if (callback) {
                            callback(1)
                        }
                    }
                }
            }
        }
    }
}
