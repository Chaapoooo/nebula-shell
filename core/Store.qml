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

    property bool quickSettingsOpen: false
    property int quickSettingsTab: 0

    function openQuickSettings(tab = 0) {
        quickSettingsTab = tab;
        quickSettingsOpen = true;
    }

    function toggleQuickSettings() {
        quickSettingsOpen = !quickSettingsOpen;
    }

    function closeQuickSettings() {
        quickSettingsOpen = false;
    }
}
