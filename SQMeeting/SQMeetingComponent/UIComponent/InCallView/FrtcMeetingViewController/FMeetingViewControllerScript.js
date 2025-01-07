//
//  FMeetingViewControllerScript.qml
//  class FMeetingViewControllerQML.
//  frtc_sdk Qt version.
//
//  Created by Yingyong.Mao on 2023/12/03.
//  Copyright © 2022 毛英勇. All rights reserved.
//

function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

// Changes 'item' color
function onClicked(item) {
    item.color = getRandomColor();
}
