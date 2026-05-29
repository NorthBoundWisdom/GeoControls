pragma Singleton

import QtQuick 2.15

Item {
    id: theme

    visible: false

    property var helper: null

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
    property color chromeDividerColor: helper ? helper.chromeDividerColor : "#c8d0da"
    property color chatComposerSurfaceColor: helper ? helper.chatComposerSurfaceColor : baseColor

    property font appFont: helper ? helper.appFont : Qt.font({
        pixelSize: 14
    })
    property font cmdlineFont: helper ? helper.cmdlineFont : appFont

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
