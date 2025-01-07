import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

//for receied remote video render.
import VideoRenderObject 1.0 //class VideoRender

import QtMultimedia



Rectangle {
    id: id_videoview
    width: 0 //100
    height: 0 //100
    radius: 10
    color: "black" // "gray"


    property string type : "videoView"
    property var viewInfo

    property var dataSourceID
    property var strDisplayName
    property bool micMuteState: true

    property string uuid: ""
    property var eVideoType
    property var removed
    property var active
    property var maxResolution
    property var pin
    //for active speaker appearance.
    property int borderWidth: 0; //2
    property string borderColor: "black";
    property bool isActiveSpeaker: false;
    
    property bool isShow: false

    property bool user_pin: true
    //========================================
    // for QML life cycle.
    //========================================

    Component.onDestruction: {

    }

    onDataSourceIDChanged: {
        provider_videoview.videoUrl = dataSourceID;
    }
    

    function setRenderSourceID(aDataSourceID) {
        provider_videoview.setRenderSourceID(aDataSourceID);
        id_videoview.dataSourceID = aDataSourceID;

        id_remote_user_mute_camera_show_rect.setVideoMuteImage(aDataSourceID)
    }

    function clearRenderSourceID() {
        provider_videoview.setRenderSourceID("")
        id_videoview.dataSourceID = ""
    }
    
    function setFrameSize() {
        provider_videoview.setFrameSize(x, y, width, height);
    }
    
    function startRendering() {
       provider_videoview.startRendering();
    }

    function stopRendering() {
        provider_videoview.stopRendering();
    }

    function renderMuteImage(mute) {
        id_remote_user_unmute_camera_show_rect.visible = !mute
        id_remote_user_mute_camera_show_rect.renderMuteImage(mute)
    }
    
    function setVisible(visible) {
        id_videoview.visible = visible
        
        if (false === visible) {
            id_videoview.x = 0
            id_videoview.y = 0
            id_videoview.width = 0
            id_videoview.height = 0
        }
    }

    function showVideoview(aShow) {
        if (true === aShow) {
            id_videoview.opacity = 1
        } else {
            id_videoview.opacity = 0
        }

        setVisible(aShow)
        id_videoview.isShow = aShow
    }

    function setMicMuteState(aMicMute) {
        id_remote_user_unmute_camera_show_rect.setMicMuteState(aMicMute) //1. remote user unmute camera.
        id_remote_user_mute_camera_show_rect.setMicMuteState(aMicMute) //2. remote user mute camera.
    }

    function setDisplayName(aDisplayName) {
       strDisplayName = aDisplayName
       id_remote_user_unmute_camera_show_rect.setDisplayName(aDisplayName) //1. remote user displayName.
       id_remote_user_mute_camera_show_rect.setDisplayName(aDisplayName) //2. remote user displayName.
    }
     
    function setAppearanceWithActive(isActiveSpeaker) {
        id_videoview.isActiveSpeaker = isActiveSpeaker;
        id_activespeaker_appearance.setAppearanceWithActive(isActiveSpeaker);
    }

    function setUserPin(isPin) {
        user_pin = isPin
    }
    
    
    //========================================
    // [sub Views]:
    //========================================
    
    VideoRenderObject {
       id: provider_videoview
       //videoUrl: "rtsp://xxx.xxx.xxx/channel=0"
       videoUrl: "" //dataSourceID //"call-1_6"

       videoSink: id_video_output.videoSink

       onCppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage: {
           //console.log("[VideoRenderView.qml][Connections][VideoRenderObject][onCppSendMsgToQMLReceiveRemoteVideoDataToSetRenderMuteImage]: -> call id_videoview.renderMuteImage(false): dataSourceID : " + dataSourceID + ", name: " + strDisplayName)
           id_videoview.renderMuteImage(false)
       }
    }

    VideoOutput {
        id: id_video_output
        //source: provider_videoview

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit

    }

    property url image_tableview_audio_mute: "qrc:/FrtcMeeting/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-mute@2x.png"
    property url image_tableview_audio_unmute: "qrc:/FrtcMeeting/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-unmute@2x.png"
    property int image_width_audio_mute: 18

    Rectangle {
        id: id_remote_user_unmute_camera_show_rect

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4

        color: "black"

        height: 22

        property int maxNameWidth: 200
        property int nameWidth: maxNameWidth
        width: nameWidth + 20 //20 for mic image

        function setWidthWithTextStringWidth(textStringWidth) {
            var nameWidthNew = Math.min(200, textStringWidth + 20 + 5)

            id_remote_user_unmute_camera_show_mic_state_image.x = nameWidthNew + 5
            nameWidth = nameWidthNew
        }

        Label {
            id: id_remote_user_unmute_camera_show_name_label

            width: 200
            //width: Math.min(contentWidth, 200)
            height: 20

            color: "white"

            text: " "
            font.pixelSize: 14
            elide: Label.ElideRight

            Layout.preferredWidth: 200
            Layout.maximumWidth: 200

            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            onTextChanged: {
               id_remote_user_unmute_camera_show_rect.setWidthWithTextStringWidth(id_remote_user_unmute_camera_show_name_label.contentWidth)
                //id_remote_user_unmute_camera_show_rect.setWidthWithTextStringWidth(Math.min(contentWidth, 200));

            }
        }

        Image {
            id: id_remote_user_unmute_camera_show_mic_state_image

            width: image_width_audio_mute
            height: image_width_audio_mute

            // anchors.bottom: parent.bottom
            // anchors.bottomMargin: 2

            anchors.verticalCenter: id_remote_user_unmute_camera_show_name_label.verticalCenter

            source: "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-unmute@2x.png" //image_tableview_audio_mute
            cache: false
        }

        Image {
            id: id_remote_user_pin_state_image

            width: image_width_audio_mute
            height: image_width_audio_mute

            // anchors.left: id_remote_user_unmute_camera_show_name_label.right
            // anchors.leftMargin: user_pin ? (id_remote_user_unmute_camera_show_mic_state_image.x - id_remote_user_unmute_camera_show_name_label.width - width) / 2 : 0

            anchors.right: id_remote_user_unmute_camera_show_mic_state_image.left
            anchors.rightMargin:-2
            anchors.verticalCenter: id_remote_user_unmute_camera_show_name_label.verticalCenter


            source: "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-status-in_call_pin@2x.png" //image_tableview_audio_mute
            cache: false
            visible: user_pin
        }


        function setDisplayName(aDisplayName) {
            id_remote_user_unmute_camera_show_name_label.text = aDisplayName
        }

        function setMicMuteState(aMicMute) {
            if (true === aMicMute) {
               id_remote_user_unmute_camera_show_mic_state_image.source = "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-mute@2x.png"
            } else if (false === aMicMute) {
               id_remote_user_unmute_camera_show_mic_state_image.source = "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-unmute@2x.png"
            }
        }
    }

    Rectangle {
        id: id_remote_user_mute_camera_show_rect
        color: "#00000000" //为窗口透明
        visible: false
        border.width: 0; //root.borderWidth
        border.color: "black"; //root.borderColor

        anchors.left: parent.left
        anchors.leftMargin: 0 //4
        anchors.right: parent.right
        anchors.rightMargin: 0 //4
        anchors.top: parent.top
        anchors.topMargin: 0 //4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0 //4


        //------------------------------------------------
        // for QML life cycle.
        //------------------------------------------------

        Component.onCompleted: {
            setMicMuteState(true)
        }


        //------------------------------------------------
        // [function]:
        //------------------------------------------------

        function setVideoMuteImage(aDataSourceID) {
            if (null !== aDataSourceID && undefined !== aDataSourceID && aDataSourceID === "_VPL_PREVIEW") {
               id_remote_user_mute_camera_show_camera_mute_image.source = "qrc:/Images/frtc_sdk_bundle_images/local_preview_off.png"
            } else if (-1 !== aDataSourceID.indexOf("VCR-")) {
            } else { //remote video
                id_remote_user_mute_camera_show_camera_mute_image.source = "qrc:/Images/frtc_sdk_bundle_images/call_camera_off.png"
            }
        }

        function setDisplayName(aDisplayName) {
           id_remote_user_mute_camera_show_name_label.text = aDisplayName
        }

        function setMicMuteState(aMicMute) {
            if (true === aMicMute) {
                id_remote_user_mute_camera_show_mic_state_image.source = "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-mute@2x.png"
            } else if (!aMicMute) {
               id_remote_user_mute_camera_show_mic_state_image.source = "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-unmute@2x.png"
            }
        }

        function renderMuteImage(mute) {
            if (mute === id_remote_user_mute_camera_show_rect.visible) {
                return;
            }

            if (true === mute) {
                id_remote_user_mute_camera_show_rect.visible = true;


            } else {
                id_remote_user_mute_camera_show_rect.visible = false;
            }
        }

        //------------------------------------------------
        // [sub views]:
        //------------------------------------------------

        Image {
            id: id_remote_user_mute_camera_show_camera_mute_image
            anchors.fill: parent

            source: "qrc:/Images/frtc_sdk_bundle_images/call_camera_off.png"
        }

        // Image {
        //     id: id_remote_user_pin_state_image_mute

        //     width: image_width_audio_mute
        //     height: image_width_audio_mute

        //     anchors.right: id_remote_user_unmute_camera_show_mic_state_image.left
        //     anchors.rightMargin:-2
        //     anchors.verticalCenter: id_remote_user_unmute_camera_show_name_label.verticalCenter


        //     source: "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-status-in_call_pin@2x.png" //image_tableview_audio_mute
        //     cache: false
        //     visible: user_pin
        // }

        Label {
            id: id_remote_user_mute_camera_show_name_label

            //width: 300
            height: 40

            color: "white"

            text: " "
            font.pixelSize: 26
            elide: Label.ElideRight

            Layout.preferredWidth: 200

            horizontalAlignment: Text.AlignHCenter

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10

        }



        property url btn_img_mic_mute: id_remote_user_mute_camera_show_mic_state_image.source
        property url btn_img_mic_unmute: id_remote_user_mute_camera_show_mic_state_image.source

        Image {
            id: id_remote_user_mute_camera_show_mic_state_image

            width: image_width_audio_mute
            height: image_width_audio_mute

            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2


            source: "" // id_remote_user_mute_camera_show_rect.btn_img_mic_mute

            cache: false
        }

        Image {
            id: id_remote_user_pin_state_image_mute

            width: image_width_audio_mute
            height: image_width_audio_mute

            anchors.left: id_remote_user_mute_camera_show_mic_state_image.right
            anchors.leftMargin: 8
            anchors.verticalCenter: id_remote_user_mute_camera_show_mic_state_image.verticalCenter


            source: "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-status-in_call_pin@2x.png" //image_tableview_audio_mute
            cache: false
            visible: user_pin
        }


    }


    Rectangle {
        id: id_activespeaker_appearance;
        color: "#00000000" //为窗口透明
        visible: false;
        border.width: 0; //root.borderWidth
        border.color: "black"; //root.borderColor

        anchors.fill: parent
        
        function setAppearanceWithActive(isActiveSpeaker) {
            if (false === isActiveSpeaker) {
                visible = false;
                border.width = 0;
                border.color = "black";
            } else {
               visible = true;
                border.width = 4;
                border.color = "#1ADC5D" //"green";
            }
        }
    }

}
