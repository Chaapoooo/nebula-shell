import QtQuick
import QtQuick.Effects
import Quickshell
import "../../widgets"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 40
    exclusiveZone: 6

    color: "transparent"

    // 1. LA BORDURE DU HAUT (6px)
    Rectangle {
        id: topFrame
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6

        color: "#e7edf9"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#60000000"
            shadowBlur: 0.5
            shadowVerticalOffset: 3
        }
    }

    Clock {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
