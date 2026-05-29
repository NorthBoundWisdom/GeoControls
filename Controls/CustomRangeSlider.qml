import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import GeoToy.Controls 1.0

Item {
    id: control
    Layout.fillWidth: true

    property alias title: titleLabel.text
    property bool showTitle: true
    property int titleAlignment: Qt.AlignHCenter

    property double from: 0
    property double to: 100
    property double fromValue: from
    property double toValue: to
    property double stepSize: 1
    property bool showValueLabel: true
    property bool showStepButton: true
    property int validatorDecimals: 1

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color buttonColor: Theme.buttonColor
    property color buttonTextColor: Theme.buttonTextColor
    property color highlightColor: Theme.highlightColor
    property color midColor: Theme.midColor
    property color buttonHoveredColor: Theme.lightColor
    readonly property real sliderTrackIdleThickness: Math.max(1, Fonts.size4 / 3)
    readonly property real sliderTrackActiveThickness: Math.max(sliderTrackIdleThickness, Fonts.size4 * 2 / 3)

    // Guard flags to prevent recursive updates
    property bool _suppressSync: false
    property bool _draggingFrom: false
    property bool _draggingTo: false
    property bool _hoveringFrom: false
    property bool _hoveringTo: false

    width: parent.width
    height: columnLayout.implicitHeight

    function roundToDecimal(value, decimals) {
        var factor = Math.pow(10, decimals)
        return Math.round(value * factor) / factor
    }

    function valueToPosition(value) {
        if (to === from)
            return 0
        return (value - from) / (to - from)
    }

    function positionToValue(position) {
        return from + position * (to - from)
    }

    // Reset all values to default: from=-100, to=100, fromValue=0, toValue=0
    function resetToDefault() {
        _suppressSync = true
        from = -100
        to = 100
        fromValue = 0
        toValue = 0
        _suppressSync = false
    }

    TextMetrics {
        id: fontMetrics
        font: Fonts.standardFont
        text: "M"
    }

    component SliderButton: Rectangle {
        id: sliderButton
        property string text: ""
        property bool down: false
        property bool hovered: false
        signal clicked

        width: height
        height: Fonts.sliderButtonHeight
        color: down ? control.highlightColor : hovered ? control.buttonHoveredColor : control.buttonColor
        radius: Fonts.size2

        Text {
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
            color: control.enabled ? control.textColor : control.disabledTextColor
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            // Custom range slider track
            Item {
                id: sliderTrack
                Layout.fillWidth: true
                Layout.preferredHeight: Fonts.size24
                Layout.alignment: Qt.AlignVCenter

                property real trackPadding: 10
                property real trackWidth: width - trackPadding * 2
                property real trackHeight: (control._draggingFrom || control._draggingTo || control._hoveringFrom || control._hoveringTo) ? control.sliderTrackActiveThickness : control.sliderTrackIdleThickness
                property real handleWidth: 10
                property real handleHeight: 10

                // Track background
                Rectangle {
                    id: trackBackground
                    x: sliderTrack.trackPadding
                    y: sliderTrack.height / 2 - height / 2
                    width: sliderTrack.trackWidth
                    height: sliderTrack.trackHeight
                    radius: height / 2
                    color: control.buttonColor
                    opacity: Theme.appearance == 0 ? 0.3 : 0.8
                }

                // Active range highlight
                Rectangle {
                    x: sliderTrack.trackPadding + control.valueToPosition(control.fromValue) * sliderTrack.trackWidth
                    y: trackBackground.y
                    width: (control.valueToPosition(control.toValue) - control.valueToPosition(control.fromValue)) * sliderTrack.trackWidth
                    height: trackBackground.height
                    radius: trackBackground.radius
                    color: control.highlightColor
                    opacity: 1.0
                    visible: width > 0
                }

                // From handle (left) - Upward triangle
                Shape {
                    id: fromHandle
                    x: sliderTrack.trackPadding + control.valueToPosition(control.fromValue) * sliderTrack.trackWidth - width / 2
                    y: sliderTrack.height / 2
                    width: sliderTrack.handleWidth
                    height: sliderTrack.handleHeight
                    z: control._draggingFrom ? 2 : 1

                    scale: (control._draggingFrom || control._hoveringFrom) ? 1.1 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    ShapePath {
                        id: fromHandlePath
                        strokeWidth: (control._draggingFrom || control._hoveringFrom) ? 2 : 1
                        strokeColor: (control._draggingFrom || control._hoveringFrom) ? control.highlightColor : control.midColor
                        fillColor: control.buttonColor
                        startX: fromHandle.width / 2
                        startY: 0
                        PathLine {
                            x: 0
                            y: fromHandle.height
                        }
                        PathLine {
                            x: fromHandle.width
                            y: fromHandle.height
                        }
                        PathLine {
                            x: fromHandle.width / 2
                            y: 0
                        }
                    }

                    MouseArea {
                        id: fromHandleMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeHorCursor

                        drag.target: parent
                        drag.axis: Drag.XAxis
                        drag.minimumX: sliderTrack.trackPadding - parent.width / 2
                        drag.maximumX: Math.min(sliderTrack.trackPadding + sliderTrack.trackWidth - parent.width / 2, toHandle.x + toHandle.width / 2 - parent.width / 2)

                        onPressed: {
                            control._draggingFrom = true
                            control._draggingTo = false
                        }

                        onReleased: {
                            control._draggingFrom = false
                        }

                        onEntered: {
                            control._hoveringFrom = true
                        }

                        onExited: {
                            control._hoveringFrom = false
                        }

                        onPositionChanged: {
                            if (drag.active) {
                                // Calculate center position relative to track
                                var centerX = parent.x + parent.width / 2 - sliderTrack.trackPadding
                                var ratio = centerX / sliderTrack.trackWidth
                                ratio = Math.max(0, Math.min(1, ratio));

                                // Limit to not exceed toHandle center position
                                var toHandleCenterX = toHandle.x + toHandle.width / 2 - sliderTrack.trackPadding
                                var maxRatio = toHandleCenterX / sliderTrack.trackWidth
                                ratio = Math.min(ratio, maxRatio)

                                var newValue = control.positionToValue(ratio)
                                newValue = control.roundToDecimal(newValue, control.validatorDecimals);
                                // No range constraints - caller is responsible for valid values
                                control._suppressSync = true
                                control.fromValue = newValue
                                control._suppressSync = false
                            }
                        }
                    }

                    CustomToolTip {
                        id: fromToolTip
                        visible: control._draggingFrom || control._hoveringFrom
                        text: control.fromValue.toFixed(control.validatorDecimals)
                        delay: control._draggingFrom ? ToolTipConfig.immediateDelay : ToolTipConfig.shortDelay
                        timeout: control._draggingFrom ? -1 : ToolTipConfig.persistentTimeout
                        x: (fromHandle.width - width) / 2
                        y: -height - Fonts.size5
                    }
                }

                // To handle (right) - Downward triangle
                Shape {
                    id: toHandle
                    x: sliderTrack.trackPadding + control.valueToPosition(control.toValue) * sliderTrack.trackWidth - width / 2
                    y: sliderTrack.height / 2 - height
                    width: sliderTrack.handleWidth
                    height: sliderTrack.handleHeight
                    z: control._draggingTo ? 2 : 1

                    scale: (control._draggingTo || control._hoveringTo) ? 1.1 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    ShapePath {
                        id: toHandlePath
                        strokeWidth: (control._draggingTo || control._hoveringTo) ? 2 : 1
                        strokeColor: (control._draggingTo || control._hoveringTo) ? control.highlightColor : control.midColor
                        fillColor: control.buttonColor
                        startX: 0
                        startY: 0
                        PathLine {
                            x: toHandle.width
                            y: 0
                        }
                        PathLine {
                            x: toHandle.width / 2
                            y: toHandle.height
                        }
                        PathLine {
                            x: 0
                            y: 0
                        }
                    }

                    MouseArea {
                        id: toHandleMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeHorCursor

                        drag.target: parent
                        drag.axis: Drag.XAxis
                        drag.minimumX: Math.max(sliderTrack.trackPadding - parent.width / 2, fromHandle.x + fromHandle.width / 2 - parent.width / 2)
                        drag.maximumX: sliderTrack.trackPadding + sliderTrack.trackWidth - parent.width / 2

                        onPressed: {
                            control._draggingTo = true
                            control._draggingFrom = false
                        }

                        onReleased: {
                            control._draggingTo = false
                        }

                        onEntered: {
                            control._hoveringTo = true
                        }

                        onExited: {
                            control._hoveringTo = false
                        }

                        onPositionChanged: {
                            if (drag.active) {
                                // Calculate center position relative to track
                                var centerX = parent.x + parent.width / 2 - sliderTrack.trackPadding
                                var ratio = centerX / sliderTrack.trackWidth
                                ratio = Math.max(0, Math.min(1, ratio));

                                // Limit to not be less than fromHandle center position
                                var fromHandleCenterX = fromHandle.x + fromHandle.width / 2 - sliderTrack.trackPadding
                                var minRatio = fromHandleCenterX / sliderTrack.trackWidth
                                ratio = Math.max(ratio, minRatio)

                                var newValue = control.positionToValue(ratio)
                                newValue = control.roundToDecimal(newValue, control.validatorDecimals);
                                // No range constraints - caller is responsible for valid values
                                control._suppressSync = true
                                control.toValue = newValue
                                control._suppressSync = false
                            }
                        }
                    }

                    CustomToolTip {
                        id: toToolTip
                        visible: control._draggingTo || control._hoveringTo
                        text: control.toValue.toFixed(control.validatorDecimals)
                        delay: control._draggingTo ? ToolTipConfig.immediateDelay : ToolTipConfig.shortDelay
                        timeout: control._draggingTo ? -1 : ToolTipConfig.persistentTimeout
                        x: (toHandle.width - width) / 2
                        y: toHandle.height + Fonts.size5
                    }
                }
            }
        }

        // Value labels row - only show min and max range boundaries
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            // Left: Minimum range (from)
            Text {
                id: minLabel
                text: control.from.toFixed(control.validatorDecimals)
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: implicitWidth
                visible: control.showValueLabel
                color: control.enabled ? control.textColor : control.disabledTextColor
                font: Fonts.standardFont
            }

            // Spacer
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size1
            }

            // Right: Maximum range (to)
            Text {
                id: maxLabel
                text: control.to.toFixed(control.validatorDecimals)
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: implicitWidth
                visible: control.showValueLabel
                color: control.enabled ? control.textColor : control.disabledTextColor
                font: Fonts.standardFont
            }
        }
    }
}
