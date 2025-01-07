import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

Window {
    id: eo_askDialog
    width: 300
    height: 200
    //为了实现以下功能，我们需要往Window中添加一些属性：
    property string title: "ask dialog"          //对话框标题
    property string content: "ask content."      //对话框内容
    property string yesButtonString: "yes"       //yes按钮的文字
    property string noButtonString: "no"         //no按钮的文字
    property string checkBoxString: "check box"  //选择框的文字
    property string titleBackgroundImage: ""     //标题栏背景图片
    property string contentBackgroundImage: ""   //内容框的背景图片
    property string buttonBarBackgroundImage: "" //按钮框的背景图片
    property bool checked: false                 //选择框是否确认
    //因为我们需要实现自定义的标题栏，所以加上这个属性可以忽略系统自带的标题栏：
    flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowStaysOnTopHint


   // A modal window prevents other windows from receiving input events. Possible values are Qt.NonModal (the default), Qt.WindowModal, and Qt.ApplicationModal.
   //当然，不能忘了这是个模态对话框，加上如下的属性：
    modality: Qt.ApplicationModal

    /** 自定义信号
         1.accept, yes按钮被点击
         2.reject, no按钮被点击
         3.checkAndAccept, 选择框和yes按钮被点击
     **/
     signal accept();
     signal reject();
     signal checkAndAccept();

    ColumnLayout{
        anchors.fill: parent

        spacing:2

        //标题栏
        Rectangle{
            id: titleBar
            Layout.fillWidth: parent
            implicitHeight: 30
            color: "darkgray"
            //1.实现标题栏
            RowLayout{
                anchors.fill: parent
                spacing: 2

                MouseArea{
                    id: mouseControler

                    property point clickPos: "0,0"

                    Layout.fillHeight: parent
                    Layout.fillWidth: parent

                    //title
                    Text{
                        text: title
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                    }

                    onPressed: {
                        clickPos = Qt.point(mouse.x,mouse.y)
                    }

                    onPositionChanged: {
                        //鼠标偏移量motai
                        var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                        //如果mainwindow继承自QWidget,用setPos
                        eo_askDialog.setX(eo_askDialog.x+delta.x)
                        eo_askDialog.setY(eo_askDialog.y+delta.y)
                    }
                }

                //close button
                MouseArea{
                    id: closeButton
                    Layout.fillHeight: parent
                    implicitWidth: 45

                    Rectangle{
                        anchors.fill: parent
                        color:"red"
                    }

                    onClicked: {
                        console.log("close button clicked.");

                        eo_askDialog.visible = false;
                        reject()
                    }
                }
            }
        }

        //内容框
        Rectangle{
            id: contentView
            Layout.fillWidth: parent
            Layout.fillHeight: parent
            color: "lightgray"
            Text{
                text: content
                anchors.centerIn: parent
            }
        }

        //按钮栏
        Rectangle{
            id: buttonBar
            Layout.fillWidth: parent
            implicitHeight: 30
            color: "darkgray"
            RowLayout{
                anchors.fill: parent
                spacing: 2

                //checkBox
                MouseArea{
                    id: checkBox
                    Layout.fillHeight: parent
                    width:100

                    Rectangle{
                        anchors.fill: parent
                        color:"lightgray"
                    }

                    Text{
                        text: checkBoxString
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        checked = checked == false
                        console.log("checked changed.", checked)
                    }
                }

                //h spacer
                Rectangle{
                    id: buttonBarSpacer
                    color: Qt.rgba(0,0,0,0)
                    Layout.fillWidth: parent
                }

                //yes button
                MouseArea{
                    id: yesButton
                    Layout.fillHeight: parent
                    width:75

                    Rectangle{
                        anchors.fill: parent
                        color:"lightgray"
                    }

                    Text{
                        text: yesButtonString
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        console.log("yes button clicked.")
                        eo_askDialog.visible = false;

                        if (checked) {
                            checkAndAccept()
                        }
                        else{
                            accept()
                        }
                    }
                }

                //no button
                MouseArea{
                    id: noButton
                    Layout.fillHeight: parent
                    width:75

                    Rectangle{
                        anchors.fill: parent
                        color:"lightgray"
                    }

                    Text{
                        text: noButtonString
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        console.log("no button clicked.")
                        eo_askDialog.visible = false;

                        reject();
                    }
                }

            }
        }
    }

}
