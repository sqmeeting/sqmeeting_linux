import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Popup {

    id: calendar
    width: 240
    height: 300
    modal: false
    focus: true

    property bool noDefaultSelection: false

    property int currentYear: new Date().getFullYear() // Current year
    property int currentMonth: new Date().getMonth()   // Current month (0-11)
    property int currentDay: new Date().getDate()      // Current day (1-31)

    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth()
    property int selectedDay: new Date().getDate()

    property var maxSelectableTimestamp: -1 // Timestamp for maximum selectable date in milliseconds, -1 means no limit
    property var minSelectableTimestamp: new Date().getTime() // Default to current date in milliseconds, can be overridden by a timestamp

    signal closeCalendar(var selectedDayText)

    Component.onCompleted: {
        if (noDefaultSelection) {
            selectedYear = -1;
            selectedMonth = -1;
            selectedDay = -1;
        }
    }

    background: Rectangle {
        color: "white"
        border.color: "#dddddd"
        radius: 4
    }

    Column {
        spacing: 10
        width: parent.width
        anchors.left: parent.left
        anchors.leftMargin: 2.5

        RowLayout {
            anchors.topMargin: 1
            width: parent.width
            height: 40
            spacing: 10

            Button {
                id: leftButton
                width: 20
                text: "<"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 5
                onClicked: {
                    calendar.currentMonth -= 1; // Previous month
                    if (calendar.currentMonth < 0) {
                        calendar.currentMonth = 11; // Go back to December
                        calendar.currentYear -= 1; // Decrease year
                    }
                    calendar.selectedDay = Math.min(calendar.selectedDay, calendar.daysInMonth); // Ensure selected day is valid
                }
            }

            Text {
                text: calendar.currentMonthDisplay + " " + calendar.currentYear
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                id: rightButton
                width: 20
                text: ">"
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 5
                onClicked: {
                    calendar.currentMonth += 1; // Next month
                    if (calendar.currentMonth > 11) {
                        calendar.currentMonth = 0; // Go to January
                        calendar.currentYear += 1; // Increase year
                    }
                    calendar.selectedDay = Math.min(calendar.selectedDay, calendar.daysInMonth); // Ensure selected day is valid
                }
            }
        }

        RowLayout {
            height: 20
            anchors.left: parent.left
            anchors.leftMargin: 5
            width: parent.width
            Repeater {
                model: ["日", "一", "二", "三", "四", "五", "六"]
                Text {
                    width: parent.width / 7
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }
        }

        GridLayout {
            id: daysGrid
            columns: 7
            width: parent.width
            columnSpacing: 3
            rowSpacing: 10

            Repeater {
                model: calendar.daysInMonth + calendar.firstDayOfMonth
                delegate: Rectangle {
                    id: itemView
                    width: (parent.width - 50) / 7
                    height: width
                    color: "white"
                    radius: width / 2

                    Text {
                        anchors.centerIn: parent
                        text: model.index >= calendar.firstDayOfMonth ? (model.index - calendar.firstDayOfMonth + 1) : ""
                        color: {
                            var day = model.index - calendar.firstDayOfMonth + 1;
                            var isSelected = (calendar.selectedDay === day
                                              && calendar.selectedYear === calendar.currentYear
                                              && calendar.selectedMonth === calendar.currentMonth);
                            var isPastMax = !calendar.isSelectableMax(day);
                            var isBeforeMin = !calendar.isSelectableMin(day);

                            if (isSelected) {
                                itemView.color = '#026FFE'
                                return "white"
                            } else if (isPastMax || isBeforeMin) {
                                itemView.color = "white"
                                return "#999"
                            } else {
                                itemView.color = "white"
                                return "#222"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var day = model.index - calendar.firstDayOfMonth + 1;
                            if ((model.index >= calendar.firstDayOfMonth) && calendar.isSelectableMin(day) && calendar.isSelectableMax(day)) {
                                calendar.selectedYear = calendar.currentYear;
                                calendar.selectedMonth = calendar.currentMonth;
                                calendar.selectedDay = day;
                                console.log("Selected date:", calendar.currentYear, formatTwoDigits(calendar.currentMonth + 1), formatTwoDigits(calendar.selectedDay));
                                closeCalendar(calendar.currentYear + "-" + formatTwoDigits(calendar.currentMonth + 1) + "-" + formatTwoDigits(calendar.selectedDay));
                            } else if (calendar.selectedDay === day && calendar.selectedMonth === calendar.currentMonth && calendar.selectedYear === calendar.currentYear) {
                                console.log("Clicked on the already selected date:", calendar.currentYear, formatTwoDigits(calendar.currentMonth + 1), formatTwoDigits(calendar.selectedDay));
                                closeCalendar(calendar.currentYear + "-" + formatTwoDigits(calendar.currentMonth + 1) + "-" + formatTwoDigits(calendar.selectedDay));
                            }
                        }
                    }
                }
            }
        }
    }

    // Calculate the number of days in the current month
    function daysInMonthFunc(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    // Calculate the first day of the current month
    function firstDayOfMonthFunc(year, month) {
        return new Date(year, month, 1).getDay();
    }

    function isSelectableMin(day) {
        var currentDate = new Date(currentYear, currentMonth, day).setHours(0, 0, 0, 0);
        var minDate = new Date(minSelectableTimestamp);
        minDate.setHours(0, 0, 0, 0);
        var normalizedMinTimestamp = minDate.getTime();
        return currentDate >= normalizedMinTimestamp;
    }

    function isSelectableMax(day) {
        if (maxSelectableTimestamp < 0) {
            return true; // No max limit set
        }
        var currentDate = new Date(currentYear, currentMonth, day).setHours(0, 0, 0, 0);
        return currentDate <= maxSelectableTimestamp;
    }

    function formatTwoDigits(value) {
        return value < 10 ? "0" + value : value;
    }

    // Bound properties
    property int daysInMonth: daysInMonthFunc(currentYear, currentMonth)
    property int firstDayOfMonth: firstDayOfMonthFunc(currentYear, currentMonth)

    // Month display in Chinese
    property var monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    property string currentMonthDisplay: monthNames[currentMonth]
}
