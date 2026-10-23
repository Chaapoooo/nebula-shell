pragma Singleton
import QtQuick

QtObject {
    id: root
    property bool chooseMenuOpen: false

    function toggleChooseMenu() {
        chooseMenuOpen = !chooseMenuOpen;
    }
    function openChooseMenu() {
        chooseMenuOpen = true;
    }
    function closeChooseMenu() {
        chooseMenuOpen = false;
    }
}
