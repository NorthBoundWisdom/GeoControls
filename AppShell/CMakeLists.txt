qt_add_library(GeoToyAppShell STATIC)
set_target_properties(GeoToyAppShell PROPERTIES
    AUTOMOC ON
    AUTORCC ON
)

qt_add_qml_module(GeoToyAppShell
    URI GeoToy.AppShell
    VERSION 1.0
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/GeoToy/AppShell"
    OUTPUT_TARGETS GEOTOY_APPSHELL_QML_EXTRA_TARGETS
    NO_PLUGIN
    IMPORTS GeoToy.Controls
    QML_FILES
        CmdInputArea.qml
        FramelessResizeHandles.qml
        MainStatusBar.qml
        MainToolBar.qml
        MiniViewer2d.qml
        ServerConfigSection.qml
        SplashScreen.qml
        WindowCaptionButtons.qml
)

target_link_libraries(GeoToyAppShell
PUBLIC
    GeoToyControls
)

set(GEOCONTROLS_EXPORT_TARGETS
    ${GEOCONTROLS_EXPORT_TARGETS}
    GeoToyAppShell
    ${GEOTOY_APPSHELL_QML_EXTRA_TARGETS}
    PARENT_SCOPE
)
