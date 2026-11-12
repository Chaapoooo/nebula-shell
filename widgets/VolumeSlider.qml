import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "../styles"
import "../core/"

ClippingRectangle {
    id: root
    color: Theme.surfaceContainer
    radius: 16

    readonly property string greyColor: '#6d6b6b'

    border.color: "white"
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Audio.muted || Audio.volume <= 0.1 ? greyColor : Theme.colorOnSurface
        shadowBlur: 0.7
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0

        Behavior on shadowColor {
            ColorAnimation {
                duration: 250
                easing: Easing.OutCubic
            }
        }
    }

    readonly property real maxY: Math.max(0, root.height - sliderDot.height)

    function updateVolume(mouseY) {
        if (root.maxY <= 0)
            return;

        const targetY = mouseY - sliderDot.height / 2;
        const clampedY = Math.max(0, Math.min(root.maxY, targetY));
        const percent = Math.round((1 - clampedY / root.maxY) * 100);

        Audio.setVolume(percent);
    }

    Rectangle {
        id: sliderDotBackground
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sliderDot.top

        topRightRadius: 16
        topLeftRadius: 16

        width: parent.width
        color: Audio.muted || Audio.volume <= 0.0 ? greyColor : Theme.colorOnSurface

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing: Easing.OutCubic
            }
        }
    }

    property var sliderDotIcons: [['', 0], ['', 0.30], ['', 0.50], ['', 0.70]]

    Rectangle {
        id: sliderDot

        width: parent.width
        height: width
        radius: 16
        y: root.maxY * (1 - Audio.volume / 100)

        Behavior on y {
            enabled: !mouseArea.pressed && root.maxY > 0

            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: '#000000'
            shadowBlur: 0.7
            shadowHorizontalOffset: 0
            shadowVerticalOffset: -2
        }

        Text {
            id: sliderDotIcon
            anchors.centerIn: parent
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
            color: Theme.surfaceContainer

            text: {
                if (Audio.muted || Audio.volume === 0)
                    return "";
                if (Audio.volume >= 60)
                    return "";
                if (Audio.volume >= 30)
                    return "";
                return "";
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton)
                updateVolume(mouse.y);
        }

        onPositionChanged: mouse => {
            if (pressed && (pressedButtons & Qt.LeftButton))
                updateVolume(mouse.y);
        }

        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0 ? 5 : -5;
            Audio.setVolume(Audio.volume + step);
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Audio.toggleMute();
        }
    }
}
