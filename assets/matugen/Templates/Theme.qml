pragma Singleton
import QtQuick

QtObject {
    // Couleurs générées automatiquement par Matugen (Material You)
    readonly property color primary: "{{colors.primary.default.hex}}"
    readonly property color colorOnPrimary: "{{colors.on_primary.default.hex}}"

    readonly property color surface: "{{colors.surface.default.hex}}"
    readonly property color surfaceContainer: "{{colors.surface_container.default.hex}}"
    readonly property color colorOnSurface: "{{colors.on_surface.default.hex}}"
    readonly property color colorOnSurfaceVariant: "{{colors.on_surface_variant.default.hex}}"

    readonly property color outline: "{{colors.outline.default.hex}}"
    readonly property color error: "{{colors.error.default.hex}}"
    readonly property color colorOnError: "{{colors.on_error.default.hex}}"
}
