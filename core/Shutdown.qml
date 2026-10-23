import QtQuick
import "../core"
import "../styles"

Item {
    id: root
    width: 25
    height: width

    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        height: root.height
        width: height
        //color: (shutdownButton.containsMouse) ? Theme.error : Theme.colorOnError
        color: 'transparent'
        radius: height / 2
        scale: shutdownButton.containsMouse ? (shutdownButton.pressed ? 0.85 : 1.2) : 1

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 70
                easing: Easing.Linear
            }
        }

        Image {
            anchors {
                centerIn: parent
            }
            height: parent.height
            width: parent.width
            source: "../assets/icons/shutdown.png"
        }

        MouseArea {
            id: shutdownButton
            anchors {
                fill: parent
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Store.openChooseMenu();
            }
        }
    }
}
