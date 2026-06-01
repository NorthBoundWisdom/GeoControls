pragma Singleton

import QtQuick 2.15

Item {
    id: theme

    visible: false

    QtObject {
        id: defaultHelper

        readonly property int appearance: 0

        readonly property color windowColor: "#f6f7f9"
        readonly property color windowTextColor: "#202124"
        readonly property color baseColor: "#ffffff"
        readonly property color alternateBaseColor: "#eef1f5"
        readonly property color textColor: "#202124"
        readonly property color buttonColor: "#edf0f4"
        readonly property color buttonTextColor: "#202124"
        readonly property color lightColor: "#ffffff"
        readonly property color darkColor: "#b9c0c9"
        readonly property color midlightColor: "#d8dde5"
        readonly property color midColor: "#b6bec8"
        readonly property color shadowColor: "#66000000"
        readonly property color highlightColor: "#2563eb"
        readonly property color highlightedTextColor: "#ffffff"
        readonly property color placeholderTextColor: "#7b8490"
        readonly property color accentColor: highlightColor
        readonly property color disabledTextColor: "#8f98a3"
        readonly property color buttonPressedColor: "#cbd5e1"
        readonly property color buttonHoveredColor: "#dbe4f0"
        readonly property color buttonDisabledColor: "#e2e6ec"
        readonly property color dividerColor: "#c8d0da"
        readonly property color railSurfaceColor: "#f1f4f8"
        readonly property color inputSurfaceColor: baseColor
        readonly property color pageSurfaceColor: windowColor
        readonly property color contentSurfaceColor: baseColor
        readonly property color popupSurfaceColor: baseColor
        readonly property color actionButtonColor: "#f7f9fc"
        readonly property color actionButtonHoveredColor: "#e8eef7"
        readonly property color actionButtonPressedColor: "#dae3f1"
        readonly property color actionButtonBorderColor: dividerColor
        readonly property color infoColor: "#2563eb"
        readonly property color successColor: "#15803d"
        readonly property color warningColor: "#b45309"
        readonly property color errorColor: "#dc2626"

        readonly property font appFont: Qt.font({
            pixelSize: 14
        })
        readonly property font monoFont: appFont
    }

    property var helper: defaultHelper

    signal colorsChanged
    signal fontsChanged

    property int appearance: helper ? helper.appearance : 0

    property color windowColor: helper ? helper.windowColor : "#f6f7f9"
    property color windowTextColor: helper ? helper.windowTextColor : "#202124"
    property color baseColor: helper ? helper.baseColor : "#ffffff"
    property color alternateBaseColor: helper ? helper.alternateBaseColor : "#eef1f5"
    property color textColor: helper ? helper.textColor : "#202124"
    property color buttonColor: helper ? helper.buttonColor : "#edf0f4"
    property color buttonTextColor: helper ? helper.buttonTextColor : "#202124"
    property color lightColor: helper ? helper.lightColor : "#ffffff"
    property color darkColor: helper ? helper.darkColor : "#b9c0c9"
    property color midlightColor: helper ? helper.midlightColor : "#d8dde5"
    property color midColor: helper ? helper.midColor : "#b6bec8"
    property color shadowColor: helper ? helper.shadowColor : "#66000000"
    property color highlightColor: helper ? helper.highlightColor : "#2563eb"
    property color highlightedTextColor: helper ? helper.highlightedTextColor : "#ffffff"
    property color placeholderTextColor: helper ? helper.placeholderTextColor : "#7b8490"
    property color accentColor: helper ? helper.accentColor : highlightColor
    property color disabledTextColor: helper ? helper.disabledTextColor : "#8f98a3"
    property color buttonPressedColor: helper ? helper.buttonPressedColor : "#cbd5e1"
    property color buttonHoveredColor: helper ? helper.buttonHoveredColor : "#dbe4f0"
    property color buttonDisabledColor: helper ? helper.buttonDisabledColor : "#e2e6ec"
    property color dividerColor: helper ? helper.dividerColor : "#c8d0da"
    property color railSurfaceColor: helper ? helper.railSurfaceColor : "#f1f4f8"
    property color inputSurfaceColor: helper ? helper.inputSurfaceColor : baseColor
    property color pageSurfaceColor: helper ? helper.pageSurfaceColor : windowColor
    property color contentSurfaceColor: helper ? helper.contentSurfaceColor : baseColor
    property color popupSurfaceColor: helper ? helper.popupSurfaceColor : baseColor
    property color actionButtonColor: helper ? helper.actionButtonColor : "#f7f9fc"
    property color actionButtonHoveredColor: helper ? helper.actionButtonHoveredColor : "#e8eef7"
    property color actionButtonPressedColor: helper ? helper.actionButtonPressedColor : "#dae3f1"
    property color actionButtonBorderColor: helper ? helper.actionButtonBorderColor : dividerColor
    property color infoColor: helper && helper.infoColor !== undefined ? helper.infoColor : "#2563eb"
    property color successColor: helper && helper.successColor !== undefined ? helper.successColor : "#15803d"
    property color warningColor: helper && helper.warningColor !== undefined ? helper.warningColor : "#b45309"
    property color errorColor: helper && helper.errorColor !== undefined ? helper.errorColor : "#dc2626"

    property font appFont: helper ? helper.appFont : Qt.font({
        pixelSize: 14
    })
    property font monoFont: helper ? helper.monoFont : appFont

    Connections {
        target: theme.helper
        ignoreUnknownSignals: true

        function onColorsChanged() {
            theme.colorsChanged()
        }

        function onFontsChanged() {
            theme.fontsChanged()
        }
    }
}
