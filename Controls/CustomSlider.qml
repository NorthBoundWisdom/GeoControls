import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Item {
    id: control

    property alias title: titleLabel.text
    property bool showTitle: true
    property int titleAlignment: Qt.AlignHCenter

    // Incoming host value. Not an alias of Slider.value: a live host binding such as
    // `value: presenter.temperature` would otherwise overwrite the handle on every
    // pointer move and cancel the drag.
    property real value: 0
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    readonly property alias visualValue: slider.value
    property bool showValueLabel: true
    property bool showStepButton: true
    property bool valEditable: true
    property int validatorDecimals: 1
    property string tooltipText: ""
    property int tooltipDelay: ToolTipConfig.shortDelay

    // Delayed commit support for expensive operations (e.g. contour extraction, denoise, etc.)
    // - When delayedCommit == true, user interactions (drag slider, +/- button, text edit)
    //   will start/restart an internal timer; once the user stops changing for commitDelay ms,
    //   the valueCommitted(value) signal is emitted exactly once.
    // - When delayedCommit == false, valueCommitted(value) is emitted immediately on user change.
    property bool delayedCommit: false
    property int commitDelay: 30
    signal valueEdited(double value)
    signal valueCommitted(double value)

    property bool showReset: false
    property real resetValue: 0
    readonly property bool isAtResetValue: Math.abs(slider.value - resetValue) < Math.max(1e-6, Math.abs(stepSize) * 0.5)
    signal resetRequested

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color buttonColor: Theme.buttonColor
    property color buttonTextColor: Theme.buttonTextColor
    property color highlightColor: Theme.highlightColor
    property color midColor: Theme.midColor
    property color buttonHoveredColor: Theme.buttonHoveredColor
    readonly property real sliderTrackIdleThickness: Math.max(Fonts.size4, 4)
    readonly property real sliderTrackActiveThickness: Math.max(Fonts.size6, sliderTrackIdleThickness + 2)

    // Guard flag to prevent recursive updates between value/text changes
    property bool _suppressSync: false
    property var _pausedFlickable: null
    property bool _pausedFlickableWasInteractive: false

    // Compact mode: when width is too small, hide buttons and min/max labels
    property int compactModeThreshold: Fonts.iconButtonSize * 6  // Minimum width before entering compact mode
    readonly property bool isCompactMode: width < compactModeThreshold

    Layout.fillWidth: true
    implicitWidth: Math.max(columnLayout.implicitWidth, Fonts.size180)
    implicitHeight: columnLayout.implicitHeight
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    Timer {
        id: commitTimer
        interval: commitDelay
        repeat: false
        onTriggered: {
            control.valueCommitted(slider.value)
        }
    }

    function valuesAlmostEqual(left, right) {
        return Math.abs(left - right) < Math.max(1e-6, Math.abs(slider.stepSize) * 0.5)
    }

    function applyIncomingValue() {
        if (control._suppressSync || slider.pressed)
            return
        if (control.valuesAlmostEqual(slider.value, control.value))
            return
        control._suppressSync = true
        slider.value = control.value
        control._suppressSync = false
    }

    function requestCommit() {
        if (control._suppressSync || !control.enabled)
            return
        if (control.delayedCommit) {
            commitTimer.restart()
        } else {
            control.valueCommitted(slider.value)
        }
    }

    function resetToDefault() {
        if (!control.enabled || control.isAtResetValue)
            return
        control._suppressSync = true
        slider.value = control.resetValue
        control._suppressSync = false
        control.resetRequested()
    }

    function findAncestorFlickable(item) {
        var current = item
        while (current) {
            if (current.flickableDirection !== undefined && current.interactive !== undefined && current.contentY !== undefined)
                return current
            current = current.parent
        }
        return null
    }

    function pauseAncestorFlickable() {
        if (control._pausedFlickable)
            return
        var flickable = findAncestorFlickable(control.parent)
        if (!flickable)
            return
        control._pausedFlickable = flickable
        control._pausedFlickableWasInteractive = flickable.interactive
        flickable.interactive = false
    }

    function resumeAncestorFlickable() {
        if (!control._pausedFlickable)
            return
        control._pausedFlickable.interactive = control._pausedFlickableWasInteractive
        control._pausedFlickable = null
        control._pausedFlickableWasInteractive = false
    }

    function updateValueLabel() {
        var rounded = slider.roundToDecimal(slider.value, control.validatorDecimals)
        var newText = rounded.toFixed(control.validatorDecimals)
        if (valueLabel.text !== newText) {
            control._suppressSync = true
            valueLabel.text = newText
            control._suppressSync = false
        }
    }

    onValueChanged: control.applyIncomingValue()
    Component.onCompleted: control.applyIncomingValue()
    Component.onDestruction: control.resumeAncestorFlickable()

    Connections {
        target: slider
        function onFromChanged() {
            control.applyIncomingValue()
        }
        function onToChanged() {
            control.applyIncomingValue()
        }
    }

    component SliderButton: Rectangle {
        id: sliderButton
        property string text: ""
        property bool down: false
        property bool hovered: false
        signal clicked

        width: height
        height: Fonts.iconButtonSize
        color: ControlState.actionFillWithColors(control.enabled, down, hovered, false, control.buttonColor, control.buttonHoveredColor, control.highlightColor, Theme.buttonDisabledColor, control.highlightColor)
        radius: ControlState.radiusSmall

        Text {
            id: buttonText
            anchors.centerIn: parent
            text: parent.text
            color: control.buttonTextColor
            font: Fonts.standardFont
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: parent.down = true
            onReleased: parent.down = false
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
            onClicked: parent.clicked()
        }
    }

    ColumnLayout {
        id: columnLayout
        width: parent.width
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: columnLayout.width
            spacing: Fonts.size4
            visible: control.showTitle || control.showReset

            CustomLabel {
                id: titleLabel
                visible: control.showTitle
                text: qsTr("Title")
                Layout.alignment: control.titleAlignment
                Layout.fillWidth: true
                color: control.enabled ? control.textColor : control.disabledTextColor
                elide: Text.ElideRight
                clip: true

                MouseArea {
                    anchors.fill: parent
                    enabled: control.showReset && control.enabled
                    onDoubleClicked: control.resetToDefault()
                }
            }

            SliderButton {
                visible: control.showReset
                text: qsTr("↺")
                Layout.preferredWidth: height
                Layout.preferredHeight: Fonts.iconButtonSize
                enabled: control.enabled && !control.isAtResetValue
                onClicked: control.resetToDefault()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.minimumHeight: Fonts.sliderButtonHeight

            SliderButton {
                id: stepButtonMinus
                text: "-"
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignLeft
                visible: control.showStepButton && !control.isCompactMode
                onClicked: {
                    slider.value -= slider.stepSize
                    control.requestCommit()
                }
            }

            Slider {
                id: slider

                function roundToDecimal(value, decimals) {
                    var factor = Math.pow(10, decimals)
                    return Math.round(value * factor) / factor
                }

                function snapToStep(value) {
                    if (stepSize <= 0)
                        return value
                    var steps = Math.round((value - from) / stepSize)
                    return from + steps * stepSize
                }

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.minimumWidth: Fonts.size80
                Layout.preferredHeight: Fonts.sliderButtonHeight
                Layout.minimumHeight: Fonts.sliderButtonHeight
                implicitWidth: Fonts.size180
                live: true
                snapMode: Slider.SnapAlways
                readonly property bool sliderTrackActive: pressed || handleHover.hovered

                onValueChanged: {
                    if (control._suppressSync)
                        return
                    control.updateValueLabel()
                }

                onMoved: {
                    if (pressed)
                        control.valueEdited(slider.value)
                    else
                        control.requestCommit()
                }

                onPressedChanged: {
                    if (pressed) {
                        control.pauseAncestorFlickable()
                        return
                    }
                    control.resumeAncestorFlickable()
                    control.requestCommit()
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: Fonts.size180
                    implicitHeight: control.sliderTrackIdleThickness
                    width: slider.availableWidth
                    height: slider.sliderTrackActive ? control.sliderTrackActiveThickness : control.sliderTrackIdleThickness
                    radius: height / 2
                    color: ControlState.trackFill(control.enabled)

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: ControlState.trackActiveFill(control.enabled)
                        radius: parent.radius
                    }
                }

                handle: Rectangle {
                    id: handleRect
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: Fonts.size20
                    implicitHeight: implicitWidth
                    width: implicitWidth
                    height: implicitHeight
                    radius: width / 2
                    color: ControlState.inputFill(control.enabled, false, handleHover.hovered || slider.pressed)
                    border.color: ControlState.handleBorder(control.enabled, slider.pressed || handleHover.hovered)
                    border.width: (handleHover.hovered || slider.pressed) ? ControlState.borderFocus : ControlState.borderThin
                    scale: (handleHover.hovered || slider.pressed) ? 1.1 : 1.0

                    HoverHandler {
                        id: handleHover
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    preventStealing: true
                    acceptedButtons: Qt.LeftButton
                    propagateComposedEvents: true
                    onPressed: function (mouse) {
                        mouse.accepted = false
                    }
                }
            }

            SliderButton {
                id: stepButtonPlus
                text: "+"
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight
                visible: control.showStepButton && !control.isCompactMode
                onClicked: {
                    slider.value += slider.stepSize
                    control.requestCommit()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            Text {
                id: minLabel
                text: slider.from.toFixed(validatorDecimals)
                Layout.alignment: Qt.AlignLeft
                visible: control.showValueLabel && !control.isCompactMode
                color: control.enabled ? control.textColor : control.disabledTextColor
                font: Fonts.standardFont
            }

            TextInput {
                id: valueLabel
                text: slider.value
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: control.showValueLabel
                readOnly: !valEditable
                selectByMouse: true
                color: control.enabled ? control.textColor : control.disabledTextColor
                font.family: Fonts.standardFont.family
                font.pixelSize: Fonts.standardFont.pixelSize
                font.weight: Fonts.standardFont.weight
                font.italic: Fonts.standardFont.italic
                font.bold: true

                // Store original value when editing starts
                property double originalValue: slider.value

                onActiveFocusChanged: {
                    if (activeFocus) {
                        // Store original value when entering edit mode
                        originalValue = slider.value
                    }
                }

                function applyEdit() {
                    if (!valEditable)
                        return
                    var newValue = parseFloat(valueLabel.text)
                    if (isNaN(newValue))
                        return

                    // Clamp to range
                    if (newValue < slider.from)
                        newValue = slider.from
                    if (newValue > slider.to)
                        newValue = slider.to

                    // Snap to step size
                    var snappedValue = slider.snapToStep(newValue)

                    // Apply rounding for display consistency
                    var rounded = slider.roundToDecimal(snappedValue, validatorDecimals)
                    var newText = rounded.toFixed(validatorDecimals)
                    if (valueLabel.text !== newText)
                        valueLabel.text = newText

                    // Update slider value only if actually different, guarded to avoid loop
                    if (rounded !== slider.value) {
                        control._suppressSync = true
                        slider.value = rounded
                        control._suppressSync = false
                    }

                    // Text-based changes are also user-driven; trigger (possibly delayed) commit.
                    control.requestCommit()

                    // Exit edit mode
                    focus = false
                }

                function cancelEdit() {
                    // Restore original value and text
                    control._suppressSync = true
                    slider.value = originalValue
                    var rounded = slider.roundToDecimal(originalValue, validatorDecimals)
                    valueLabel.text = rounded.toFixed(validatorDecimals)
                    control._suppressSync = false

                    // Exit edit mode
                    focus = false
                }

                onEditingFinished: {
                    applyEdit()
                }

                Keys.onReturnPressed: {
                    applyEdit()
                    event.accepted = true
                }

                Keys.onEnterPressed: {
                    applyEdit()
                    event.accepted = true
                }

                Keys.onEscapePressed: {
                    cancelEdit()
                    event.accepted = true
                }

                validator: DoubleValidator {
                    decimals: validatorDecimals
                }
            }

            Text {
                id: maxLabel
                text: slider.to.toFixed(validatorDecimals)
                Layout.alignment: Qt.AlignRight
                visible: control.showValueLabel && !control.isCompactMode
                color: control.enabled ? control.textColor : control.disabledTextColor
                font: Fonts.standardFont
            }
        }
    }

    // Tooltip support
    MouseArea {
        id: tooltipMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: -1
    }

    CustomToolTip {
        visible: tooltipText !== "" && tooltipMouseArea.containsMouse && enabled
        delay: tooltipDelay
        text: tooltipText
    }
}
