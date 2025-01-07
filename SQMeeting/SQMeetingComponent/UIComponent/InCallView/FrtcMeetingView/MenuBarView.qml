import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14

import "./"
import "./../../../../SQMeetingComponent/UIComponent/InCallView/FrtcMeetingInfoView/View/"
import "./../../../../SQMeetingComponent/UIComponent/InCallView/FrtcNetWorkInfoView/View/"
import "./../../../../SQMeetingComponent/UIComponent/InCallView/FrtcGridModeView/View/"
import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp


Rectangle {
    z: 3; //keep on the top order.

    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 0

    //MenuBarView.EnumButtonType
    enum EnumButtonType {
        NoneEnumBtnType, //0
        MettingInfoEnumBtnType, //1
        NetWorkEnumBtnType,
        GalleryEnumBtnType,
        FullScreenEnumBtnType
    }

    property string meetingDuration: "00:00" //time_duration_label.text

    property int tabbaarButtonMarginWidth: 100

    property var subPopupMeetingInfoViewQML: null

    function showOrHideMenuBarView(aShow) {
        visible = aShow

        if (aShow) {

        } else {
            menu_buttons_view.hideCurrentDetailView()
            menu_buttons_view.currentMouseHoverInMenuButtonType = MenuBarView.EnumButtonType.NoneEnumBtnType
        }

    }

    Rectangle {
        id: menu_buttons_view
        height: 40 - 6

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 0

        color: "white"

        property var mettingInfoButton_bottom: title_meeting_info_button.bottom
        property var mettingInfoButton_left: title_meeting_info_button.left

        property int currentMouseHoverInMenuButtonType: MenuBarView.EnumButtonType.NoneEnumBtnType


        //[function]:

        function hideCurrentDetailView() {
           if (MenuBarView.EnumButtonType.MettingInfoEnumBtnType === currentMouseHoverInMenuButtonType) {
                meeting_info_view_and_button_view.showOrHideDetailView(false);
                return
            } else if (MenuBarView.EnumButtonType.NetWorkEnumBtnType === currentMouseHoverInMenuButtonType) {
                network_info_view_and_button_view.showOrHideDetailView(false);
                return
            } else if (MenuBarView.EnumButtonType.GalleryEnumBtnType === currentMouseHoverInMenuButtonType) {
                return
            }
        }

        function showNewDetailView(aNewButtonMouseHoverEntering) {
            if (MenuBarView.EnumButtonType.MettingInfoEnumBtnType === aNewButtonMouseHoverEntering) {
                meeting_info_view_and_button_view.showOrHideDetailView(true);
                return
            } else if (MenuBarView.EnumButtonType.NetWorkEnumBtnType === aNewButtonMouseHoverEntering) {
                network_info_view_and_button_view.showOrHideDetailView(true);
                return
            }  else if (MenuBarView.EnumButtonType.GalleryEnumBtnType === aNewButtonMouseHoverEntering) {
                return
            }
        }

        function handleMouseHoverEnteredButton(aNewButtonMouseHoverEntering) {
            if (MenuBarView.EnumButtonType.NoneEnumBtnType === currentMouseHoverInMenuButtonType) {
                currentMouseHoverInMenuButtonType = aNewButtonMouseHoverEntering
                showNewDetailView(aNewButtonMouseHoverEntering)
                return
            }

            if (currentMouseHoverInMenuButtonType === aNewButtonMouseHoverEntering) {
                return
            } else {
                hideCurrentDetailView()
                showNewDetailView(aNewButtonMouseHoverEntering)
            }

            currentMouseHoverInMenuButtonType = aNewButtonMouseHoverEntering
        }

        function handleMouseHoverExitedButton(aButtonMouseHoverExiting) {
            if (MenuBarView.EnumButtonType.NoneEnumBtnType === aButtonMouseHoverExiting) {
               return
            }

            hideCurrentDetailView()
            menu_buttons_view.currentMouseHoverInMenuButtonType = MenuBarView.EnumButtonType.NoneEnumBtnType
        }

        //1.1.top line
        Image {
            id: top_line_image
            //width: parent.width
            height: 2
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0
            source: "qrc:/Images/SettingView/gray_line_content_select.png"
            fillMode: Image.Stretch
            visible: true
        }


        Rectangle {
            id: meeting_info_view_and_button_view

            width: 100
            height: 26
            //z: 0
            radius: 4

            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: 8

            color: "transparent"


            function showOrHideDetailView(aShow) {
                if (aShow) {
                    width = 260
                    height = 200 + 26 + 4
                    meeting_info_view.visible = true
                } else {
                    width = 100
                    height = 26
                    meeting_info_view.visible = false
                }
            }

            MouseArea {
                id: id_meetinginfo_mousearea
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {}
                onExited: {
                    menu_buttons_view.handleMouseHoverExitedButton(MenuBarView.EnumButtonType.MettingInfoEnumBtnType)
                    meeting_info_view_and_button_view.showOrHideDetailView(false)
                }
            }

            TitleButton {
                id: title_meeting_info_button
                anchors.top: parent.top
                anchors.left: parent.left

                isStateChangeButton: false
                state: "SELECTED"
                btn_txt_unselected: "会议信息"
                btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_meeting_info@2x.png"
                btn_txt_selected: "会议信息"
                btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_meeting_info@2x.png"

                //mouse hover entered.
                onMouseHoverEntered: {
                    menu_buttons_view.handleMouseHoverEnteredButton(MenuBarView.EnumButtonType.MettingInfoEnumBtnType)
                }

                //mouse hover exited.
                onMouseHoverExited:  {}
            }


            FrtcMeetingInfoView {
                id: meeting_info_view
                width: 240
                height: 140
                z: 0

                anchors.top: title_meeting_info_button.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 2

                visible: false
                color: "white"
            }

            Component.onCompleted: {
                meeting_info_view.setMeetingInfoData(root.conferenceName, root.meetingID, root.ownerName, root.meetingPasscode)
            }
        }

        Rectangle {
            id: network_info_view_and_button_view


            width: 100
            height: 26
            z: 0
            radius: 4

            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: 8 + 100 + 8


            color: "transparent"

            function showOrHideDetailView(aShow) {
                if (aShow) {
                    network_info_view_and_button_view.width = 260
                    network_info_view_and_button_view.height = 200 + 26 + 4
                    network_info_view.visible = true
                } else {
                    network_info_view_and_button_view.width = 100
                    network_info_view_and_button_view.height = 26
                    network_info_view.visible = false
                }
            }

            MouseArea {
                id: id_network_mousearea
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {}
                onExited: {
                    console.log("[UI][MessageBox.qml][TitleButton: title_meeting_info_button][MouseArea onExited:]: -> call menu_buttons_view.handleMouseHoverExitedButton(aButtonMouseHoverExiting: NetWorkEnumBtnType)")
                    menu_buttons_view.handleMouseHoverExitedButton(MenuBarView.EnumButtonType.NetWorkEnumBtnType)

                    network_info_view_and_button_view.showOrHideDetailView(false)
                }
            }

            TitleButton {
                id: title_network_info_button
                anchors.top: parent.top
                anchors.left: parent.left

                isStateChangeButton: false
                state: "SELECTED"
                btn_txt_unselected: "网络状况"
                btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_network_info@2x.png"
                btn_txt_selected: "网络状况"
                btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_network_info@2x.png"
                onMouseClicked: {
                }
                //mouse hover entered.
                onMouseHoverEntered: {
                    menu_buttons_view.handleMouseHoverEnteredButton(MenuBarView.EnumButtonType.NetWorkEnumBtnType)

                }

                //mouse hover exited.
                onMouseHoverExited:  {}
            }

            FrtcNetWorkInfoView {
                id: network_info_view //detail
                width: 260
                height: 190
                anchors.top: title_network_info_button.bottom
                anchors.topMargin: 8
                anchors.left: parent.left

                visible: false
                color: "white"
            }

            Component.onCompleted: {
                network_info_view.setMeetingInfoData(root.conferenceName, root.meetingID)
            }
        }

        Text {
            id:time_duration_label
            anchors.centerIn: parent
            text: meetingDuration
        }


        Rectangle {
            id: gridmode_view_and_button_view

            width: 100
            height: 26
            z: 0
            radius: 4

            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 10

            color: "transparent"

            function showOrHideDetailView(aShow) {
                if (aShow) {
                    gridmode_view_and_button_view.width = 256
                    gridmode_view_and_button_view.height = 162 + 26 + 4 + 4
                    grid_mode_view.visible = true
                } else {
                    gridmode_view_and_button_view.width = 100
                    gridmode_view_and_button_view.height = 26
                    grid_mode_view.visible = false
                }
                root.setIsShowGridModeDetail(aShow);
            }

            function hideDetailView() {
                var isShow = title_grid_view_button.isShowDetailView
                if (isShow) {
                    title_grid_view_button.isShowDetailView = false
                    showOrHideDetailView(false)
                }
            }




            TitleButton {
                id: title_grid_view_button
                anchors.top: parent.top
                anchors.right: parent.right


                isStateChangeButton: false
                btn_txt_unselected: "画廊视图"
                btn_img_src_unselected: "qrc:/Images/InCall/FMeetingVC/MenuBar/menuBar/in_conference_menubar_grid_mode@2x.png"
                btn_txt_selected: "演讲者视图"
                btn_img_src_selected: "qrc:/Images/InCall/FMeetingVC/MenuBar/gridModeButton/presenter_small@2x.png"
                state: SDKUserDefaultObject.getSelectGridModel() ? "UNSELECTED" : "SELECTED" //true: "gallery"; false: "presenter"

                property bool isShowDetailView: false
                onMouseClicked: {
                    isShowDetailView = !isShowDetailView
                    gridmode_view_and_button_view.showOrHideDetailView(isShowDetailView)

                }
            }

            FrtcGridModeView {
                id: grid_mode_view //detail
                width: 256
                height: 162
                anchors.top: title_grid_view_button.bottom
                anchors.topMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                radius: 4

                visible: false

                function hideGridModeDetail() {
                    title_grid_view_button.state = SDKUserDefaultObject.getSelectGridModel() ? "SELECTED" : "UNSELECTED"
                    gridmode_view_and_button_view.hideDetailView()
                }

            }
        }

    }

}


