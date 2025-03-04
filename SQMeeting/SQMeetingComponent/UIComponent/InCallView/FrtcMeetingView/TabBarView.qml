import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts 1.15

import "./"

import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FrtcParticipantsViewControllerObject 1.0 //class FrtcParticipantsViewController

Rectangle {
    height: 60

    anchors.top: parent.bottom
    anchors.topMargin: - height
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.margins: 0

    property int tabbaarButtonMarginWidth: 100

    property bool authiority: false
    property bool meetingOwner: false
    property bool allowSelfUnmute: false

    //-------------------------------------------------
    // functions.
    //-------------------------------------------------

    function setRosterNumber(nRosterNumber) {
        var strRosterNumber = nRosterNumber.toString()
        tabbar_participant_button.setRosterNumber(strRosterNumber)
    }

    function qmlGetRosterNumber() {
        var nRosterNumber = FrtcParticipantsViewControllerObject.onQmlGetParticipantsNumber()
        console.log("[TabBarView.qml][qmlGetRosterNumber()] -> : rosterNumber: " + nRosterNumber);
        setRosterNumber(nRosterNumber)
    }

    Connections {
        target: FrtcParticipantsViewControllerObject //created by FrtcCall::init().

        // 使用新的语法
        function onCppSendMsgToQMLUpdateRosterNumber(rosterNumber) {
            setRosterNumber(rosterNumber)
        }
    }

    Component.onCompleted: {
        if (authiority) {
            tabbar_enable_message_button.Layout.alignment = Qt.AlignHCenter
        } else if (meetingOwner) {
            tabbar_participant_button.Layout.alignment = Qt.AlignRight
            tabbar_enable_message_button.Layout.alignment = Qt.AlignLeft
        }
        tabbar_audio_mute_button.state = "UNSELECTED";
        tabbar_camera_mute_button.state = "UNSELECTED";

        setLocalPreviewEnable(false)

        //for rosterNumber.
        qmlGetRosterNumber()
    }

    function setAllowSelfUnmute(allowSelfUnmute) {
        //allowSelfUnmute = allowSelfUnmute;
        tabbar_audio_mute_button.allowSelfUnmute = allowSelfUnmute
        console.log("it is of have teh event setAudioMuteButtonEnable(allowSelfUnmute(allowSelfUnmute: " + allowSelfUnmute + ")")
        console.log("[TabBarView.qml][rectangle_tab_bar][setAllowSelfUnmute]: -> setAudioMuteButtonEnable(allowSelfUnmute(allowSelfUnmute: " + allowSelfUnmute + ")")
        setAudioMuteButtonEnable(allowSelfUnmute)
    }
    
    function setMicMute(mute) {
        if (mute) {
            tabbar_audio_mute_button.state = "SELECTED"
        } else {
            tabbar_audio_mute_button.state = "UNSELECTED"
        }
        root.onQmlLocalAudioMute(mute);
    }

    function setCameraMute(mute) {
        if (mute) {
            tabbar_camera_mute_button.state = "SELECTED"
        } else {
            tabbar_camera_mute_button.state = "UNSELECTED"
        }
        //console.log("[TabBarView.qml][rectangle_tab_bar][setCameraMute()]: ---1---1---1---1 -> call root.onQmlLocalVideoMute(mute: " + mute + ")");
        root.onQmlLocalVideoMute(mute);
    }

    function audioOnlyJoin() {
        console.log('[TabBarView.qml][rectangle_tab_bar][s')
        tabbar_camera_mute_button.setEnable(false)
        tabbar_share_content_button.setEnable(false)
    }

    function setLocalPreviewEnable(aEnable) {
        console.log("[TabBarView.qml][rectangle_tab_bar][setLocalPreviewEnable]: -> call tabbar_local_preview_button.setEnable(aEnable: " + aEnable + ")");
        tabbar_local_preview_button.setEnable(aEnable)
    }
    
    function setAudioMuteButtonEnable(aEnable) {
        console.log("[TabBarView.qml][rectangle_tab_bar][setAudioMuteButtonEnable]: -> call tabbar_audio_mute_button.setEnable(aEnable: " + aEnable + ")");
        tabbar_audio_mute_button.setEnable(aEnable)
    }

    RowLayout {
        spacing: 0
        anchors.top: parent.top
        anchors.left: parent.left

        TabButton {
            id: tabbar_audio_mute_button

            isStateChangeButton: true
            //qsTr("button")
            btn_txt_unselected: "静音"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_unmute@2x.png"
            btn_txt_selected: "解除静音"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_audio_mute@2x.png"
            onMouseClicked: {
                if(!tabbar_audio_mute_button.allowSelfUnmute) {

                    console.log('it is of have teh event11111111111');
                    tabbar_audio_mute_button.isSelected = true
                    tabbar_audio_mute_button.state = "SELECTED";
                    root.showAskForUnmuteDialog();
                    return;
                }

                var isLocalAudioMute = tabbar_audio_mute_button.isSelected;
                console.log("[TabBarView.qml][rectangle_tab_bar][TabButton]: Tabbar audio_mute Button clicked, -> call root[FMeetingWindow.qml]: FMeetingWindowControllerObject.onQmlLocalAudioMute(isLocalAudioMute: " + isLocalAudioMute + ")");
                SDKUserDefaultObject.onQmlSaveTempSelectMicMute(isLocalAudioMute);
                root.onQmlLocalAudioMute(isLocalAudioMute);
            }
        }

        TabButton {
            id: tabbar_camera_mute_button

            isStateChangeButton: true
            btn_txt_unselected: "停止视频"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_unmute@2x.png"
            btn_txt_selected: "开启视频"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_video_mute@2x.png"
            onMouseClicked: {
                var isLocalVideoMute = tabbar_camera_mute_button.isSelected;
               SDKUserDefaultObject.onQmlSaveTempSelectCameraMute(isLocalVideoMute)

                root.onQmlLocalVideoMute(isLocalVideoMute);
            }
        }
    }



    function muteLocalAudio() {
        var isLocalAudioMute = tabbar_audio_mute_button.isSelected;
        root.onQmlLocalAudioMute(isLocalAudioMute);
    }

    function muteLocalVideo() {
        var isLocalVideoMute = tabbar_camera_mute_button.isSelected;
        root.onQmlLocalVideoMute(isLocalVideoMute);
    }

    function handleButtonState(tag, isCancel) {
        if(tag === 0) {
            console.log('***1111111111***')
            tabbar_recording_button.handleMessage(isCancel)
        } else {
            console.log('***2222222222***')
            tabbar_streaming_button.handleMessage(isCancel)
        }
    }

    function handleInviteButton(show) {
        if(show) {
            console.log('handle invite button show is true')
        } else {
            console.log('handle invite button show is false')
        }

        tabbar_invite_streaming_url_button.visible = show
    }

    RowLayout {
        id: dynamicButtons
        spacing: 2
        anchors.centerIn: parent

        TabButton {
            id: tabbar_share_content_button
            visible: true
            isStateChangeButton: false
            btn_txt_unselected: "共享屏幕"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_share_content@2x.png"
            btn_txt_selected: "共享屏幕"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_share_content@2x.png"
            onMouseClicked: {
                root.onQmlShowContentSelectWindow();
            }
        }

        TabButton {
            id: tabbar_local_preview_button

            visible: true
            isStateChangeButton: true
            state: "SELECTED"
            btn_txt_unselected: "开启本人浮窗"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_local_preview_unselected@2x.png"
            btn_txt_selected: "关闭本人浮窗"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_local_preview_selected@2x.png"

            onMouseClicked: {
               var isLocalPreviewShow = tabbar_local_preview_button.isSelected;
                root.onQmlLocalPreview(isLocalPreviewShow);
            }
        }


        TabButton {
            id: tabbar_invitate_button
            visible: true
            Layout.alignment: !authiority && !meetingOwner ? Qt.AlignHCenter : Qt.AlignLeft
            isStateChangeButton: false
            btn_txt_unselected: "邀请入会"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_invitate@2x.png"
            btn_txt_selected: "邀请入会"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_invitate@2x.png"
            onMouseClicked: {
                root.showInvitationDialog();
            }
        }


        TabButton {
            id: tabbar_participant_button
            visible: true
            //visible: authiority || meetingOwner
            Layout.alignment: authiority ? Qt.AlignLeft : Qt.AlignRight

            isStateChangeButton: false
            btn_txt_unselected: "参会者"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_participant@2x.png"
            btn_txt_selected: "参会者"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_participant@2x.png"

            function setRosterNumber(rosterNumber) {
                id_rosterNumber_text_view.text = rosterNumber
            }

            onMouseClicked: {
                root.showParticipantDialog();
            }

            Text {
                id: id_rosterNumber_text_view

                property string strRosterNumber: "0"

                text: strRosterNumber

                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 10

                font.pixelSize: 8
                color: "#222222"
            }
        }


        TabButton {
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
               root.showEnableMessageDialog();
            }
        }


        TabButton {
            id: tabbar_disable_message_button
            visible: authiority || meetingOwner

            isStateChangeButton: false
            btn_txt_unselected: "停止横幅"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_untext@2x.png";
            btn_txt_selected: "停止横幅"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_untext@2x.png";
            onMouseClicked: {
                root.stopMessageOverlay()
            }
        }

        TabButton {
            id: tabbar_recording_button
            visible: authiority || meetingOwner

            isStateChangeButton: true
            isStateControl: true
            btn_txt_unselected: "结束录制"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_stop_recording@2x.png"
            btn_txt_selected: "录制"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_recording@2x.png"

            onMouseClicked: {
                if(tabbar_recording_button.isSelected) {
                    root.showRecordingWindow()
                } else {
                    root.showStopRecordingWindow()
                }
            }
        }

        TabButton {
            id: tabbar_streaming_button
            visible: authiority
            isStateChangeButton: true
            isStateControl: true
            btn_txt_unselected: "结束直播"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_stop_streaming@2x.png"
            btn_txt_selected: "直播"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_streaming@2x.png"
            onMouseClicked: {
                if(tabbar_streaming_button.isSelected) {
                    root.showStreamingWindow()
                } else {
                    root.showStopStreamingWindow()
                }
            }
        }

        TabButton {
            id: tabbar_invite_streaming_url_button
            visible: false
            width: 15
            isStateChangeButton: false
            btn_txt_unselected: ''
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_streaming_url@2x.png"
            btn_txt_selected: ''
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/icon_streaming_url@2x.png"
            onMouseClicked: {
                root.popupStreamingUrlView()
            }
        }

        TabButton {
            id: tabbar_setting_button
            visible: true
            isStateChangeButton: false
            btn_txt_unselected: "设置"
            btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_setting@2x.png"
            btn_txt_selected: "设置"
            btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_setting@2x.png"
            onMouseClicked: {
                console.log("[TabBarView.qml][rectangle_tab_bar]" + btn_txt_unselected + "Tabbar setting Button clicked.");
                root.showSettingDialog()
            }
        }

        Component.onCompleted: {
            if (authiority) {
                tabbar_enable_message_button.Layout.alignment = Qt.AlignHCenter
            } else if (meetingOwner) {
                tabbar_participant_button.Layout.alignment = Qt.AlignRight
                tabbar_enable_message_button.Layout.alignment = Qt.AlignLeft
            }
        }
    }

    TabButtonDropCall {
        id: tabbar_dropcall_button
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 18

        //isStateChangeButton: false
        btn_txt_unselected: "结束"
        btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_dropcall@2x.png"
        btn_txt_selected: "结束"
        btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/TabBar/in_conference_tabbar_dropcall@2x.png"
        onMouseClicked: {
           root.showAskLeaveMeetingDialog();
        }
    }
}
