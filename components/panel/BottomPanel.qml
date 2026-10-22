import QtQuick
import QtQuick.Effects
import Quickshell

PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 25
    exclusiveZone: 6
    color: "transparent"

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6

        color: "#e7edf9"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#60000000"
            shadowBlur: 0.5
            shadowVerticalOffset: -4
        }
    }
}
