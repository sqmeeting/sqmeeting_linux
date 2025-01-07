import QtQuick 2.12
import QtQuick.Window 2.15
import QtQuick.Controls 2.14
import SDKUserDefaultObject 1.0

import "./" //for SettingButton.qml, SaveAddressButton.qml.
import "../../../CommonView"

Window {
    visible: true
    id: id_setting_view
    width: 640
    height: 480

    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height
    x:(screen.width - width)/2
    y:(screen.height - height)/2
    title: qsTr("设置")

    property string strText : ""
    property string strColor : ""

    //========================================
    // 1.two lines.
    //========================================

    //1.1.top line
    Rectangle {
        id:top_line_view
        height: 1.5
        y:0

        anchors.right: parent.right
        anchors.left: parent.left
        color: "#EEEFF0"
    }

    //1.1.midle line
    Rectangle {
        id:vertical_line_view
        width: 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 170
        anchors.margins: 0
        color: "#EEEFF0"
    }

    //========================================
    // 2.left menu pan.
    //========================================

    //常规设置 音视频 关于我们

    Rectangle {
        id: rectangle_setting_buttons_view

        //anchors.top: rectangle_menu_bar.bottom
        width: 170
        anchors.top: top_line_view.bottom
        anchors.topMargin: 10; //40
        anchors.left: parent.left
        //anchors.right: parent.right
        anchors.margins: 0

        //----------------------------------------
        //1.General setting button.
        //----------------------------------------
        SettingButton {
            id: general_setting_button
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "SELECTED"
            btn_txt_unselected: "常规设置"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_setting_off@2x.png"
            btn_txt_selected: "常规设置"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_setting_on@2x.png"

            Loader {
                id: general_push_button
                source: "FrtcSaveAddressView.qml"

                onLoaded: {
                    if (item) {
                        item.y = 0; // 设置 y 坐标
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                general_setting_button.state="SELECTED"
                general_push_button.source = "FrtcSaveAddressView.qml"

                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");

            }
        }

        SettingButton {
            id: video_preview_setting_button
            anchors.top: general_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "视频"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_media_off@2x.png"
            btn_txt_selected: "视频"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_media_on@2x.png"
            Loader{
                id: video_preview_push_button

                onLoaded: {
                    if (item) {
                        // if(SDKUserDefaultObject.getLoginState()) {
                        //     item.y = -((26 + 10) * 7 + 20 ); // 设置 y 坐标
                        // } else {
                        //     item.y = -((26 + 10) * 5 + 20) ;
                        // }

                        if (item) {
                            item.y = -((26 + 10) + 20); // 设置 y 坐标
                        }
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                video_preview_setting_button.state="SELECTED"
                video_preview_push_button.source = "FrtcCameraSettingView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: Diagnostic button");

            }
        }

        //----------------------------------------
        //2.video setting button.
        //----------------------------------------
        // SettingButton {
        //     id: video_setting_button
        //     anchors.top: general_setting_button.bottom
        //     anchors.topMargin: 10
        //     anchors.left: parent.left
        //     anchors.leftMargin: 16

        //     isStateChangeButton: true
        //     state: "UNSELECTED"
        //     btn_txt_unselected: "音视频"
        //     btn_img_src_unselected: "qrc:/Images/SettingView/icon_media_off@2x.png"
        //     btn_txt_selected: "音视频"
        //     btn_img_src_selected: "qrc:/Images/SettingView/icon_media_on@2x.png"
        //     Loader {
        //         id: video_push_button

        //         onLoaded: {
        //             if (item) {
        //                 item.y = -(26 + 10); // 设置 y 坐标
        //             }
        //         }
        //     }

        //     onMouseClicked: {
        //         clearSourceAndState()
        //         video_setting_button.state="SELECTED"
        //         video_push_button.source = "FrtcMediaSettingView.qml"
        //         setInfoText(btn_txt_unselected + " A Button clicked.");
        //         console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");

        //     }
        // }

        SettingButton {
            id: audio_setting_button
            anchors.top: video_preview_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "音频"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_audio_off@2x.png"
            btn_txt_selected: "音频"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_audio_on@2x.png"
            Loader{
                id: audio_push_button
                onLoaded: {

                    onLoaded: {
                        if (item) {
                            item.y = -(26 + 10) * 2; // 设置 y 坐标
                        }
                    }
                }

            }

            onMouseClicked: {
                clearSourceAndState()
                audio_setting_button.state="SELECTED"
                audio_push_button.source = "FrtcAudioSettingView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");

            }
        }

        SettingButton {
            id: recording_setting_button
            anchors.top: audio_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "我的录制"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_media_off@2x.png"
            btn_txt_selected: "我的录制"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_media_on@2x.png"
            visible: SDKUserDefaultObject.getLoginState()
            Loader {
                id: recording_push_button

                onLoaded: {
                    if (item) {
                        item.y = -(26 + 10 + 10) * 3 // 设置 y 坐标
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                recording_setting_button.state="SELECTED"
                recording_push_button.source = "FrtcRecordingSettingView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");

            }
        }

        //----------------------------------------
        //3.User setting button.
        //----------------------------------------
        SettingButton {
            id: user_setting_button
            anchors.top: recording_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "账户管理"
            btn_img_src_unselected: "qrc:/Images/SettingView/frtc_setting_head_off@2x.png"
            btn_txt_selected: "账户管理"
            btn_img_src_selected: "qrc:/Images/SettingView/frtc_setting_head_on@2x.png"
            visible: SDKUserDefaultObject.getLoginState()
            Loader{
                id: user_push_button

                onLoaded: {
                    if (item) {
                        //item.x = 200; // 设置 x 坐标
                        item.y = -(26 + 10) * 4; // 设置 y 坐标
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                user_setting_button.state="SELECTED"
                user_push_button.source = "FrtcUserSettingView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");
            }
        }

        //----------------------------------------
        //4.About setting button.
        //----------------------------------------
        SettingButton {
            id: about_setting_button
            anchors.top: SDKUserDefaultObject.getLoginState() ? user_setting_button.bottom : audio_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "关于我们"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_about_off@2x.png"
            btn_txt_selected: "关于我们"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_about_on@2x.png"
            Loader{
                id: about_push_button

                onLoaded: {
                    if (item) {
                        if(SDKUserDefaultObject.getLoginState()) {
                            item.y = -((26 + 10) * 5 + 20); // 设置 y 坐标
                        } else {
                            item.y = -((26 + 10 ) * 3 + 20);
                        }
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                about_setting_button.state = "SELECTED"
                about_push_button.source = "FrtcAboutSettingView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: General setting button");

            }
        }

        //----------------------------------------
        //5.Diagnostic setting button.
        //----------------------------------------
        SettingButton {
            id: diagnostic_setting_button
            anchors.top: about_setting_button.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 16

            isStateChangeButton: true
            state: "UNSELECTED"
            btn_txt_unselected: "问题诊断"
            btn_img_src_unselected: "qrc:/Images/SettingView/icon_diagnosis_un_selected@2x.png"
            btn_txt_selected: "问题诊断"
            btn_img_src_selected: "qrc:/Images/SettingView/icon_diagnosis_selected@2x.png"
            Loader{
                id: diagnostic_push_button

                onLoaded: {
                    if (item) {
                        if(SDKUserDefaultObject.getLoginState()) {
                            item.y = -((26 + 10 ) * 6 + 20); // 设置 y 坐标
                        } else {
                            item.y = -((26 + 10 ) * 4 + 20);
                        }
                    }
                }
            }

            onMouseClicked: {
                clearSourceAndState()
                diagnostic_setting_button.state="SELECTED"
                diagnostic_push_button.source = "FrtcDiagnosticView.qml"
                setInfoText(btn_txt_unselected + " A Button clicked.");
                console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: Diagnostic button");

            }
        }

        // SettingButton {
        //     id: video_preview_setting_button
        //     anchors.top: diagnostic_setting_button.bottom
        //     anchors.topMargin: 10
        //     anchors.left: parent.left
        //     anchors.leftMargin: 16

        //     isStateChangeButton: true
        //     state: "UNSELECTED"
        //     btn_txt_unselected: "视频"
        //     btn_img_src_unselected: "qrc:/Images/SettingView/icon_media_off@2x.png"
        //     btn_txt_selected: "视频"
        //     btn_img_src_selected: "qrc:/Images/SettingView/icon_media_on@2x.png"
        //     Loader{
        //         id: video_preview_push_button

        //         onLoaded: {
        //             if (item) {
        //                 if(SDKUserDefaultObject.getLoginState()) {
        //                     item.y = -((26 + 10) * 7 + 20 ); // 设置 y 坐标
        //                 } else {
        //                     item.y = -((26 + 10) * 5 + 20) ;
        //                 }
        //             }
        //         }
        //     }

        //     onMouseClicked: {
        //         clearSourceAndState()
        //         video_preview_setting_button.state="SELECTED"
        //         video_preview_push_button.source = "FrtcVideoSettingView.qml"
        //         setInfoText(btn_txt_unselected + " A Button clicked.");
        //         console.log("[UI][FrtcSettingtingViewController.qml][onMouseClicked:]: Diagnostic button");

        //     }
        // }
    }

    function clearSourceAndState() {
        general_setting_button.state        = "UNSELECTED"
        user_setting_button.state           = "UNSELECTED"
        about_setting_button.state          = "UNSELECTED"
        //video_setting_button.state          = "UNSELECTED"
        audio_setting_button.state          = "UNSELECTED"
        diagnostic_setting_button.state     = "UNSELECTED"
        video_preview_setting_button.state  = "UNSELECTED"
        recording_setting_button.state      = "UNSELECTED"

        general_push_button.source          = ""
        user_push_button.source             = ""
        about_push_button.source            = ""
       // video_push_button.source            = ""
        audio_push_button.source            = ""
        diagnostic_push_button.source       = ""
        video_preview_push_button.source    = ""
        recording_push_button.source        = ""
    }


    Component.onCompleted: {
        FrtcTool.closeSettingView.connect(function () {
            id_setting_view.destroy()
        })
    }

    Component.onDestruction: {}
}


