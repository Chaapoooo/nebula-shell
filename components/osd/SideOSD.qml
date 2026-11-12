import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../../styles"
import "../../core"
import "../../widgets"

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

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            const point = osdBox.mapFromItem(root, mouse.x, mouse.y);

            if (!osdBox.contains(point))
                root.requestClose();
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.requestClose()
    }

    GlobalShortcut {
        name: "sideOSD"

        onPressed: {
            if (root.opened)
                root.requestClose();
            else
                openSideOsd();
        }
    }

    function openSideOsd(mode = "all") {
        Store.closeAllModals("sideOsd");
        Store.sideOsdMode = mode;
        Store.sideOsdOpen = true;

        if (mode !== "all")
            Store.sideOsdTimer.restart();
        else
            Store.sideOsdTimer.stop();
    }

    property bool opened: false
    property string hoverReturnMode: "all"

    onVisibleChanged: {
        if (visible)
            startupTimer.start();
        else
            root.requestClose();
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

    Item {
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6

        HoverHandler {
            onHoveredChanged: {
                if (hovered && root.opened)
                    Store.sideOsdTimer.restart();
            }
        }
    }

    Rectangle {
        id: osdBox

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        height: root.opened ? mainColumn.height + 36 : 0
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

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    root.hoverReturnMode = Store.sideOsdMode;
                    Store.sideOsdTimer.stop();

                    if (root.hoverReturnMode !== "all")
                        Store.sideOsdMode = "all";
                } else if (root.opened) {
                    if (root.hoverReturnMode === "all") {
                        root.requestClose();
                    } else {
                        Store.sideOsdMode = root.hoverReturnMode;
                        Store.sideOsdTimer.restart();
                    }
                }
            }
        }

        Column {
            id: mainColumn

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
                margins: 18
            }

            width: parent.width - 31
            spacing: 12

            height: {
                if (volumeSlider.visible && brightnessSlider.visible)
                    return volumeSlider.height + brightnessSlider.height + spacing;
                if (volumeSlider.visible)
                    return volumeSlider.height;
                if (brightnessSlider.visible)
                    return brightnessSlider.height;
                return 0;
            }

            VolumeSlider {
                id: volumeSlider

                width: parent.width
                height: 165
                visible: Store.sideOsdMode === "all" || Store.sideOsdMode === "volume"
                opacity: root.opened && enabled ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing: Easing.OutCubic
                    }
                }
            }

            BrightnessSlider {
                id: brightnessSlider

                width: parent.width
                height: 165
                visible: Store.sideOsdMode === "all" || Store.sideOsdMode === "brightness"
                opacity: root.opened && enabled ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing: Easing.OutCubic
                    }
                }
            }
        }
    }

    Shape {
        anchors {
            left: osdBox.right
            leftMargin: root.opened ? -36 : 0
            bottom: osdBox.bottom
            bottomMargin: -30
        }

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
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
        anchors {
            right: osdBox.right
            rightMargin: root.opened ? 6 : -36
            top: osdBox.top
            topMargin: -30
        }

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
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
