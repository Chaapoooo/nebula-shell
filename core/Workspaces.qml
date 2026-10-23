import QtQuick
import QtQuick.Effects
import Quickshell.Hyprland
import "../styles"

Item {
    id: root

    readonly property int totalWorkspaces: 10
    property int activeWorkspace: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id >= 1 && Hyprland.focusedWorkspace.id <= 10) ? Hyprland.focusedWorkspace.id : internalActiveWs
    property int internalActiveWs: 1

    readonly property var workspaceIcons: ["󰈹", "󰨞", "", "󰙯", "·", "·", "·", "·", "·", "󰓇"]

    function isOccupied(wsId) {
        var dummy = Hyprland.workspaces;

        if (!dummy || !dummy.values)
            return false;
        let list = dummy.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === wsId) {
                return list[i].windows > 0;
            }
        }
        return false;
    }

    width: 28
    height: wsColumn.height

    Rectangle {
        id: pill
        width: 28
        height: 28
        radius: 12

        color: Theme.primary
        border.color: Theme.outline
        border.width: 0

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#50000000"
            shadowBlur: 0.7
            shadowHorizontalOffset: 1.5
            shadowVerticalOffset: 1.5
        }

        Behavior on y {
            SpringAnimation {
                spring: 4.5
                damping: 0.35
                epsilon: 0.15
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    Column {
        id: wsColumn
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            id: wsRepeater
            model: root.totalWorkspaces

            Behavior on height {
                NumberAnimation {
                    duration: 120
                    easing: Easing.OutQuad
                }
            }

            Item {
                id: wsItem
                readonly property int wsId: index + 1
                readonly property bool isActive: root.activeWorkspace === wsItem.wsId

                property bool isOccupiedState: {
                    var dummy = Hyprland.workspaces;
                    return root.isOccupied(wsItem.wsId);
                }

                readonly property string baseIcon: root.workspaceIcons[index] ?? wsItem.wsId

                visible: (baseIcon !== "·" || isActive || isOccupiedState)

                width: 28
                height: 28

                onYChanged: {
                    if (isActive)
                        pill.y = y;
                }
                onIsActiveChanged: {
                    if (isActive)
                        pill.y = y;
                }

                Text {
                    anchors.centerIn: parent

                    text: (wsItem.baseIcon === "·" && wsItem.isOccupiedState) ? "•" : wsItem.baseIcon
                    font.pixelSize: (text === "·" || text === "•") ? 20 : 16
                    font.family: "JetBrainsMono Nerd Font"

                    color: wsItem.isActive ? Theme.colorOnPrimary : Theme.colorOnSurfaceVariant

                    opacity: (wsItem.baseIcon === "·" && !wsItem.isActive && !wsItem.isOccupiedState) ? 0.0 : 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        root.internalActiveWs = wsItem.wsId;
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsItem.wsId}, on_current_monitor = true })`);
                    }

                    onWheel: wheel => {
                        let currentIdx = root.activeWorkspace - 1;
                        let targetIdx = currentIdx;

                        if (wheel.angleDelta.y > 0) {
                            do {
                                targetIdx = (targetIdx > 0) ? (targetIdx - 1) : (root.totalWorkspaces - 1);
                            } while (!wsRepeater.itemAt(targetIdx).visible && targetIdx !== currentIdx)
                        } else if (wheel.angleDelta.y < 0) {
                            do {
                                targetIdx = (targetIdx < root.totalWorkspaces - 1) ? (targetIdx + 1) : 0;
                            } while (!wsRepeater.itemAt(targetIdx).visible && targetIdx !== currentIdx)
                        }

                        if (targetIdx !== currentIdx) {
                            let targetWs = targetIdx + 1;
                            root.internalActiveWs = targetWs;
                            Hyprland.dispatch(`hl.dsp.focus({ workspace = ${targetWs}, on_current_monitor = true })`);
                        }
                    }
                }
            }
        }
    }
}
