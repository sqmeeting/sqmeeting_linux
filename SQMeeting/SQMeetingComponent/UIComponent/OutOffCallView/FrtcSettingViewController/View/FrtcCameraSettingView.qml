import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.2
import "./../../../CommonView/"
import "./../../FrtcMainViewController/View/"
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0

Item {
    property int comboBoxHeight: 33
    property int comboBoxWidth: 300
    property int comboBoxMargin: 25
    property bool isInCall: false
    property bool video_mirrored: false

    Component.onCompleted: {
        myCheckBox.setStateChecked(true);
    }

    Component.onDestruction: {
        console.log("Page is being destroyed...");
        mediaInfoManager.stopCamera()
    }

    Connections {
        target: mediaInfoManager

        function onCppSendMsgToQMLCameraListChanged(cameraList) {
            camera_comboBox.model = cameraList
        }
    }

    Rectangle{
        id:media_setting_view
        x:isInCall ? 0 : 155

        width: 640-170
        height: 480
        color: "#ffffff"

        //camera
        Text {
            x:15
            y:15
            id: camera_title
            text: qsTr("摄像头")
        }

        FrtcComboBox {
            id:camera_comboBox
            anchors.left: layout_comboBox.left
            anchors.verticalCenter: camera_title.verticalCenter
            width: comboBoxWidth
            height: comboBoxHeight
            fontColor: "#222222"
            model: mediaInfoManager.getCameraList()

            property string savedCamera: SDKUserDefaultObject.getSelectCamera()

            Component.onCompleted: {
                var matchedIndex = -1; // 默认未匹配到
                for (var i = 0; i < model.length; i++) {
                    if (model[i] === savedCamera) {
                        matchedIndex = i;
                        break;
                    }
                }
                if (matchedIndex >= 0) {
                    // 匹配到了，设置选中的索引
                    currentIndex = matchedIndex;
                } else {
                    // 没有匹配到，默认选择第一个
                    currentIndex = 0;
                }

                console.log("Auto selected camera: " + model[currentIndex]);
                mediaInfoManager.frtcSelectCamera(model[currentIndex]);
            }

            onActivated: {
                console.log("text :" + model[currentIndex])
                mediaInfoManager.frtcSelectCamera(model[currentIndex]);
                SDKUserDefaultObject.onQmlSaveCameraSelected(model[currentIndex]);
            }
        }

        //layout
        Text {
            anchors.left: camera_title.left
            anchors.top: camera_title.bottom
            anchors.topMargin: comboBoxMargin
            id: layout_title
            text: qsTr("画面布局")
        }

        FrtcComboBox {
            id:layout_comboBox
            anchors.left: layout_title.right
            anchors.leftMargin: 20
            anchors.verticalCenter: layout_title.verticalCenter
            width: comboBoxWidth
            height: comboBoxHeight
            fontColor: "#222222"
            currentIndex: SDKUserDefaultObject.getSelectGridModel() ? 1 : 0
            model: ["演讲者视图","画廊视图"]
            onActivated: {
                SDKUserDefaultObject.onQmlSaveSelectGridModel(index === 1 ? true : false )
            }
        }

        FrtcCheckBoxView {
            id:videoMirrorCheckBox

            anchors.left: camera_title.left
            anchors.top: layout_title.bottom
            anchors.topMargin: 20

            isStateChangeButton: true
            checkable: true

            property bool mirrorChecked: false

            btn_txt_unchecked: qsTr("视频镜像")
            btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
            btn_txt_checked: qsTr("视频镜像")
            btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

            checked: SDKUserDefaultObject.getMirrorStatus() ? true : false

            onMouseClicked: {
                mirrorChecked = videoMirrorCheckBox.checked

                if(mirrorChecked) {
                    console.log('checked')
                } else {
                    console.log('not checked')
                }

                FMeetingWindowControllerObject.onQmlSetCameraVideoMirror(!mirrorChecked)
                SDKUserDefaultObject.onQmlSaveVideoMirrored(mirrorChecked);
            }

            Component.onCompleted:{
                console.log('----------FMeetingWindowControllerObject.onQmlSetCameraVideoMirror(!mirrorChecked)----')

                video_mirrored = SDKUserDefaultObject.getMirrorStatus() ? true : false

                if(video_mirrored) {
                    console.log('mirrored')
                } else {
                    console.log('not mirrored')
                }


                FMeetingWindowControllerObject.onQmlSetCameraVideoMirror(!video_mirrored)
            }
        }
    }
}
