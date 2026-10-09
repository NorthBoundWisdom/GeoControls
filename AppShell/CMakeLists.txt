qt_add_library(GeoControlsAppShell STATIC)
set_target_properties(GeoControlsAppShell PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    EXPORT_NAME AppShell
)

get_target_property(geocontrols_controls_qml_directory
    GeoControlsControls QT_QML_MODULE_OUTPUT_DIRECTORY)
get_filename_component(geocontrols_controls_qml_import_root
    "${geocontrols_controls_qml_directory}" DIRECTORY)

qt_add_qml_module(GeoControlsAppShell
    URI GeoControls.AppShell
    VERSION 1.0
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/GeoControls/AppShell"
    OUTPUT_TARGETS GEOCONTROLS_APPSHELL_QML_EXTRA_TARGETS
    NO_PLUGIN
    IMPORTS GeoControls
    IMPORT_PATH "${geocontrols_controls_qml_import_root}"
    QML_FILES
        CmdInputArea.qml
        FramelessResizeHandles.qml
        MainStatusBar.qml
        MainToolBar.qml
        MiniViewer2d.qml
        RouteView.qml
        ServerConfigSection.qml
        SplashScreen.qml
        WindowCaptionButtons.qml
)

target_link_libraries(GeoControlsAppShell
PUBLIC
    GeoControlsControls
)

set(GEOCONTROLS_EXPORT_TARGETS
    ${GEOCONTROLS_EXPORT_TARGETS}
    GeoControlsAppShell
    ${GEOCONTROLS_APPSHELL_QML_EXTRA_TARGETS}
    PARENT_SCOPE
)
