import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../styles"
import "../../core"

PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-sideOSD"
    exclusionMode: "Ignore"
    focusable: true

    anchors {
        right: true
        top: true
        bottom: true
        left: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.requestClose()
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            root.requestClose();
        }
    }

    color: "transparent"

    GlobalShortcut {
        name: "sideOSD"
        onPressed: {
            if (root.opened) {
                root.requestClose();
            } else {
                openSideOsd();
            }
        }
    }

    function openSideOsd(mode = "all") {
        Store.closeAllModals("sideOsd");
        Store.sideOsdMode = mode;
        Store.sideOsdOpen = true;

        if (mode !== "all") {
            Store.sideOsdTimer.restart();
        } else {
            Store.sideOsdTimer.stop();
        }
    }

    property bool opened: false
    onVisibleChanged: {
        if (visible)
            startupTimer.start();
        else {
            root.requestClose();
        }
    }
    Timer {
        id: startupTimer
        interval: 50
        onTriggered: root.opened = true
    }

    Connections {
        target: Store
        function onRequestCloseSideOsd() {
            root.requestClose();
        }
    }

    function requestClose() {
        if (!root.opened)
            return;
        root.opened = false;
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: Store.closeSideOsd()
    }

    Rectangle {
        id: osdBox
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        x: 0

        height: root.opened ? 420 : 0
        width: root.opened ? 70 : 0

        topLeftRadius: 28
        bottomLeftRadius: 28
        color: Theme.surface
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                Store.sideOsdTimer.stop();
            }

            onExited: {
                Store.sideOsdTimer.restart();
            }
        }
    }

    Shape {
        anchors.left: osdBox.right
        anchors.leftMargin: root.opened ? -36 : 0
        anchors.bottom: osdBox.bottom
        anchors.bottomMargin: -30

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 150
                easing: Easing.OutCubic
            }
        }

        width: 30
        height: 30

        ShapePath {
            fillColor: Theme.surface
            strokeColor: "transparent"

            startX: 30
            startY: 30

            PathLine {
                x: 30
                y: 0
            }

            PathLine {
                x: 0
                y: 0
            }

            PathArc {
                x: 30
                y: 30
                radiusX: 30
                radiusY: 30
                direction: PathArc.Clockwise
            }
        }
    }
    Shape {
        anchors.right: osdBox.right
        anchors.rightMargin: root.opened ? 6 : -36
        anchors.top: osdBox.top
        anchors.topMargin: -30

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 150
                easing: Easing.OutCubic
            }
        }

        width: 30
        height: 30

        ShapePath {
            fillColor: Theme.surface
            strokeColor: "transparent"

            startX: 30
            startY: 0

            PathLine {
                x: 30
                y: 30
            }

            PathLine {
                x: 0
                y: 30
            }

            PathArc {
                x: 30
                y: 0
                radiusX: 30
                radiusY: 30
                direction: PathArc.Counterclockwise
            }
        }
    }
}
