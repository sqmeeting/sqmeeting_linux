pragma Singleton
import QtQuick 2.0

QtObject {

    id: alertManager

    property var currentAlert: null
    property var tostViewQml: null
    property var currentCustomAlert: null

    function showAlertView(title, message, buttonFlags, callback, okButtonText = "确定", cancelButtonText = "取消") {
        if (currentAlert) {
            currentAlert.destroy();
        }

        var component = Qt.createComponent("FrtcAlertView.qml");
        if (component.status === Component.Ready) {
            currentAlert = component.createObject(FrtcTool.rootWindow, {
                                                      "title": title,
                                                      "text": message,
                                                      "buttonFlags": buttonFlags,
                                                      "callback": callback,
                                                      "okButtonText": okButtonText,
                                                      "cancelButtonText": cancelButtonText
                                                  });

            if (currentAlert) {
                currentAlert.show();
            } else {
                console.error("Failed to create alert view.");
            }
        } else {
            console.error("Failed to load FrtcAlertView component.");
        }
    }

    function closeAlert() {
        if (currentAlert) {
            currentAlert.close();
            currentAlert = null;
        }
    }

    // function toast(message) {
    //     if (tostViewQml) {
    //         tostViewQml.destroy();
    //     }

    //     var component = Qt.createComponent("FrtcToastView.qml");
    //     if (component.status === Component.Ready) {
    //         tostViewQml = component.createObject(FrtcTool.rootWindow);
    //         tostViewQml.showText(message)
    //     } else {
    //         console.error("Failed to load tostViewQml component.");
    //     }
    // }


}
