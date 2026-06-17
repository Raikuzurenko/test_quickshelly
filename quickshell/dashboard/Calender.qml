import QtQuick
import QtMultimedia
import Quickshell.Io

Rectangle {
    color: "#000000"
    radius: 20
    clip: true
    layer.enabled: true

    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property int today: new Date().getDate()
    property var videoFiles: []
    property string currentVideo: ""

    Process {
        id: videoListProc
        command: ["bash", "-c", "ls ~/.config/quickshell/dashboard/calender_video/*.{mp4,webm,mkv,avi,mov} 2>/dev/null | tr '\n' '|'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var files = data.trim().split("|").filter(f => f.length > 0)
                videoFiles = files
                if (files.length > 0)
                    currentVideo = "file://" + files[Math.floor(Math.random() * files.length)]
            }
        }
    }

    Video {
        id: bgVideo
        anchors.fill: parent
        source: currentVideo
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite
        volume: 0
        opacity: hoverArea.containsMouse ? 1.0 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        onOpacityChanged: {
            if (opacity > 0) play()
                else stop()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: hoverArea.containsMouse ? 0.3 : 0
        radius: 20
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        z: 10
    }

    Text {
        id: monthLabel
        x: -10
        y: 50
        width: 245
        horizontalAlignment: Text.AlignHCenter
        font.family: UniFont.fontFamily
        font.pixelSize: 30
        color: "white"
        z: 11
        text: {
            var months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
            return months[currentMonth] + " " + currentYear
        }
    }

    Row {
        x: 4
        y: 110
        spacing: 0
        z: 11
        Repeater {
            model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
            Text {
                width: 32
                font.family: UniFont.fontFamily
                font.pixelSize: 15
                color: "#aaaaaa"
                text: modelData
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Grid {
        id: dayGrid
        x: 5
        y: 150
        columns: 7
        spacing: 0
        z: 11
        Repeater {
            model: {
                var firstDay = new Date(currentYear, currentMonth, 1).getDay()
                var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
                return firstDay + daysInMonth
            }
            Rectangle {
                width: 32
                height: 32
                color: {
                    var firstDay = new Date(currentYear, currentMonth, 1).getDay()
                    var day = index - firstDay + 1
                    return (day === today && index >= firstDay) ? "#ffffff" : "transparent"
                }
                radius: 4
                Text {
                    anchors.centerIn: parent
                    font.family: UniFont.fontFamily
                    font.pixelSize: 11
                    color: {
                        var firstDay = new Date(currentYear, currentMonth, 1).getDay()
                        var day = index - firstDay + 1
                        if (day === today && index >= firstDay) return "#161616"
                            return index < firstDay ? "transparent" : "white"
                    }
                    text: {
                        var firstDay = new Date(currentYear, currentMonth, 1).getDay()
                        var day = index - firstDay + 1
                        return index < firstDay ? "" : String(day)
                    }
                }
            }
        }
    }

    Row {
        id: pixelBarRow
        x: 20
        y: 400
        spacing: 2
        z: 11

        property int totalPixels: 20
        property int filledPixels: 0

        Repeater {
            model: pixelBarRow.totalPixels
            Rectangle {
                width: 8
                height: 8
                color: index < pixelBarRow.filledPixels ? "white" : "#333333"
            }
        }
    }

    Text {
        id: timeLeft
        x: -10
        y: 415
        width: 245
        horizontalAlignment: Text.AlignHCenter
        font.family: UniFont.fontFamily
        font.pixelSize: 11
        color: "#aaaaaa"
        z: 11
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var secondsPassedToday = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()
            pixelBarRow.filledPixels = Math.floor(pixelBarRow.totalPixels * (secondsPassedToday / 86400))
            var hoursLeft = 23 - now.getHours()
            var minutesLeft = 59 - now.getMinutes()
            var secondsLeft = 59 - now.getSeconds()
            timeLeft.text = hoursLeft + "h " + minutesLeft + "m " + secondsLeft + "s left"
        }
    }
}
