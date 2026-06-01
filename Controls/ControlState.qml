pragma Singleton

import QtQuick 2.15

Item {
    id: controlState

    visible: false

    readonly property int radiusSmall: Fonts.size2
    readonly property int radiusMedium: Fonts.size4
    readonly property int borderThin: Fonts.size1
    readonly property int borderFocus: Fonts.size2
    readonly property int iconGap: Fonts.size6
    readonly property int textPadding: Fonts.size6
    readonly property int compactPadding: Fonts.size4
    readonly property int minInputHeight: Fonts.inputFieldHeight
    readonly property int minButtonHeight: Fonts.inputFieldHeight

    readonly property int animationFast: 80
    readonly property int animationNormal: 120

    function actionFill(enabled, pressed, hovered, checked) {
        if (!enabled) {
            return Theme.buttonDisabledColor
        }
        if (checked) {
            return Theme.highlightColor
        }
        if (pressed) {
            return Theme.buttonPressedColor
        }
        if (hovered) {
            return Theme.buttonHoveredColor
        }
        return Theme.buttonColor
    }

    function actionFillWithColors(enabled, pressed, hovered, checked, baseColor, hoveredColor, pressedColor, disabledColor, checkedColor) {
        if (!enabled) {
            return disabledColor
        }
        if (checked) {
            return checkedColor
        }
        if (pressed) {
            return pressedColor
        }
        if (hovered) {
            return hoveredColor
        }
        return baseColor
    }

    function actionText(enabled, pressed, checked) {
        if (!enabled) {
            return Theme.disabledTextColor
        }
        if (checked || pressed) {
            return Theme.highlightedTextColor
        }
        return Theme.buttonTextColor
    }

    function actionTextWithColors(enabled, pressed, checked, textColor, disabledTextColor, highlightedTextColor) {
        if (!enabled) {
            return disabledTextColor
        }
        if (checked || pressed) {
            return highlightedTextColor
        }
        return textColor
    }

    function actionBorder(enabled, pressed, hovered, focused, checked) {
        if (!enabled) {
            return Theme.midColor
        }
        if (focused || checked || pressed || hovered) {
            return Theme.highlightColor
        }
        return Theme.midColor
    }

    function inputFill(enabled, readOnly, hovered) {
        if (!enabled) {
            return Theme.buttonDisabledColor
        }
        if (readOnly) {
            return Theme.buttonColor
        }
        if (hovered) {
            return Theme.railSurfaceColor
        }
        return Theme.inputSurfaceColor
    }

    function inputBorder(enabled, focused, hovered, readOnly) {
        if (!enabled) {
            return Theme.midColor
        }
        if (focused) {
            return Theme.highlightColor
        }
        if (hovered && !readOnly) {
            return Theme.highlightColor
        }
        return Theme.midColor
    }

    function inputText(enabled, empty) {
        if (!enabled) {
            return Theme.disabledTextColor
        }
        return empty ? Theme.placeholderTextColor : Theme.textColor
    }

    function selectionFill(enabled, checked, pressed, hovered) {
        if (!enabled) {
            return Theme.buttonDisabledColor
        }
        if (checked) {
            return Theme.highlightColor
        }
        if (pressed) {
            return Theme.buttonPressedColor
        }
        if (hovered) {
            return Theme.railSurfaceColor
        }
        return Theme.baseColor
    }

    function selectionMark(enabled) {
        return enabled ? Theme.highlightedTextColor : Theme.disabledTextColor
    }

    function selectionBorder(enabled, checked, pressed, hovered, focused) {
        if (!enabled) {
            return Theme.midColor
        }
        if (checked || pressed || hovered || focused) {
            return Theme.highlightColor
        }
        return Theme.midColor
    }

    function trackFill(enabled) {
        return enabled ? Theme.buttonColor : Theme.buttonDisabledColor
    }

    function trackActiveFill(enabled) {
        return enabled ? Theme.highlightColor : Theme.midColor
    }

    function handleBorder(enabled, active) {
        if (!enabled) {
            return Theme.midColor
        }
        return active ? Theme.highlightColor : Theme.midColor
    }
}
