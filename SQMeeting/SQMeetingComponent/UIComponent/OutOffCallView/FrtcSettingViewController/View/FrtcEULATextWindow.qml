import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QMLFileHelperObj 1.0

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
    title: qsTr("服务协议")

    Flickable{
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        contentHeight: textEdit.implicitHeight
        clip: true
        Text{
            id: textEdit
            width: parent.width
            wrapMode: Text.WordWrap
            Component.onCompleted: {
                textEdit.text = QMLFileHelperObj.readTextFile(":/EULA.txt")
            }
        }
    }
}