import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.frtc.FrtcApiManager 1.0
import SDKUserDefaultObject 1.0
import "../../../CommonView"
import "../../FrtcHome"

Window {
    id: inviteUser_Window
    width: 350
    height: 500
    x:(screen.width - width)/2
    y:(screen.height - height)/2 - 50

    color: 'white'

    visible: true
    title: qsTr("添加邀请用户")

    property var userToken: SDKUserDefaultObject.getUserToken()
    property int selectedSegment: 0
    property int currentPage: 1
    property bool isLoading: false
    //选中的用户
    property var selectListUsersArray: []


    signal clickFinishButtonBlock(var selectUserIdList)

    function addSelectListUsers(users) {
        console.log("user ===== users ", users)
        users.forEach(function(user) {
            selectListModel.append(user);
        });
    }

    ListModel {
        id: selectListModel
    }

    ListModel {
        id: searchResultListModel

        // function refresh(){
        //     searchResultListModel.clear()
        //     currentPage = 1
        //     getUserListRequest(currentPage,"")
        // }

        function loadMore(){
            currentPage += 1
            getUserListRequest(currentPage , searchInput.text)
        }

        function canLoadMore(){
            return count > 30 ? false : true;
        }

        //Component.onCompleted: refresh()
    }

    function getUserListRequest(page,filter) {
        //请求用户列表
        if (isLoading) return;
        isLoading = true;
        FrtcApiManager.getUserList(userToken,page,filter)
    }

    Row {
        id: segmentView
        spacing: 0
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        Button {

            width: (parent.width) / 2
            height: 45

            background: Rectangle {
                color: selectedSegment === 0 ? '#026FFE' : "#F8F9FA"
            }

            Text {
                text: "邀请用户"
                color: selectedSegment === 0 ? "white" : "black"
                anchors.centerIn: parent
            }

            onClicked: {
                selectedSegment = 0;
            }
        }

        Button {

            width: (parent.width - 0) / 2
            height: 45

            background: Rectangle {
                color: selectedSegment === 1 ? '#026FFE' : "#F8F9FA"
            }

            Text {
                text: "已邀请用户"
                color: selectedSegment === 1 ? "white" : "black"
                anchors.centerIn: parent
            }

            onClicked: {
                selectedSegment = 1;
            }
        }

    }

    FrtcTextField {

        id: searchInput
        height: 35
        anchors.top: segmentView.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        border.color: '#F8F9FA'
        placeholderText: qsTr("搜索")
        textFont: 14

        onTextInputChanged: {
            console.log("searchInput.text",newText)
            currentPage = 1
            getUserListRequest("1",newText)
        }
    }


    PullListView {

        id: search_result_View
        clip: true
        anchors.top: searchInput.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 330
        model: selectedSegment === 0 ? searchResultListModel : selectListModel

        delegate: FrtcInviteUserListView {
            id:cell
            width: 310
            height: 45
            color: "white"
            titleText: model.real_name + "(" + model.username + ")"
            cellState: selectedSegment === 0 ? model.cstate : "CANCEL"

            onClickedCell: {

                if (selectedSegment === 0) {
                    var newState = (model.cstate === "UNCHECKED") ? "CHECKED" : "UNCHECKED";
                    searchResultListModel.set(index, {"cstate": newState });
                    if (newState === "CHECKED")  {
                        var exists = false;
                        for (var i = 0; i < selectListModel.count; i++) {
                            if (selectListModel.get(i).user_id === model.user_id) {
                                exists = true;
                                break;
                            }
                        }
                        if (!exists) { //如果不存在添加
                            selectListModel.append({"real_name": model.real_name,
                                                       "user_id":model.user_id,
                                                       "username":model.username,
                                                       "cstate": newState});
                        }
                    }else if (newState === "UNCHECKED") {
                        for (var j = 0; j < selectListModel.count; j++) {
                            if (selectListModel.get(j).user_id === model.user_id) {
                                selectListModel.remove(j);
                                break;
                            }
                        }
                    }
                }else {

                    for (var z = 0; z < searchResultListModel.count; z++) {
                        var itemModel =  searchResultListModel.get(z)
                        if (itemModel.user_id === model.user_id) {
                            searchResultListModel.set(z, {"cstate": "UNCHECKED" });
                            break;
                        }
                    }

                    for (var k = 0; k < selectListModel.count; k++) {
                        var itemModel1 =  selectListModel.get(k)
                        if (itemModel1.user_id === model.user_id) {
                            selectListModel.remove(k);
                            break;
                        }
                    }
                }

                var content = selectListModel.count
                if (content === 0) {
                    finish_btn.text = qsTr("完成")
                }else{
                    finish_btn.text = qsTr("完成") + "(" + selectListModel.count + ")"
                }
            }
        }

        // Component{
        //     id: cmpHeader
        //     Rectangle{
        //         color: "red"
        //         width: search_result_View.width
        //         height: 16
        //         Text{
        //             anchors.centerIn: parent
        //             text: search_result_View.headerHold ? "正在刷新" : "刷新"
        //         }
        //     }
        // }
        // header: headerVisible ? cmpHeader : null

        // onHeaderHoldChanged:{
        //     if(headerHold)
        //         searchResultListModel.refresh()
        // }

        Component{
            id: cmpFooter
            Rectangle{
                color: "#fefefe"
                width: search_result_View.width
                height: 30
                visible: selectedSegment === 0 ? true : false
                Text{
                    anchors.centerIn: parent
                    text: search_result_View.footerHold ? "正在加载..." : "加载更多"
                }
            }
        }

        footer: footerVisible ? cmpFooter : null

        onFooterHoldChanged: {
            if(footerHold)
                searchResultListModel.loadMore()
        }
    }


    Row {

        id: bottomView
        spacing: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Button {

            width: 100
            height: 45

            background: Rectangle {
                color: "#F8F9FA"
                radius: 8
            }

            Text {
                text: qsTr("取消")
                color: "black"
                anchors.centerIn: parent
            }

            onClicked: {
                inviteUser_Window.destroy();
            }
        }

        Button {

            width: 100
            height: 45

            background: Rectangle {
                color: '#026FFE'
                radius: 8
            }

            Text {
                id: finish_btn
                text: qsTr("完成")
                color: "white"
                anchors.centerIn: parent
            }

            onClicked: {
                inviteUser_Window.destroy();
                var userids = []
                for (var i = 0 ; i < selectListModel.count ; i ++) {
                    var userId = selectListModel.get(i).user_id
                    userids.push(userId)
                }
                clickFinishButtonBlock(userids)
            }
        }

    }

    Component.onCompleted:  {

        if (selectListUsersArray.length > 0) {
            var item1 = selectListUsersArray[0]
            console.log("name ---+++ :", item1,selectListUsersArray.length)
            finish_btn.text = qsTr("完成") + "(" + selectListUsersArray.length + ")"
        }

        getUserListRequest("1","")
    }

    Connections {
        target: FrtcApiManager
        function onUserListCompleted(success, json) {
            isLoading = false;
            //search_result_View.headerVisible = false
            search_result_View.headerVisible = false

            if (success) {
                var resultList = json.users;

                if (currentPage === 1) {
                    searchResultListModel.clear()
                }

                console.log("resultList.length  = ",resultList.length)
                if (!resultList || resultList.length === 0) {
                    console.log("No more data to load.");
                    return;
                }

                resultList.forEach(function(item) {
                    if (item && item.real_name) {
                        var cstate = "UNCHECKED"
                        if (selectListUsersArray.includes(item.user_id)) {
                            cstate = "CHECKED"
                            selectListModel.append(item)
                        }
                        searchResultListModel.append({"real_name": item.real_name, "user_id":item.user_id, "username":item.username, "cstate": cstate});
                    } else {
                        console.warn("Invalid user item:", item);
                    }
                });
                console.log("Total items in model:", searchResultListModel.count);
            } else {
                console.error("Failed to fetch user list");
            }
        }
    }
}
