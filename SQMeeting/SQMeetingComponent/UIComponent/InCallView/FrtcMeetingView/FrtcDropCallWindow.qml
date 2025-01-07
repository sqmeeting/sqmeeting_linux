import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.14

import "./"

import com.frtc.FMeetingViewControllerObject 1.0 //class FMeetingViewController.cpp


Window {
    id: root

    x: (screen.width - width)/2
    y: (screen.height - height)/2



    color: "#00000000"
    
    //为了实现以下功能，需要往Window中添加一些属性：
    property string content: "ask content."      //对话框内容
    property string yesButtonString: "yes"       //yes按钮的文字
    property string noButtonString: "no"         //no按钮的文字
    property string contentBackgroundImage: ""   //内容框的背景图片
    property string buttonBarBackgroundImage: "" //按钮框的背景图片
    property bool checked: false                 //选择框是否确认

    property bool authority: false

    property var onStopButtonClickedCallback

    width: 250
    height: authority ? 180 : 140

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height
    
    //flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowStaysOnTopHint
    //flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint //| Qt.WindowStaysOnTopHint
    flags: Qt.Window | Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
    
    // A modal window prevents other windows from receiving input events. Possible values are Qt.NonModal (the default), Qt.WindowModal, and Qt.ApplicationModal.
    modality: Qt.ApplicationModal
    //modality: Qt.WindowModal
    
    // 自定义信号
    // 1.accept, yes按钮被点击
    // 2.reject, no按钮被点击
    // 3.checkAndAccept, 选择框和yes按钮被点击

    signal accept();
    signal reject();
    signal checkAndAccept();
    
    signal qmlUserDropCallButtonSignal() //for dropCall

    Rectangle {
        id: dialog_buttons_rec
        Layout.fillWidth: parent

        border.color: "lightgray";
        border.width: 1
        radius: 8
        opacity: 1
        anchors.fill: parent

        //----------------------------------------
        Component.onDestruction: {
        }

        
        //----------------------------------------
        DialogButton {
            id: leaveMeetingButton
            x: 20
            y: 30
            width: 210
            height: 40
            border.width: 1
            border.color: "#0465E6" //blue, "lightgray"
            
            isStateChangeButton: false
            state: "SELECTED"
            
            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "离开会议"
            btn_txt_selected: "离开会议"
            btn_txt_color_unselected: "#0465E6"
            btn_txt_color_selected: "#0465E6"
            
            onMouseClicked: {
                root.visible = false
                root.qmlUserDropCallButtonSignal()
            }

            onMouseHoverEntered: {
                leaveMeetingButton.color = "#eef6ff"
            }

            onMouseHoverExited: {
                leaveMeetingButton.color = "white"

            }
        }

        DialogButton {
            id: stopMeetingButton
            x: 20
            y: 80
            width: 210
            height: 40
            visible: authority
            border.width: 1
            border.color: "#E32726" //blue, "lightgray"

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "结束会议"
            btn_txt_selected: "结束会议"
            btn_txt_color_unselected: Qt.rgba(227/255, 39/255, 38/255, 1.0)//"#E32726"
            btn_txt_color_selected: Qt.rgba(227/255, 39/255, 38/255, 1.0)//"#E32726"

            onMouseClicked: {
                root.visible = false
                onStopButtonClickedCallback()
                //root.qmlUserDropCallButtonSignal()
            }

            onMouseHoverEntered: {
                stopMeetingButton.color = Qt.rgba(227/255, 39/255, 38/255, 0.06) // 0.25 表示 25% 不透明
            }

            onMouseHoverExited: {
                leaveMeetingButton.color = "white"

            }
        }

        //----------------------------------------
        DialogButton {
            id: cancelButton
            x: 20
            y: authority ? 130 : 80
            width: 210
            height: 40
            isStateChangeButton: false
            state: "SELECTED"
            
            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "取消"
            btn_txt_selected: "取消"
            btn_txt_color_unselected: "black" //blue
            btn_txt_color_selected: "black" //blue
            clr_enter: "#ffffff"

            onMouseClicked: {
                root.visible = false
            }
        }

    } //[1.Dialog Rectangle] end of Rectangle.

} //end of Window.

