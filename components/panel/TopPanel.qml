import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import "../../widgets"
import "../../styles"

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

        color: Theme.surface

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

        Shape {
            anchors.right: parent.left
            anchors.top: parent.top
            anchors.topMargin: 6

            width: 8
            height: 8

            ShapePath {
                fillColor: Theme.surface
                strokeColor: "transparent"
                startX: 0
                startY: 0
                PathLine {
                    x: 8
                    y: 0
                }
                PathLine {
                    x: 8
                    y: 8
                }
                PathArc {
                    x: 0
                    y: 0
                    radiusX: 8
                    radiusY: 8
                    direction: PathArc.Counterclockwise
                }
            }
        }

        Shape {
            anchors.left: parent.right
            anchors.top: parent.top
            anchors.topMargin: 6

            width: 8
            height: 8

            ShapePath {
                fillColor: Theme.surface
                strokeColor: "transparent"

                startX: 8
                startY: 0

                PathLine {
                    x: 0
                    y: 0
                }
                PathLine {
                    x: 0
                    y: 8
                }
                PathArc {
                    x: 8
                    y: 0
                    radiusX: 8
                    radiusY: 8
                    direction: PathArc.Clockwise
                }
            }
        }
    }
}
