import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// Message box: will automatically hide after 5 seconds.
//========================================

//0.1.message box, automatically hide.
Rectangle {
    //id: prompt_message_box_view
    //width: 200
    //height: 40
    //opacity: 0.5;
    //z: 3

    property alias messageString: prompt_message_text_view.text
    property int timerCounter: 0
    property int timerDuration: 3 //default 3 seconds.


    function popMessageBox(messageString) {
        //console.log("[UI][MessageBox.qml][prompt_message_box_view][popMessageBox:]: messageString: " + messageString);
        prompt_message_text_view.text = messageString;
        //console.log("[UI][MessageBox.qml][prompt_message_box_view][popMessageBox:]: -> set prompt_message_box_view.visible = true");
        prompt_message_box_view.visible = true;
        //console.log("[UI][MessageBox.qml][prompt_message_box_view][popMessageBox:]: -> set prompt_message_box_view.start()");
        prompt_message_box_view_timer.start();
    }

    Text {
        id: prompt_message_text_view
        width: 200
        height: 15

        anchors.top: parent.top
        anchors.topMargin: 10; //40
        anchors.horizontalCenter: parent.horizontalCenter

        text: ""; //qsTr("Saved successfully.")
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter

        color: "white"
    }

    Timer {
        id: prompt_message_box_view_timer
        interval: 1000
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            //console.log("[UI][MessageBox.qml][Timer][onTriggered:]: timerCounter: " + prompt_message_box_view.timerCounter);
            if (timerDuration <= prompt_message_box_view.timerCounter) {
                //console.log("[UI][MessageBox.qml][Timer][onTriggered:]: -> set prompt_message_box_view.visible = false");
                prompt_message_box_view.visible = false;
                //console.log("[UI][MessageBox.qml][Timer][onTriggered:]: -> call timer stop()");
                stop();
                prompt_message_box_view.timerCounter = 0;
            } else {
                ++prompt_message_box_view.timerCounter;
            }
        }
    }

}


