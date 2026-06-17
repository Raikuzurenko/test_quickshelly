import QtQuick
import Quickshell
import Quickshell.Io
import "."
import "dashboard"
import "launcher"
import "desktop_widgets"

ShellRoot {

    FontLoader {
        id: globalFont
        source: "/home/raikuzu/.config/quickshell/fonts/Silkscreen-Regular.ttf"
    }


    PanelWindow {
        id: toplevel
        anchors.top: true
        implicitHeight: 1
        visible: true
        Desk_clock { id: deskClock }
        Home { id: home }
        Launch { id: launch }
    }

    FileView {
        path: "/tmp/popup_toggle"
        watchChanges: true
        onFileChanged: {
            reload()
            home.shown = !home.shown
            if (home.shown) launch.visible = false
        }
    }

    FileView {
        path: "/tmp/launch_toggle"
        watchChanges: true
        onFileChanged: {
            reload()
            launch.visible = !launch.visible
            if (launch.visible) home.shown = false
        }
    }

    FileView {
        id: walFileView
        path: "/home/raikuzu/.local/state/DankMaterialShell/session.json"
    }

    // poll Dank's session file every 800ms
    Timer {
        id: pollSession
        interval: 800
        repeat: true
        running: true
        onTriggered: {
            walFileView.reload()
            try {
                var wallPath = JSON.parse(walFileView.text()).wallpaperPath
                if (wallPath && wallPath !== walProc.wallpaper) {
                    console.log("[SHELL] wallpaper ->", wallPath)
                    walProc.queueWall = wallPath
                    if (!walProc.running) {
                        walProc.wallpaper = wallPath
                        walProc.running = true
                    }
                }
            } catch(e) {}
        }
    }

    Timer {
        id: colorApplyDelay
        interval: 1200
        repeat: false
        onTriggered: deskClock.reloadColors()
    }

    Process {
        id: walProc
        property string wallpaper: ""
        property string queueWall: ""
        command: ["wal", "-i", wallpaper, "-n", "-q", "--backend", "colorthief"]
        running: false
        onRunningChanged: {
            if (running) console.log("[SHELL] WAL >>>", wallpaper)
                else if (wallpaper) {
                    console.log("[SHELL] WAL done")
                    colorApplyDelay.restart()
                    if (queueWall !== wallpaper) {
                        wallpaper = queueWall
                        running = true
                    }
                }
        }
    }
}
