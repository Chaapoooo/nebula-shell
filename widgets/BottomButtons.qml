import QtQuick
import "../widgets"

Column {
    id: root
    spacing: 12

    WifiButton {
        height: root.width
        width: root.width
    }

    BluetoothButton {
        height: root.width
        width: root.width
    }

    BatteryButton {
        height: root.width
        width: root.width
    }
}
