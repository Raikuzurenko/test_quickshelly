pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: fontLoader.name
    property FontLoader fontLoader: FontLoader {
        source: "/home/raikuzu/.config/quickshell/fonts/hiro-misake-font/HiroMisakeJapaneseGraffiti-5yG0a.otf"
    }
}
