import QtQuick
import QtQuick.Effects
import Quickshell.Widgets

import "../styles"
import "../core"

ClippingRectangle {
    id: root

    color: Theme.surfaceContainer
    radius: 16

    readonly property string greyColor: "#6d6b6b"

    property var sliderDotIcons: [["󰃞", 30], ["󰃝", 50], ["󰃟", 70], ["󰃠", 100]]

    border.color: "white"
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Brightness.brightness <= 10 ? root.greyColor : Theme.colorOnSurface
        shadowBlur: 0.7
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0

        Behavior on shadowColor {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    readonly property real maxY: Math.max(0, height - sliderDot.height)

    function updateBrightness(mouseY) {
        if (maxY <= 0)
            return;

        const targetY = mouseY - sliderDot.height / 2;
        const clampedY = Math.max(0, Math.min(maxY, targetY));
        const percent = Math.round((1 - clampedY / maxY) * 100);

        root.displayedBrightness = percent;
        Brightness.setBrightness(percent);
    }

    property real displayedBrightness: 0

    Binding {
        target: root
        property: "displayedBrightness"
        value: Brightness.brightness
        when: !mouseArea.pressed
    }

    Rectangle {
        id: sliderDotBackground

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            top: sliderDot.top
        }

        width: parent.width
        topRightRadius: 16
        topLeftRadius: 16
        color: Brightness.brightness <= 0 ? root.greyColor : Theme.colorOnSurface

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: sliderDot

        width: parent.width
        height: width
        radius: 16
        y: root.maxY * (1 - Brightness.brightness / 100)

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
            shadowColor: "#000000"
            shadowBlur: 0.7
            shadowHorizontalOffset: 0
            shadowVerticalOffset: -2
        }

        Text {
            id: sliderDotIcon

            anchors.centerIn: parent
            font.pixelSize: 20
            color: Theme.surfaceContainer

            text: {
                if (Brightness.brightness < root.sliderDotIcons[0][1])
                    return root.sliderDotIcons[0][0];
                if (Brightness.brightness < root.sliderDotIcons[1][1])
                    return root.sliderDotIcons[1][0];
                if (Brightness.brightness < root.sliderDotIcons[2][1])
                    return root.sliderDotIcons[2][0];
                return root.sliderDotIcons[3][0];
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            updateBrightness(mouse.y);
        }

        onPositionChanged: mouse => {
            if (pressed && (pressedButtons & Qt.LeftButton))
                updateBrightness(mouse.y);
        }

        onWheel: wheel => {
            const step = wheel.angleDelta.y > 0 ? 5 : -5;
            Brightness.setBrightness(Brightness.brightness + step);
        }
    }
}
