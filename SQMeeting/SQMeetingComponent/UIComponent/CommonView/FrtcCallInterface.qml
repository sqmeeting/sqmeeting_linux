pragma Singleton
import QtQuick 2.0

import SDKUserDefaultObject 1.0 //class SDKUserDefault.cpp
import com.frtc.FMeetingWindowControllerObject 1.0 //class FMeetingWindowController.cpp

import "./"
import "../OutOffCallView/FrtcMainViewController/View/"

QtObject {

    property var  subPopupFMeetingViewControllerQML;
    property var  subPopupPasswordViewControllerQML;
    property bool localMicMute: true
    property bool localCameraMute: true
    property bool localAudioOnly: false
    property string localUserName: ""

    signal makeCallStateBlock(bool success, int reason)

    //保存当前会议信息
    property var currentMeetingInfo: ({})

    function makeCall(userName, meetingID, micMute, cameraMute, audioOnly, passWord) {

        localMicMute = micMute
        localCameraMute = cameraMute
        localAudioOnly = audioOnly
        localUserName = userName

        currentMeetingInfo = {
            "meetingPassword": passWord,
            "meetingStartTime": "",
            "meetingName": "",
            "meetingId": "",
            "meetingOwner": "",
            "meetingOwnerName": "",
        };

        makeCallStateBlock(false, -1);
        frtcCallViewObject.onJoinVideoMeetingButtonPressed(userName, meetingID, micMute, cameraMute, audioOnly, passWord);

        frtcCallViewObject.onCppCallSuccessBlockHandler.disconnect(makeCallSuccessHandler);
        frtcCallViewObject.onCppCallFailureBlockHandler.disconnect(makeCallFailureHandler);
        frtcCallViewObject.onCppInputPasscodeCallbackHandler.disconnect(inputPasscodeHandler);

        frtcCallViewObject.onCppCallSuccessBlockHandler.connect(function (authority, meetingOwner, ownerName, meetingName, meetingNumber) {
            makeCallSuccessHandler(authority, meetingOwner, ownerName, meetingName, meetingNumber, localUserName, localMicMute, localCameraMute, localAudioOnly)
        });

        frtcCallViewObject.onCppCallFailureBlockHandler.connect(makeCallFailureHandler);
        frtcCallViewObject.onCppInputPasscodeCallbackHandler.connect(inputPasscodeHandler);
    }


    function makeCallSuccessHandler(authority, meetingOwner, ownerName, meetingName, meetingNumber,userName,micMute, cameraMute, audioOnly) {
        FrtcTool.isMeetingIn = true
        saveMeetingInfo(meetingOwner, ownerName, meetingName, meetingNumber);
        showInCallUI(authority, meetingOwner, meetingNumber, userName, micMute, cameraMute, audioOnly);
        FMeetingWindowControllerObject.onQmlGetMeetingDuration();
        makeCallStateBlock(true, 0);
    }

    function makeCallFailureHandler(reason) {
        if (currentMeetingInfo.meetingId) {
            currentMeetingInfo["meetingStopTime"] = new Date();
            FrtcTool.saveMeetigfData(currentMeetingInfo);
            FrtcTool.refreshHistoryList();
        }

        FrtcTool.isMeetingIn = false
        FrtcTool.hideMainWindow(false);
        showFailureMessage(reason);
        makeCallStateBlock(false, reason);
    }

    function inputPasscodeHandler(wrongPassCode) {
        currentMeetingInfo["meetingPassword"] = wrongPassCode;
        showPasswordView(wrongPassCode);
    }

    function initInCallUI(authority, meetingOwner) {
        if (null !== subPopupFMeetingViewControllerQML && undefined !== subPopupFMeetingViewControllerQML) {
            subPopupFMeetingViewControllerQML.show();
            return;
        }

        var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/InCallView/FrtcMeetingView/FMeetingWindow.qml");

        if (component.status === Component.Ready) {
            var subParams = {
                "authiority":  authority,
                "meetingOwner": meetingOwner
            }

            subPopupFMeetingViewControllerQML = component.createObject(FrtcTool.rootWindow, subParams)

            subPopupFMeetingViewControllerQML.setUserConfig(authority, meetingOwner, localMicMute, localCameraMute)

            subPopupFMeetingViewControllerQML.dynamicLoaded.connect(function() {
                FMeetingWindowControllerObject.onQmlDynamicLoaded(); // 通知 C++
            })
            subPopupFMeetingViewControllerQML.dynamicLoaded()

            subPopupFMeetingViewControllerQML.show();
        }

    }

    function showPasswordView(wrongPassCode) {

        if (null !== subPopupPasswordViewControllerQML && undefined !== subPopupPasswordViewControllerQML) {
            subPopupPasswordViewControllerQML.destroy();
        }

        var component = Qt.createComponent("qrc:/SQMeetingComponent/UIComponent/OutOffCallView/FrtcMainViewController/View/InputPasscodeWindow/InputPasscodeWindow.qml");

        if (component.status === Component.Ready) {
            subPopupPasswordViewControllerQML = component.createObject(FrtcTool.rootWindow);
            subPopupPasswordViewControllerQML.showDialogWithPromptInvalidePasscode(wrongPassCode)
            subPopupPasswordViewControllerQML.accept.connect(function(password) {
                frtcCallViewObject.onJoinVideoMeetingButtonPressedWithPasscode(password)
            });
            subPopupPasswordViewControllerQML.reject.connect(function() {
                FMeetingWindowControllerObject.dropCall(0);
            });
            subPopupPasswordViewControllerQML.show();
        } else {
            console.error("Failed to load InputPasscodeWindow component.");
        }

    }

    function showInCallUI(authority, meetingOwner,currentMeetingID, currentUserName, currentMicMute, currentCameraMute, currentAudioOnly) {
        initInCallUI(authority, meetingOwner,currentMeetingID, currentUserName, currentMicMute, currentCameraMute, currentAudioOnly)
        FrtcTool.hideMainWindow(true)
    }

    function saveMeetingInfo(meetingOwner,ownerName, meetingName, meetingNumber) {
        if (SDKUserDefaultObject.getLoginState()) {
            currentMeetingInfo["meetingStartTime"]   = new Date()
            currentMeetingInfo["meetingName"]        = meetingName
            currentMeetingInfo["meetingId"]          = meetingNumber
            currentMeetingInfo["meetingOwner"]       = meetingOwner
            currentMeetingInfo["meetingOwnerName"]   = ownerName
        }
    }

    function showFailureMessage(reason) {

        if (null !== subPopupFMeetingViewControllerQML && undefined !== subPopupFMeetingViewControllerQML) {
            subPopupFMeetingViewControllerQML.destroy()
        }

        if (reason === 1) {
            //toast.show("入会失败:会议不存在.")
        } else if (reason === 4) {
            showAlertView("" , "该会议已过期，无法入会")
        } else if (reason === 6) {
            console.log("[UI][FrtcCallView.qml][showFailureMessage] reason: " + reason + ": 会议已结束")
        } else if (reason === 8) {
            showAlertView("入会失败！" , "该会议不存在")
        } else if (reason === 7) {
            showAlertView("入会失败！" , "该会议已锁定，无法入会")
        }  else if (reason === 9) {
            showAlertView("入会失败！" , "会议开始前30分钟方可入会")
        } else if (reason === 10) {
            showAlertView("会议已结束" , "主持人结束了这次会议")
        } else if (reason === 14) {
            showAlertView("入会失败！" , "密码错误已达上限请重新加入会议")
        } else if (reason === 15) {
            showAlertView("入会失败！" , "该会议室不允许访客入会，请登录后重试")
        } else if (reason === 17) {
            showAlertView("会议已结束" , "用户数已达到上限，请升级软件许可")
        } else if (reason === 18) {
            showAlertView("" , "服务未获取软件许可或软件许可已过期")
        } else if (reason === 19) {
            showAlertView("" , "您被主持人移除了会议！")
        } else if (reason === 20) {
            showAlertView("" , "入会失败: 请检查您的服务器地址")
        } else if (reason === 21) {
            showAlertView("" , "该会议室，不允许访客入会，请登录后重试！")
        } else if (reason === 22) {
            showAlertView("" , "该会议室已满员，无法入会！")
        } else if (reason === 23) {
            showAlertView("" , "服务未获取软件许可，或软件许可已过期！")
        } else if (reason === 24) {
            showAlertView("" , "用户数已达到上限，请升级软件许可！")
        } else if (reason === 41) {
            showAlertView("" , "密码错误已达上限,请重新加入会议")
        }  else {

        }
    }

    function showAlertView(title,text) {
        AlertManager.showAlertView(title,
                                   text,
                                   FrtcAlertView.OkButton,
                                   function() {

                                   }
                                   );
    }

}
