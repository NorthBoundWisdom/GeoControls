set(GUIDEMO_RESOURCES
    testnetwork.qrc
)

set(GUIDEMO_SOURCES
    main.cpp
    ${GUIDEMO_RESOURCES}
)

qt_add_executable(GuiDemo ${GUIDEMO_SOURCES})

set_target_properties(GuiDemo PROPERTIES
    AUTOMOC ON
    AUTOUIC ON
    AUTORCC ON
)

if(APPLE)
    set_target_properties(GuiDemo PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "GeoControls GuiDemo"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.northboundwisdom.geocontrols.guidemo"
    )
    add_custom_command(TARGET GuiDemo POST_BUILD
        COMMAND ${CMAKE_COMMAND}
            -DGUIDEMO_LAUNCHER_PATH=${CMAKE_CURRENT_BINARY_DIR}/GuiDemo
            -DGUIDEMO_BUNDLE_PATH=$<TARGET_BUNDLE_DIR:GuiDemo>
            -DGUIDEMO_EXECUTABLE_PATH=$<TARGET_FILE:GuiDemo>
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/WriteLauncher.cmake
        COMMENT "Writing GuiDemo launcher"
    )
endif()

target_link_libraries(GuiDemo
PRIVATE
    GeoControlsControls
    GeoControlsAppShell
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

target_include_directories(GuiDemo
PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

qt_import_qml_plugins(GuiDemo)

if(WIN32)
    get_target_property(_guidemo_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(_guidemo_qt_bin_dir "${_guidemo_qmake_executable}" DIRECTORY)
    find_program(GUIDEMO_WINDEPLOYQT_EXECUTABLE windeployqt
        HINTS "${_guidemo_qt_bin_dir}"
        NO_DEFAULT_PATH
    )
    if(GUIDEMO_WINDEPLOYQT_EXECUTABLE)
        add_custom_command(TARGET GuiDemo POST_BUILD
            COMMAND "${GUIDEMO_WINDEPLOYQT_EXECUTABLE}"
                --verbose 0
                --qmldir "${CMAKE_SOURCE_DIR}/Controls"
                --no-translations
                --compiler-runtime
                "$<TARGET_FILE:GuiDemo>"
            COMMENT "Deploying Qt dependencies for GuiDemo"
        )
    else()
        message(WARNING "GuiDemo: windeployqt not found, Qt runtime files will not be auto-copied.")
    endif()
endif()
