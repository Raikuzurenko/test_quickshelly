pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: fontLoader.name
    property FontLoader fontLoader: FontLoader {
        source: "/home/raikuzu/.config/quickshell/fonts/Silkscreen-Regular.ttf"
    }
}
