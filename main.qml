import QtQuick
import "./components/panel"

QtObject {
    property var topBar: TopPanel {}
    property var bottomBar: BottomPanel {}
    property var leftBar: LeftPanel {}
    property var rightBar: RightPanel {}
}
