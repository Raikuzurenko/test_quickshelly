import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    visible: false
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // ─────────────────────────────
    // CONFIG: Launch_code geometry
    // ─────────────────────────────
    property real launchX: 0
    property real launchY: 0
    property real launchW: 1000
    property real launchH: 600

    // ─────────────────────────────
    // CONFIG: Sys_info geometry
    // ─────────────────────────────
    property real sysX: 20
    property real sysY: 20
    property real sysW: 300
    property real sysH: 200

    onVisibleChanged: launchCode.resetLauncher()

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (!root.visible) return
                if (event.angleDelta.y > 0) {
                    if (launchCode.filteredApps.length > 0) {
                        launchCode.selectedIndex = Math.max(0, launchCode.selectedIndex - 1)
                        if (sysInfo) sysInfo.flashUp()
                    }
                } else if (event.angleDelta.y < 0) {
                    if (launchCode.filteredApps.length > 0) {
                        launchCode.selectedIndex = Math.min(launchCode.filteredApps.length - 1, launchCode.selectedIndex + 1)
                        if (sysInfo) sysInfo.flashDown()
                    }
                }
        }
    }

    Rectangle {
        x: 150
        y: 300
        width: 1000
        height: 440
        color: "#000000"
        radius: 20

        Launch_code {
            id: launchCode
            sysInfoRef: sysInfo
            x: root.launchX
            y: -90
            width: root.launchW
            height: root.launchH
        }

        Workspace {
            id: ws
            x: 600
            y: 230
            width: 300
            height: 30
        }

        Sys_info {
            id: sysInfo
            x: 510
            y: 320
            width: 480
            height: 100
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
        z: -1
    }
}
