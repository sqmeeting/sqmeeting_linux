import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp
import com.frtc.FrtcParticipantsViewControllerObject 1.0 //class FrtcParticipantsViewController
import com.frtc.FrtcApiManager 1.0

//========================================
// Sharing Bar View: will automatically hide after 5 seconds.
//========================================

import "./"
import "./../../../../OutOffCallView/FrtcSettingViewController/"

Rectangle {
    id: rectangle_tab_bar

    signal barButtonViewLoaded()

    property bool authority: true
    property bool meetingOwner:true

    property bool isRecording:false

    property bool isButtonEnabled: true


    //width: meetingOwner? 650 :458
    width: (meetingOwner || authority)? 650 :458
    height: 60

    property int tabbaarButtonMarginWidth: 14


    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    Component.onCompleted: {
        console.log("[FrtcSharingBarButtonsView.qml][Component.onCompleted:]: tabbar_audio_mute, set state = UNSELECTED");
        var micMute = SDKUserDefaultObject.getTempSelectMicMute()
        var cameraMute = SDKUserDefaultObject.getTempSelectCameraMute()

        tabbar_audio_mute_button.state = micMute ? "SELECTED" : "UNSELECTED";
        tabbar_camera_mute_button.state = cameraMute ? "SELECTED" : "UNSELECTED";

        rosterNumber = qmlGetRosterNumber()
        setRosterNumber(rosterNumber)

        rectangle_tab_bar.barButtonViewLoaded.connect(function() {
            FMeetingWindowControllerObject.onShareBarButtonViewLoaded(); // 通知 C++
        })

        barButtonViewLoaded()
    }

    function setMicMute(mute) {
        if (mute) {
            tabbar_audio_mute_button.state = "SELECTED"
        } else {
            tabbar_audio_mute_button.state = "UNSELECTED"
        }
    }

    function setCameraMute(mute) {
        if (mute) {
            tabbar_camera_mute_button.state = "SELECTED"
        } else {
            tabbar_camera_mute_button.state = "UNSELECTED"
        }
    }

    //----------------------------------------
    // [function]: for participant number: roster number.
    //----------------------------------------

    property int rosterNumber: 0

    //----------------------------------------

    function qmlGetRosterNumber() {
        var rosterNumber = FrtcParticipantsViewControllerObject.onQmlGetParticipantsNumber()
        console.log("[FrtcParticipantsViewController.qml][qmlGetRosterNumber()] -> rosterNumber: " + rosterNumber);
        return rosterNumber
    }

    function setRosterNumber(rosterNumber) {
        tabbar_participant_button.setRosterNumber(rosterNumber)
    }

    //------------------------------------------------
    // [CPP Object]: FrtcParticipantsViewControllerObject
    //------------------------------------------------

    Connections {
        target: FrtcParticipantsViewControllerObject; //created by FrtcCall::init().

        onCppSendMsgToQMLUpdateRosterNumber: {
            console.log("[FrtcSharingBarButtonsView.qml][Connections][onCppSendMsgToQMLUpdateRosterNumber:] -> rosterNumber: " + rosterNumber);
            setRosterNumber(rosterNumber)
        }

    }

    function handleStartRecordingSuccess() {
        isRecording = true; // 更新录制状态
        console.log('------------ceshiceshi--------------')
        tabbar_recording_button.state = "SELECTED"; // 更新按钮状态
        isButtonEnabled = true; // 解锁按钮
        tabbar_recording_button.isSelected = true
        console.log("录制成功");
    }

    function handleStopRecordingSuccess() {
        isRecording = false; // 更新录制状态
        tabbar_recording_button.state = "UNSELECTED"; // 更新按钮状态
        isButtonEnabled = true; // 解锁按钮
        tabbar_recording_button.isSelected = false
        console.log("停止录制成功");
    }

    function handleStartStreamingSuccess() {
        tabbar_streaming_button.state = "SELECTED"; // 更新按钮状态
        isButtonEnabled = true; // 解锁按钮
        tabbar_streaming_button.isSelected = true
        console.log("录制成功");
    }

    function handleStopStreamingSuccess() {
        tabbar_streaming_button.state = "UNSELECTED"; // 更新按钮状态
        isButtonEnabled = true; // 解锁按钮
        tabbar_streaming_button.isSelected = false
    }

    function handleWaterMaskCallBack(live_meeting_url,
                                     live_password,
                                     live_status,
                                    recording_status) {
        if(live_status === 'STARTED') {
            handleStartStreamingSuccess()
        } else {
            handleStopStreamingSuccess()
        }

        if(recording_status === 'STARTED') {
            handleStartRecordingSuccess()
        } else {
            handleStopRecordingSuccess()
        }
    }

    Connections {
        target: FMeetingWindowControllerObject; //created by FrtcCall::init().

        onCppSendMsgToQMLOnWaterMaskCallBack:handleWaterMaskCallBack(live_meeting_url,
                                                                     live_password,
                                                                     live_status,
                                                                    recording_status)


    }

    Connections {
        target: FrtcApiManager

        function onStartOverlayMessageCompleted(success) {
            //id_toast.showText("横幅已启用")
        }

        function onStopOverlayMessageCompleted(success) {
            //id_toast.showText("横幅已停止")
        }

        function onStartRecordingCompleted(success) {
            handleStartRecordingSuccess()
        }

        function onStopRecordingCompleted(success) {
            //recording_success_view.visible = false
            handleStopRecordingSuccess()
            //id_toast.showText("录制已结束")
        }

        function onStartStreamingingCompleted(success) {
            //id_toast.showText("直播已开始")
            handleStartStreamingSuccess()
        }

        function onStopStreamingCompleted(boolsuccess) {
            //id_toast.showText("直播已结束")
            handleStopStreamingSuccess()
        }
    }

    //-------------------------------------------------
    // subviews.
    //-------------------------------------------------

    RowLayout {
        id: dynamicButtons
        spacing: -2
        anchors.centerIn: parent

        FrtcTabButton {
            id: tabbar_audio_mute_button

            isStateChangeButton: true
            btn_txt_unselected: "静音"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_unmute@2x.png"
            btn_txt_selected: "解除静音"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_mute@2x.png"

            onMouseClicked: {
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlMuteLocalAudio()");
                FMeetingWindowControllerObject.onQmlMuteLocalAudio();
            }
        }


        FrtcTabButton {
            id: tabbar_camera_mute_button

            isStateChangeButton: true
            btn_txt_unselected: "停止视频"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_unmute@2x.png"
            btn_txt_selected: "开启视频"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_mute@2x.png"

            onMouseClicked: {
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlMuteLocalVideo()");
                FMeetingWindowControllerObject.onQmlMuteLocalVideo();
            }
        }


        FrtcTabButton {
            id: tabbar_invitate_button

            isStateChangeButton: false

            btn_txt_unselected: "邀请入会"
            btn_img_src_unselected: 'qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_invitate@2x.png'
            btn_txt_selected: "邀请入会"
            btn_img_src_selected: 'qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_invitate@2x.png'

            onMouseClicked: {
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlShowParticipantsDialog()");
                FMeetingWindowControllerObject.onQmlShowInvitationDialog();
            }
        }


        FrtcTabButton {
            id: tabbar_participant_button

            isStateChangeButton: false

            btn_txt_unselected: "参会者"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_participant@2x.png"
            btn_txt_selected: "参会者"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_participant@2x.png"

            //----------------------------------------
            // [function]
            //----------------------------------------

            function setRosterNumber(rosterNumber) {
                id_sharingbar_rosterNumber_text_view.strRosterNumber = rosterNumber
            }

            onMouseClicked: {
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlShowParticipantsDialog()");
                FMeetingWindowControllerObject.onQmlShowParticipantsDialog();
            }

            //----------------------------------------
            // [subviews]:
            //----------------------------------------

            Text {
                id: id_sharingbar_rosterNumber_text_view

                property string strRosterNumber: "0"

                text: strRosterNumber

                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 2

                font.pixelSize: 8
                color: "#222222"

            }
        }

        FrtcTabButton {
            id: tabbar_enable_message_button
            //visible: true
            visible: authiority || meetingOwner
            Layout.alignment: authiority ? Qt.AlignHCenter : Qt.AlignLeft

            isStateChangeButton: false
            btn_txt_unselected: "启用横幅"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_text@2x.png"
            btn_txt_selected: "启用横幅"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_text@2x.png"

            onMouseClicked: {
               FMeetingWindowControllerObject.onQmlShowMessageOverLayDialog();

            }
        }


        FrtcTabButton {
            id: tabbar_disable_message_button
            visible: authiority || meetingOwner

            isStateChangeButton: false
            btn_txt_unselected: "停止横幅"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_untext@2x.png";
            btn_txt_selected: "停止横幅"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_untext@2x.png";
            onMouseClicked: {
                FMeetingWindowControllerObject.onQmlStopMessageOverLay()
            }
        }


        FrtcTabButton {
            id: tabbar_recording_button
            visible: authiority || meetingOwner

            isStateChangeButton: false
            isSelected:false

            btn_txt_selected: "结束录制"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_stop_recording@2x.png"

            btn_txt_unselected: "录制"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_recording@2x.png"

            onMouseClicked: {
                if(tabbar_recording_button.isSelected) {
                    FMeetingWindowControllerObject.onQmlShowStopRecordingDialog()
                } else {
                    FMeetingWindowControllerObject.onQmlShowRecordingDialog()
                }
            }
        }

        FrtcTabButton {
            id: tabbar_streaming_button
            visible: authiority

            isStateChangeButton: false
            isSelected:false

            btn_txt_unselected: '直播'
            btn_img_src_unselected: 'qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_streaming@2x.png'

            btn_txt_selected:'结束直播'
            btn_img_src_selected: 'qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_stop_streaming@2x.png'

            onMouseClicked: {
                if(tabbar_streaming_button.isSelected) {
                    FMeetingWindowControllerObject.onQmlShowStopStreamingDialog()
                } else {
                    FMeetingWindowControllerObject.onQmlShowStreamingingDialog()
                }
            }
        }

        FrtcTabButton {
            id: tabbar_setting_button

            isStateChangeButton: false
            btn_txt_unselected: "设置"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_setting@2x.png"
            btn_txt_selected: "设置"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_setting@2x.png"

            onMouseClicked: {
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlShowSettingDialog()");
                FMeetingWindowControllerObject.onQmlShowSettingDialog();
            }
        }

        FrtcTabButtonDropCall {
            id: tabbar_stopsharecontent_button

            isStateChangeButton: false
            btn_txt_unselected: "结束共享"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_stop_sharingbar@2x.png"
            btn_txt_selected: "结束共享"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_stop_sharingbar@2x.png"

            onMouseClicked: {
                //console.log(btn_txt_unselected + "Tabbar stopShareContent Button clicked.");
                console.log("[FrtcSharingBarButtonsView.qml][FrtcTabButton][onMouseClicked:]: -> call FMeetingWindowControllerObject.onQmlStopShareScreen()");
                FMeetingWindowControllerObject.onQmlStopShareScreen();
            }
        }
    }
} //end of 4.[UI][CallView] Tab bar.
