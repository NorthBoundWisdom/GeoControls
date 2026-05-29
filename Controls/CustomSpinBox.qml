import QtQuick 2.15
import QtQuick.Controls 2.15
import GeoToy.Controls 1.0

SpinBox {
    id: control
    hoverEnabled: enabled
    focusPolicy: Qt.StrongFocus
    font: Fonts.standardFont

    // custom properties
    property int defaultHeight: Fonts.inputFieldHeight
    property int defaultRadius: Fonts.size2
    property int defaultPadding: Fonts.size3
    property int buttonWidth: Fonts.size16
    property int buttonSpacing: Fonts.size1
    property int minWidth: Fonts.size50
    property int minTextWidth: Fonts.size24

    // text color properties
    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color placeholderColor: Theme.placeholderTextColor

    // background color properties
    property color backgroundColor: Theme.buttonColor
    property color hoveredBackgroundColor: Theme.buttonHoveredColor
    property color pressedBackgroundColor: Theme.buttonPressedColor
    property color disabledBackgroundColor: Theme.buttonDisabledColor

    // border color properties
    property color borderColor: Theme.midColor
    property color focusedBorderColor: Theme.highlightColor
    property color hoveredBorderColor: Theme.highlightColor
    property color darkColor: Theme.darkColor
    property color shadowColor: Theme.shadowColor

    // Float support properties
    required property int decimals
    property double realValue: 0.0
    property double realFrom: -999999.0
    property double realTo: 999999.0
    property double realStepSize: 1.0
    signal editingCommitted(double realValue)

    implicitHeight: defaultHeight
    implicitWidth: max(Fonts.size50, minWidth)

    // Guard flag to prevent recursive updates between `value` and `realValue`.
    property bool _syncing: false

    // Use stable references that aren't affected by delegate/model role shadowing.
    readonly property var _Number: (0).constructor

    // Clamp to 32-bit signed int range (SpinBox uses `int` internally).
    readonly property int _intMin: -2147483648
    readonly property int _intMax: 2147483647
    readonly property bool _hasActiveFocus: control.activeFocus || (input && input.activeFocus)
    readonly property int effectiveButtonWidth: {
        var maxAllowed = width - minTextWidth - Fonts.size6;
        var clampedMax = max(Fonts.size12, maxAllowed);
        return max(Fonts.size12, min(buttonWidth, clampedMax));
    }

    function clampInt(v, lo, hi) {
        if (v < lo)
            return lo;
        if (v > hi)
            return hi;
        return v;
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    function max(a, b) {
        return a > b ? a : b;
    }

    function abs(v) {
        return v < 0 ? -v : v;
    }

    function isFiniteNumber(v) {
        return (typeof v === "number") && (v === v) && (v !== _Number.POSITIVE_INFINITY) && (v !== _Number.NEGATIVE_INFINITY);
    }

    function roundToInt(v) {
        var n = _Number(v);
        if (!isFiniteNumber(n))
            return 0;
        if (n >= _intMax)
            return _intMax;
        if (n <= _intMin)
            return _intMin;
        var r = n >= 0 ? (n + 0.5) : (n - 0.5);
        return r | 0;
    }

    function pow10(exp) {
        var e = exp | 0;
        if (e <= 0)
            return 1;
        var r = 1;
        for (var i = 0; i < e; i++)
            r *= 10;
        return r;
    }

    readonly property int _decimals: decimals > 0 ? decimals : 0
    readonly property int scaleFactor: pow10(_decimals)

    readonly property int _fromIntRaw: roundToInt(realFrom * scaleFactor)
    readonly property int _toIntRaw: roundToInt(realTo * scaleFactor)
    readonly property int _fromInt: min(_fromIntRaw, _toIntRaw)
    readonly property int _toInt: max(_fromIntRaw, _toIntRaw)
    readonly property int _stepInt: max(1, roundToInt(abs(realStepSize) * scaleFactor))

    from: _fromInt
    to: _toInt
    stepSize: _stepInt

    function _syncValueFromReal() {
        var newValue = roundToInt(realValue * scaleFactor);
        newValue = clampInt(newValue, from, to);
        if (value === newValue)
            return;
        _syncing = true;
        value = newValue;
        _syncing = false;
    }

    function _syncRealFromValue() {
        var newReal = value / scaleFactor;
        if (abs(realValue - newReal) <= _Number.EPSILON)
            return;
        _syncing = true;
        realValue = newReal;
        _syncing = false;
    }

    function _requestActiveFocus() {
        if (_hasActiveFocus)
            return;
        forceActiveFocus();
    }

    function _refreshDisplayedText(selectAll) {
        if (!input)
            return;
        input.text = textFromValue(value, locale);
        if (selectAll && input.activeFocus)
            input.selectAll();
    }

    onValueChanged: {
        if (_syncing)
            return;
        _syncRealFromValue();
    }

    onRealValueChanged: {
        if (_syncing)
            return;
        _syncValueFromReal();
    }

    onFromChanged: {
        if (_syncing)
            return;
        _syncValueFromReal();
    }
    onToChanged: {
        if (_syncing)
            return;
        _syncValueFromReal();
    }
    onScaleFactorChanged: {
        if (_syncing)
            return;
        _syncValueFromReal();
    }

    Component.onCompleted: {
        _syncValueFromReal();
        _refreshDisplayedText(false);
    }

    onValueModified: {
        _requestActiveFocus();
        _refreshDisplayedText(true);
        _syncRealFromValue();
        editingCommitted(realValue);
    }

    textFromValue: function (v, locale) {
        return _Number(v / scaleFactor).toLocaleString(locale, "f", _decimals);
    }

    valueFromText: function (text, locale) {
        var s = String(text).trim();
        if (s.length === 0)
            return control.value;
        var parsed = _Number.fromLocaleString(locale, s);
        if (!isFiniteNumber(parsed))
            return control.value;
        return roundToInt(parsed * scaleFactor);
    }

    // contentItem - the text input area
    contentItem: TextInput {
        id: input
        z: 2

        font: control.font
        color: control.enabled ? control.textColor : control.disabledTextColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        clip: true

        anchors.left: parent.left
        anchors.leftMargin: Fonts.size2
        anchors.right: parent.right
        anchors.rightMargin: control.effectiveButtonWidth + Fonts.size2
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        leftPadding: Fonts.size1
        rightPadding: Fonts.size1

        readOnly: !control.editable
        selectByMouse: true
        activeFocusOnPress: true
        cursorVisible: activeFocus
        mouseSelectionMode: TextInput.SelectCharacters
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        validator: DoubleValidator {
            bottom: control.min(control.realFrom, control.realTo)
            top: control.max(control.realFrom, control.realTo)
            decimals: control._decimals
            notation: DoubleValidator.StandardNotation
        }

        Binding {
            target: input
            property: "text"
            value: control.textFromValue(control.value, control.locale)
            when: !input.activeFocus
        }

        function commit() {
            if (!control.editable)
                return;
            var newValue = control.valueFromText(text, control.locale);
            control.value = newValue;
            text = control.textFromValue(control.value, control.locale);
            control.editingCommitted(control.realValue);
        }

        onActiveFocusChanged: {
            if (activeFocus) {
                text = control.textFromValue(control.value, control.locale);
                selectAll();
            } else {
                commit();
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_PageUp) {
                control.increase();
                control._refreshDisplayedText(true);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_PageDown) {
                control.decrease();
                control._refreshDisplayedText(true);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                commit();
                input.focus = false;
                // Trigger focus-based commit handlers in parent code, then return focus to this control.
                control.focus = false;
                Qt.callLater(function () {
                    control.forceActiveFocus();
                });
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                text = control.textFromValue(control.value, control.locale);
                input.focus = false;
                control.focus = false;
                Qt.callLater(function () {
                    control.forceActiveFocus();
                });
                event.accepted = true;
            }
        }

        // Show full text as tooltip when text is clipped
        CustomToolTip {
            visible: control.hovered && (contentWidth > width)
            delay: ToolTipConfig.shortDelay
            text: control.textFromValue(control.value, control.locale)
        }
    }

    // up button
    up.indicator: Rectangle {
        id: upIndicator
        x: control.width - control.effectiveButtonWidth
        y: 0
        width: control.effectiveButtonWidth
        height: control.height / 2
        radius: 0
        z: 1

        color: {
            if (!control.enabled)
                return control.disabledBackgroundColor;
            if (control.up.pressed)
                return control.pressedBackgroundColor;
            if (control.up.hovered)
                return control.hoveredBackgroundColor;
            return control.backgroundColor;
        }

        border.color: {
            if (!control.enabled)
                return control.borderColor;
            if (control.visualFocus || control._hasActiveFocus)
                return control.focusedBorderColor;
            if (control.up.hovered)
                return control.hoveredBorderColor;
            return control.borderColor;
        }
        border.width: (control.visualFocus || control._hasActiveFocus || control.up.hovered) ? Fonts.size2 : Fonts.size1

        opacity: control.up.hovered ? 0.8 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Text {
            anchors.centerIn: parent
            text: "▲"
            color: control.enabled ? control.textColor : control.disabledTextColor
            font.pixelSize: Fonts.scaledFontPixelSize(9)
        }
    }

    // down button
    down.indicator: Rectangle {
        id: downIndicator
        x: control.width - control.effectiveButtonWidth
        y: control.height / 2
        width: control.effectiveButtonWidth
        height: control.height / 2
        radius: 0
        z: 1

        color: {
            if (!control.enabled)
                return control.disabledBackgroundColor;
            if (control.down.pressed)
                return control.pressedBackgroundColor;
            if (control.down.hovered)
                return control.hoveredBackgroundColor;
            return control.backgroundColor;
        }

        border.color: {
            if (!control.enabled)
                return control.borderColor;
            if (control.visualFocus || control._hasActiveFocus)
                return control.focusedBorderColor;
            if (control.down.hovered)
                return control.hoveredBorderColor;
            return control.borderColor;
        }
        border.width: (control.visualFocus || control._hasActiveFocus || control.down.hovered) ? Fonts.size2 : Fonts.size1

        opacity: control.down.hovered ? 0.8 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Text {
            anchors.centerIn: parent
            text: "▼"
            color: control.enabled ? control.textColor : control.disabledTextColor
            font.pixelSize: Fonts.scaledFontPixelSize(9)
        }
    }

    // background
    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.defaultHeight
        color: {
            if (!control.enabled)
                return control.disabledBackgroundColor;
            if (control.pressed)
                return control.pressedBackgroundColor;
            if (control.hovered)
                return control.hoveredBackgroundColor;
            return control.backgroundColor;
        }
        border.color: {
            if (!control.enabled)
                return control.borderColor;
            if (control.visualFocus || control._hasActiveFocus)
                return control.focusedBorderColor;
            if (control.hovered)
                return control.hoveredBorderColor;
            return control.borderColor;
        }
        border.width: (control.visualFocus || control._hasActiveFocus || control.hovered) ? Fonts.size2 : Fonts.size1
        radius: defaultRadius
        opacity: control.hovered ? 0.9 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        // Add a separator line between input area and buttons
        Rectangle {
            x: parent.width - control.effectiveButtonWidth - Fonts.size1
            y: Fonts.size1
            width: Fonts.size1
            height: parent.height - Fonts.size2
            color: control.borderColor
            opacity: 0.6
            z: 2
            visible: control.width > 40
        }

        // Add a separator line between up and down buttons
        Rectangle {
            x: parent.width - control.effectiveButtonWidth
            y: parent.height / 2 - 0.5
            width: control.effectiveButtonWidth
            height: Fonts.size1
            color: control.borderColor
            opacity: 0.6
            z: 2
        }
    }

    // Helper functions for easier usage
    function setRealValue(val) {
        realValue = val;
    }

    function getRealValue() {
        return realValue;
    }
}
