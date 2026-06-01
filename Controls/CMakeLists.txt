set_source_files_properties(Fonts.qml Theme.qml ToolTipConfig.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_library(GeoControlsControls STATIC)
set_target_properties(GeoControlsControls PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    EXPORT_NAME Controls
)

qt_add_qml_module(GeoControlsControls
    URI GeoControls
    VERSION 1.0
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/GeoControls"
    OUTPUT_TARGETS GEOCONTROLS_CONTROLS_QML_EXTRA_TARGETS
    NO_PLUGIN
    QML_FILES
        ChartLine.qml
        ChartPie.qml
        ChartScatter.qml
        ColorTabBar.qml
        ColorTabButton.qml
        ConfirmationButtons.qml
        CustomAxisSwitcher.qml
        CustomBinarySwitch.qml
        CustomButton.qml
        CustomChart.qml
        CustomCheckBox.qml
        CustomColorPicker.qml
        CustomComboBox.qml
        CustomEditPanel.qml
        CustomGroupBox.qml
        CustomIconActionButton.qml
        CustomLabel.qml
        CustomMatrixInput.qml
        CustomPanelCheckButton.qml
        CustomPanelDisclosureButton.qml
        CustomPanelGlyphButton.qml
        CustomPanelIconButton.qml
        CustomPlusMinusControl.qml
        CustomRadioButton.qml
        CustomRangeSlider.qml
        CustomRectangle.qml
        CustomSlider.qml
        CustomSpinBox.qml
        CustomSwitch.qml
        CustomTabBar.qml
        CustomTabBarEven.qml
        CustomTabButton.qml
        CustomTextField.qml
        CustomToolButton.qml
        CustomToolTip.qml
        CustomVector3SpinBox.qml
        DialogShell.qml
        EqualActionButtonRow.qml
        ExtendLine.qml
        Fonts.qml
        MessageDialog.qml
        QmlExportImageOptionsDialogPage.qml
        QmlFileDialogPage.qml
        QmlInputDialogPage.qml
        QmlKeyValueDialogPage.qml
        QmlListDialogPage.qml
        RButtonMenu.qml
        SelectionBox.qml
        SliderWithPresets.qml
        Theme.qml
        ToolTipConfig.qml
        TwoSideSpinBox.qml
    SOURCES
        QmlExportImageOptionsDialog.cpp
        QmlExportImageOptionsDialog.h
        QmlFileDialog.cpp
        QmlFileDialog.h
        QmlInputDialog.cpp
        QmlInputDialog.h
        QmlKeyValueDialog.cpp
        QmlKeyValueDialog.h
        QmlListDialog.cpp
        QmlListDialog.h
        QmlMessageBox.cpp
        QmlMessageBox.h
        ThemeHelper.cpp
        ThemeHelper.h
        Vector3SpinBoxWrapper.cpp
        Vector3SpinBoxWrapper.h
)

target_include_directories(GeoControlsControls
PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/GeoControls>
)

target_sources(GeoControlsControls
PRIVATE
    icons.qrc
)

target_link_libraries(GeoControlsControls
PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
)

if(GEOCONTROLS_INSTALL_SDK)
    install(
        DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/GeoControls/Controls
        FILES_MATCHING PATTERN "*.h"
    )
endif()

set(GEOCONTROLS_EXPORT_TARGETS
    GeoControlsControls
    ${GEOCONTROLS_CONTROLS_QML_EXTRA_TARGETS}
    PARENT_SCOPE
)
