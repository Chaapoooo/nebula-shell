import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import "../../core"
import "../../widgets"

PanelWindow {
    id: root

    anchors {
        left: true
        top: true
        bottom: true
    }

    implicitWidth: 60
    exclusiveZone: 47

    color: "transparent"

    Rectangle {
        id: mainRectangle
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: 45

        color: "#e7edf9"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#60000000" // Noir à 37% d'opacité
            shadowBlur: 0.6          // Intensité du flou (entre 0.0 et 1.0)
            shadowHorizontalOffset: 4 // Décale l'ombre vers la droite ( relief )
            shadowVerticalOffset: 0
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 15

            TopIcon {
                id: topIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Workspaces {
                id: workspacesRow
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            ActiveAppsBar {
                id: activeAppsBar
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Shape {
        anchors.left: mainRectangle.right
        anchors.top: parent.top

        width: 20
        height: 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.5
            shadowHorizontalOffset: 3
            shadowVerticalOffset: 3
        }

        ShapePath {
            fillColor: "#e7edf9"
            strokeColor: "transparent"

            startX: 0
            startY: 0

            PathLine {
                x: 20
                y: 0
            }

            PathArc {
                x: 0
                y: 20
                radiusX: 20
                radiusY: 20
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: 0
                y: 0
            }
        }
    }
    Shape {
        anchors.left: mainRectangle.right
        anchors.bottom: parent.bottom

        width: 20
        height: 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.5
            shadowHorizontalOffset: 3
            shadowVerticalOffset: -3
        }

        ShapePath {
            fillColor: "#e7edf9"
            strokeColor: "transparent"

            startX: 0
            startY: 20

            PathLine {
                x: 20
                y: 20
            }

            PathArc {
                x: 0
                y: 0
                radiusX: 20
                radiusY: 20
                direction: PathArc.Clockwise
            }

            PathLine {
                x: 0
                y: 20
            }
        }
    }
}
