import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    anchors.top: true
    anchors.left: true
    implicitWidth: 3000
    implicitHeight: 3000
    color: "transparent"
    WlrLayershell.layer: editMode ? WlrLayer.Overlay : WlrLayer.Bottom

    property real clockX: 20
    property real clockY: 20
    property real fontSize: 36
    property bool editMode: false
    property string primaryColor: "#c1a053"
    property string outlineColor: "#c5c5c5"

    onEditModeChanged: {
        if (!editMode) saveProc.running = true
    }

    function reloadColors() {
        schemeFile.reload()
    }

    Timer {
        id: pollWal
        interval: 1500
        running: true
        repeat: true
        onTriggered: schemeFile.reload()
    }

    FileView {
        id: schemeFile
        path: "/home/raikuzu/.cache/wal/colors.json"
        watchChanges: false
        onLoaded: {
            try {
                var json = JSON.parse(text())
                root.primaryColor = json.colors.color6
                root.outlineColor = json.colors.color1
            } catch(e) {}
        }
        Component.onCompleted: reloadColors()
    }

    FileView {
        id: configFile
        path: "/home/raikuzu/.config/quickshell/desk_clock.conf"
        onLoaded: {
            var lines = text().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split("=")
                if (parts[0] === "x")        root.clockX   = parseFloat(parts[1])
                    if (parts[0] === "y")        root.clockY   = parseFloat(parts[1])
                        if (parts[0] === "fontSize") root.fontSize = parseFloat(parts[1])
            }
        }
    }

    Process {
        id: saveProc
        command: ["bash", "-c",
        "echo 'x=" + root.clockX +
        "\ny=" + root.clockY +
        "\nfontSize=" + root.fontSize +
        "' > /home/raikuzu/.config/quickshell/desk_clock.conf"
        ]
        running: false
    }

    Rectangle {
        id: handle
        visible: editMode
        x: root.clockX + 412
        y: root.clockY - 8
        width: Math.max(dayText.width, dateText.width, timeText.width) + 16
        height: dayText.height + dateText.height + timeText.height + 20
        color: "transparent"
        border.color: root.primaryColor
        border.width: 1
        radius: 4
    }

    MouseArea {
        x: root.clockX + 412
        y: root.clockY - 8
        width: Math.max(dayText.width, dateText.width, timeText.width) + 16
        height: dayText.height + dateText.height + timeText.height + 20
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        drag.target: editMode ? handle : null
        drag.axis: Drag.XAndYAxis
        onReleased: {
            if (editMode) {
                root.clockX = handle.x - 412
                root.clockY = handle.y + 8
            }
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.editMode = !root.editMode
        }
        onWheel: wheel => {
            if (editMode)
                root.fontSize = Math.max(10, root.fontSize + (wheel.angleDelta.y > 0 ? 2 : -2))
        }
    }

    Text { x: dayText.x - 1; y: dayText.y;     font.pixelSize: 130; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dayText.text }
    Text { x: dayText.x + 1; y: dayText.y;     font.pixelSize: 130; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dayText.text }
    Text { x: dayText.x;     y: dayText.y - 1; font.pixelSize: 130; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dayText.text }
    Text { x: dayText.x;     y: dayText.y + 1; font.pixelSize: 130; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dayText.text }

    Text {
        id: dayText
        x: clockX + 420
        y: clockY
        color: editMode ? "#ffff00" : root.primaryColor
        font.pixelSize: 130
        font.family: UniFont.fontFamily
        font.hintingPreference: Font.PreferFullHinting
        renderType: Text.NativeRendering
        text: Qt.formatDate(new Date(), "dddd")
    }

    Text { x: dateText.x - 1; y: dateText.y;     font.pixelSize: 50; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dateText.text }
    Text { x: dateText.x + 1; y: dateText.y;     font.pixelSize: 50; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dateText.text }
    Text { x: dateText.x;     y: dateText.y - 1; font.pixelSize: 50; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dateText.text }
    Text { x: dateText.x;     y: dateText.y + 1; font.pixelSize: 50; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: dateText.text }

    Text {
        id: dateText
        x: dayText.x + (dayText.width - width) / 2
        y: clockY + dayText.height + 4
        color: editMode ? "#ffff00" : root.primaryColor
        font.pixelSize: 50
        font.family: UniFont.fontFamily
        font.hintingPreference: Font.PreferFullHinting
        renderType: Text.NativeRendering
        text: Qt.formatDate(new Date(), "d/MMMM/yyyy")
    }

    Text { x: timeText.x - 1; y: timeText.y;     font.pixelSize: 40; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: timeText.text }
    Text { x: timeText.x + 1; y: timeText.y;     font.pixelSize: 40; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: timeText.text }
    Text { x: timeText.x;     y: timeText.y - 1; font.pixelSize: 40; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: timeText.text }
    Text { x: timeText.x;     y: timeText.y + 1; font.pixelSize: 40; font.family: UniFont.fontFamily; font.hintingPreference: Font.PreferFullHinting; renderType: Text.NativeRendering; color: root.outlineColor; text: timeText.text }

    Text {
        id: timeText
        x: dayText.x + (dayText.width - width) / 2
        y: clockY + dayText.height + dateText.height + 10
        color: editMode ? "#ffff00" : root.primaryColor
        font.pixelSize: 40
        font.family: UniFont.fontFamily
        font.hintingPreference: Font.PreferFullHinting
        renderType: Text.NativeRendering
        text: Qt.formatTime(new Date(), "h:mm ap")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            dayText.text  = Qt.formatDate(new Date(), "dddd")
            dateText.text = Qt.formatDate(new Date(), "d/MMMM/yyyy")
            timeText.text = Qt.formatTime(new Date(), "h:mm ap")
        }
    }
}
