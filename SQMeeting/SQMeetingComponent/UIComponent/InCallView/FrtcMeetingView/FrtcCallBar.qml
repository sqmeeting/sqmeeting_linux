import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// 3.[CallBar] Tab bar
//========================================
    
Rectangle {
    id: rectangle_tab_bar
    x: 0
    y: 972
    width: 1538
    height: 60


    TabButton {
        //id: audio_mute_button;
        x: 34
        y: 0

        //text: "test"
    }


//        Rectangle {
//            id: audio_mute_button;

//            property string btMesg: "点击静音按钮"
//            property string btText: "静音"

//            property color  textColor: "#ff000000"
//            property string pressedTextColor: textColor
//            property string releaseTextColor: textColor

//            property real   fontSize: 10

//            property string buttonColor: "#00000000"
//            property string pressedColor: buttonColor
//            property string releaseColor: buttonColor

//            property string btIcon: ""
//            property string pressedIcon: btIcon
//            property string releaseIcon: btIcon

//            property string borderColor: textColor
//            property string pressdBorderColor: pressedTextColor

//            property alias wrapMode: text_audio.wrapMode
//            property alias elide: text_audio.elide

//            property bool isMute: false;

//            x: 34
//            width: 60; height: 60
//            color: mouseArea_mute.pressed?pressedColor:releaseColor
//            border.width: 0
//            border.color: mouseArea_mute.pressed?pressdBorderColor:borderColor
//            focus : true
//            signal clicked()
//            signal clickedWithMesg(string mesg)
//            signal pressed()
//            signal release()


//            state: "UNMUTE"

//            states: [
//                        State {
//                            name: "UNMUTE"
//                            //PropertyChanges { target: audio_mute_button; color: "green"}
//                            PropertyChanges { target: text_audio; text: "静音"}
//                            PropertyChanges { target: image_audio; source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_audio_unmute@2x.png"}
//                        },
//                        State {
//                            name: "MUTE"
//                            //PropertyChanges { target: audio_mute_button; color: "red"}
//                            PropertyChanges { target: text_audio; text: "解除静音"}
//                            PropertyChanges { target: image_audio; source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_audio_mute@2x.png"}
//                        }
//                    ]

//            Image {
//                id: image_audio
//                width: 32
//                height: 32
//                anchors.horizontalCenterOffset: 9
//                anchors.topMargin: 5
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.top: parent.top
//                source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_audio_unmute@2x.png"
//                fillMode: Image.PreserveAspectFit
//            }

//            Text {
//                id: text_audio
//                x: 0
//                y: 40
//                anchors.top: image.bottom
//                anchors.horizontalCenter: parent.horizontalCenter
//                horizontalAlignment: Text.AlignHCenter
//                wrapMode: Text.WordWrap
//                width: parent.width
//                text:  "静音"
//                anchors.horizontalCenterOffset: 8
//                color: mouseArea.pressed?pressedTextColor:releaseTextColor
//                font.pixelSize:10 // fontSize
//            }

//            MouseArea{
//                id : mouseArea_mute
//                x: 0
//                hoverEnabled: true
//                anchors.fill: parent
//                onClicked: {
//                    console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked === audio_mute_button')
////                    parent.clicked()
////                    parent.clickedWithMesg(btMesg)

//                    if (audio_mute_button.state == "UNMUTE") {
//                        audio_mute_button.state = "MUTE"
//                        console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked === MUTE 静音')
//                    } else {
//                        audio_mute_button.state = "UNMUTE"
//                        console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked === UNMUTE 解除静音')
//                    }

//                }
//                onPressed: {
//                    console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
//                    parent.pressed(btMesg)




//                }
//                onReleased: {
//                    console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
//                    parent.release()
//                }
//            }
//        } //end of Rectangle



    Rectangle {
        id: video_mute_button;

        property string btMesg: "点击视频按钮"
        property string btText: "开启视频"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_video.wrapMode
        property alias elide: textId_video.elide

        width: 60; height: 60
        color: mouseArea_video.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_video.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 114

        state: "UNMUTE"

        states: [
                    State {
                        name: "UNMUTE"
                        //PropertyChanges { target: video_mute_button; color: "green"}
                        PropertyChanges { target: textId_video; text: "停止视频"}
                        PropertyChanges { target: image_video; source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_video_unmute@2x.png"}
                    },
                    State {
                        name: "MUTE"
                        //PropertyChanges { target: video_mute_button; color: "red"}
                        PropertyChanges { target: textId_video; text: "开启视频"}
                        PropertyChanges { target: image_video; source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_video_mute@2x.png"}
                    }
                ]

        Image {
            id: image_video
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_video_unmute@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_video
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "视频"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_video
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
//                    parent.clicked()
//                    parent.clickedWithMesg(btMesg)

                if (video_mute_button.state == "UNMUTE") {
                    video_mute_button.state = "MUTE"
                    console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked === MUTE 停止视频')
                } else {
                    video_mute_button.state = "UNMUTE"
                    console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked === UNMUTE 开启视频')
                }


            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle



    Rectangle {
        property string btMesg: "点击共享屏幕按钮"
        property string btText: "共享屏幕"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_share_content.wrapMode
        property alias elide: textId_share_content.elide

        width: 80; height: 60
        color: mouseArea_share_content.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_share_content.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 300

        Image {
            id: image_share_content
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_share_content@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_share_content
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "共享屏幕"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_share_content
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle





    Rectangle {
        property string btMesg: "点击本人浮窗按钮"
        property string btText: "开启本人浮窗"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_local_preview.wrapMode
        property alias elide: textId_local_preview.elide

        width: 80; height: 60
        color: mouseArea_local_preview.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_local_preview.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 386

        Image {
            id: image_local_preview
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_share_content@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_local_preview
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "关闭本人浮窗"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_local_preview
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle




    Rectangle {
        property string btMesg: "点击邀请参会按钮"
        property string btText: "邀请参会"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_invitate.wrapMode
        property alias elide: textId_invitate.elide

        width: 60; height: 60
        color: mouseArea_invitate.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_invitate.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 472

        Image {
            id: image_invitate
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_invitate@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_invitate
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "邀请参加"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_invitate
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle




    Rectangle {
        property string btMesg: "点击参会者按钮"
        property string btText: "参会者"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_participant.wrapMode
        property alias elide: textId_participant.elide

        width: 60; height: 60
        color: mouseArea_participant.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_participant.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 551

        Image {
            id: image_participant
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_participant@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_participant
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "参会者"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_participant
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle




    Rectangle {
        property string btMesg: "点击安全按钮"
        property string btText: "安全"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_security.wrapMode
        property alias elide: textId_security.elide

        width: 60; height: 60
        color: mouseArea_security.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_security.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 622

        Image {
            id: image_security
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_share_content@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_security
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "安全"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_security
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle




    Rectangle {
        property string btMesg: "点击设置按钮"
        property string btText: "设置"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_setting.wrapMode
        property alias elide: textId_setting.elide

        width: 60; height: 60
        color: mouseArea_setting.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_setting.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: 704

        Image {
            id: image_setting
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_setting@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_setting
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "设置"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_setting
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle


    Rectangle {
        property string btMesg: "点击结束按钮"
        property string btText: "结束"

        property color  textColor: "#ff000000"
        property string pressedTextColor: textColor
        property string releaseTextColor: textColor

        property real   fontSize: 10

        property string buttonColor: "#00000000"
        property string pressedColor: buttonColor
        property string releaseColor: buttonColor

        property string btIcon: ""
        property string pressedIcon: btIcon
        property string releaseIcon: btIcon

        property string borderColor: textColor
        property string pressdBorderColor: pressedTextColor

        property alias wrapMode: textId_dropcall.wrapMode
        property alias elide: textId_dropcall.elide

        width: 60; height: 60
        color: mouseArea_dropcall.pressed?pressedColor:releaseColor
        border.width: 0
        border.color: mouseArea_dropcall.pressed?pressdBorderColor:borderColor
        focus : true
        signal clicked()
        signal clickedWithMesg(string mesg)
        signal pressed()
        signal release()
        x: parent.width - 34 - 60

        Image {
            id: image_dropcall
            width: 32
            height: 32
            anchors.horizontalCenterOffset: 9
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: "../../../Image/FMeetingVC/tabbar/in_conference_tabbar_dropcall@2x.png"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: textId_dropcall
            x: 0
            y: 40
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            text:  "结束"
            anchors.horizontalCenterOffset: 8
            color: mouseArea.pressed?pressedTextColor:releaseTextColor
            font.pixelSize:10 // fontSize
        }

        MouseArea{
            id : mouseArea_dropcall
            x: 0
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onClicked')
                parent.clicked()
                parent.clickedWithMesg(btMesg)
            }
            onPressed: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onPressed')
                parent.pressed(btMesg)
            }
            onReleased: {
                console.log('[main.qml][fMeetingViewController_obj]: qml MouseArea onReleased')
                parent.release()
            }
        }
    } //end of Rectangle


    //        Button {
    //            id: button5
    //            x: 192
    //            y: 0
    //            text: qsTr("网络状况")
    //        }

    //        Button {
    //            id: button6
    //            x: 1230
    //            y: 0
    //            text: qsTr("画廊视图")
    //        }

    //        Button {
    //            id: button7
    //            x: 1370
    //            y: 0
    //            text: qsTr("全屏")
    //        }


} //[3.CallView] end of Rectangle, for 3. Tab bar.






