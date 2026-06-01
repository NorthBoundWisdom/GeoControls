import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

SpinBox {
    id: control

    // custom properties
    property int defaultHeight: Fonts.inputFieldHeight
    property int defaultRadius: Fonts.size2
    property int defaultPadding: Fonts.size6
    property color textColor: Theme.textColor
    property color buttonColor: Theme.buttonColor
    font: Fonts.standardFont

    implicitHeight: defaultHeight
    implicitWidth: Fonts.standardFontMetrics.width + Fonts.size2 * defaultPadding + up.indicator.width + down.indicator.width

    padding: defaultPadding
    leftPadding: padding + (down.indicator ? down.indicator.width : 0)
    rightPadding: padding + (up.indicator ? up.indicator.width : 0)

    editable: true

    TextMetrics {
        id: fontMetrics

        text: {
            var maxLength = Math.max(control.from.toString().length, control.to.toString().length, control.value.toString().length)
            return "0".repeat(maxLength)
        }
    }

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)

        color: control.enabled ? control.textColor : Theme.disabledTextColor
        selectionColor: Theme.highlightColor
        selectedTextColor: Theme.highlightedTextColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        selectByMouse: true

        onTextEdited: {
            var newValue = control.valueFromText(text, control.locale)
            if (newValue !== undefined) {
                control.value = newValue
            }
        }

        Rectangle {
            z: -1
            visible: parent.activeFocus
            anchors.fill: parent
            color: Theme.highlightColor
            opacity: 0.1
        }
    }

    up.indicator: Rectangle {
        x: parent.width - width
        height: parent.height - (control.activeFocus ? Fonts.size2 : Fonts.size1)
        y: control.activeFocus ? Fonts.size1 : 0.5
        implicitWidth: control.defaultHeight
        color: control.buttonColor
        opacity: up.pressed ? 0.8 : up.hovered ? 0.2 : 1.0
        border.color: up.pressed ? Theme.highlightColor : up.hovered ? Theme.highlightColor : Theme.midColor
        border.width: Fonts.size1

        radius: control.defaultRadius
        Rectangle {
            width: parent.width
            height: parent.radius
            anchors.bottom: parent.bottom
            color: parent.color
        }

        Canvas {
            id: upArrow
            anchors.centerIn: parent
            width: Fonts.size8
            height: Fonts.size4
            contextType: "2d"

            Connections {
                target: control
                function onTextColorChanged() {
                    upArrow.requestPaint()
                }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, height)
                ctx.lineTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.fillStyle = control.textColor
                ctx.fill()
            }
        }
    }

    down.indicator: Rectangle {
        x: 0
        height: parent.height - (control.activeFocus ? Fonts.size2 : Fonts.size1)
        y: control.activeFocus ? Fonts.size1 : 0.5
        implicitWidth: control.defaultHeight
        color: control.buttonColor
        opacity: down.pressed ? 0.8 : down.hovered ? 0.2 : 1.0
        border.color: down.pressed ? Theme.highlightColor : down.hovered ? Theme.highlightColor : Theme.midColor
        border.width: Fonts.size1

        radius: control.defaultRadius
        Rectangle {
            width: parent.width
            height: parent.radius
            anchors.bottom: parent.bottom
            color: parent.color
        }

        Canvas {
            id: downArrow
            anchors.centerIn: parent
            width: Fonts.size8
            height: Fonts.size4
            contextType: "2d"

            Connections {
                target: control
                function onTextColorChanged() {
                    downArrow.requestPaint()
                }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width / 2, height)
                ctx.lineTo(width, 0)
                ctx.closePath()
                ctx.fillStyle = control.textColor
                ctx.fill()
            }
        }
    }

    background: Rectangle {
        implicitWidth: Fonts.size80
        color: control.enabled ? Theme.baseColor : Theme.buttonDisabledColor
        border.color: control.activeFocus ? Theme.highlightColor : Theme.midColor
        border.width: control.activeFocus ? Fonts.size2 : Fonts.size1
        radius: control.defaultRadius
    }
}
