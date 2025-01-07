import QtQuick
import QtMultimedia
import QtQuick.Window

import "./../../../CommonView/"
import "./../../FrtcMainViewController/View/"
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0

Item {
    property int comboBoxHeight: 33
    property int comboBoxWidth: 300
    property int comboBoxMargin: 25

    Rectangle{
        id:video_view
        x:155

        width: 470
        height: 450
        color: "#ffffff"

        // 查询可用摄像头
        Component.onCompleted: {
            camera2_ID.start()
        }

        Component.onDestruction: {
            console.log("Page is being destroyed...");
            camera2_ID.stop();
            mediaInfoManager.stopCamera()
        }

        MediaDevices {
            id: mediaDevices_ID
        }

        Camera {
            id: camera2_ID
            property string currentCameraId: ""
            cameraDevice: mediaDevices_ID.videoInputs.length > 0
                ? mediaDevices_ID.videoInputs.find(device => device.description === camera_comboBox.currentText) || mediaDevices_ID.videoInputs[0]
                : null
        }

        CaptureSession {
            camera: camera2_ID

            videoOutput: videoOutput2_ID
        }


        VideoOutput {
            id: videoOutput2_ID
            width: 408   // 设置预览的宽度
            height: 220  // 设置预览的高度

            fillMode: VideoOutput.PreserveAspectCrop

            x:31
            y:23
            // anchors.top: video_view.top
            // anchors.topMargin: 23

            // anchors.horizontalCenter: video_view.horizontalCenter

            transform: Scale {
                id: mirrorScale
                xScale: videoMirrorCheckBox.checked ? -1 : 1 // 水平镜像
                origin.x: (video_view.width - videoOutput2_ID.width) / 2 // +  videoOutput2_ID.width    // 设置中心点为视频中心
            }

            onWidthChanged: adjustHorizontalPosition()
            onHeightChanged: adjustHorizontalPosition()

            function adjustHorizontalPosition() {
                // 如果启用了镜像，确保镜像后位置不变
                if (videoMirrorCheckBox.checked) {
                    videoOutput2_ID.x = video_view.width / 2 - videoOutput2_ID.width / 2  + videoOutput2_ID.width - 31 - 31
                } else {
                    videoOutput2_ID.x = 31
                }
            }
        }

        FrtcCheckBoxView {
            id:videoMirrorCheckBox

            anchors.left: camera_title.left
            anchors.top: videoOutput2_ID.bottom
            anchors.topMargin: 20

            isStateChangeButton: true
            checkable: true

            property bool mirrorChecked: false

            btn_txt_unchecked: qsTr("视频镜像")
            btn_img_src_unchecked: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
            btn_txt_checked: qsTr("视频镜像")
            btn_img_src_checked: "qrc:/Images/MainView/icon_checkbox_checked@2x.png"

            onMouseClicked: {
                mirrorChecked = videoMirrorCheckBox.checked

                if(mirrorChecked) {
                    console.log('checked')
                } else {
                    console.log('not checked')
                }

                FMeetingWindowControllerObject.onQmlSetCameraVideoMirror(!mirrorChecked)

                // 调整 VideoOutput 的位置
                videoOutput2_ID.adjustHorizontalPosition();
            }
        }

        //camera
        Text {
            id: camera_title
            anchors.top: videoMirrorCheckBox.bottom
            anchors.topMargin: 17

            anchors.left: video_view.left
            anchors.leftMargin: 31
            text: qsTr("摄像头")
        }

        FrtcComboBox {
            id:camera_comboBox
            anchors.left: layout_comboBox.left
            //anchors.leftMargin: 20
            anchors.verticalCenter: camera_title.verticalCenter
            width: comboBoxWidth
            height: comboBoxHeight
            fontColor: "#222222"
            model: mediaDevices_ID.videoInputs.map(device => device.description)//mediaInfoManager.getCameraList()

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

                camera2_ID.currentCameraId = mediaDevices_ID.videoInputs[currentIndex].id;
                camera2_ID.cameraDevice = mediaDevices_ID.videoInputs[currentIndex];
                camera2_ID.start();

                console.log("Auto selected camera: " + model[currentIndex]);
                mediaInfoManager.frtcSelectCamera(model[currentIndex]);
            }

            onActivated: {
                console.log("text :" + model[currentIndex])
                mediaInfoManager.frtcSelectCamera(model[currentIndex]);
                SDKUserDefaultObject.onQmlSaveCameraSelected(model[currentIndex]);

                console.log("Selected Camera: " + model[currentIndex]);

                camera2_ID.currentCameraId = mediaDevices_ID.videoInputs[currentIndex].id;
                camera2_ID.cameraDevice = mediaDevices_ID.videoInputs[currentIndex];
                camera2_ID.stop();
                camera2_ID.start();
                SDKUserDefaultObject.onQmlSaveCameraSelected(model[currentIndex]);
            }
        }

        Text {
            anchors.left: camera_title.left
            anchors.top: camera_comboBox.bottom
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

    }
}
