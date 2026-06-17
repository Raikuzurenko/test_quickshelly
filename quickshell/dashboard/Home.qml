import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool shown: false
    property string bgColor: "#161616"

    FileView {
        id: schemeFile
        path: "/home/raikuzu/.cache/wal/colors.json"
        watchChanges: false
        onLoaded: {
            try {
                var json = JSON.parse(text())
                root.bgColor = json.colors.color0
            } catch(e) {}
        }
        Component.onCompleted: schemeFile.reload()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: schemeFile.reload()
    }

    onShownChanged: {
        if (shown) {
            fadeOut.stop()
            content.opacity = 0
            visible = true
            fadeIn.start()
        } else {
            fadeIn.stop()
            fadeOut.start()
        }
    }
    NumberAnimation {
        id: fadeIn
        target: content
        property: "opacity"
        from: content.opacity
        to: 1
        duration: 200
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: fadeOut
        target: content
        property: "opacity"
        from: content.opacity
        to: 0
        duration: 200
        easing.type: Easing.InCubic
        onFinished: {
            root.visible = false
            content.opacity = 0
        }
    }
    Rectangle {
        id: content
        x: 240
        y: root.height - 518 - 500
        width: 800
        height: 500
        color: root.bgColor
        radius: 20
        opacity: 0
        Profile  { x: 20;  y: 20;  width: 510; height: 100 }
        Clock    { x: 20;  y: 140; width: 245; height: 340 }
        Calender { x: 550; y: 20;  width: 230; height: 460 }
        Music    { x: 285; y: 140; width: 245; height: 340 }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.shown = false
        z: -1
    }
    Keys.onEscapePressed: root.shown = false
}
