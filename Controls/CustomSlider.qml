import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Item {
    id: control

    property alias title: titleLabel.text
    property bool showTitle: true
    property int titleAlignment: Qt.AlignHCenter

    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
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
    signal valueCommitted(double value)

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color buttonColor: Theme.buttonColor
    property color buttonTextColor: Theme.buttonTextColor
    property color highlightColor: Theme.highlightColor
    property color midColor: Theme.midColor
    property color buttonHoveredColor: Theme.lightColor
    readonly property real sliderTrackIdleThickness: Math.max(1, Fonts.size4 / 3)
    readonly property real sliderTrackActiveThickness: Math.max(sliderTrackIdleThickness, Fonts.size4 * 2 / 3)

    // Guard flag to prevent recursive updates between value/text changes
    property bool _suppressSync: false

    // Compact mode: when width is too small, hide buttons and min/max labels
    property int compactModeThreshold: Fonts.iconButtonSize * 6  // Minimum width before entering compact mode
    readonly property bool isCompactMode: width < compactModeThreshold

    width: parent.width
    implicitHeight: columnLayout.implicitHeight
    implicitWidth: columnLayout.implicitWidth
    height: implicitHeight

    Timer {
        id: commitTimer
        interval: commitDelay
        repeat: false
        onTriggered: {
            control.valueCommitted(slider.value);
        }
    }

    function requestCommit() {
        if (control._suppressSync || !control.enabled)
            return;
        if (control.delayedCommit) {
            commitTimer.restart();
        } else {
            control.valueCommitted(slider.value);
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
        color: down ? control.highlightColor : hovered ? control.buttonHoveredColor : control.buttonColor
        radius: Fonts.size2

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

        CustomLabel {
            id: titleLabel
            visible: control.showTitle
            text: qsTr("Title")
            Layout.alignment: control.titleAlignment
            Layout.fillWidth: true
            Layout.maximumWidth: columnLayout.width
            color: control.enabled ? control.textColor : control.disabledTextColor
            elide: Text.ElideRight
            clip: true
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
                    slider.value -= slider.stepSize;
                    control.requestCommit();
                }
            }

            Slider {
                id: slider

                function roundToDecimal(value, decimals) {
                    var factor = Math.pow(10, decimals);
                    return Math.round(value * factor) / factor;
                }

                function snapToStep(value) {
                    if (stepSize <= 0)
                        return value;
                    var steps = Math.round((value - from) / stepSize);
                    return from + steps * stepSize;
                }

                function valueToPosition(value) {
                    if (to === from)
                        return 0;
                    var ratio = (value - from) / (to - from);
                    return slider.leftPadding + ratio * (slider.availableWidth - handleRect.width);
                }

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: Fonts.sliderButtonHeight
                Layout.minimumHeight: Fonts.sliderButtonHeight
                value: 0
                // Add this property to force alignment to the step value
                snapMode: Slider.SnapAlways
                readonly property bool sliderTrackActive: pressed || handleMouseArea.containsMouse || handleMouseArea.drag.active

                // Keep rounding, but make the update idempotent and guarded to avoid loops
                onValueChanged: {
                    if (control._suppressSync)
                        return;
                    var rounded = roundToDecimal(value, validatorDecimals);
                    var newText = rounded.toFixed(validatorDecimals);
                    if (valueLabel.text !== newText) {
                        control._suppressSync = true;
                        valueLabel.text = newText;
                        control._suppressSync = false;
                    }
                    // Force update handle position when value changes programmatically
                    // This ensures handle position updates even when set via code
                    Qt.callLater(function () {
                        if (slider.availableWidth > 0 && slider.availableWidth >= handleRect.width) {
                            var pos = isNaN(slider.visualPosition) ? 0 : Math.max(0, Math.min(1, slider.visualPosition));
                            handleRect.x = slider.leftPadding + pos * (slider.availableWidth - handleRect.width);
                        }
                    });
                }

                // When slider is released (e.g., after clicking on the track), trigger commit
                onPressedChanged: {
                    if (!pressed) {
                        control.requestCommit();
                    }
                }

                // Custom style
                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: slider.availableWidth
                    height: slider.sliderTrackActive ? control.sliderTrackActiveThickness : control.sliderTrackIdleThickness
                    radius: height / 2
                    color: control.buttonColor
                    opacity: Theme.appearance == 0 ? 0.3 : 0.8

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: control.highlightColor
                        opacity: slider.pressed ? 0.8 : 1.0
                        radius: parent.radius
                    }
                }

                handle: Rectangle {
                    id: handleRect
                    // Position is manually controlled to ensure synchronization with value
                    // Use visualPosition (same as blue bar) to ensure consistency, especially during initialization
                    // During drag, let handle follow mouse freely; otherwise update position based on value
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: Fonts.size20
                    height: width
                    radius: width / 2
                    color: control.buttonColor
                    border.color: {
                        if (slider.pressed || handleMouseArea.drag.active || handleMouseArea.containsMouse) {
                            return control.highlightColor;
                        } else {
                            return control.midColor;
                        }
                    }
                    border.width: (handleMouseArea.containsMouse || slider.pressed || handleMouseArea.drag.active) ? Fonts.size2 : Fonts.size1

                    // Force update position when visualPosition or availableWidth changes
                    // This ensures handle position updates even when value is set programmatically
                    // But skip during drag to allow free movement
                    function updatePosition() {
                        if (handleMouseArea.drag.active) {
                            return; // Don't update position during drag - let it follow mouse
                        }
                        if (slider.availableWidth > 0 && slider.availableWidth >= handleRect.width) {
                            var pos = isNaN(slider.visualPosition) ? 0 : Math.max(0, Math.min(1, slider.visualPosition));
                            handleRect.x = slider.leftPadding + pos * (slider.availableWidth - handleRect.width);
                        }
                    }

                    Component.onCompleted: {
                        updatePosition();
                    }

                    // Monitor visualPosition and availableWidth changes to ensure position updates
                    // But skip during drag to allow free movement
                    Connections {
                        target: slider
                        function onVisualPositionChanged() {
                            if (!handleMouseArea.drag.active) {
                                handleRect.updatePosition();
                            }
                        }
                        function onAvailableWidthChanged() {
                            if (!handleMouseArea.drag.active) {
                                handleRect.updatePosition();
                            }
                        }
                    }

                    scale: (handleMouseArea.containsMouse || slider.pressed || handleMouseArea.drag.active) ? 1.1 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    MouseArea {
                        id: handleMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        // Store the original value when drag starts
                        property double dragStartValue: slider.value
                        property bool isDragging: false

                        drag.target: parent
                        drag.axis: Drag.XAxis
                        drag.minimumX: slider.leftPadding
                        drag.maximumX: slider.leftPadding + slider.availableWidth - parent.width

                        onPressed: {
                            // Record the starting value when drag begins
                            dragStartValue = slider.value;
                            isDragging = true;
                        }

                        onPositionChanged: {
                            if (drag.active) {
                                // Calculate value based on handle's absolute position
                                var handleX = parent.x - slider.leftPadding;
                                var denom = slider.availableWidth - handleRect.width;
                                if (denom <= 0) {
                                    return;
                                }
                                var ratio = handleX / denom;
                                ratio = Math.max(0, Math.min(1, ratio));
                                var rawValue = slider.from + ratio * (slider.to - slider.from);

                                // During drag, allow handle to follow mouse freely
                                // Calculate snapped value for display
                                var snappedValue = slider.snapToStep(rawValue);
                                snappedValue = Math.max(slider.from, Math.min(slider.to, snappedValue));

                                // Update the value to the snapped value for display
                                // Position updates are suppressed during drag (checked in updatePosition)
                                // Also directly update the display text during drag to ensure UI updates
                                control._suppressSync = true;
                                slider.value = snappedValue;
                                // Directly update display text during drag to ensure it updates
                                var rounded = slider.roundToDecimal(snappedValue, control.validatorDecimals);
                                var newText = rounded.toFixed(control.validatorDecimals);
                                if (valueLabel.text !== newText) {
                                    valueLabel.text = newText;
                                }
                                control._suppressSync = false;
                            }
                        }

                        onReleased: {
                            isDragging = false;

                            // Calculate the final snapped value based on current handle position
                            var handleX = parent.x - slider.leftPadding;
                            var denom = slider.availableWidth - handleRect.width;
                            if (denom <= 0) {
                                control.requestCommit();
                                return;
                            }
                            var ratio = handleX / denom;
                            ratio = Math.max(0, Math.min(1, ratio));
                            var rawValue = slider.from + ratio * (slider.to - slider.from);
                            var snappedValue = slider.snapToStep(rawValue);
                            snappedValue = Math.max(slider.from, Math.min(slider.to, snappedValue));

                            // Check if we've actually moved to a different step value
                            // Use a small epsilon to account for floating point precision
                            var epsilon = Math.max(1e-10, Math.abs(slider.stepSize) * 1e-6);
                            if (Math.abs(snappedValue - dragStartValue) < epsilon) {
                                // Reset to original value - user didn't move enough to change the value
                                control._suppressSync = true;
                                slider.value = dragStartValue;
                                control._suppressSync = false;
                            } else {
                                // Update to the new snapped value
                                control._suppressSync = true;
                                slider.value = snappedValue;
                                control._suppressSync = false;
                            }

                            // Force synchronization: update position based on final value
                            var finalValue = slider.value;
                            var finalRatio = (finalValue - slider.from) / (slider.to - slider.from);
                            var correctX = slider.leftPadding + finalRatio * (slider.availableWidth - handleRect.width);
                            parent.x = correctX;

                            // When user releases the handle after dragging, trigger (possibly delayed) commit
                            control.requestCommit();
                        }
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
                    slider.value += slider.stepSize;
                    control.requestCommit();
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
                        originalValue = slider.value;
                    }
                }

                function applyEdit() {
                    if (!valEditable)
                        return;
                    var newValue = parseFloat(valueLabel.text);
                    if (isNaN(newValue))
                        return;

                    // Clamp to range
                    if (newValue < slider.from)
                        newValue = slider.from;
                    if (newValue > slider.to)
                        newValue = slider.to;

                    // Snap to step size
                    var snappedValue = slider.snapToStep(newValue);

                    // Apply rounding for display consistency
                    var rounded = slider.roundToDecimal(snappedValue, validatorDecimals);
                    var newText = rounded.toFixed(validatorDecimals);
                    if (valueLabel.text !== newText)
                        valueLabel.text = newText;

                    // Update slider value only if actually different, guarded to avoid loop
                    if (rounded !== slider.value) {
                        control._suppressSync = true;
                        slider.value = rounded;
                        control._suppressSync = false;
                    }

                    // Text-based changes are also user-driven; trigger (possibly delayed) commit.
                    control.requestCommit();

                    // Exit edit mode
                    focus = false;
                }

                function cancelEdit() {
                    // Restore original value and text
                    control._suppressSync = true;
                    slider.value = originalValue;
                    var rounded = slider.roundToDecimal(originalValue, validatorDecimals);
                    valueLabel.text = rounded.toFixed(validatorDecimals);
                    control._suppressSync = false;

                    // Exit edit mode
                    focus = false;
                }

                onEditingFinished: {
                    applyEdit();
                }

                Keys.onReturnPressed: {
                    applyEdit();
                    event.accepted = true;
                }

                Keys.onEnterPressed: {
                    applyEdit();
                    event.accepted = true;
                }

                Keys.onEscapePressed: {
                    cancelEdit();
                    event.accepted = true;
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
