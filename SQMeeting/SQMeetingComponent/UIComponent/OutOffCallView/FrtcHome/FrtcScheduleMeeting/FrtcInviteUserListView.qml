import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Rectangle {

    id: invite_User_list_view

    property alias titleText: contentText.text
    property var cellState: "UNCHECKED"

    signal clickedCell()

    RowLayout {

        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10

        spacing: 10

        // Image {
        //     id: selectedImage
        //     source: "qrc:/Images/Home/frtc_schedulet_user_no@3x.png";
        // }

        Image {
            id: selectedImage
            source: cellState === "UNCHECKED" ? "qrc:/Images/Home/frtc_schedulet_user_no@3x.png" :
                    cellState === "CHECKED" ? "qrc:/Images/Home/frtc_schedulet_user_select@3x.png" :
                                            "qrc:/Images/Home/frtc_schedulet_user_cancle@3x.png"
        }

        Image {
            id: meeting_avatar
            source: "qrc:/Images/Home/frtc_schedule_invite_user_eader@2x.png";
        }

        Text {
            id: contentText
            font.pixelSize: 14
            color: "#222"
        }

    }

    // state: "UNCHECKED"

    // states: [
    //     State {
    //         name: "UNCHECKED"
    //         PropertyChanges { target: invite_User_list_view; enabled: true }
    //         PropertyChanges { target: selectedImage; source: "qrc:/Images/Home/frtc_schedulet_user_no@3x.png"; }
    //     },
    //     State {
    //         name: "CHECKED"
    //         PropertyChanges { target: invite_User_list_view; enabled: true }
    //         PropertyChanges { target: selectedImage; source: "qrc:/Images/Home/frtc_schedulet_user_select@3x.png"; }
    //     }
        //,
        // State {
        //     name: "CANCEL"
        //     PropertyChanges { target: invite_User_list_view; enabled: false }
        //     PropertyChanges { target: selectedImage; source: "qrc:/Images/Home/frtc_schedulet_user_cancle@3x.png"; }
        // }
    // ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: invite_User_list_view.color = '#F8F9FA'
        onExited: invite_User_list_view.color = 'white'
        //onClicked: mouse.accepted = false
        onClicked: {
            if (cellState === "UNCHECKED") {
                cellState = "CHECKED";
            } else if (cellState === "CHECKED") {
                cellState = "UNCHECKED";
            } else if (cellState === "CANCEL") {
                //cellState = "CANCEL";
            }
            clickedCell();
        }
    }

}
