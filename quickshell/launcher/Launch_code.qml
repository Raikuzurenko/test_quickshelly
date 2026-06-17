import QtQuick
import Quickshell.Io
import QtQuick.Effects
import QtMultimedia

FocusScope {
    id: root
    focus: true

    property int videoLeftX: 0
    property int videoLeftY: 0
    property int videoLeftWidth: 600
    property int videoLeftHeight: 500
    property var videoLeftFiles: []
    property string currentLeftVideo: ""

    property int videoRightX: 0
    property int videoRightY: 0
    property int videoRightWidth: 550
    property int videoRightHeight: 350
    property var videoRightFiles: []
    property string currentRightVideo: ""

    property var sysInfoRef: null
    property real upBtnOpacity: 0.4
    property real downBtnOpacity: 0.4
    property var allApps: []
    property string searchText: ""
    property int selectedIndex: 0
    property string cpuUsage: "0"
    property string ramUsage: "0"
    property int pixelIconSize: 16
    property bool iconHover: false
    property bool isFileSearch: searchText.startsWith("/")
    property var fileResults: []
    property var filteredApps: isFileSearch ? fileResults : (searchText.length > 0 ? allApps.filter(a => a.name.toLowerCase().includes(searchText.toLowerCase())) : allApps)

    function resetLauncher() {
        searchInput.text = ""
        searchText = ""
        fileResults = []
        selectedIndex = 0
        searchInput.forceActiveFocus()
    }

    Component.onCompleted: resetLauncher()

    Process {
        id: videoLeftListProc
        command: ["bash", "-c", "ls ~/.config/quickshell/launcher/launch_left/*.{mp4,webm,mkv,avi,mov} 2>/dev/null | tr '\n' '|'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var files = data.trim().split("|").filter(f => f.length > 0)
                videoLeftFiles = files
                if (files.length > 0) currentLeftVideo = "file://" + files[Math.floor(Math.random() * files.length)]
            }
        }
    }

    Process {
        id: videoRightListProc
        command: ["bash", "-c", "ls ~/.config/quickshell/launcher/launch_right/*.{mp4,webm,mkv,avi,mov} 2>/dev/null | tr '\n' '|'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var files = data.trim().split("|").filter(f => f.length > 0)
                videoRightFiles = files
                if (files.length > 0) currentRightVideo = "file://" + files[Math.floor(Math.random() * files.length)]
            }
        }
    }

    MouseArea {
        id: hoverAreaLeft
        x: 0; y: 90; width: parent.width * 0.5; height: 440
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        z: 99
    }

    MouseArea {
        id: hoverAreaRight
        x: 500; y: 90; width: parent.width * 0.5 - 10; height: 300
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        z: 99
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.angleDelta.y > 0) {
                if (filteredApps.length > 0) {
                    selectedIndex = Math.max(0, selectedIndex - 1)
                    if (sysInfoRef) sysInfoRef.flashUp()
                }
            } else {
                if (filteredApps.length > 0) {
                    selectedIndex = Math.min(filteredApps.length - 1, selectedIndex + 1)
                    if (sysInfoRef) sysInfoRef.flashDown()
                }
            }
            event.accepted = true
        }
    }

    function launchApp(app) {
        if (isFileSearch) {
            var safePath = app.path.replace(/"/g, '\\"')
            launchProc.command = ["bash", "-c", "p=\"" + safePath + "\"; if [ -d \"$p\" ]; then xdg-open \"$p\"; else if command -v dolphin >/dev/null; then dolphin --select \"$p\"; elif command -v nautilus >/dev/null; then nautilus --select \"$p\"; else xdg-open \"$(dirname \"$p\")\"; fi; fi &"]
            launchProc.running = true
        } else {
            countProc.command = ["bash", "-c", "echo '" + app.name + "' >> ~/.config/quickshell/launcher/launch_counts"]
            countProc.running = true
            launchProc.command = ["bash", "-c", app.exec + " &"]
            launchProc.running = true
        }
        resetLauncher()
    }

    Process {
        id: appProc
        command: ["bash", "-c", "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do [ -f \"$f\" ] || continue; nodisplay=$(grep -i '^NoDisplay=true' \"$f\"); [ -n \"$nodisplay\" ] && continue; name=$(grep '^Name=' \"$f\" | head -1 | cut -d= -f2-); icon=$(grep '^Icon=' \"$f\" | head -1 | cut -d= -f2-); exec=$(grep '^Exec=' \"$f\" | head -1 | cut -d= -f2- | sed 's/ %[fFuUdDnNickvm]//g'); [ -z \"$name\" ] || [ -z \"$exec\" ] && continue; if [ -f \"$icon\" ]; then iconpath=\"$icon\"; else iconpath=$(find $HOME/.local/share/icons /usr/share/icons/hicolor/48x48/apps /usr/share/icons/hicolor/32x32/apps /usr/share/pixmaps $HOME/.local/share/steam $HOME/.steam -type f \\( -name \"${icon}.png\" -o -name \"${icon}.svg\" -o -name \"${icon}.*\" \\) 2>/dev/null | head -1); fi; count=$(grep -c \"^$name$\" ~/.config/quickshell/launch_counts 2>/dev/null || echo 0); echo \"$count|$name|$iconpath|$exec\"; done | sort -rn | sed 's/^[0-9]*|//'"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var line = data.trim()
                if (!line) return
                    var parts = line.split("|")
                    if (parts.length >= 3 && parts[0] && parts[2]) {
                        var newApps = allApps.slice()
                        newApps.push({ name: parts[0], icon: parts[1] || "", exec: parts[2] })
                        allApps = newApps
                    }
            }
        }
    }

    Process {
        id: fileSearchProc
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var line = data.trim()
                if (!line) return
                    var name = line.split('/').pop()
                    var icon = ""
                    if (/\.(png|jpg|jpeg|webp|gif|bmp|svg)$/i.test(name)) icon = line
                        fileResults.push({ name: name, path: line, icon: icon, exec: "" })
                        fileResults = fileResults.slice()
            }
        }
    }

    Process { id: launchProc; running: false }
    Process { id: countProc; running: false }

    Process {
        id: sysInfoProc
        command: ["bash", "-c", "while true; do cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d. -f1); ram=$(free | awk 'NR==2{printf \"%d\", $3/$2*100}'); echo \"${cpu}|${ram}\"; sleep 2; done"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => { var p = data.trim().split("|"); if (p.length >= 2) { cpuUsage = p[0]; ramUsage = p[1] } }
        }
    }

    Rectangle {
        id: leftPanel
        x: 0; y: 90; width: parent.width * 0.5; height: 440
        color: "transparent"; radius: 10; clip: true

        Video {
            id: bgVideoLeft
            x: -50
            y: root.videoLeftY
            width: root.videoLeftWidth
            height: root.videoLeftHeight
            source: currentLeftVideo
            fillMode: VideoOutput.PreserveAspectCrop
            loops: MediaPlayer.Infinite
            muted: true
            volume: 0
            opacity: hoverAreaLeft.containsMouse ? 1.0 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
            onOpacityChanged: { if (opacity > 0) play(); else stop() }
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: hoverAreaLeft.containsMouse ? 0.3 : 0.55
            radius: parent.radius
            z: 3
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Item {
            anchors.centerIn: parent
            width: bgIconSrc.width * 1.4; height: width
            opacity: root.iconHover ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 220 } }
            z: 0
            Image {
                id: glowSrc
                anchors.centerIn: parent
                width: parent.width * 0.7; height: width
                source: bgIconSrc.source
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            MultiEffect {
                anchors.centerIn: parent
                width: glowSrc.width; height: glowSrc.height
                source: glowSrc
                blurEnabled: true; blur: 1.0; blurMax: 80
                saturation: 1.4; brightness: 0.15; opacity: 0.38
            }
        }

        Image {
            id: bgIconSrc
            anchors.centerIn: parent
            width: parent.height * 0.85; height: width
            source: filteredApps[selectedIndex] && filteredApps[selectedIndex].icon ? "file://" + filteredApps[selectedIndex].icon : ""
            fillMode: Image.PreserveAspectFit; visible: false; z: 1
        }

        MultiEffect {
            anchors.centerIn: parent; width: bgIconSrc.width; height: bgIconSrc.height
            source: bgIconSrc; blurEnabled: true; blur: 1.0; blurMax: 80
            opacity: bgIconSrc.source != "" ? 0.35 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            z: 2
        }
    }

    Rectangle {
        id: rightPanel
        x: 500; y: 90; width: parent.width * 0.5 - 10; height: 300
        color: "transparent"; radius: 20; clip: true

        Video {
            id: bgVideoRight
            x: -15
            y: 15
            width: root.videoRightWidth
            height: root.videoRightHeight
            source: currentRightVideo
            fillMode: VideoOutput.PreserveAspectCrop
            loops: MediaPlayer.Infinite
            muted: true
            volume: 0
            opacity: hoverAreaRight.containsMouse ? 1.0 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
            onOpacityChanged: { if (opacity > 0) play(); else stop() }
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: hoverAreaRight.containsMouse ? 0.3 : 0.6
            radius: parent.radius
            z: 1
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Column {
            x: 20; y: 50; spacing: 20; width: parent.width - 40; z: 2
            Text {
                width: parent.width
                text: searchText.length > 0 ? searchText : (isFileSearch ? "/ " : (filteredApps[selectedIndex] ? filteredApps[selectedIndex].name : ""))
                color: searchText.length > 0 ? "#aaaaaa" : "white"
                font.family: UniFont.fontFamily
                font.pixelSize: 50
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }
            Rectangle {
                width: 160; height: 36
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"; radius: 8; visible: filteredApps[selectedIndex] !== undefined
                Text { anchors.centerIn: parent; text: isFileSearch ? "open" : "launch"; color: "transparent"; font.family: UniFont.fontFamily; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; onClicked: if (filteredApps[selectedIndex]) launchApp(filteredApps[selectedIndex]) }
            }
        }
    }

    Item {
        id: listContainer; anchors.fill: leftPanel; clip: true
        property real itemHeight: 56
        Repeater {
            model: filteredApps.length
            Item {
                width: listContainer.width; height: listContainer.itemHeight
                y: 210 - (selectedIndex * listContainer.itemHeight) + (index * listContainer.itemHeight) - listContainer.itemHeight / 2
                Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                scale: index === selectedIndex ? 2.2 : 0.75
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                opacity: index === selectedIndex ? 1.0 : 0.35
                Behavior on opacity { NumberAnimation { duration: 150 } }
                z: index === selectedIndex ? 10 : 0

                Image {
                    width: 36; height: 36; anchors.centerIn: parent
                    source: filteredApps[index] && filteredApps[index].icon ? "file://" + filteredApps[index].icon : ""
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: pixelIconSize; sourceSize.height: pixelIconSize
                    Rectangle {
                        anchors.fill: parent; color: "#333333"; radius: 4; visible: parent.status !== Image.Ready
                        Text { anchors.centerIn: parent; text: filteredApps[index] ? filteredApps[index].name.charAt(0).toUpperCase() : ""; color: "white"; font.family: UniFont.fontFamily; font.pixelSize: 13 }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.iconHover = true
                    onExited: root.iconHover = false
                    onClicked: selectedIndex = index
                    onDoubleClicked: if (filteredApps[index]) launchApp(filteredApps[index])
                }
            }
        }
    }

    TextInput {
        id: searchInput
        anchors.fill: parent; opacity: 0; focus: true
        onTextChanged: {
            searchText = text
            selectedIndex = 0
            if (isFileSearch) {
                fileResults = []
                var q = searchText.slice(1).trim().replace(/'/g, "'\\''")
                if (!q) return
                    fileSearchProc.running = false
                    fileSearchProc.command = ["bash", "-c", "find \"$HOME\" \\( -type f -o -type d \\) -iname '*" + q + "*' 2>/dev/null | head -n 100"]
                    fileSearchProc.running = true
            }
        }
        Keys.onUpPressed: { if (filteredApps.length) { selectedIndex = Math.max(0, selectedIndex - 1); if (sysInfoRef) sysInfoRef.flashUp() } }
        Keys.onDownPressed: { if (filteredApps.length) { selectedIndex = Math.min(filteredApps.length - 1, selectedIndex + 1); if (sysInfoRef) sysInfoRef.flashDown() } }
        Keys.onReturnPressed: { if (filteredApps[selectedIndex]) launchApp(filteredApps[selectedIndex]) }
        Keys.onEscapePressed: resetLauncher()
    }
}
