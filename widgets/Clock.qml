import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../styles"
import "../core"

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
        shadowVerticalOffset: 8
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Store.quickSettingsOpen = !Store.quickSettingsOpen
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
}
