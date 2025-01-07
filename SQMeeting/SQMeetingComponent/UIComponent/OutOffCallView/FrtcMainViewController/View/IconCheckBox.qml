//
//  IconCheckBox.qml
//  Component Rectangle IconCheckBox.
//  frtc_sdk Qt version.
//  [Note]: Conference UI.
//
//  Created by Yingyong.Mao on 2022/07/25.
//  Copyright © 2022 毛英勇. All rights reserved.
//

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Title button
//========================================

Rectangle {
    id: icon_button_rec

    property bool isEnable: true                //for audio only and cameraMute.

    property bool isStateChangeButton: false

    property var btn_txt_unchecked: button.text
    property url btn_img_src_unchecked: icon.source

    property var btn_txt_checked: button.text //button.textChecked
    property url btn_img_src_checked: icon.source //icon.sourceChecked

    //    property alias img_src: icon.source
    //    property alias btn_txt: button.text

    //    property alias img_src_checked: icon.source //icon.sourceChecked
    //   property alias btn_txt_checked: button.text //button.textChecked

    property color clr_enter: "#dcdcdc"
    property color clr_exit: "#ffffff"
    property color clr_click: "#aba9b2"
    property color clr_release: "#ffffff"
    
    property bool checked: false                 //选择框是否确认
    property bool checkable: true                //选择框是否确认

    //自定义点击信号
    signal mouseClicked()         //slot: user's onMouseClicked: .
    signal mouseClickedLeft()   //slot: user's onMouseClickedLeft: .
    signal mouseClickedRight() //slot: user's onMouseClickedRight: .
    signal mouseReleased()        //slot: user's onMouseReleased: .
    signal mouseHoverEntered()      //slot: user's onMouseHoverEntered: .
    signal mouseHoverExited()        //slot: user's onMouseHoverExited: .

    width: 100
    height: 30
    //y: 5

    anchors.top: icon.top
    anchors.topMargin: 5
    anchors.left: parent.left
    anchors.leftMargin: 0

    radius: 4

    //border.width: 1
    //border.color: "lightgray"

    function setInfoText( str) {
        console.log('[IconCheckBox.qml][TabBar]:  ', str);
    }

    Image {
        id: icon
        width: 16
        height: 16

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8

        source: "qrc:/Images/MainView/icon_checkbox_unchecked@2x.png"
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: button_text

        width: 70
        height: 14

        anchors.top: parent.top
        anchors.topMargin: 3
        //anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 30

        //text: qsTr("Text")
        text: btn_txt_checked
        font.pixelSize: 14


    }
    
    state: "CHECKED"

    states: [
        State {
            name: "UNCHECKED"
            //PropertyChanges { target: button; color: "gray"}
            PropertyChanges { target: button_text; text: btn_txt_unchecked; }
            PropertyChanges { target: icon; source: btn_img_src_unchecked; }
        },
        State {
            name: "CHECKED"
            //PropertyChanges { target: button; color: "black"}
            PropertyChanges { target: button_text; text: btn_txt_checked; }
            PropertyChanges { target: icon; source: btn_img_src_checked; }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //set: accept mouse's left button and right button.
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            console.log("[IconCheckBox][onClicked:]: checked changed.", checked)

            if (false === isEnable) {
                console.log("[IconCheckBox]: ifalse === isEnable, so do nothing.")
                return;
            }

            /*
            //左键点击
            if (mouse.button === Qt.LeftButton) {
                parent.mouseClickedLeft()
                //console.log("[IconCheckBox][onClicked:]:" + button.text + " mouse: Left button clicked.")
            } else if (mouse.button === Qt.RightButton) {
                parent.mouseClickedRight()
                //console.log("[IconCheckBox][onClicked:]:" + button.text + " mouse: Right button clicked.")
            }
            */
            
            if (checkable) {
                //checked = checked == false
                console.log("[IconCheckBox][onClicked:]: checked changed.", checked)
                
                console.log("[IconCheckBox][onClicked:]: btn_txt_checked : " + btn_txt_checked)
                console.log("[IconCheckBox][onClicked:]: btn_txt_unchecked : " + btn_txt_unchecked)
                //color = clr_click

                if (isStateChangeButton) {
                    if (false === checked) {
                        console.log('[IconCheckBox][onClicked:]:: mouse state: UNCHECKED -> CHECKED.')
                        icon_button_rec.state = "CHECKED"
                        checked = true;
                        
                    } else if (true === checked) {
                        console.log('[IconCheckBox][onClicked:]:: mouse state: CHECKED -> UNCHECKED.')
                        icon_button_rec.state = "UNCHECKED"
                        checked = false;
                    }
                }
                parent.mouseClicked()
            }
        }

        /*
        //mouse pressed.
        onPressed: {

        }

        //mouse released.
        onReleased: {
            //console.log("[IconCheckBox]: Release")
            //color = clr_enter
            parent.mouseReleased()
        }

        //mouse hover entered.
        onEntered: {
            //console.log("[IconCheckBox]: " + button.text + " mouse hover entered.")
            //color = clr_enter
            parent.mouseHoverEntered()
        }

        //mouse hover exited.
        onExited: {
            //console.log("[IconCheckBox]: " + button.text + " mouse hover exited.")
            //color = clr_exit
            parent.mouseHoverExited()
        }
         */

    } //end of MouseArea

    //load complet.
    Component.onCompleted: {
        console.log("[IconCheckBox]: " + button_text.text + " Component.onCompleted.")
        if (false === isStateChangeButton) {
            state = "CHECKED";
            console.log("[IconCheckBox]: " + button_text.text + " Component.onCompleted: set state = CHECKED")
        }

    }

    function setStateChecked(bChecked) {
        checked = bChecked;
        state = bChecked?"CHECKED":"UNCHECKED";
    }

    function setEnable(bEnable) {
        console.log("[IconCheckBox]: -> set isEnable: " + bEnable)
        isEnable = bEnable

        //console.log("[IconCheckBox]: -> set checked = bEnable: " + bEnable)
        //checked = bEnable;
        //state = bEnable?"CHECKED":"UNCHECKED";

        if (bEnable) {
            button_text.color = "black"
        } else {
            button_text.color = "gray"
        }
    }
}



