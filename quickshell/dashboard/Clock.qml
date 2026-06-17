import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    color: "#161616"
    radius: 20
    width: 245
    height: 340
    clip: true
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }
    property bool colonVisible: true
    property var pixelArtFiles: []
    property string currentArt: ""

    Process {
        id: listProc
        command: ["bash", "-c", "ls ~/.config/quickshell/dashboard/clock_pics/*.{png,jpg,jpeg,gif} 2>/dev/null | tr '\n' '|'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var files = data.trim().split("|").filter(f => f.length > 0)
                pixelArtFiles = files
                if (files.length > 0)
                    currentArt = "file://" + files[Math.floor(Math.random() * files.length)]
            }
        }
    }

    Timer {
        interval: 1800000
        repeat: true
        running: true
        onTriggered: {
            if (pixelArtFiles.length > 0)
                currentArt = "file://" + pixelArtFiles[Math.floor(Math.random() * pixelArtFiles.length)]
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: currentArt
        opacity: 0.8
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: hoverArea.containsMouse ? 0 : 0.4
        radius: 20
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: colonVisible = !colonVisible
    }

    Row {
        id: timeRow
        anchors.horizontalCenter: parent.horizontalCenter
        y: 225
        Text {
            id: hours
            font.family: UniFont.fontFamily
            font.pixelSize: 40
            color: "white"
        }
        Text {
            id: colon
            text: ":"
            font.family: UniFont.fontFamily
            font.pixelSize: 40
            color: colonVisible ? "white" : "#161616"
        }
        Text {
            id: minutes
            font.family: UniFont.fontFamily
            font.pixelSize: 40
            color: "white"
        }
        Text {
            id: ampm
            font.family: UniFont.fontFamily
            font.pixelSize: 20
            color: "white"
            leftPadding: 6
            topPadding: 18
        }
    }

    Text {
        id: dateText
        anchors.horizontalCenter: parent.horizontalCenter
        y: timeRow.y + timeRow.height + 5
        font.family: UniFont.fontFamily
        font.pixelSize: 20
        color: "#aaaaaa"
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var h = now.getHours()
            var isPM = h >= 12
            h = h % 12
            if (h === 0) h = 12
                hours.text = String(h).padStart(2, "0")
                minutes.text = String(now.getMinutes()).padStart(2, "0")
                ampm.text = isPM ? "PM" : "AM"
                var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                dateText.text = days[now.getDay()]
        }
    }
}
