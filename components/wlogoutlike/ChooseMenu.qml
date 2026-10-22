import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

PanelWindow {
    id: wlogoutWindow
    exclusionMode: "Ignore"
    WlrLayershell.namespace: "quickshell-wlogout"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors {
        top: true
        bottom: true
        right: true
        left: true
    }
    color: '#00ffffff'

    MouseArea {
        anchors.fill: parent
        onClicked: wlogoutWindow.closeRequested()

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                wlogoutWindow.activeIndex = (wlogoutWindow.activeIndex - 1 + wlogoutWindow.activeTotalButton) % wlogoutWindow.activeTotalButton;
            } else if (wheel.angleDelta.y < 0) {
                wlogoutWindow.activeIndex = (wlogoutWindow.activeIndex + 1) % wlogoutWindow.activeTotalButton;
            }
        }
    }

    focusable: true
    signal closeRequested
    signal lockRequested
    property bool uiLoaded: false

    onHeightChanged: {
        if (height > 0 && !uiLoaded) {
            startupTimer.start();
        }
    }

    onCloseRequested: {
        Qt.quit();
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            wlogoutWindow.closeRequested();
        }
    }

    Timer {
        id: startupTimer
        interval: 50
        onTriggered: wlogoutWindow.uiLoaded = true
    }

    property int activeIndex: 0
    property int activeTotalButton: 4
    Rectangle {
        id: contentRoot
        width: parent.width
        height: parent.height
        color: 'transparent'

        x: wlogoutWindow.uiLoaded ? 0 : 150

        Behavior on x {
            enabled: wlogoutWindow.uiLoaded

            NumberAnimation {
                duration: 320
                easing.type: Easing.OutQuad
            }
        }

        Rectangle {
            id: mainWindow
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 0
            }
            color: '#e7edf9'
            width: buttonsRow.width + 24
            height: buttonsRow.height + 24
            topLeftRadius: 15
            bottomLeftRadius: 15

            Shortcut {
                sequence: "Down"
                onActivated: {
                    wlogoutWindow.activeIndex = (wlogoutWindow.activeIndex + 1) % wlogoutWindow.activeTotalButton;
                }
            }

            Shortcut {
                sequence: "Up"
                onActivated: {
                    wlogoutWindow.activeIndex = (wlogoutWindow.activeIndex - 1 + wlogoutWindow.activeTotalButton) % wlogoutWindow.activeTotalButton;
                }
            }

            Shortcut {
                sequence: "Return"
                onActivated: {
                    wlogoutWindow.closeRequested();

                    if (wlogoutWindow.activeIndex === 0) {
                        Quickshell.execDetached(["sh", "-c", "systemctl poweroff"]);
                    } else if (wlogoutWindow.activeIndex === 1) {
                        Quickshell.execDetached(["sh", "-c", "systemctl reboot"]);
                    } else if (wlogoutWindow.activeIndex === 2) {
                        Quickshell.execDetached(["sh", "-c", "./.config/quickshell/lockscreen/lock.sh"]);
                        wlogoutWindow.closeRequested();
                    } else if (wlogoutWindow.activeIndex === 3) {
                        Quickshell.execDetached(["sh", "-c", "./.config/quickshell/lockscreen/lock.sh & systemctl suspend"]);
                        wlogoutWindow.closeRequested();
                    }
                }
            }

            //layer.enabled: true
            //layer.effect: MultiEffect {
            //    autoPaddingEnabled: true
            //    shadowEnabled: true
            //    shadowColor: '#80000000'
            //    shadowBlur: 0.7
            //    shadowHorizontalOffset: -3
            //    shadowVerticalOffset: 3
            //}

            Shape {
                anchors.left: mainWindow.right
                anchors.leftMargin: -36
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -30

                width: 30
                height: 30

                ShapePath {
                    fillColor: "#e7edf9"
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
                anchors.right: mainWindow.right
                anchors.rightMargin: 6
                anchors.top: parent.top
                anchors.topMargin: -30

                width: 30
                height: 30

                ShapePath {
                    fillColor: "#e7edf9"
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

            Column {
                id: buttonsRow
                anchors {
                    centerIn: parent
                }
                spacing: 16

                Rectangle {
                    id: shutdownButtonArea
                    color: (shutdownMouse.containsMouse || wlogoutWindow.activeIndex === 0) ? '#D2D7E2' : '#e7edf9'
                    height: 40
                    width: 40
                    radius: 8

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: true
                        shadowEnabled: true
                        shadowColor: '#80000000'
                        shadowBlur: (shutdownMouse.containsMouse || wlogoutWindow.activeIndex === 0) ? 0.7 : 10
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0

                        Behavior on shadowBlur {
                            NumberAnimation {
                                duration: 150
                                easing: Easing.OutQuart
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    Image {
                        id: shutdownImage
                        source: "/home/leo/Documents/Projects/nebula-shell/assets/icons/rofilike/shutdown.png"
                        anchors {
                            centerIn: parent
                        }
                        fillMode: Image.PreserveAspectCrop
                        height: 30
                        width: 30

                        scale: (wlogoutWindow.activeIndex === 0 || shutdownMouse.containsMouse) ? 1.15 : 0.9
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "systemctl poweroff"]);
                        }
                    }
                }
                Rectangle {
                    id: rebootButtonArea
                    color: (rebootMouse.containsMouse || wlogoutWindow.activeIndex === 1) ? '#D2D7E2' : '#e7edf9'
                    height: 40
                    width: 40
                    radius: 8

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: true
                        shadowEnabled: true
                        shadowColor: '#80000000'
                        shadowBlur: (rebootMouse.containsMouse || wlogoutWindow.activeIndex === 1) ? 0.7 : 10
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0

                        Behavior on shadowBlur {
                            NumberAnimation {
                                duration: 150
                                easing: Easing.OutQuart
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    Image {
                        id: rebootImage
                        source: "/home/leo/Documents/Projects/nebula-shell/assets/icons/rofilike/reboot.png"
                        anchors {
                            centerIn: parent
                        }
                        fillMode: Image.PreserveAspectCrop
                        height: 30
                        width: 30

                        scale: (wlogoutWindow.activeIndex === 1 || rebootMouse.containsMouse) ? 1.15 : 0.9

                        transformOrigin: Item.Center
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: rebootMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "systemctl reboot"]);
                        }
                    }
                }
                Rectangle {
                    id: lockButtonArea
                    color: (lockMouse.containsMouse || wlogoutWindow.activeIndex === 2) ? '#D2D7E2' : '#e7edf9'
                    height: 40
                    width: 40
                    radius: 8

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: true
                        shadowEnabled: true
                        shadowColor: '#80000000'
                        shadowBlur: (lockMouse.containsMouse || wlogoutWindow.activeIndex === 2) ? 0.7 : 10
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0

                        Behavior on shadowBlur {
                            NumberAnimation {
                                duration: 150
                                easing: Easing.OutQuart
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    Image {
                        id: lockImage
                        source: "/home/leo/Documents/Projects/nebula-shell/assets/icons/rofilike/lock.png"
                        anchors {
                            centerIn: parent
                        }
                        fillMode: Image.PreserveAspectCrop
                        height: 30
                        width: 30

                        scale: (wlogoutWindow.activeIndex === 2 || lockMouse.containsMouse) ? 1.15 : 0.9
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "./.config/quickshell/lockscreen/lock.sh"]);
                            wlogoutWindow.closeRequested();
                        }
                    }
                }
                Rectangle {
                    id: suspendButtonArea
                    color: (suspendMouse.containsMouse || wlogoutWindow.activeIndex === 3) ? '#D2D7E2' : '#e7edf9'
                    height: 40
                    width: 40
                    radius: 8

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: true
                        shadowEnabled: true
                        shadowColor: '#80000000'
                        shadowBlur: (suspendMouse.containsMouse || wlogoutWindow.activeIndex === 3) ? 0.7 : 10
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0

                        Behavior on shadowBlur {
                            NumberAnimation {
                                duration: 150
                                easing: Easing.OutQuart
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }
                    }

                    Image {
                        id: suspendImage
                        source: "/home/leo/Documents/Projects/nebula-shell/assets/icons/rofilike/suspend.png"
                        anchors {
                            centerIn: parent
                        }
                        fillMode: Image.PreserveAspectCrop
                        height: 30
                        width: 30

                        scale: (wlogoutWindow.activeIndex === 3 || suspendMouse.containsMouse) ? 1.15 : 0.9
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: suspendMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "./.config/quickshell/lockscreen/lock.sh & systemctl suspend"]);
                            wlogoutWindow.closeRequested();
                        }
                    }
                }
            }

            Rectangle {
                id: selectSquare

                anchors.right: buttonsRow.right
                anchors.rightMargin: -20

                width: 15
                bottomLeftRadius: 5
                topLeftRadius: 5
                color: "#D2D7E2"
                border.color: '#b6aab6ec'
                border.width: 1

                property real targetY: buttonsRow.y + (wlogoutWindow.activeIndex * 56)

                property real fastY: targetY
                property real slowY: targetY

                Behavior on fastY {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
                Behavior on slowY {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutQuad
                    }
                }

                y: Math.min(fastY, slowY)
                height: (Math.max(fastY, slowY) + 35) - y

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: '#80000000'
                    shadowBlur: 0.8
                    shadowHorizontalOffset: -3
                    shadowVerticalOffset: 3
                }
            }
        }
    }
}
