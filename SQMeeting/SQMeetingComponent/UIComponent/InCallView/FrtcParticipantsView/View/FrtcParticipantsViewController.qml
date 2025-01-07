import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import Qt.labs.qmlmodels 1.0

import com.frtc.FrtcParticipantsViewControllerObject 1.0 //class FrtcParticipantsViewController

Rectangle {
    id: id_participants_view_root
    width: 388
    height: 360 + 40 //463

    property url image_tableview_group_people:  "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon_unmute_people@2x.png"
    property url image_tableview_audio_mute:    "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-mute@2x.png"
    property url image_tableview_audio_unmute:  "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-audioIncall-unmute@2x.png"
    property url image_tableview_video_mute:    "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-videoIncall-mute@2x.png"
    property url image_tableview_video_unmute:  "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-videoIncall-unmute@2x.png"
    property url image_tableview_group_pin:     "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon_status_pin@2x.png"

    property int image_width_people: 20
    property int image_width_audio_mute: 18
    property int image_width_video_mute: 18

    property int colume_width_people_image: 44 //24 + 20
    property int colume_width_name: 212
    property int colume_width_audio_incall: 35 // 54 - 42 + 18
    property int colume_width_video_incall: 57 //24 + 18

    property string lecture_id: ''
    property string pin_id:''

    property string searchText: ""


    property var onCellClickedCallback

    property bool authority: false

    property bool isBySettingSpeaker:false

    property int row_height: 40

    // roster data.
    property int rosterNumber: 0

    property var rosterArray: []

    Rename {
        id: renameWindow
    }

    RenameInputDialog {
        id: renameInputDialog
    }

    Rectangle {
        id: searchBox
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 10
        height: 40
        color: "#FDFDFD"

        border.color: "transparent" // 去掉边框颜色

        TextField {
            id: searchField
            width: parent.width - 30
            height: 40//parent.height// - 10
            anchors.centerIn: parent
            placeholderText: "搜索"
            font.pixelSize: 13

            padding: 10 // 为图片留出空间

            leftPadding: 40

            verticalAlignment: Text.AlignVCenter
               // Filter model based on search input
            onTextChanged: {
                var filterText = searchField.text.toLowerCase();
                searchText = filterText

                filterRosterData()
            }

            Image {
                id: searchIcon
                source: "qrc:/Images/InCall/FMeetingVC/ParticipantView/mute/icon-roster-searching@2x.png"
                width: 20
                height: 20
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle {
        id: id_tableview_header
        width: parent.width
        height: 2

        Image {
            id: top_line_image
            //width: parent.width
            height: 1
            anchors.top: searchBox.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0
            source: "qrc:/Images/SettingView/gray_line_content_select.png"
            fillMode: Image.Stretch
            visible: true
        }
    }

    TableView {
        id: tableView
        width: parent.width -30

        //anchors.top: id_tableview_header.bottom
        anchors.top: searchBox.bottom
        anchors.left: parent.left
        anchors.margins: 15
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        boundsBehavior: Flickable.OvershootBounds

        ScrollBar.vertical: ScrollBar {
            anchors.right: parent.right
            anchors.rightMargin: 0
            visible: tableModel.rowCount > 5

            background: Rectangle {
                color: "#FDFDFD"
            }
            onActiveChanged: {
                active = true;
            }
            contentItem: Rectangle {
                implicitWidth  : 6
                implicitHeight : 30
                radius : 3
                color: "#FDFDFD"
            }
        }

        model: TableModel {
            id:tableModel

            TableModelColumn {display: "people"}
            TableModelColumn {display: "display_name"}
            TableModelColumn {display: "user_pin"}
            TableModelColumn {display: "audio_mute"}
            TableModelColumn {display: "video_mute"}

        }

        // 分割线组件
        component LineSeparator: Rectangle {
            width: parent.width
            height: 1
            color: "#cccccc"  // 分割线颜色
            anchors.bottom: parent.bottom
        }

        delegate:DelegateChooser {
            // [Column]: people image.
            DelegateChoice {
                column: 0
                delegate: Item {
                    implicitWidth: colume_width_people_image
                    implicitHeight: row_height

                    Rectangle {
                        color: "#F8F9FA"
                        anchors.fill: parent

                        Image {
                            width: 20
                            height: 20
                            anchors.verticalCenter:parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 24

                            fillMode: Image.PreserveAspectFit
                            //antialiasing: true
                            source: image_tableview_group_people
                        }

                    }

                    LineSeparator { }

                }
            }

            // [Column]: user name.
            DelegateChoice{
                column: 1
                delegate: Item {
                    implicitWidth: colume_width_name
                    implicitHeight: row_height

                    Rectangle {
                        color: "#F8F9FA"
                        anchors.fill: parent

                        Text {
                            text: display
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 13
                            color: "#333333"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var rosterInfo = tableModel.getRow(0);

                                if(authiority) {
                                    rosterInfo = tableModel.getRow(row);
                                    var isSpeaker = rosterInfo.display_name.endsWith('(演讲者)');


                                    if (id_participants_view_root.onCellClickedCallback) {
                                        id_participants_view_root.onCellClickedCallback(rosterInfo.display_name, rosterInfo.uuid, rosterInfo.audio_mute, row, isSpeaker, rosterInfo.user_pin) // 调用回调函数
                                    }
                                } else {
                                    if(row == 0){
                                        if (id_participants_view_root.onCellClickedCallback) {
                                            id_participants_view_root.onCellClickedCallback(rosterInfo.display_name, '', rosterInfo.audio_mute, row, false, rosterInfo.user_pin) // 调用回调函数
                                        }
                                    }
                                }
                            }
                        }

                        LineSeparator { }  // 添加分割线
                    }
                }
            }

            DelegateChoice {
                column: 2
                delegate: Item {
                    implicitWidth: colume_width_people_image
                    implicitHeight: row_height

                    Rectangle {
                        color: "#F8F9FA"
                        anchors.fill: parent

                        Image {
                            width: 20
                            height: 20
                            anchors.verticalCenter:parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 6

                            fillMode: Image.PreserveAspectFit

                            visible: rosterArray[row].user_pin === true ? true :false
                            source: image_tableview_group_pin
                        }

                    }

                    LineSeparator { }

                }
            }


            // [Column]: audio mute image.
            DelegateChoice {
                column: 3

                delegate: Rectangle {
                    implicitWidth: colume_width_audio_incall
                    implicitHeight: row_height

                    color: "#F8F9FA"
                    property url imageSource: id_participants_view_root.image_tableview_audio_mute

                    function getImageSource() {
                        if (display) {
                            imageSource = id_participants_view_root.image_tableview_audio_mute
                        } else {
                            imageSource = id_participants_view_root.image_tableview_audio_unmute
                        }

                        return imageSource
                    }

                    Image {
                        width: 18
                        height: 18
                        anchors.verticalCenter:parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        source: getImageSource()
                    }

                    LineSeparator { }

                }
            }

            // [Column]: video mute image.
            DelegateChoice {
                column: 4

                delegate: Rectangle {
                    implicitWidth: colume_width_video_incall
                    implicitHeight: row_height
                    color: "#F8F9FA"

                    property url imageSource: id_participants_view_root.image_tableview_video_mute

                    function getImageSource() {
                        if (display) {
                            imageSource = id_participants_view_root.image_tableview_video_mute
                        } else {
                            imageSource = id_participants_view_root.image_tableview_video_unmute
                        }
                        return imageSource
                    }


                    Image {
                        id: id_mute_video
                        width: 18
                        height: 18
                        anchors.verticalCenter:parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: 0

                        source: getImageSource()
                    }

                    LineSeparator { }
                }
            }
        }
    }

    function qmlGetRosterNumber() {
        var rosterNumber = FrtcParticipantsViewControllerObject.onQmlGetParticipantsNumber()
        return rosterNumber
    }

    function filterRosterData() {
        tableModel.clear(); // 清空表格模型

        for (var i = 0; i < rosterArray.length; i++) {
            var rosterInfo = rosterArray[i];
            if (rosterInfo.display_name.toLowerCase().indexOf(searchText) !== -1) {
                tableModel.appendRow(rosterInfo);
            }
        }

        //tableView.forceLayout();
    }

    function updateSpeakerInRoster() {
        for (let i = 0; i < rosterArray.length; ++i) {
            let rosterInfo = rosterArray[i];
            if (rosterInfo.uuid === lecture_id) {
                if (!rosterInfo.display_name.endsWith('(演讲者)')) {
                    rosterInfo.display_name += '(演讲者)';
                }

                // 如果是本地参会者，则不移动位置
                if (rosterInfo.display_name.includes("(我)")) {
                    break;
                }
                // 将演讲者移到第二个位置
                rosterArray.splice(i, 1);
                rosterArray.splice(1, 0, rosterInfo);
                break;
            }
        }
    }

    // 更新表格模型
    function updateTableModel() {
        tableModel.clear();
        for (let rosterInfo of rosterArray) {
            rosterInfo.people = true;
            tableModel.appendRow(rosterInfo);
        }

        if(searchText === '') {
            tableView.forceLayout();
        }
    }

    // 清理演讲者后缀
    function clearSpeakerSuffix() {
        for (let rosterInfo of rosterArray) {
            if (rosterInfo.display_name.endsWith('(演讲者)')) {
                rosterInfo.display_name = rosterInfo.display_name.slice(0, -5); // 去掉后缀
            }
        }
    }

    function dealwithUpdateRosterList(rosterListObject) {
        var detail = rosterListObject;

        rosterArray = detail.rosterListJsonArray;

        // 获取第一个参会者
            var localParticipant = rosterArray[0];

            // 如果第一个参会者的 display_name 中没有 "(我)"，则加上 "(我)"
            if (!localParticipant.display_name.includes("(我)")) {
                localParticipant.display_name += " (我)";
            }

            // 重新替换 rosterArray[0]
            rosterArray[0] = localParticipant;

        if (lecture_id) {
            console.log()
            updateSpeakerInRoster()
        }

        updateTableModel()
        filterRosterData()
    }

    function reLayoutList() {
        clearSpeakerSuffix()

        if (isBySettingSpeaker) {
                // 如果自己是演讲者，确保自己在第一个位置并加上 " 演讲者" 后缀
            var selfInfo = rosterArray[0];
            if (!selfInfo.display_name.endsWith('(演讲者)')) {
                selfInfo.display_name += '(演讲者)'
            }
        } else if (lecture_id) {
            // 找到匹配项
            updateSpeakerInRoster()
        } else {
            for (var i = 0; i < rosterArray.length; ++i) {
                var rosterInfo = rosterArray[i]
                if (rosterInfo.display_name.endsWith('(演讲者)')) {
                    rosterInfo.display_name = rosterInfo.display_name.slice(0, -5); // 移除后缀
                }
            }
        }

        updateTableModel()
    }


    Component.onCompleted: {
        rosterNumber = qmlGetRosterNumber()
    }

}
