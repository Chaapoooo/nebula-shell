import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import "../styles"

Rectangle {
    id: root

    width: clockLayout.implicitWidth + 24
    height: 24
    bottomLeftRadius: 12
    bottomRightRadius: 12

    color: Theme.surface

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#50000000"
        shadowBlur: 0.7
        shadowHorizontalOffset: 1.5
        shadowVerticalOffset: 1.5
    }

    property string timeString: "00:00"
    property string dateString: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let d = new Date();
            let h = d.getHours().toString().padStart(2, '0');
            let m = d.getMinutes().toString().padStart(2, '0');
            root.timeString = `${h}:${m}`;

            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            root.dateString = `${days[d.getDay()]} ${d.getDate()} ${months[d.getMonth()]}`;
        }
    }

    RowLayout {
        id: clockLayout
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.timeString
            font.pixelSize: 13
            font.bold: true
            font.family: "Inter"
            color: Theme.colorOnSurfaceVariant
        }

        Text {
            text: "•"
            font.pixelSize: 10
            font.family: "Inter"
            color: Theme.outline
        }

        Text {
            text: root.dateString
            font.pixelSize: 12
            font.bold: true
            font.family: "Inter"
            color: Theme.colorOnSurfaceVariant
        }
    }

    Shape {
        anchors.right: root.left
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
        anchors.left: root.right
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
