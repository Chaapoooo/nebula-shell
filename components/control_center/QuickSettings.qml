import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../core"
import "../../styles"
import "../../widgets"

PanelWindow {
    id: root
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: "Ignore"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quicksetting-nebula-shell"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: 'transparent'

    visible: Store.quickSettingsOpen
    Shortcut {
        sequence: 'Escape'
        onActivated: root.requestClose()
    }
    GlobalShortcut {
        name: "quicksettings"
        onPressed: {
            if (root.opened) {
                root.requestClose();
            } else {
                Store.openQuickSettings();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.requestClose()
    }

    property bool opened: false

    onVisibleChanged: {
        if (visible) {
            startupTimer.start();
        } else {
            opened = false;
        }
    }

    Timer {
        id: startupTimer
        interval: 40
        onTriggered: root.opened = true
    }

    function requestClose() {
        if (!opened)
            return;
        opened = false;
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: {
            Store.closeQuickSettings();
        }
    }

    Connections {
        target: Store
        function onRequestCloseQuickSettings() {
            root.requestClose();
        }
    }

    Shortcut {
        sequence: "Right"
        onActivated: {
            if (Store.quickSettingsTab < 2) {
                Store.quickSettingsTab++;
            }
        }
    }

    Shortcut {
        sequence: "Left"
        onActivated: {
            if (Store.quickSettingsTab > 0) {
                Store.quickSettingsTab--;
            }
        }
    }

    Rectangle {
        id: mainRectangle
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.opened ? 250 : 0
        width: root.opened ? 650 : 150
        clip: true
        color: Theme.surface
        bottomLeftRadius: 60
        bottomRightRadius: 60

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#60000000"
            shadowBlur: 0.9
            shadowHorizontalOffset: 0
            shadowVerticalOffset: -2
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing: Easing.OutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Row {
            id: widgetsPagesRow
        }
    }

    Clock {
        anchors.top: mainRectangle.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.opened ? 200 : 120

        Behavior on width {
            NumberAnimation {
                duration: 450
                easing: Easing.OutCubic
            }
        }

        Shape {
            anchors.right: parent.left
            anchors.top: parent.top

            width: 12
            height: 12

            ShapePath {
                fillColor: Theme.surface
                strokeColor: "transparent"
                startX: 0
                startY: 0
                PathLine {
                    x: 12
                    y: 0
                }
                PathLine {
                    x: 12
                    y: 12
                }
                PathArc {
                    x: 0
                    y: 0
                    radiusX: 12
                    radiusY: 12
                    direction: PathArc.Counterclockwise
                }
            }
        }
        Shape {
            anchors.left: parent.right
            anchors.top: parent.top

            width: 12
            height: 12

            ShapePath {
                fillColor: Theme.surface
                strokeColor: "transparent"

                startX: 12
                startY: 0

                PathLine {
                    x: 0
                    y: 0
                }
                PathLine {
                    x: 0
                    y: 12
                }
                PathArc {
                    x: 12
                    y: 0
                    radiusX: 12
                    radiusY: 12
                    direction: PathArc.Clockwise
                }
            }
        }
    }

    Shape {
        anchors.right: mainRectangle.left
        anchors.top: parent.top
        anchors.topMargin: 6

        width: 25
        height: 25

        ShapePath {
            fillColor: Theme.surface
            strokeColor: "transparent"
            startX: 0
            startY: 0
            PathLine {
                x: 25
                y: 0
            }
            PathLine {
                x: 25
                y: 25
            }
            PathArc {
                x: 0
                y: 0
                radiusX: 25
                radiusY: 25
                direction: PathArc.Counterclockwise
            }
        }
    }
    Shape {
        anchors.left: mainRectangle.right
        anchors.top: parent.top
        anchors.topMargin: 6

        width: 25
        height: 25

        ShapePath {
            fillColor: Theme.surface
            strokeColor: "transparent"

            startX: 25
            startY: 0

            PathLine {
                x: 0
                y: 0
            }
            PathLine {
                x: 0
                y: 25
            }
            PathArc {
                x: 25
                y: 0
                radiusX: 25
                radiusY: 25
                direction: PathArc.Clockwise
            }
        }
    }
}
