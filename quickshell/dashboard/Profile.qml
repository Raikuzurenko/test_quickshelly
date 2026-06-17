import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Rectangle {
    property string weatherData: ""
    property string weatherIn3h: ""
    property string bannerImage: ""

    color: "#161616"
    radius: 20
    width: 510
    height: 130
    clip: false

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        z: 10
    }

    RectangularGlow {
        anchors.fill: parent
        glowRadius: 6
        spread: 0.1
        color: "white"
        cornerRadius: parent.radius + glowRadius
        opacity: hoverArea.containsMouse ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Process {
        id: weatherproc
        command: ["bash", "-c", "curl -s 'wttr.in/Gujranwala?format=%C'"]
        running: true
        stdout: SplitParser {
            onRead: data => weatherData = data.trim().toLowerCase()
        }
    }

    Process {
        id: weather3hproc
        command: ["bash", "-c", "while true; do curl -s 'wttr.in/Gujranwala?format=j1' | python3 -c \"import sys,json; data=json.load(sys.stdin); hours=data['weather'][0]['hourly']; from datetime import datetime; current_hour=datetime.now().hour; target=next((h for h in hours if int(h['time'])//100 >= current_hour+3), hours[-1]); pop=int(target['chanceofrain']); mm=float(target['precipMM']); desc=target['weatherDesc'][0]['value'].lower(); print(desc if pop>30 or mm>0.2 else 'clear')\"; sleep 1800; done"]
        running: true
        stdout: SplitParser {
            onRead: data => weatherIn3h = data.trim().toLowerCase()
        }
    }

    Process {
        id: usernameproc
        command: ["whoami"]
        running: true
        stdout: SplitParser {
            onRead: data => username.text = data.trim()
        }
    }

    Process {
        id: uptimeproc
        command: ["uptime", "-p"]
        running: true
        stdout: SplitParser {
            onRead: data => uptime.text = data.trim()
        }
    }

    Process {
        id: osProc
        command: ["bash", "-c", "cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"'"]
        running: true
        stdout: SplitParser {
            onRead: data => os.text = data.trim()
        }
    }

    Process {
        id: bannerProc
        command: ["bash", "-c", "ls ~/.config/quickshell/dashboard/profile_banner/*.{png,jpg,jpeg,gif,webp} 2>/dev/null | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => bannerImage = "file://" + data.trim()
        }
    }

    Image {
        x: 415
        y: 30
        width: 90
        height: 75
        fillMode: Image.PreserveAspectCrop
        source: bannerImage
        opacity: 1
    }

    Image {
        id: pfpImage
        x: 10
        y: 10
        width: 80
        height: 80
        source: username.text ? "file:///home/" + username.text + "/.face" : ""
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: pfpMask
        x: 10
        y: 10
        width: 80
        height: 80
        radius: 1000
        visible: false
    }

    OpacityMask {
        x: 10
        y: 10
        width: 80
        height: 80
        source: pfpImage
        maskSource: pfpMask
    }

    Text {
        id: username
        font.pixelSize: 20
        font.family: UniFont.fontFamily
        color: "white"
        x: 105
        y: 10
    }

    Text {
        id: uptime
        x: 105
        y: 38
        font.pixelSize: 13
        font.family: UniFont.fontFamily
        color: "white"
    }

    Text {
        id: os
        x: 105
        y: 60
        font.pixelSize: 11
        font.family: UniFont.fontFamily
        color: "white"
    }

    Image {
        x: 10000
        y: 6
        width: 43
        height: 43
        fillMode: Image.PreserveAspectFit
        source: {
            if (weatherData.includes("sunny") || weatherData.includes("clear"))
                return "/home/raikuzu/.config/quickshell/dashboard/weather/sunny.png"
                else if (weatherData.includes("rain") || weatherData.includes("drizzle"))
                    return "/home/raikuzu/.config/quickshell/dashboard/weather/rainy.png"
                    else if (weatherData.includes("snow") || weatherData.includes("blizzard"))
                        return "/home/raikuzu/.config/quickshell/dashboard/weather/snowing.png"
                        else if (weatherData.includes("cloud") || weatherData.includes("overcast"))
                            return "/home/raikuzu/.config/quickshell/dashboard/weather/cloudy.png"
                            else
                                return "/home/raikuzu/.config/quickshell/dashboard/weather/sunny.png"
        }
    }

    Image {
        x: 440
        y: 6
        width: 40
        height: 40
        fillMode: Image.PreserveAspectFit
        source: {
            if (weatherIn3h.includes("sunny") || weatherIn3h.includes("clear"))
                return "/home/raikuzu/.config/quickshell/dashboard/weather/sunny.png"
                else if (weatherIn3h.includes("rain") || weatherIn3h.includes("drizzle"))
                    return "/home/raikuzu/.config/quickshell/dashboard/weather/rainy.png"
                    else if (weatherIn3h.includes("snow") || weatherIn3h.includes("blizzard"))
                        return "/home/raikuzu/.config/quickshell/dashboard/weather/snowing.png"
                        else if (weatherIn3h.includes("cloud") || weatherIn3h.includes("overcast"))
                            return "/home/raikuzu/.config/quickshell/dashboard/weather/cloudy.png"
                            else
                                return "/home/raikuzu/.config/quickshell/dashboard/weather/sunny.png"
        }
    }
}
