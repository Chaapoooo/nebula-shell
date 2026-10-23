import QtQuick
import "./components/panel"
import "./components/wlogoutlike"

QtObject {
    property var topBar: TopPanel {}
    property var bottomBar: BottomPanel {}
    property var leftBar: LeftPanel {}
    property var rightBar: RightPanel {}

    property var wlogoutlike: ChooseMenu {}
}
