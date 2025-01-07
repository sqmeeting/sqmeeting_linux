import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import "./../../OutOffCallView/FrtcSettingViewController/View"

Window{
    visible: true
    width: 388
    height: 388
    maximumWidth : width
    maximumHeight : height
    minimumWidth : width
    minimumHeight : height
    x:(screen.width - width)/2
    y:(screen.height - height)/2
    title: "设置"
    id: inCall_metting_setting_view
    color: "#ffffff"
    flags: Qt.WindowStaysOnTopHint |  Qt.WindowCloseButtonHint
    FrtcMediaSettingView{
        anchors.fill: parent
        isInCall: true
    }

}
