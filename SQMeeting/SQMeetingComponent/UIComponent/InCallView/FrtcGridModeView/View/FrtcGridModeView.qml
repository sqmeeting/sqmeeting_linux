import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp

//========================================
// Message box: will automatically hide after 5 seconds.
//========================================

Rectangle {
    id: grid_mode_view
    //width: 200
    //height: 40
    //opacity: 0.5;
    //z: 3

    //property alias messageString: meeting_id_text_view.text
    property int timerCounter: 0
    property int timerDuration: 3
    width: 254
    height: 168
    color: "#f8f9fa"

    function setMeetingInfoData(conferenceName, meetingID, ownerName, meetingPasscode) {
        console.log("[UI][FrtcMeetingInfoView.qml][setMeetingInfoData:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        meetinginfo_conference_name_text_view.text = conferenceName
        meeting_id_text_view.text = meetingID
        meeting_ownername_text_view.text = ownerName
        meeting_passcode_text_view.text = meetingPasscode
    }

    function showMeetingInfoView(conferenceName, meetingID, ownerName, meetingPasscode) {
        console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: conferenceName: " + conferenceName + ", meetingID: " + meetingID + ", ownerName: " + ownerName + ", meetingPasscode: " + meetingPasscode)
        meetinginfo_conference_name_text_view.text = conferenceName
        //TODO: test
        //meetinginfo_conference_name_text_view.text = "conferenceName long meeting name so we need minize the font size to fit it ."

        meeting_id_text_view.text = meetingID
        meeting_ownername_text_view.text = ownerName
        meeting_passcode_text_view.text = meetingPasscode
        //console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: -> set prompt_message_box_view.visible = true")
        visible = true

        //Timer.
        //console.log("[UI][FrtcMeetingInfoView.qml][showMeetingInfoView:]: -> set prompt_message_box_view.start()")
        //prompt_message_box_view_timer.start()
    }

    function switchGridMode(bGallery) {
        console.log("[FrtcMeetingInfoView.qml][switchGridMode]: -> root : " + root)
        console.log("[FrtcMeetingInfoView.qml][switchGridMode]: -> call root[FMeetingViewController.qml]: root.switchGridMode(bGallery: " + bGallery)
        root.switchGridMode(bGallery) //true: "gallery"; false: "presenter"
    }

    function changeSeletGridView() {
        console.log("[FrtcGridModeView.qml][changeSeletGridView]")
        presenter_button.state = SDKUserDefaultObject.getSelectGridModel() ? "UNSELECTED" : "SELECTED"
        gallery_button.state = SDKUserDefaultObject.getSelectGridModel() ? "SELECTED" : "UNSELECTED"
    }

    Timer {
        id: prompt_message_box_view_timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: timerCounter: " + prompt_message_box_view.timerCounter)
            if (timerDuration <= prompt_message_box_view.timerCounter) {
                console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: -> set prompt_message_box_view.visible = false")
                visible = false
                console.log("[UI][FrtcMeetingInfoView.qml][Timer][onTriggered:]: -> call timer stop()")
                stop()
                prompt_message_box_view.timerCounter = 0
            } else {
                ++prompt_message_box_view.timerCounter
            }
        }
    }



    //-------------------------------------------------
    // 1.[left] gallery mode.
    //-------------------------------------------------

    Rectangle {
        id: left_gellery_view
        width: 100
        height: 28 //default 3 seconds.
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16
        //anchors.margins: 18

        color: "#ffffff"
        //border.color: "black"
        //border.width: 1

        Image {
            id: gellery_button_image
            width: 12
            height: 12
            source: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/gallery_small@2x.png"
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 12
            //anchors.margins: 18

            z: 3; //keep on the top order.
        }

        Text {
            id: gellery_button_text
            width: 52
            height: 24
            text: qsTr("画廊视图")
            //text: qsTr("button")
            anchors.top: parent.top
            anchors.topMargin: 2 //"gallery"
            anchors.left: gellery_button_image.right
            anchors.leftMargin: 8
            anchors.margins: 8

            //font.bold: true
            font.pixelSize: 10

            z: 3; //keep on the top order.
        }
    }

    //-------------------------------------------------
    // 2.[right] presenter mode.
    //-------------------------------------------------

    Rectangle {
        id: right_present_view
        width: 100
        height: 28
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: left_gellery_view.right
        anchors.leftMargin: 16
        //anchors.margins: 18

        color: "#ffffff"
        //border.color: "black"
        //border.width: 1

        Image {
            id: presenter_button_image
            width: 12
            height: 12
            source: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/presenter_small@2x.png"
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 12
            //anchors.margins: 24

            z: 3; //keep on the top order.
        }

        Text {
            id: presenter_button_text
            width: 52
            height: 24
            text: qsTr("演讲者视图") //"presenter"
            //text: qsTr("button")
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: presenter_button_image.right
            anchors.leftMargin: 8
            anchors.margins: 8

            //font.bold: true
            font.pixelSize: 10

            z: 3; //keep on the top order.
        }

    }

    //-------------------------------------------------
    // 3.[left] gallery mode button.
    //-------------------------------------------------

    FrtcGridButton {
        id: gallery_button
        width: 100
        height: 90
        anchors.top: right_present_view.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16

        border.color: "lightgray"
        border.width: 1

        isStateChangeButton: false
        btn_txt_unselected: qsTr("画廊视图")
        btn_txt_selected: qsTr("画廊视图")

        btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/gallery_large@2x.png"
        btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/gallery_large@2x.png"

        state: SDKUserDefaultObject.getSelectGridModel() ? "SELECTED" : "UNSELECTED"

        onMouseClicked: {
            console.log("[FrtcGridModeView.qml][presenter_button]" + btn_txt_unselected + "Tabbar invitate Button clicked.")

            console.log("[FrtcGridModeView.qml][gallery_button][onMouseClicked]: -> root : " + root)
            console.log("[FrtcGridModeView.qml][gallery_button][onMouseClicked]: -> parent : " + parent)

            console.log("[FrtcGridModeView.qml][gallery_button][onMouseClicked]: -> call grid_mode_view.hideGridModeDetail()")
            grid_mode_view.hideGridModeDetail()
            presenter_button.state = "UNSELECTED"
            gallery_button.state = "SELECTED"
            console.log("[FrtcGridModeView.qml][gallery_button][onMouseClicked]: -> call root[FMeetingViewController.qml]: root.switchGridMode(true)")
            parent.switchGridMode(true) //true: "gallery"; false: "presenter"
        }
    }


    //-------------------------------------------------
    // 4.[right] presenter mode button.
    //-------------------------------------------------

    FrtcGridButton {
        id: presenter_button
        width: 100
        height: 90
        anchors.top: right_present_view.bottom
        anchors.topMargin: 16
        anchors.left: gallery_button.right
        anchors.leftMargin: 16

        border.color: "lightgray"
        border.width: 1

        isStateChangeButton: false
        btn_txt_unselected: qsTr("演讲者视图")
        btn_txt_selected: qsTr("演讲者视图")

        btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/presenter_large@2x.png"
        btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/presenter_large@2x.png"

        state: SDKUserDefaultObject.getSelectGridModel() ? "UNSELECTED" : "SELECTED"

        onMouseClicked: {
            console.log("[FrtcGridModeView.qml][presenter_button][onMouseClicked]: -> call grid_mode_view.hideGridModeDetail()")
            grid_mode_view.hideGridModeDetail()
            presenter_button.state = "SELECTED"
            gallery_button.state = "UNSELECTED"
            console.log("[FrtcGridModeView.qml][presenter_button][onMouseClicked]: -> call root[FMeetingViewController.qml]: root.switchGridMode(false)")
            parent.switchGridMode(false) //true: "gallery"; false: "presenter"
        }
    }

}




