pragma Singleton
import QtQuick

QtObject {
    id: root
    property bool chooseMenuOpen: false
    signal requestCloseChooseMenu

    function toggleChooseMenu() {
        if (chooseMenuOpen) {
            requestCloseChooseMenu();
        } else {
            openChooseMenu();
        }
    }
    function openChooseMenu() {
        chooseMenuOpen = true;
    }
    function closeChooseMenu() {
        chooseMenuOpen = false;
    }

    /////////////////////////////////////////

    property bool quickSettingsOpen: false
    property int quickSettingsTab: 0

    function openQuickSettings(tab = 0) {
        quickSettingsTab = tab;
        quickSettingsOpen = true;
    }

    signal requestCloseQuickSettings

    function toggleQuickSettings() {
        if (quickSettingsOpen) {
            requestCloseQuickSettings();
        } else {
            openQuickSettings();
        }
    }

    function closeQuickSettings() {
        quickSettingsOpen = false;
    }
}
