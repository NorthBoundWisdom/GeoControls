import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoToy.Controls 1.0

ToolButton {
    id: control

    property int defaultHeight: Fonts.toolbarHeight
    property int defaultPadding: Fonts.size1

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
        color: midlightColor
        opacity: control.pressed ? 0.7 : control.hovered ? 0.5 : 0
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
