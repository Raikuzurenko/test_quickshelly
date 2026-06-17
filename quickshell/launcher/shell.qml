import QtQuick
import Quickshell
import Quickshell.Io
import "."
//components
import "dashboard"
ShellRoot {
    PanelWindow {
        id: toplevel
        anchors.top: true
        implicitHeight: 1
        visible: true

        Home {
            id: home
            parentWin: toplevel
        }

        Launch {
            id: launch

        }
    }

    // home toggle
    FileView {
        path: "/tmp/popup_toggle"
        watchChanges: true
        onFileChanged: {
            reload()
            if (home.shown) {
                // home is open, so close it
                home.shown = false
            } else {
                // open home, and make sure launch is closed
                home.shown = true
                launch.visible = false
            }
        }
    }

    // launch toggle
    FileView {
        path: "/tmp/launch_toggle"
        watchChanges: true
        onFileChanged: {
            reload()
            if (launch.visible) {
                launch.visible = false
            } else {
                launch.visible = true
                home.shown = false   // close home if it was open
            }
        }
    }
}
