import QtQuick
import Quickshell.Io
import QtMultimedia

Rectangle {
    id: root
    width: 260
    height: 400
    radius: 20
    color: "transparent"
    clip: true
    layer.enabled: true
    layer.smooth: true

    property int videoX: 0
    property int videoY: 0
    property int videoWidth: 300
    property int videoHeight: 450

    property int battHundredsX: 15
    property int battHundredsY: 7
    property int battTensX: 5
    property int battTensY: 30
    property int battOnesX: 28
    property int battOnesY: 53
    property int totalPixels: 10
    property int pixelSize: 14
    property int pixelGap: 3
    property int cpuFilled: 0
    property int ramFilled: 0
    property int gpuFilled: 0
    property int batteryFilled: 0
    property int batteryPercent: 0
    property string batteryStatus: "Discharging"
    property int battPercentX: 35
    property int battPercentY: 50
    property int batteryPercentOffsetX: 0
    property int batteryPercentOffsetY: 0
    property real upBtnOpacity: 0.4
    property real downBtnOpacity: 0.4

    property var videoFiles: []
    property string currentVideo: ""

    property bool cpuHover: false
    property bool gpuHover: false
    property bool ramHover: false
    property bool battHover: false
    property real hue: 0
    property bool anyHover: cpuHover || gpuHover || ramHover || battHover

    function rainbow(offset) {
        return Qt.hsla((hue + offset) % 1, 1, 0.55, 1)
    }

    NumberAnimation on hue {
        from: 0
        to: 1
        duration: 1000
        loops: Animation.Infinite
        running: anyHover
    }

    function flashUp() {
        root.upBtnOpacity = 1.0
        upTimer.restart()
    }
    function flashDown() {
        root.downBtnOpacity = 1.0
        downTimer.restart()
    }

    Process {
        id: videoListProc
        command: ["bash", "-c", "ls ~/.config/quickshell/launcher/sys_video/*.{mp4,webm,mkv,avi,mov} 2>/dev/null | tr '\n' '|'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var files = data.trim().split("|").filter(f => f.length > 0)
                videoFiles = files
                if (files.length > 0) {
                    currentVideo = "file://" + files[Math.floor(Math.random() * files.length)]
                }
            }
        }
    }

    Video {
        id: bgVideo
        x: root.videoX
        y: -100
        width: root.videoWidth
        height: root.videoHeight
        source: currentVideo
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite
        muted: true
        volume: 0
        z: -2
        opacity: hoverArea.containsMouse ? 1.0 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        onOpacityChanged: {
            if (opacity > 0) play()
                else stop()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#000000"
        opacity: hoverArea.containsMouse ? 0.3 : 0
        z: -1
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        z: 99
    }

    Process {
        id: sysInfoProc
        command: ["bash", "-c", "while true; do cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d. -f1); ram=$(free | awk 'NR==2{printf \"%d\", $3/$2*100}'); echo \"${cpu}|${ram}\"; sleep 2; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var p = data.trim().split("|")
                if (p.length >= 2) {
                    root.cpuFilled = Math.floor(root.totalPixels * parseInt(p[0]) / 100)
                    root.ramFilled = Math.floor(root.totalPixels * parseInt(p[1]) / 100)
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["bash", "-c", "while true; do v=$(timeout 3 intel_gpu_top -l -s 2000 2>/dev/null | awk 'NR==3 {printf \"%d\", $7}'); echo ${v:-0}; sleep 2; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const v = parseInt(data.trim())
                if (!isNaN(v)) {
                    root.gpuFilled = Math.floor(root.totalPixels * Math.min(v,100) / 100)
                }
            }
        }
    }

    Process {
        id: batteryProc
        command: ["bash", "-c", "while true; do if [ -r /sys/class/power_supply/BAT0/capacity ]; then p=$(cat /sys/class/power_supply/BAT0/capacity); s=$(cat /sys/class/power_supply/BAT0/status); else dev=$(upower -e | grep BAT | head -1); p=$(upower -i \"$dev\" | awk '/percentage/{print $2}' | tr -d '%'); s=$(upower -i \"$dev\" | awk '/state/{print $2}'); fi; echo \"$p|$s\"; sleep 5; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var p = data.trim().split("|")
                if (p.length >= 2) {
                    root.batteryPercent = parseInt(p[0]) || 0
                    root.batteryStatus = p[1]
                    root.batteryFilled = Math.min(8, Math.ceil(root.batteryPercent * 8 / 100))
                }
            }
        }
    }

    Timer { id: upTimer; interval: 150; onTriggered: root.upBtnOpacity = 0.4 }
    Timer { id: downTimer; interval: 150; onTriggered: root.downBtnOpacity = 0.4 }

    Column {
        x: 15
        y: -7
        spacing: 8
        z: 1

        Row {
            spacing: 30
            Text {
                text: "CPU"
                color: "#aaaaaa"
                font.family: UniFont.fontFamily
                font.pixelSize: 25
                width: 55
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                width: root.totalPixels*20 + (root.totalPixels-1)*root.pixelGap
                height: 20
                y: 7
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.cpuHover = true
                    onExited: root.cpuHover = false
                }
                Row {
                    spacing: root.pixelGap
                    anchors.fill: parent
                    Repeater {
                        model: root.totalPixels
                        Rectangle {
                            width: 20
                            height: 20
                            color: index < root.cpuFilled ? (root.cpuHover ? rainbow(index*0.08) : "white") : "#161616"
                        }
                    }
                }
            }
        }

        Row {
            spacing: 30
            Text {
                text: "GPU"
                color: "#aaaaaa"
                font.family: UniFont.fontFamily
                font.pixelSize: 25
                width: 55
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                width: root.totalPixels*20 + (root.totalPixels-1)*root.pixelGap
                height: 20
                y: 7
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.gpuHover = true
                    onExited: root.gpuHover = false
                }
                Row {
                    spacing: root.pixelGap
                    anchors.fill: parent
                    Repeater {
                        model: root.totalPixels
                        Rectangle {
                            width: 20
                            height: 20
                            color: index < root.gpuFilled ? (root.gpuHover ? rainbow(index*0.08) : "white") : "#161616"
                        }
                    }
                }
            }
        }

        Row {
            spacing: 30
            Text {
                text: "RAM"
                color: "#aaaaaa"
                font.family: UniFont.fontFamily
                font.pixelSize: 25
                width: 55
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                width: root.totalPixels*20 + (root.totalPixels-1)*root.pixelGap
                height: 20
                y: 7
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.ramHover = true
                    onExited: root.ramHover = false
                }
                Row {
                    spacing: root.pixelGap
                    anchors.fill: parent
                    Repeater {
                        model: root.totalPixels
                        Rectangle {
                            width: 20
                            height: 20
                            color: index < root.ramFilled ? (root.ramHover ? rainbow(index*0.08) : "white") : "#161616"
                        }
                    }
                }
            }
        }
    }

    Item {
        x: 358
        y: 4
        width: 43
        height: 150
        z: 1

        Rectangle { x: 15; y: 0; width: 12; height: 4; color: "#aaaaaa"; radius: 1 }
        Rectangle { x: 0; y: 7; width: 43; height: 89; color: "#161616"; radius: 3; z: -1 }

        Row {
            id: battGrid
            y: 7
            spacing: root.pixelGap
            Column {
                spacing: root.pixelGap
                Repeater {
                    model: 4
                    Rectangle {
                        width: 20
                        height: 20
                        color: {
                            var r = 3 - index
                            var n = r*2 + 1
                            if (root.batteryFilled >= n) {
                                return root.battHover ? rainbow(n*0.12) : (root.batteryStatus === "Charging" ? "#00ff88" : "white")
                            }
                            return "transparent"
                        }
                    }
                }
            }
            Column {
                spacing: root.pixelGap
                Repeater {
                    model: 4
                    Rectangle {
                        width: 20
                        height: 20
                        color: {
                            var r = 3 - index
                            var n = r*2 + 2
                            if (root.batteryFilled >= n) {
                                return root.battHover ? rainbow(n*0.12) : (root.batteryStatus === "Charging" ? "#00ff88" : "white")
                            }
                            return "transparent"
                        }
                    }
                }
            }
        }

        MouseArea {
            x: battGrid.x
            y: battGrid.y
            width: battGrid.width
            height: battGrid.height
            hoverEnabled: true
            onEntered: root.battHover = true
            onExited: root.battHover = false
        }

        Text { x: 27; y: 6; visible: root.batteryPercent >= 100; text: Math.floor(root.batteryPercent / 100); color: "white"; font.family: UniFont.fontFamily; font.pixelSize: 16 }
        Text { x: battGrid.x + root.battTensX; y: 28; visible: root.batteryPercent >= 10; text: Math.floor((root.batteryPercent % 100) / 10); color: "#000000"; font.family: UniFont.fontFamily; font.pixelSize: 16 }
        Text { x: 26; y: 51; text: root.batteryPercent % 10; color: "#000000"; font.family: UniFont.fontFamily; font.pixelSize: 16 }
        Text { y: battGrid.y + battGrid.height + 8; anchors.horizontalCenter: battGrid.horizontalCenter; text: "BAT"; color: "#000000"; font.family: UniFont.fontFamily; font.pixelSize: 12 }
        Text { x: 5; y: 79; text: "%"; color: "#000000"; font.family: UniFont.fontFamily; font.pixelSize: 12 }
    }

    Image {
        id: upCanvas
        x: root.width - 50
        y: 8
        width: 40
        height: 40
        source: "button_icon/top.png"
        fillMode: Image.PreserveAspectFit
        opacity: root.upBtnOpacity
        z: 1
        Behavior on opacity { NumberAnimation { duration: 150 } }
        MouseArea { anchors.fill: parent; onClicked: root.flashUp() }
    }

    Image {
        id: downCanvas
        x: root.width - 50
        y: 50
        width: 40
        height: 40
        source: "button_icon/down.png"
        fillMode: Image.PreserveAspectFit
        opacity: root.downBtnOpacity
        z: 1
        Behavior on opacity { NumberAnimation { duration: 150 } }
        MouseArea { anchors.fill: parent; onClicked: root.flashDown() }
    }
}
