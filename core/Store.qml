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

    ////////////////////////////////////////

    property bool sideOsdOpen: false
    property string sideOsdMode: "all" // "all", "volume", "brightness"

    signal requestCloseSideOsd

    function openSideOsd(mode = "all") {
        sideOsdMode = mode;
        sideOsdOpen = true;

        if (mode !== "all") {
            sideOsdTimer.restart();
        } else {
            sideOsdTimer.stop();
        }
    }

    function triggerVolumeOsd() {
        openSideOsd("volume");
    }

    function triggerBrightnessOsd() {
        openSideOsd("brightness");
    }

    function closeSideOsd() {
        sideOsdOpen = false;
    }

    property var sideOsdTimer: Timer {
        interval: 100
        onTriggered: {
            root.requestCloseSideOsd();
        }
    }

    //////////////////////////////////////////////

    function closeAllModals(except = "") {
        if (except !== "chooseMenu" && chooseMenuOpen) {
            requestCloseChooseMenu();
        }
        if (except !== "quickSettings" && quickSettingsOpen) {
            requestCloseQuickSettings();
        }
        if (except !== "sideOsd" && sideOsdOpen) {
            requestCloseSideOsd();
        }
    }
}
