import QtQuick
import Quickshell

Image {
    source: "../../assets/icons/arch_icon.png"
    width: 24
    height: 24
    fillMode: Image.PreserveAspectFit
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["ghostty"])
    }
}
