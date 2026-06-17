import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Io

Rectangle {
    id: root
    width: 240
    height: 470
    radius: 20
    clip: true
    color: "transparent"
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    Process {
        id: titleProc
        command: ["playerctl", "metadata", "title"]
        running: true
        stdout: SplitParser { onRead: data => title.text = data }
    }

    Process {
        id: artistProc
        command: ["playerctl", "metadata", "artist"]
        running: true
        stdout: SplitParser { onRead: data => artist.text = data }
    }

    Process {
        id: albumProc
        command: ["playerctl", "metadata", "album"]
        running: true
        stdout: SplitParser { onRead: data => album.text = data }
    }

    Process {
        id: artProc
        command: ["playerctl", "metadata", "mpris:artUrl"]
        running: true
        stdout: SplitParser { onRead: data => albumArt.source = data }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            titleProc.running = false; titleProc.running = true
            artistProc.running = false; artistProc.running = true
            albumProc.running = false; albumProc.running = true
            artProc.running = false; artProc.running = true
        }
    }

    Process { id: prevProc;  command: ["playerctl", "previous"];   running: false }
    Process { id: pauseProc; command: ["playerctl", "play-pause"]; running: false }
    Process { id: nextProc;  command: ["playerctl", "next"];       running: false }

    Image {
        id: bgArt
        anchors.fill: parent
        source: albumArt.source
        fillMode: Image.PreserveAspectCrop
    }

    FastBlur {
        anchors.fill: bgArt
        source: bgArt
        radius: 40
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.45
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        z: 0
    }

    Image {
        id: albumArt
        x: 30
        y: 20
        width: 180
        height: 180
        fillMode: Image.PreserveAspectCrop
        opacity: hoverArea.containsMouse ? 1.0 : 0.3
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Text {
        id: title
        x: 20
        y: 210
        width: 200
        color: "white"
        font.pixelSize: 20
        font.bold: true
        font.family: UniFont.fontFamily
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        maximumLineCount: 1
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: artist
        x: 20
        y: 240
        width: 200
        color: "#aaaaaa"
        font.pixelSize: 13
        font.family: UniFont.fontFamily
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        maximumLineCount: 1
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: album
        x: 20
        y: 260
        width: 200
        color: "#888888"
        font.pixelSize: 11
        font.family: UniFont.fontFamily
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        maximumLineCount: 1
        horizontalAlignment: Text.AlignHCenter
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 290
        spacing: 22

        Canvas {
            width: 30
            height: 30
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "white"
                var p = 6
                var shape = ["00001000","00011000","00111100","00011000","00001000"]
                for (var y = 0; y < shape.length; y++)
                    for (var x = 0; x < shape[y].length; x++)
                        if (shape[y][x] === "1")
                            ctx.fillRect(x * p, y * p, p, p)
            }
            MouseArea { anchors.fill: parent; onClicked: prevProc.running = true }
        }

        Canvas {
            id: playPauseCanvas
            width: 30
            height: 30
            property bool playing: true
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "white"
                var px = 3
                if (playing) {
                    ctx.fillRect(4, 0, px * 2, 30)
                    ctx.fillRect(16, 0, px * 2, 30)
                } else {
                    for (var i = 0; i < 15; i++)
                        ctx.fillRect(i, i, px, 30 - i * 2)
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    playPauseCanvas.playing = !playPauseCanvas.playing
                    playPauseCanvas.requestPaint()
                    pauseProc.running = true
                }
            }
        }

        Canvas {
            width: 30
            height: 30
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "white"
                var p = 6
                var shape = ["10000000","11000000","11100000","11000000","10000000"]
                for (var y = 0; y < shape.length; y++)
                    for (var x = 0; x < shape[y].length; x++)
                        if (shape[y][x] === "1")
                            ctx.fillRect(x * p, y * p, p, p)
            }
            MouseArea { anchors.fill: parent; onClicked: nextProc.running = true }
        }
    }
}
