import QtQuick 2.15
import GeoControls 1.0

CustomButton {
    id: control

    property bool selected: false

    buttonColor: control.selected ? Theme.highlightColor : "transparent"
    hoveredColor: control.selected ? Theme.highlightColor : Theme.buttonHoveredColor
    pressedColor: Theme.highlightColor
    buttonTextColor: control.selected ? Theme.highlightedTextColor : Theme.textColor
    disabledColor: Theme.buttonDisabledColor
    midColor: "transparent"
    darkColor: control.selected ? Theme.highlightColor : Theme.midColor
    defaultHeight: ControlState.minInputHeight
    defaultPadding: Fonts.size8
    defaultRadius: ControlState.radiusSmall
}
