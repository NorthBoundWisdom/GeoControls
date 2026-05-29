pragma Singleton
import QtQuick 2.15

Item {
    id: fonts
    visible: false

    property font globalFont: Theme.appFont
    property int baseFontPx: 16

    function makeScaledFont(baseFont, factor) {
        var f = Qt.font({
            family: baseFont.family,
            weight: baseFont.weight,
            italic: baseFont.italic,
            underline: baseFont.underline,
            strikeout: baseFont.strikeout
        })
        if (baseFont.pixelSize > 0) {
            f.pixelSize = Math.max(1, Math.round(baseFont.pixelSize * factor))
        } else if (baseFont.pointSize > 0) {
            f.pointSize = Math.max(1, baseFont.pointSize * factor)
        } else {
            f.pixelSize = Math.max(1, Math.round(Qt.application.font.pixelSize * factor))
        }
        return f
    }

    function makeBoldFont(baseFont) {
        var f = Qt.font({
            family: baseFont.family,
            weight: Font.Bold,
            italic: baseFont.italic,
            underline: baseFont.underline,
            strikeout: baseFont.strikeout
        })
        if (baseFont.pixelSize > 0) {
            f.pixelSize = baseFont.pixelSize
        } else if (baseFont.pointSize > 0) {
            f.pointSize = baseFont.pointSize
        } else {
            f.pixelSize = Qt.application.font.pixelSize
        }
        return f
    }

    function makeUnderlineFont(baseFont) {
        var f = Qt.font({
            family: baseFont.family,
            weight: baseFont.weight,
            italic: baseFont.italic,
            underline: true,
            strikeout: baseFont.strikeout
        })
        if (baseFont.pixelSize > 0) {
            f.pixelSize = baseFont.pixelSize
        } else if (baseFont.pointSize > 0) {
            f.pointSize = baseFont.pointSize
        } else {
            f.pixelSize = Qt.application.font.pixelSize
        }
        return f
    }

    function makeItalicFont(baseFont) {
        var f = Qt.font({
            family: baseFont.family,
            weight: baseFont.weight,
            italic: true,
            underline: baseFont.underline,
            strikeout: baseFont.strikeout
        })
        if (baseFont.pixelSize > 0) {
            f.pixelSize = baseFont.pixelSize
        } else if (baseFont.pointSize > 0) {
            f.pointSize = baseFont.pointSize
        } else {
            f.pixelSize = Qt.application.font.pixelSize
        }
        return f
    }

    function scaledFontPixelSize(px) {
        var configured = globalFont.pixelSize
        var fallback = Qt.application.font.pixelSize
        var base = configured > 0 ? configured : (fallback > 0 ? fallback : baseFontPx)
        return Math.max(1, Math.round(base * (px / baseFontPx)))
    }

    function resolvedFontPixelSize() {
        var configured = globalFont.pixelSize
        var fallback = Qt.application.font.pixelSize
        return configured > 0 ? configured : (fallback > 0 ? fallback : baseFontPx)
    }

    readonly property real uiScaleFactor: {
        var base = resolvedFontPixelSize()
        return base > 0 ? (base / baseFontPx) : 1.0
    }

    function scaledUiSize(px) {
        return Math.max(1, Math.round(px * uiScaleFactor))
    }

    property font standardFont: globalFont
    property font annotationFont: makeScaledFont(globalFont, 0.8)
    property font listFont: makeScaledFont(globalFont, 0.8)

    FontMetrics {
        id: standardFontMetricsItem
        font: standardFont
    }
    FontMetrics {
        id: listFontMetricsItem
        font: listFont
    }
    FontMetrics {
        id: annotationFontMetricsItem
        font: annotationFont
    }

    property FontMetrics standardFontMetrics: standardFontMetricsItem
    property FontMetrics listFontMetrics: listFontMetricsItem
    property FontMetrics annotationFontMetrics: annotationFontMetricsItem

    property int standardMargin: Math.round(standardFontMetrics.height * 0.6)
    property int standardSpacing: standardMargin

    property int listMargin: Math.round(listFontMetrics.height * 0.6)
    property int listSpacing: listMargin

    property int smallMargin: Math.round(standardFontMetrics.height * 0.3)
    property int smallSpacing: smallMargin

    property int iconButtonSize: Math.round(standardFontMetrics.height * 1.2)
    property int statusBarHeight: Math.round(standardFontMetrics.height * 1.2)
    property int inputFieldHeight: Math.round(standardFontMetrics.height * 1.4)
    property int separatorWidth: Math.round(standardFontMetrics.height * 3)
    property int loadingIndicatorHeight: Math.round(standardFontMetrics.height * 4)
    property int loadingDotSize: Math.round(standardFontMetrics.height * 0.4)
    property int iconSize: Math.round(standardFontMetrics.height * 0.8)
    property int toolbarHeight: Math.round(standardFontMetrics.height * 2.0)
    property int menuBarHeight: Math.round(standardFontMetrics.height * 1.2)
    property int menuFontSize: Math.round(standardFontMetrics.height)
    property int inputPadding: Math.round(standardFontMetrics.height * 0.10)
    property int tabPadding: Math.round(standardSpacing)

    property int listIndexWidth: Math.round(listFontMetrics.height * 2.0)
    property int listItemHeight: Math.round(listFontMetrics.height * 1.8)
    property int tableRowHeight: Math.round(listFontMetrics.height * 1.8)

    property int sliderButtonHeight: Math.round(standardFontMetrics.height * 1.5)
    property int infoViewHeight: Math.round(standardFontMetrics.height * 1.4)
    property int tinyMargin: Math.round(standardFontMetrics.height * 0.2)
    property int smallFontSize: Math.round(standardFontMetrics.height * 0.6)
    property int standardHeight: Math.round(standardFontMetrics.height * 1.0)
    property int groupBoxTopMargin: Math.round(standardFontMetrics.height * 1.2)
    property int toolbarButtonWidth: Math.round(standardFontMetrics.height * 8.0)

    property int panelPadding: Math.round(standardFontMetrics.height * 0.5)
    property int panelBorderRadius: Math.round(standardFontMetrics.height * 0.3)
    property int buttonBorderRadius: Math.round(standardFontMetrics.height * 0.15)
    property int iconButtonSpacing: Math.round(standardFontMetrics.height * 0.25)
    property int titleFontSize: Math.round(standardFontMetrics.height * 1.6)
    property int iconCompactSize: titleFontSize
    property int titleBarHeight: Math.round(standardFontMetrics.height * 1.6)

    // Dialog sizing (fixed for maintainability; not tied to DPI/font metrics)
    property int messageDialogWidth: 300

    // Common UI size tokens
    property int sizeBasePx: 16
    function scaledSize(px) {
        return Math.round(standardFontMetrics.height * (px / sizeBasePx))
    }
    property int size1: 1
    property int size2: scaledUiSize(2)
    property int size3: scaledUiSize(3)
    property int size4: scaledUiSize(4)
    property int size5: scaledUiSize(5)
    property int size6: scaledUiSize(6)
    property int size7: scaledUiSize(7)
    property int size8: scaledUiSize(8)
    property int size9: scaledUiSize(9)
    property int size10: scaledUiSize(10)
    property int size12: scaledUiSize(12)
    property int size14: scaledUiSize(14)
    property int size15: scaledUiSize(15)
    property int size16: scaledUiSize(16)
    property int size18: scaledUiSize(18)
    property int size20: scaledUiSize(20)
    property int size24: scaledUiSize(24)
    property int size25: scaledUiSize(25)
    property int size30: scaledSize(30)
    property int size40: scaledSize(40)
    property int size50: scaledSize(50)
    property int size60: scaledSize(60)
    property int size70: scaledSize(70)
    property int size80: scaledSize(80)
    property int size100: scaledSize(100)
    property int size120: scaledSize(120)
    property int size150: scaledSize(150)
    property int size180: scaledSize(180)
    property int size200: scaledSize(200)
    property int size300: scaledSize(300)
    property int size350: scaledSize(350)
    property int size400: scaledSize(400)
    property int size420: scaledSize(420)
    property int size480: scaledSize(480)
    property int size500: scaledSize(500)
    property int size600: scaledSize(600)
}
