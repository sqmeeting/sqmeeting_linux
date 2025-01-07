import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.2
import "./../../../CommonView/"
import "./../../FrtcMainViewController/View/"
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0

Rectangle {
    id:audio_setting_view

    property int comboBoxHeight: 33
    property int comboBoxWidth: 300
    property int comboBoxMargin: 25

    property bool noise_reduction: false

    x:155
    y:-92
    color: "#ffffff"
    width: 640-170
    height: 480

    Component.onCompleted: {
       // myCheckBox.setStateChecked(true);
    }

    Connections {
        target: mediaInfoManager

        function onCppSendMsgToQMLMicrophoneListChanged(micphoneList) {
            microphone_comboBox.model = micphoneList
            microphone_comboBox.currentIndex =  microphone_comboBox.indexOfValue(mediaInfoManager.getCurrentMicphoneName())
        }

        function onCppSendMsgToQMLSpeakerListChanged(speakerList) {
            speaker_comboBox.model = speakerList
        }

        function onCppSendMsgToQMLSelectedMicChanged(mic) {
            console.log("onCppSendMsgToQMLSelectedMicChanged")
            microphone_comboBox.currentIndex =  microphone_comboBox.indexOfValue(mic);
        }

        function onCppSendMsgToQMLSelectedSpeakerChanged(speaker) {
            console.log("onCppSendMsgToQMLSelectedSpeakerChanged")
            speaker_comboBox.currentIndex = speaker_comboBox.indexOfValue(speaker)
        }
    }

    Text {
        x:15
        y:15
        id: microphone_title
        text: qsTr("麦克风")
    }

    FrtcComboBox {
        id:microphone_comboBox
        anchors.left: microphone_title.right
        anchors.leftMargin: 20
        anchors.verticalCenter: microphone_title.verticalCenter
        width: comboBoxWidth
        height: comboBoxHeight
        fontColor: "#222222"
        model: mediaInfoManager.getMicrophoneList()
        onActivated: {
            console.log("index:" + index + "  " + "text :" + model[index])
            mediaInfoManager.frtcSelectMic(model[currentIndex]);
        }
        Component.onCompleted: currentIndex = find(mediaInfoManager.getCurrentMicphoneName())
    }

    //speaker
    Text {
        anchors.left: microphone_title.left
        anchors.top: microphone_title.bottom
        anchors.topMargin: comboBoxMargin
        id: speaker_title
        text: qsTr("扬声器")
    }

    FrtcComboBox {
        id: speaker_comboBox
        anchors.left: microphone_comboBox.left
        anchors.verticalCenter: speaker_title.verticalCenter
        width: comboBoxWidth
        height: comboBoxHeight
        fontColor: "#222222"
        model:  mediaInfoManager.getSpeakerList()
        onActivated: {
            mediaInfoManager.frtcSelectSpeaker(model[currentIndex]);
        }
        Component.onCompleted: currentIndex = find(mediaInfoManager.getCurrentSpeakerName())
    }

    FrtcCheckBoxView {
        id:myCheckBox

        anchors.left: microphone_title.left
        anchors.top: speaker_title.bottom
        anchors.topMargin: 20

        isStateChangeButton: true
        checkable: true

        property bool noiseReduction: false

        btn_txt_unchecked: qsTr("智能降噪")
        btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
        btn_txt_checked: qsTr("智能降噪")
        btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

        checked: SDKUserDefaultObject.getNoiseReductionStatus() ? true : false


        onMouseClicked: {
            noiseReduction = myCheckBox.checked

            if(noiseReduction) {
                console.log('checked')
            } else {
                console.log('not checked')
            }

            SDKUserDefaultObject.onQmlSaveIntelligentNoiseReduction(noiseReduction);
            FMeetingWindowControllerObject.onNoiseReductionEnable(noiseReduction);
        }

        Component.onCompleted:{
            noise_reduction = SDKUserDefaultObject.getNoiseReductionStatus() ? true : false

            if(noise_reduction) {
                console.log('------checked-------')
               // myCheckBox.checked = false
            } else {
                console.log('------not checked-------')
                //myCheckBox.checked = true
            }

            FMeetingWindowControllerObject.onNoiseReductionEnable(noise_reduction)
        }
    }
}
