import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

ToolButton {
    id: control

    property int defaultHeight: Fonts.toolbarHeight
    property int defaultPadding: ControlState.borderThin

    property int iconSize: Fonts.iconButtonSize
    property string actionName: ""
    property string iconSource: ""
    property var parameter: null
    property string shortcutSequence: ""
    property bool handleInCpp: true
    property string displayName: ""
    property string tooltip: ""

    signal actionRequested(var parameter)

    property color textColor: Theme.buttonTextColor
    property color disabledColor: Theme.disabledTextColor
    property color highlightColor: Theme.highlightColor
    property color midlightColor: Theme.midlightColor
    property color hoveredColor: Theme.actionButtonHoveredColor
    property color pressedColor: Theme.actionButtonPressedColor
    property color borderColor: Theme.actionButtonBorderColor
    property color highlightedTextColor: Theme.highlightedTextColor
    font: Fonts.standardFont

    implicitHeight: defaultHeight

    implicitWidth: display === AbstractButton.IconOnly ? implicitHeight : Math.max(implicitHeight, implicitContentWidth + Fonts.size2 * padding)
    padding: defaultPadding
    focusPolicy: Qt.NoFocus

    icon.width: iconSize
    icon.height: iconSize
    icon.source: iconSource
    text: displayName || actionName
    display: AbstractButton.IconOnly

    palette.buttonText: textColor
    palette.text: textColor

    icon.color: !control.enabled ? disabledColor : control.pressed ? highlightedTextColor : textColor

    background: Rectangle {
        color: ControlState.actionFillWithColors(control.enabled, control.pressed, control.hovered, false, "transparent", control.hoveredColor, control.pressedColor, "transparent", control.highlightColor)
        border.color: ControlState.actionBorder(control.enabled, control.pressed, control.hovered, control.visualFocus, false)
        border.width: control.visualFocus ? ControlState.borderFocus : ControlState.borderThin
        radius: ControlState.radiusSmall
        opacity: control.enabled && (control.pressed || control.hovered || control.visualFocus) ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: ControlState.animationFast
            }
        }
    }

    onClicked: {
        if (handleInCpp) {
            control.actionRequested(parameter)
        }
    }

    CustomToolTip {
        visible: control.hovered
        delay: ToolTipConfig.longDelay
        text: tooltip + (shortcutSequence ? " (" + shortcutSequence + ")" : "")
    }
}
