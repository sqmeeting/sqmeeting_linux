//
//  CustomTitleBar.qml
//  Component Rectangle CustomTitleBar.
//  FrtcMeeting Qt version.
//  [Note]: [Out of Call] Conference UI.
//
//  Created by Yingyong.Mao on 2023/04/17.
//  Copyright © 2023 毛英勇. All rights reserved.
//

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14


//========================================
// CustomTitleBar.
//========================================

// Custom title item implementation

Item {
    property alias title: titleLabel.text

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "red"
        opacity: 0.5
    }

    Text {
        id: titleLabel
        text: "My Window"
        color: "white"
        anchors.centerIn: parent
    }

    // Reposition the item when the window is resized or moved

//    onWindowChanged: {
//        if (window) {
//            window.WindowTitleBar {
//                anchors.fill: parent
//                visible: false
//            }

//            // Move the item to the top of the window stack
//            parent.raiseToTop()
//        }
//    }

}


