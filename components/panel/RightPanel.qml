import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell

PanelWindow {
    id: root

    anchors {
        right: true
        top: true
        bottom: true
    }

    implicitWidth: 26

    exclusiveZone: 6

    color: "transparent"

    Rectangle {
        id: mainRectangle
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: 6
        color: "#e7edf9"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.5
            shadowHorizontalOffset: -3
            shadowVerticalOffset: 3
        }
    }

    Shape {
        anchors.right: mainRectangle.left
        anchors.top: parent.top

        width: 20
        height: 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.5
            shadowHorizontalOffset: -3
            shadowVerticalOffset: 3
        }

        ShapePath {
            fillColor: "#e7edf9"
            strokeColor: "transparent"

            startX: 20
            startY: 20

            PathLine {
                x: 20
                y: 0
            }

            PathLine {
                x: 0
                y: 0
            }

            PathArc {
                x: 20
                y: 20
                radiusX: 20
                radiusY: 20
                direction: PathArc.Clockwise
            }
        }
    }

    Shape {
        anchors.right: mainRectangle.left
        anchors.bottom: parent.bottom

        width: 20
        height: 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.5
            shadowHorizontalOffset: -3
            shadowVerticalOffset: -3
        }

        ShapePath {
            fillColor: "#e7edf9"
            strokeColor: "transparent"

            startX: 20
            startY: 0

            PathLine {
                x: 20
                y: 20
            }

            PathLine {
                x: 0
                y: 20
            }

            PathArc {
                x: 20
                y: 0
                radiusX: 20
                radiusY: 20
                direction: PathArc.Counterclockwise
            }
        }
    }
}
