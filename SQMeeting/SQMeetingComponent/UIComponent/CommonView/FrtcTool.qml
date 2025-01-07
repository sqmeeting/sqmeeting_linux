pragma Singleton
import QtQuick
import SDKUserDefaultObject 1.0
import com.frtc.FrtcApiManager 1.0

QtObject {

    property var  rootWindow: null
    property bool isMeetingIn: false

    signal refreshHomeMeetingList()
    signal refreshHistoryList()
    signal refreshMainWindow(bool login)
    signal hideMainWindow(bool hide)
    signal closeSettingView()

    function log(message) {
        FrtcApiManager.log(message)
    }

    function cancleUserInfo() {
        SDKUserDefaultObject.onQmlSaveUserInfo({})
        SDKUserDefaultObject.onQmlSaveUserToken("")
        SDKUserDefaultObject.onQmlSaveLoginState(false)
    }

    // 保存单个字典到数组中
    function saveMeetigfData(dictionary) {
        fileManager.saveMeetingData(dictionary)
    }

    // 读取所有数据
    function loadMeetigData() {
        let data = fileManager.loadMeetingData();
        return data
    }

    // 根据开始时间删除历史会议，默认为删除指定的会议；如果 deleteAll 为 true，则删除全部数据
    function deleteDataByMeetingStartTime(meetingStartTime, deleteAll = false) {
        fileManager.deleteDataByMeetingStartTime(meetingStartTime,deleteAll)
    }

    function formatTimestamp(ts, format = "yyyy-MM-dd HH:mm", alwaysShowFullDate = false) {
        var date = new Date(ts);

        var year = date.getFullYear();
        var month = ("0" + (date.getMonth() + 1)).slice(-2);
        var day = ("0" + date.getDate()).slice(-2);
        var hours = ("0" + date.getHours()).slice(-2);
        var minutes = ("0" + date.getMinutes()).slice(-2);
        //var seconds = ("0" + date.getSeconds()).slice(-2);

        if (isToday(ts) && !alwaysShowFullDate) {
            format = format.replace("yyyy-", '');
            format = format.replace("MM-", '');
            format = format.replace("dd", '');
            format = format.replace(" ", '');
            format = format.replace("HH", hours);
            format = format.replace("mm", minutes);
        }else{
            format = format.replace("yyyy", year);
            format = format.replace("MM", month);
            format = format.replace("dd", day);
            format = format.replace("HH", hours);
            format = format.replace("mm", minutes);
            //format = format.replace("ss", seconds);
        }

        return format;
    }

    function isToday(ts) {

        var date = new Date(ts);
        var now = new Date();

        return date.getFullYear() === now.getFullYear() &&
                date.getMonth() === now.getMonth() &&
                date.getDate() === now.getDate();
    }

    function calculateTimeDifference(timestamp1, timestamp2) {

        let timeDifference = Math.abs(timestamp2 - timestamp1);
        let hours = Math.floor(timeDifference / (1000 * 60 * 60));
        let minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));

        if (hours !== 0 && minutes !== 0) {
            return hours + qsTr('小时') + minutes + qsTr('分钟')
        }else if (hours === 0 && minutes !== 0) {
            return minutes + qsTr('分钟')
        }else if (hours !== 0 && minutes === 0) {
            return hours + qsTr('小时')
        }else {
            return ''
        }
    }

    function calculateTimeDifferenceMinutes(timestamp) {
        var now = new Date();
        var inputTime = new Date(timestamp);

        let timeDifference = inputTime - now;

        // 如果当前时间大于传入时间，返回 -1
        if (timeDifference < 0) {
            return -1;
        }

        let hours = Math.floor(timeDifference / (1000 * 60 * 60));
        let minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));
        return hours * 60 + minutes;
    }


    function compareOneDay(timeStamp1, timeStamp2) {
        var date1 = new Date(parseInt(timeStamp1, 10));
        var date2 = new Date(parseInt(timeStamp2, 10));

        if (date1 > date2) {
            return 1;
        } else if (date1 < date2) {
            return -1;
        } else {
            return 0;
        }
    }

    function getMeetingDetailData(json) {

        let meetingSchedules = json.meeting_schedules;

        for (let i = 0 ; i < meetingSchedules.length ; i ++ ) {
            let item = meetingSchedules[i];
            item.start_time = FrtcTool.formatTimestamp(item.schedule_start_time)
            item.end_time   = FrtcTool.formatTimestamp(item.schedule_end_time)
            //会议时长
            item.meeting_duration  = FrtcTool.calculateTimeDifference(item.schedule_start_time,item.schedule_end_time)
            //会议状态
            let minutes = FrtcTool.calculateTimeDifferenceMinutes(item.schedule_start_time)
            console.log("预约会议的个数 minutes : " , minutes);
            item.meeting_statusStr =  (minutes >= 0 && minutes <= 15) ? qsTr('即将开始') : ''
            item.meeting_statusStrColor = 'red'
            if (!item.meeting_statusStr) {
                var milliseconds = new Date().getTime();
                let statrResult =  FrtcTool.compareOneDay(milliseconds,item.schedule_start_time)
                let endResult   =  FrtcTool.compareOneDay(milliseconds,item.schedule_end_time)
                item.meeting_statusStr = (statrResult === 1 && endResult === -1) ? qsTr('已开始') : ''
                item.meeting_statusStrColor = 'green'
            }
            //会议权限
            let user_id  =  SDKUserDefaultObject.getUserInfo().user_id
            item.yourSelf = (user_id === item.owner_id)
            item.joinYourself = false
            if (!item.yourSelf && !(item.participantUsers.indexOf(user_id) !== -1)) {
                item.joinYourself = true
            }
            //周期会议
            item.isRecurrence = (item.meeting_type ===  'recurrence') ? true : false

            if (item.isRecurrence) {
                if (item.recurrence_type === "DAILY") {
                    item.recurrenceInterval_result = FrtcTool.everyNumberDays(item.recurrenceInterval);
                }else if (item.recurrence_type === "WEEKLY") {
                    item.recurrenceInterval_result = FrtcTool.everyNumberWeeks(item.recurrenceInterval);
                }else if (item.recurrence_type === "MONTHLY"){
                    item.recurrenceInterval_result = FrtcTool.everyNumberMonths(item.recurrenceInterval);
                }
            }
        }

        return meetingSchedules
    }

    //获取日期是周几
    function getDayOfWeek(dateString) {
        var daysOfWeek = [qsTr("周日"), qsTr("周一"), qsTr("周二"), qsTr("周三"), qsTr("周四"), qsTr("周五"), qsTr("周六")];
        var date = dateString ? new Date(dateString) : new Date();
        var dayOfWeek = daysOfWeek[date.getDay()];
        return dayOfWeek;
    }

    //返回传入时间半小时后的时间
    function getHalfHourLater(timeString) {
        var parts = timeString.split(":");
        var hours = parseInt(parts[0], 10);
        var minutes = parseInt(parts[1], 10);

        // 增加 30 分钟
        minutes += 30;
        if (minutes >= 60) {
            minutes -= 60;
            hours = (hours + 1) % 24;  // 超过 23 小时后回到 0 点
        }

        var formattedHours = String(hours).padStart(2, '0');
        var formattedMinutes = String(minutes).padStart(2, '0');
        return formattedHours + ":" + formattedMinutes;
    }

    //把传入的时间转换成时间戳(RW rel week)
    function dateToTimestampRW(dateString) {
        // 去掉中文字符（"周五"）
        var datePart = dateString.split(" ")[0]; // 只取日期部分，例如 "2024-11-08"
        var date = new Date(datePart + "T00:00:00");
        // 转换成时间戳并返回（以毫秒秒为单位）
        return Math.floor(date.getTime());
    }

    function add24Hours(timestamp) {
        // 24小时的毫秒数
        var millisecondsIn24Hours = 24 * 60 * 60 * 1000;
        var newTimestamp = timestamp + millisecondsIn24Hours;
        return newTimestamp;
    }

    //把字符串转换成时间戳 yyyy-MM-dd week HH:mm
    function dateStringToTimestampYMDWHM(dateString) {
        var parts = dateString.split(" ");
        if (parts.length < 3) {
            console.error("日期格式不正确");
            return -1;
        }
        var datePart = parts[0];  // 例如 "2024-11-10"
        var timePart = parts[2];  // 例如 "20:40"
        var dateTimeString = datePart + "T" + timePart + ":00";
        var date = new Date(dateTimeString);
        return date.getTime();
    }

    // 定义函数，用于比较两个时间戳
    function compareTimestamps(timestamp1, timestamp2) {
        if (timestamp1 > timestamp2) {
            return 1;  // timestamp1 大于 timestamp2
        } else if (timestamp1 < timestamp2) {
            return -1; // timestamp1 小于 timestamp2
        } else {
            return 0;  // timestamp1 等于 timestamp2
        }
    }

    //根据时间戳获取  YYYY-MM-DD Week 默认当前日期
    function formatDateYMDW(timestamp) {
        var daysOfWeek = [qsTr("周日"), qsTr("周一"), qsTr("周二"), qsTr("周三"), qsTr("周四"), qsTr("周五"), qsTr("周六")];
        var date = timestamp ? new Date(timestamp) : new Date();
        var year = date.getFullYear();
        var month = String(date.getMonth() + 1).padStart(2, '0');
        var day = String(date.getDate()).padStart(2, '0');
        var dayOfWeek = daysOfWeek[date.getDay()];
        return year + "-" + month + "-" + day + " " + dayOfWeek;
    }

    /**
      获取第N个周期的时间
      startDate: 开始时间
      periodType: day,week,month
      periodLength:  每 n (天、周、日) 一个周期 周期长度
      numPeriods:  一共几个周期(默认7个) 周期数
    */
    function calculateEndDate(startDate, periodType, periodLength, numPeriods = 6) {
        var start = new Date(startDate); // 将 startDate 转换为 Date 对象
        var endDate = new Date(start);

        if (periodType === "day") {
            // 按天计算
            endDate.setDate(start.getDate() + periodLength * numPeriods);
        } else if (periodType === "week") {
            // 按周计算，每周有7天
            endDate.setDate(start.getDate() + (periodLength * 7) * numPeriods);
        } else if (periodType === "month") {
            // 按月计算
            endDate.setMonth(start.getMonth() + periodLength * numPeriods);
        } else {
            console.log("Invalid period type. Must be 'day', 'week', or 'month'.");
            return null;
        }

        // 算出月末或者周末的时间
        if (periodType === "week") {
            // 调整为当前周的周末 (星期日)
            var dayOfWeek = endDate.getDay(); // 获取当前是星期几（0表示星期日，6表示星期六）
            var daysToSunday = 7 - dayOfWeek; // 计算到周末（星期日）还有多少天
            endDate.setDate(endDate.getDate() + daysToSunday);
        } else if (periodType === "month") {
            // 调整为当前月的月末
            var nextMonth = new Date(endDate);
            nextMonth.setMonth(endDate.getMonth() + 1);
            nextMonth.setDate(0); // 设置为下个月的第0天即为当前月的最后一天
            endDate = nextMonth;

            // 设置为月末的最后一秒
            endDate.setHours(23);
            endDate.setMinutes(59);
            endDate.setSeconds(59);
        }

        // 如果结束日期超过了 startDate 的 365 天，将结束日期调整为不超过 365 天的日期
        var maxEndDate = new Date(start);
        maxEndDate.setDate(start.getDate() + 365);
        if (endDate > maxEndDate) {
            endDate = maxEndDate;
        }

        //返回毫秒时间戳
        return endDate.getTime();
    }

    //周数据转换成后台数据 周一 -> 2
    function convertToNumber(chineseWeekday) {
        var resultWeeks = [];
        for (var i = 0; i < chineseWeekday.length; i++) {
            var item = chineseWeekday[i];
            if (item === qsTr("日")) {
                resultWeeks.push(1);
            } else if (item === qsTr("一")) {
                resultWeeks.push(2);
            } else if (item === qsTr("二")) {
                resultWeeks.push(3);
            } else if (item === qsTr("三")) {
                resultWeeks.push(4);
            } else if (item === qsTr("四")) {
                resultWeeks.push(5);
            } else if (item === qsTr("五")) {
                resultWeeks.push(6);
            } else if (item === qsTr("六")) {
                resultWeeks.push(7);
            }
        }
        return resultWeeks;
    }

    //后台数据转换成周数据 2 -> 周一
    function convertToChineseWeekday(numberday) {
        var resultWeeks = [];
        for (var i = 0; i < numberday.length; i++) {
            var item = numberday[i];
            if (item === 1) {
                resultWeeks.push(qsTr("日"));
            } else if (item === 2) {
                resultWeeks.push(qsTr("一"));
            } else if (item === 3) {
                resultWeeks.push(qsTr("二"));
            } else if (item === 4) {
                resultWeeks.push(qsTr("三"));
            } else if (item === 5) {
                resultWeeks.push(qsTr("四"));
            } else if (item === 6) {
                resultWeeks.push(qsTr("五"));
            } else if (item === 7) {
                resultWeeks.push(qsTr("六"));
            }
        }
        return resultWeeks;
    }


    /**
     * 会议将于每x周(周一，周二)重复
     */
    function weekRecurrenceDate(resultList) {
        var weekResult = ""

        for (var i = 0; i < resultList.length; i++) {
            var item = resultList[i];
            if (i === resultList.length - 1) {
                weekResult += qsTr("周") + item;
            } else {
                weekResult += qsTr("周") + item + "、";
            }
        }

        return weekResult;
    }


    /**
     * 会议将于每x月(1日，2日)重复
     */
    function monthRecurrenceDate(resultList) {
        var monthResult = ""

        resultList.sort(function(a, b) {
            return a - b;
        });

        for (var i = 0; i < resultList.length; i++) {
            var item = resultList[i];
            if (i === resultList.length - 1) {
                monthResult += item + qsTr("日");
            } else {
                monthResult += item + qsTr("日") + "、";
            }
        }

        return monthResult;
    }

    function everyNumberDays(days) {
        if (days === 1) {
            return qsTr("每天");
        } else {
            return qsTr("每") + days + qsTr("天");
        }
    }

    function everyNumberWeeks(weeks) {
        if (weeks === 1) {
            return qsTr("每周");
        } else {
            return qsTr("每") + weeks + qsTr("周");
        }
    }

    function everyNumberMonths(months) {
        if (months === 1) {
            return qsTr("每月");
        } else {
            return qsTr("每") + months + qsTr("月");
        }
    }

    //获取下一天的开始时间
    function getNextDayOrQuarterHour(timestamp) {

        var now = new Date();
        var date = new Date(timestamp);

        if (date.toDateString() === now.toDateString()) {
            // Round up to the nearest quarter-hour (00, 15, 30, 45)
            var minutes = now.getMinutes();
            var roundedMinutes = Math.ceil(minutes / 15) * 15;
            if (roundedMinutes === 60) {
                roundedMinutes = 0;
                now.setHours(now.getHours() + 1);
            }
            now.setMinutes(roundedMinutes);
            now.setSeconds(0);
            now.setMilliseconds(0);
            return now.getTime();
        } else {
            date.setDate(date.getDate() + 1);
            date.setHours(0, 0, 0, 0);
            return date.getTime();
        }
    }

    //获取下一天的开始时间
    function getPreviousDayOrQuarterHour(timestamp) {
        var now = new Date();
        var date = new Date(timestamp);

        // If the provided date is the same as today
        if (date.toDateString() === now.toDateString()) {
            // Round up to the nearest quarter-hour (00, 15, 30, 45)
            var minutes = now.getMinutes();
            var roundedMinutes = Math.ceil(minutes / 15) * 15;
            if (roundedMinutes === 60) {
                roundedMinutes = 0;
                now.setHours(now.getHours() + 1);
            }
            now.setMinutes(roundedMinutes);
            now.setSeconds(0);
            now.setMilliseconds(0);
            return now.getTime();
        } else {
            // Move to the previous day and set to the end of the day
            date.setDate(date.getDate() - 1);
            date.setHours(23, 59, 59, 999);
            return date.getTime();
        }
    }

    //判断两个时间戳是否是同一天
    function isSameDay(timestamp1, timestamp2) {
        var date1 = new Date(timestamp1);
        var date2 = new Date(timestamp2);

        return date1.getFullYear() === date2.getFullYear() &&
                date1.getMonth() === date2.getMonth() &&
                date1.getDate() === date2.getDate();
    }

    // 获取指定时间或当前时间的 HH:MM，默认分钟四舍五入到下一个 15 分钟
    function getCurrentTimeHM(timestamp = new Date().getTime(), noRound = false) {

    var date = new Date(timestamp);
    var hours = date.getHours();
    var minutes = date.getMinutes();

    // 如果 noRound 为 true，直接返回时间戳对应的时间
    if (noRound) {
        var formattedHours = String(hours).padStart(2, '0');
        var formattedMinutes = String(minutes).padStart(2, '0');
        return formattedHours + ":" + formattedMinutes;
    }

    // 将分钟四舍五入到下一个 15 分钟
    if (minutes > 0 && minutes <= 15) {
        minutes = 15;
    } else if (minutes > 15 && minutes <= 30) {
        minutes = 30;
    } else if (minutes > 30 && minutes <= 45) {
        minutes = 45;
    } else {
        minutes = 0;
        hours = (hours + 1) % 24; // 如果超过 45 分钟，将小时加 1，并对 24 取模
    }

    var formattedHours1 = String(hours).padStart(2, '0');
    var formattedMinutes1 = String(minutes).padStart(2, '0');
    return formattedHours1 + ":" + formattedMinutes1;
}

}
