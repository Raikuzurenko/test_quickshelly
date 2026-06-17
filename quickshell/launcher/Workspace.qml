import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    width: 260
    height: 40
    radius: 20
    color: "#161616"
    clip: true
    layer.enabled: true
    property int activeWs: Hyprland.focusedWorkspace?.id ?? 1
    property bool hovered: false
    property real hue: 0

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    NumberAnimation on hue {
        from: 0; to: 1
        duration: 1000
        loops: Animation.Infinite
        running: root.hovered
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: root.hovered ? 1 : 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.hsla((hue + 0.00) % 1, 1, 0.55, 1) }
            GradientStop { position: 0.2; color: Qt.hsla((hue + 0.20) % 1, 1, 0.55, 1) }
            GradientStop { position: 0.4; color: Qt.hsla((hue + 0.40) % 1, 1, 0.55, 1) }
            GradientStop { position: 0.6; color: Qt.hsla((hue + 0.60) % 1, 1, 0.55, 1) }
            GradientStop { position: 0.8; color: Qt.hsla((hue + 0.80) % 1, 1, 0.55, 1) }
            GradientStop { position: 1.0; color: Qt.hsla((hue + 1.00) % 1, 1, 0.55, 1) }
        }
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 4
        Repeater {
            model: ["1","2","3","4","5","6","7","8","9","0"]
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: wsNum === activeWs ? "#ffffff" : "transparent"
                property int wsNum: modelData === "0" ? 10 : parseInt(modelData)
                Text {
                    anchors.centerIn: parent
                    font.family: UniFont.fontFamily
                    font.pixelSize: 15
                    text: modelData
                    color: wsNum === activeWs ? "#161616" : "white"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + wsNum)
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            activeWs = Hyprland.focusedWorkspace?.id ?? 1
        }
    }
}
