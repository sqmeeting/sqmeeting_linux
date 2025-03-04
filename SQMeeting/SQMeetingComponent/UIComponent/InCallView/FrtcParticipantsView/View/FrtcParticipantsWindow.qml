import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import "./../../../CommonView/"
import "./"

import com.frtc.FrtcParticipantsViewControllerObject 1.0 //class FrtcParticipantsViewController
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0

Window {
    id: root
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint

    width: 388
    height: 462

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height

    property var onMuteSelfCallback


    title: title_with_rosterNumber //"参会者"

    //----------------------------------------
    // roster data.
    property int rosterNumber: 0
    property var rosterListObject
    property string title_with_rosterNumber: "参会者 (" + rosterNumber + ")"
    //----------------------------------------

    //metting info
    property string conferenceName: ""
    property string meetingID: ""
    property string ownerName: ""
    property string meetingPasscode: ""
    
    //为了实现以下功能，需要往Window中添加一些属性：
    property string content: "ask content."      //对话框内容
    property string yesButtonString: "yes"       //yes按钮的文字
    property string noButtonString: "no"         //no按钮的文字
    property string contentBackgroundImage: ""   //内容框的背景图片
    property string buttonBarBackgroundImage: "" //按钮框的背景图片
    property bool checked: false                 //选择框是否确认

    property bool authiority: false
    property bool meetingOwner:false

    property string lectureUUID:''
    property string pinUUID:''


    property var remove_meeting_dialog
    
    
    // 自定义信号
    // 1.accept, yes按钮被点击
    // 2.reject, no按钮被点击
    // 3.checkAndAccept, 选择框和yes按钮被点击

    signal accept();
    signal reject();
    signal checkAndAccept();
    
    
    //========================================
    // [1].[Dialog Rectangle] begin of Rectangle.
    //========================================

    Component {
        id: muteAllDialogComponent
        FrtcMuteAllWindow {}
    }

    Component {
        id:unMuteAllDialogComponent
        FrtcUnMuteAllWindow{}
    }

    Component {
        id:changeNameDialogComponent
        FrtcChangeNameWindow{}
    }

    FrtcToastView {
        id: toast_view
        z:3
    }

    Rename {
        id: renameWindow

        onButtonClickedCallback: callRestApi
        onButtonClickedUnLectureCallback:un_lecture
        onButtonClickedMuteCallBack:setUserMute
    }

    function showPopup(display_name, uuid, audio_mute, index, is_speaker, user_pin) {
        renameWindow.open(display_name, uuid, audio_mute, index, authiority | meetingOwner, is_speaker, user_pin)
    }

    function un_lecture(uuid) {
        var userToken = SDKUserDefaultObject.getUserToken()
        FrtcApiManager.un_set_user_lecturer(userToken, meetingID, uuid)
    }

    function setUserMute(index, muted, uuid) {
        if(index ===0) {
            FMeetingWindowControllerObject.onQmlLocalAudioMute(muted)
            onMuteSelfCallback(!muted)
        } else {
            var userToken = SDKUserDefaultObject.getUserToken()
            if(muted) {
                FrtcApiManager.un_mute_participant(userToken, meetingID,[uuid]);
            } else {
                FrtcApiManager.mute_participant(userToken, meetingID, true,[uuid]);
            }
        }
    }

    function callRestApi(uuid, index, user_pin) {
        var userToken = SDKUserDefaultObject.getUserToken()
        if(index === 0) {
            FrtcApiManager.set_user_lecturer(userToken, meetingID, uuid)
        } else if(index === 1) {
            if(user_pin) {
                FrtcApiManager.set_user_un_pin(userToken, meetingID)
            } else {
                FrtcApiManager.set_user_pin(userToken, meetingID, [uuid])
            }
        } else if(index === 2) {
            showRemoveMeetingDialog(uuid)
        }
    }

    function showRemoveMeetingDialog(uuid) {
        if (undefined === remove_meeting_dialog) {
            var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/View/GeneralDialog.qml");
            if (component.status === Component.Ready) {
               var newQmlObject = component.createObject(root) //parent: here is root.

                remove_meeting_dialog = newQmlObject

                remove_meeting_dialog.titleText = "移除会议室"
                remove_meeting_dialog.messageText = "您要把该用户移出会议室吗"
                remove_meeting_dialog.leftButtonText = "取消"
                remove_meeting_dialog.rightButtonText = "确定"

                remove_meeting_dialog.accept.connect(function() {
                    var userToken = SDKUserDefaultObject.getUserToken()
                    FrtcApiManager.remove_user_from_meeting(userToken, meetingID, uuid)
                    remove_meeting_dialog.destroy()
                    remove_meeting_dialog = undefined
                })
                remove_meeting_dialog.reject.connect(function() {
                    remove_meeting_dialog.destroy()
                    remove_meeting_dialog = undefined
                })
            }
        }
        remove_meeting_dialog.show();
    }

    Rectangle {
        id: dialog_buttons_rec
        width: 388
        height: 463

        border.color: "lightgray";
        border.width: 1
        opacity: 1

        FrtcParticipantsViewController {
            id: id_participants_view

            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.right: parent.right

            lecture_id: lectureUUID

            pin_id: pinUUID

            authority: authiority | meetingOwner

            isAuthority: authiority | meetingOwner

            onCellClickedCallback: showPopup

        }

        Image {
            id: id_bottom_line_image
            z: 3

            height: 2

            anchors.bottom: root.bottom
            anchors.bottomMargin: 62
            anchors.left: root.left
            anchors.right: root.right
            anchors.margins: 0
            source: "qrc:/FrtcMeeting/Images/SettingView/gray_line_content_select.png"
            fillMode: Image.Stretch
            visible: true
        }

        Rectangle {
            id:line_view
            width: 388
            height: 1
            color: "#cccccc"

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 70
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        DialogButton {
            id: id_invita_btn

            width: 80
            height: 30
            border.width: 1
            border.color: "#666666"
            
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 24

            isStateChangeButton: false
            state: "SELECTED"
            
            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "邀请入会"
            btn_txt_selected: "邀请入会"
            btn_txt_color_unselected: "#666666" //blue
            btn_txt_color_selected: "#666666" //blue
            
            onMouseClicked: {
                FMeetingWindowControllerObject.onQmlShowInvitationDialog();
            }

            onMouseHoverEntered: {
                id_invita_btn.color = "white"
                id_invita_btn.border.color = "#026ffe"
                id_invita_btn.btn_txt_color_unselected = "#026ffe"
                id_invita_btn.btn_txt_color_selected = "#026ffe"
            }

            onMouseHoverExited: {
                id_invita_btn.color = "white"
                id_invita_btn.border.color = "#666666"
                id_invita_btn.btn_txt_color_unselected = "#666666"
                id_invita_btn.btn_txt_color_selected = "#666666"
            }
        }

        DialogButton {
            id: id_cancel_mute_all

            width: 110
            height: 30
            border.width: 1
            border.color: "#666666"

            visible: authiority | meetingOwner

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 15

            isStateChangeButton: false
            state: "SELECTED"

            btn_txt_font_pixelsize: 14
            btn_txt_unselected: "取消全体静音"
            btn_txt_selected: "取消全体静音"
            btn_txt_color_unselected: "#666666" //blue
            btn_txt_color_selected: "#666666" //blue

            onMouseClicked: {
                var unMuteDialog = unMuteAllDialogComponent.createObject(root);

                if (unMuteDialog !== null) {
                    unMuteDialog.x = (parent.width - unMuteDialog.width) / 2;
                    unMuteDialog.y = (parent.height - unMuteDialog.height) / 2;
                }
            }

            onMouseHoverEntered: {
                id_cancel_mute_all.color = "white"
                id_cancel_mute_all.border.color = "#026ffe"
                id_cancel_mute_all.btn_txt_color_unselected = "#026ffe"
                id_cancel_mute_all.btn_txt_color_selected = "#026ffe"
            }

            onMouseHoverExited: {
                id_cancel_mute_all.color = "white"
                id_cancel_mute_all.border.color = "#666666"
                id_cancel_mute_all.btn_txt_color_unselected = "#666666"
                id_cancel_mute_all.btn_txt_color_selected = "#666666"
            }
        }
    }

    DialogButton {
        id: id_mute_all

        width: 80
        height: 30
        border.width: 1
        border.color: "#666666"

        visible: authiority | meetingOwner

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        anchors.right: parent.right
        anchors.rightMargin: 145

        isStateChangeButton: false
        state: "SELECTED"

        btn_txt_font_pixelsize: 14
        btn_txt_unselected: "全体静音"
        btn_txt_selected: "全体静音"
        btn_txt_color_unselected: "#666666" //blue
        btn_txt_color_selected: "#666666" //blue

        onMouseClicked: {
            var muteDialog = muteAllDialogComponent.createObject(root);

            if (muteDialog !== null) {
                muteDialog.x = (parent.width - muteDialog.width) / 2;
                muteDialog.y = (parent.height - muteDialog.height) / 2;
            }
        }

        onMouseHoverEntered: {
            id_mute_all.color = "white"
            id_mute_all.border.color = "#026ffe"
            id_mute_all.btn_txt_color_unselected = "#026ffe"
            id_mute_all.btn_txt_color_selected = "#026ffe"
        }

        onMouseHoverExited: {
            id_mute_all.color = "white"
            id_mute_all.border.color = "#666666"
            id_mute_all.btn_txt_color_unselected = "#666666"
            id_mute_all.btn_txt_color_selected = "#666666"
        }
    }

    function qmlGetRosterNumber() {
        var rosterNumber = FrtcParticipantsViewControllerObject.onQmlGetParticipantsNumber()
        return rosterNumber
    }

    function qmlGetRosterList() {
        var rosterListObject = FrtcParticipantsViewControllerObject.onQmlGetParticipantsList()
        return rosterListObject
    }

    function handleLayoutSettingChangedCallBack(lecture_id, max_cell_count, is_by_setting_speaker) {
        lectureUUID = lecture_id
        id_participants_view.lecture_id = lecture_id
        id_participants_view.isBySettingSpeaker = is_by_setting_speaker

        id_participants_view.reLayoutList()
    }

    function handlePinUUIDChangedCallBack(pin_uuid) {
        pinUUID = pin_uuid
        id_participants_view.pin_id = pin_uuid
    }

    Component.onCompleted: {     
        rosterNumber = qmlGetRosterNumber()
        rosterListObject = qmlGetRosterList()

        id_participants_view.dealwithUpdateRosterList(rosterListObject);
    }


    Connections {
        target: FrtcParticipantsViewControllerObject; //created by FrtcCall::init().

        onCppSendMsgToQMLUpdateRosterNumber: {
           root.rosterNumber = rosterNumber
        }

        onCppSendMsgToQMLUpdateRosterList: {
            id_participants_view.dealwithUpdateRosterList(rosterListObject);
        }
    }

    Connections {
        target: FMeetingWindowControllerObject; //created by FrtcCall::init().

        onCppSendMsgToQMLonMessageLayoutSettingChangedCallBack:handleLayoutSettingChangedCallBack(lecture_id, max_cell_count, is_by_setting_speaker)
        onCppSendMegToQMLOnPinSpeakerChangedCallBack:handlePinUUIDChangedCallBack(pin_uuid)
    }

    Connections {
        target: FrtcApiManager
        function onMuteAllCompleted(success) {
            toast_view.showText("已开启全体静音")
        }
    }

    Connections {
        target: FrtcApiManager
        function onUnMuteAllCompleted(success) {
            toast_view.showText("已取消全体静音")
        }
    }

} //end of Window.


