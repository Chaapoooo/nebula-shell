import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../styles"

Rectangle {
    id: root
    width: 32
    color: Theme.surfaceContainer
    radius: Math.min(8, height / 2)

    border.color: Theme.outline
    border.width: 0

    clip: true

    layer.enabled: true
    layer.effect: MultiEffect {
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: "#80000000"
        shadowBlur: 0.7
        shadowHorizontalOffset: 3
        shadowVerticalOffset: 3
    }

    property var activeClients: []
    property var appIconDatabase: ({})

    property bool refreshPending: false

    readonly property int iconSize: 28
    readonly property int iconSpacing: 8
    readonly property int contentMargin: 3
    readonly property int itemStep: iconSize + iconSpacing

    height: activeClients.length > 0 ? contentMargin * 2 + activeClients.length * iconSize + (activeClients.length - 1) * iconSpacing : 0

    visible: activeClients.length > 0

    Behavior on height {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Component.onCompleted: {
        loadAppIconsDatabase();
        refreshClients();
    }

    function addIconAlias(db, alias, icon) {
        if (!alias || !icon)
            return;
        var key = String(alias).toLowerCase().trim();
        key = key.replace(/\.desktop$/, "");

        if (key.length > 0)
            db[key] = icon;
    }

    function loadAppIconsDatabase() {
        var xhr = new XMLHttpRequest();

        xhr.open("GET", "file:///home/leo/Documents/Projects/nebula-shell/assets/out/apps.json", true);

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            if (xhr.status !== 200 && xhr.status !== 0) {
                console.log("[AppDock] Impossible de charger apps.json");
                return;
            }

            try {
                var apps = JSON.parse(xhr.responseText);
                var db = {};

                for (var i = 0; i < apps.length; i++) {
                    var app = apps[i];
                    var icon = app.icon_file || app.icon;

                    if (!icon)
                        continue;
                    addIconAlias(db, app.name, icon);
                    addIconAlias(db, app.desktop, icon);
                    addIconAlias(db, app.startup_wm_class, icon);
                    addIconAlias(db, app.startupWMClass, icon);

                    if (app.exec) {
                        var match = String(app.exec).trim().match(/^"([^"]+)"|'([^']+)'|([^\s]+)/);

                        if (match) {
                            var executable = match[1] || match[2] || match[3];
                            executable = executable.split("/").pop();

                            addIconAlias(db, executable, icon);
                        }
                    }
                }

                db["kitty"] = db["kitty"] || "kitty"; // because kitty shows as neovim icon

                root.appIconDatabase = db;

                console.log("[AppDock] " + Object.keys(db).length + " alias chargés");
            } catch (e) {
                console.log("[AppDock] Erreur JSON :", e);
            }
        };

        xhr.send();
    }

    function getIconPath(appClass) {
        if (!appClass)
            return "";

        var cleanClass = String(appClass).toLowerCase().trim();
        var icon = root.appIconDatabase[cleanClass];

        if (!icon) {
            var bestMatch = "";

            for (var key in root.appIconDatabase) {
                if (key.length >= 4 && (cleanClass.indexOf(key) !== -1 || key.indexOf(cleanClass) !== -1) && key.length > bestMatch.length) {
                    bestMatch = key;
                }
            }

            if (bestMatch)
                icon = root.appIconDatabase[bestMatch];
        }

        if (!icon)
            icon = cleanClass;

        icon = String(icon).trim();

        if (icon.indexOf("file://") === 0)
            return icon;

        if (icon.charAt(0) === "/")
            return "file://" + icon;

        if (icon.indexOf("image://icon/") === 0) {
            icon = icon.substring("image://icon/".length);
            icon = icon.split("?")[0];
        }

        return Quickshell.iconPath(icon, "application-x-executable");
    }

    function applyClients(jsonText) {
        try {
            if (!jsonText || jsonText.trim() === "")
                return;
            var clients = JSON.parse(jsonText);

            if (!Array.isArray(clients))
                return;
            var filtered = clients.filter(function (client) {
                return client.workspace && client.workspace.id > 0;
            });

            filtered.sort(function (a, b) {
                var classA = String(a.class || a.initialClass || "").toLowerCase();

                var classB = String(b.class || b.initialClass || "").toLowerCase();

                if (classA < classB)
                    return -1;

                if (classA > classB)
                    return 1;

                var addressA = String(a.address || "");
                var addressB = String(b.address || "");

                if (addressA < addressB)
                    return -1;

                if (addressA > addressB)
                    return 1;

                return 0;
            });

            if (JSON.stringify(filtered) !== JSON.stringify(root.activeClients)) {
                root.activeClients = filtered;
            }
        } catch (e) {
            console.log("[AppDock] Erreur clients JSON :", e);
        }
    }

    function refreshClients() {
        if (clientsProcess.running) {
            refreshPending = true;
            return;
        }

        refreshDebounce.restart();
    }

    readonly property string focusedClientAddress: {
        var workspace = Hyprland.focusedWorkspace;

        if (!workspace)
            return "";

        for (var i = 0; i < activeClients.length; i++) {
            var client = activeClients[i];

            if (Number(client.focusHistoryID) === 0 && client.workspace && Number(client.workspace.id) === Number(workspace.id)) {
                return String(client.address || "");
            }
        }

        return "";
    }

    readonly property int activeClientIndex: {
        var address = focusedClientAddress;

        if (!address)
            return -1;

        return activeClients.findIndex(function (client) {
            return String(client.address || "") === address;
        });
    }

    Timer {
        id: refreshDebounce

        interval: 45
        repeat: false

        onTriggered: {
            if (clientsProcess.running) {
                root.refreshPending = true;
                return;
            }

            clientsProcess.running = true;
        }
    }

    Process {
        id: clientsProcess

        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.applyClients(this.text);
            }
        }

        onRunningChanged: {
            if (!running && root.refreshPending) {
                root.refreshPending = false;
                refreshDebounce.start();
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            switch (event.name) {
            case "openwindow":
            case "closewindow":
            case "movewindow":
            case "movewindowv2":
            case "moveworkspace":
            case "moveworkspacev2":
            case "workspace":
            case "focusedmon":
            case "activewindow":
            case "activewindowv2":
            case "createworkspace":
            case "destroyworkspace":
                root.refreshClients();
                break;
            }
        }
    }

    Rectangle {
        id: activeAppBackground

        z: 0

        width: 28
        height: 28

        radius: 9

        color: Theme.colorOnPrimary

        border.width: 0
        border.color: Theme.outline

        property int activeIndex: root.activeClientIndex

        property real targetY: root.contentMargin

        anchors.horizontalCenter: parent.horizontalCenter

        onActiveIndexChanged: {
            if (activeIndex >= 0) {
                targetY = root.contentMargin + activeIndex * root.itemStep;
            }
        }

        Component.onCompleted: {
            if (activeIndex >= 0) {
                targetY = root.contentMargin + activeIndex * root.itemStep;
            }
        }

        y: targetY

        opacity: activeIndex >= 0 ? 1 : 0

        Behavior on y {
            NumberAnimation {
                duration: 260
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 220
            }
        }

        layer.enabled: true

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#35000000"
            shadowBlur: 0.45
            shadowVerticalOffset: 2
        }
    }

    Column {
        id: appsColumn

        z: 1

        anchors {
            top: parent.top
            topMargin: root.contentMargin
            horizontalCenter: parent.horizontalCenter
        }

        spacing: root.iconSpacing

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 260
                easing.type: Easing.InOutCubic
            }
        }

        Repeater {
            model: root.activeClients

            delegate: Item {
                id: appDelegate

                width: 28
                height: 28

                property string appClass: String(modelData.class || "unknown")

                HoverHandler {
                    id: appHover
                }

                Image {
                    id: appImage

                    anchors.centerIn: parent

                    width: 23
                    height: 23

                    source: root.getIconPath(appDelegate.appClass)

                    sourceSize.width: 46
                    sourceSize.height: 46

                    fillMode: Image.PreserveAspectFit

                    asynchronous: true
                    cache: true
                    mipmap: true

                    scale: appHover.hovered ? 1.12 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent

                    visible: appImage.status !== Image.Ready

                    text: appDelegate.appClass.substring(0, 2).toUpperCase()

                    color: Theme.colorOnSurface

                    font {
                        pixelSize: 10
                        bold: true
                    }
                }

                Rectangle {
                    anchors.fill: parent

                    z: -1

                    radius: 8

                    color: Theme.colorOnSurface

                    opacity: appHover.hovered ? 0.45 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        var workspaceId = modelData.workspace.id;

                        if (workspaceId <= 0)
                            return;
                        Hyprland.dispatch(`hl.dsp.focus({
                                workspace = ${workspaceId},
                                on_current_monitor = true
                            })`);
                    }
                }
            }
        }
    }
}
