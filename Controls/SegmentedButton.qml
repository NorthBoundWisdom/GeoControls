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
    defaultPadding: Fonts.size6
    defaultRadius: 0
    borderWidth: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: defaultPadding
    rightPadding: defaultPadding

    contentItem: Item {
        implicitWidth: label.implicitWidth
        implicitHeight: label.implicitHeight

        FontMetrics {
            id: labelMetrics
            font: control.font
        }

        Text {
            id: label
            anchors.centerIn: parent
            // Mixed-case Latin ink sits below the layout box center because of extra ascent.
            anchors.verticalCenterOffset: Math.round((labelMetrics.descent - labelMetrics.ascent + labelMetrics.xHeight) / 2)
            text: control.text
            font: control.font
            color: ControlState.actionTextWithColors(control.enabled, control.pressed, false, control.buttonTextColor, control.disabledTextColor, control.highlightedTextColor)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: control.textElideMode
        }
    }
}
