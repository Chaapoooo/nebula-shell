pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int brightness: 0
    property bool ready: false
    property string deviceName: ""

    property Process writeProcess: Process {
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("Brightness: brightnessctl a échoué en écriture.");

            root.refresh();
        }
    }

    property Process readProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: root.updateFromOutput(text)
        }
    }

    property Timer pollTimer: Timer {
        interval: 250
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    onBrightnessChanged: {
        if (ready)
            Store.triggerBrightnessOsd();
    }

    function refresh() {
        if (!readProcess.running)
            readProcess.exec(["brightnessctl", "-m"]);
    }

    function setBrightness(percent) {
        if (!deviceName) {
            refresh();
            return;
        }

        const value = Math.max(0, Math.min(100, Math.round(percent)));

        writeProcess.exec(["brightnessctl", "-d", deviceName, "set", `${value}%`]);
    }

    Component.onCompleted: refresh()

    function updateFromOutput(output) {
        const line = output.trim().split("\n").find(entry => {
            const fields = entry.split(",");
            return fields.length >= 5 && fields[1] === "backlight";
        });

        if (!line)
            return;

        const fields = line.split(",");
        const percent = Number.parseInt(fields[3].replace("%", ""), 10);

        if (!Number.isFinite(percent))
            return;

        deviceName = fields[0];
        const value = Math.max(0, Math.min(100, percent));

        if (!ready) {
            brightness = value;
            ready = true;
            return;
        }

        brightness = value;
    }
}
