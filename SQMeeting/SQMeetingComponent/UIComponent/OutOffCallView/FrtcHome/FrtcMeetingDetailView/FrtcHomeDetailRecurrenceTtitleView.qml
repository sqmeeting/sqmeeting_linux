import QtQuick 2.15
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Rectangle  {

    id: recurrenceTitleView
    color: "white"
    height: 25

    property alias contentText: titleText.text

    signal clickRecurrenceTitle()
    signal clickEditMeeting()


    Rectangle {

        id: recurrenceTitle
        width: recurrenceContentTitle.width + 30
        height: 25
        anchors.top: parent.top
        anchors.left: parent.left

        MouseArea {
            anchors.fill: parent
            onClicked: clickRecurrenceTitle()
        }

        Rectangle {

            id:recurrenceRectangle
            width: 40
            height: 25

            Rectangle {
                width: 25
                height: 40
                rotation: 270
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop { position: 0.0 ; color: "#3EC76E" }
                    GradientStop { position: 1.0 ; color: "#72E5A7" }
                }
            }

            Text {
                anchors.centerIn: parent
                text: qsTr('周期')
                color: 'white'
                font.pixelSize: 11
            }
        }

        Rectangle {
            id: recurrenceContentTitle
            anchors.left: recurrenceRectangle.right
            anchors.leftMargin: -1
            anchors.verticalCenter: recurrenceRectangle.verticalCenter
            border.width: 0.5
            border.color: "#3EC76E"
            clip: true

            width: titleText.contentWidth + 20
            height: 25

            Rectangle {
                width: recurrenceContentTitle.height - 2
                height: recurrenceContentTitle.width - 2
                rotation: 270
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop { position: 0.0 ; color: "#E5FFF1" }
                    GradientStop { position: 1.0 ; color: "white" }
                }
            }

            Text {
                id: titleText
                anchors.verticalCenter: recurrenceContentTitle.verticalCenter
                text: contentText
                color: 'black'
                font.pixelSize: 11
            }

            Image {
                id: rightImage
                anchors.left: titleText.right
                anchors.leftMargin: 5
                anchors.verticalCenter: recurrenceContentTitle.verticalCenter
                source: "qrc:/Images/Home/frtc_meetingDetail_right@3x.png"
            }
        }
    }


    Rectangle {

        width: changeText.contentWidth + 10 + 30
        anchors.right: parent.right
        height: 25

        RowLayout {

            spacing: 5

            Image{
                id: changeImage
                source: "qrc:/Images/Home/frtc_icon_recurrence_modify@2x.png"
            }

            Text {
                id: changeText
                text: qsTr("修改")
                height: 25
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: clickEditMeeting()
        }
    }
}
