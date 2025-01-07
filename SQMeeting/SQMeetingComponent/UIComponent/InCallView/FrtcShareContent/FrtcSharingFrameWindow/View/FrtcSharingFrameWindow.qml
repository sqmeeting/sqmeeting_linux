import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import "./../../FrtcSharingBarView/View/"
import "./../../../../CommonView/" //for FrtcToastView.qml.

import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp


Window {
    id: id_sharingbar_window
    x: 0
    y: 0
    width: screenWidth
    height: screenHeight

    visible: true
    color: "#00000000" //"transparent"


    flags: Qt.FramelessWindowHint | Qt.Window | Qt.WA_TranslucentBackground
    
    //========================================
    // for screen change.
    //========================================

    property int indicatorFrameLineWidth: 10

    property var screenWidth: Screen.width //640
    property var screenHeight: Screen.height //480

    property var rect_width: screenWidth
    property var rect_height: screenHeight

    property bool isShowSharingBarExpandView: true

    property bool authiority: false
    property bool meetingOwner:false

    //========================================
    // [function]: for screen change.
    //========================================

    Component.onCompleted: {
        currentScreenSize()

        if (true === isShowSharingBarExpandView) {
           id_hide_sharing_bar_expaned_view_timer.start()
        }
    }

    function currentScreenSize() {
        screenWidth = Screen.width // /3
        screenHeight = Screen.height // /3.

        id_sharingbar_window.width = screenWidth
        id_sharingbar_window.height = screenHeight
    }

    function showSharingBarExpandView() {
        if (false === isShowSharingBarExpandView) {
            isShowSharingBarExpandView = true
            id_sharing_bar_expand_view.visible = true
            FMeetingWindowControllerObject.onQmlShowSharingBarExpandView(true)
        }
    }

    function showSharingBarShrinkView() {
        if (true === isShowSharingBarExpandView) {
            isShowSharingBarExpandView = false
            id_sharing_bar_expand_view.visible = false

            FMeetingWindowControllerObject.onQmlShowSharingBarExpandView(false)
        }
    }

    function releaseInstance() {
        id_sharing_bar_expand_view = null
        id_sharing_bar_shrink_view = null
        id_toast = null
    }

    Connections {
        target: FMeetingWindowControllerObject; //created by FrtcCall::init().
        
        onCppSendMsgToQMLOpenCameraFailedSetCameraMuteButtonState: {
            console.log("FrtcSharingBarShrinkView.qml][onCppSendMsgToQMLOpenCameraFailedSetCameraMuteButtonState]: -> camera open nOpenResulte: " + nOpenResulte)
            if (0 !== nOpenResulte) {
                id_sharing_bar_expand_view.setCameraMute(true)
                id_toast.showText("未检测到可用摄像头，请插入设备后重试")
            }
        }
    }

    Timer {
        id: id_hide_sharing_bar_expaned_view_timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: true

        property int timerCounter: 0
        property int timerDuration: 3

        onTriggered: {
            if (timerDuration <= timerCounter) {
                showSharingBarShrinkView()
                stop()
                timerCounter = 0
            } else {
                ++timerCounter
            }
        }
    }

    //========================================
    // for sharing bar time count.
    //========================================

    property int sharingContentTimerCounter: 0
    property string strSharingContentCount: "00:00:00"

    onVisibleChanged: {
        if (!visible) {
            releaseInstance()
        }
    }

    Timer {
        id: id_sharing_content_count_timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: true

        property int timerCounter: 0

        onTriggered: {
            ++sharingContentTimerCounter

            var nSecond = Math.trunc(sharingContentTimerCounter % 60)
            var nMinute = Math.trunc((sharingContentTimerCounter / 60) % 60)
            var nHour = Math.trunc((sharingContentTimerCounter / (60 * 60)) % 24)

            strSharingContentCount = formatTime(nHour, nMinute, nSecond)
            setStrSharingContentCount(strSharingContentCount)
        }
    }

    function formatTime(hour, minute, second) {
        return (hour < 10 ? "0" + hour : hour) + ":" + (minute < 10 ? "0" + minute : minute) + ":" + (second < 10 ? "0" + second : second)
    }


    function setStrSharingContentCount(strSharingContentCount) {
        id_sharing_window_mouse_area.setStrSharingContentCount(strSharingContentCount)
    }

    MouseArea {
        id: id_sharing_window_mouse_area
        anchors.fill: parent

        enabled: true
        hoverEnabled: true

        function setStrSharingContentCount(strSharingContentCount) {
            id_sharing_bar_shrink_view.setStrSharingContentCount(strSharingContentCount)
            id_sharing_bar_expand_view.setStrSharingContentCount(strSharingContentCount)
        }

        onEntered: {
            if (true === isShowSharingBarExpandView) {
                id_hide_sharing_bar_expaned_view_timer.stop()
            }
        }

        onExited: {
           if (true === isShowSharingBarExpandView) {
               id_hide_sharing_bar_expaned_view_timer.start()
            }
        }


        Canvas {
            z: 3

            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d");	//获取画师，每个画布都有一个独一无二的画师
                ctx.lineWidth = indicatorFrameLineWidth //10;	//设置画布宽度
                ctx.strokeStyle = "green";	//设置画布颜色
                ctx.beginPath();	//开始绘图信号
                ctx.rect(0, 0, rect_width, rect_height);
                ctx.stroke();	//使用画笔颜色勾勒边框
            }

            // onWidthChanged: requestPaint() // 宽度改变时重新绘制
            // onHeightChanged: requestPaint() // 高度改变时重新绘制

            // MouseArea {
            //     anchors.fill: parent
            //     propagateComposedEvents: true

            //     enabled: true
            //     hoverEnabled: false

            // }
        } //end of Canvas.



        //-------------------------------------------------
        // .[Frame] sharing bar shrink/Expend view.
        //-------------------------------------------------
        FrtcSharingBarShrinkView {
            id: id_sharing_bar_shrink_view // rectangle_tab_bar

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            anchors.topMargin:40//macOS 40
            color: Qt.rgba(0,0,0,0.65)
            z: 4; //keep on the top order.

            textColor: "white"
            visible: true


            Component.onCompleted: {
                //backgroundColor = "#333333" //"gray"
            }
        } //end of 4.[UI][CallView] Tab bar.


        FrtcSharingBarExpandView {
            id: id_sharing_bar_expand_view // rectangle_tab_bar
            z: 4;
            authority: id_sharingbar_window.authiority
            meetingOwner: id_sharingbar_window.meetingOwner

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40//UOS  40//macOS
            anchors.margins: 0

            visible: false
        } //end of 4.[UI][CallView] Tab bar.


        //----------------------------------------
        // Toast view for show message: open camera failed, or other msg.
        //----------------------------------------

        FrtcToastView {
            id: id_toast
        }
        
    } //end of Window's MouseArea
}


