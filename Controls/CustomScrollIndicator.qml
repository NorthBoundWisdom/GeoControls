import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ScrollIndicator {
    id: control
    padding: Fonts.size2
    implicitWidth: orientation === Qt.Vertical ? Fonts.size6 : Fonts.size40
    implicitHeight: orientation === Qt.Horizontal ? Fonts.size6 : Fonts.size40
    minimumSize: Math.min(1, (orientation === Qt.Vertical ? width : height) / Math.max(1, orientation === Qt.Vertical ? height : width))
    contentItem: Rectangle {
        implicitWidth: Fonts.size2
        implicitHeight: Fonts.size2
        radius: Math.min(width, height) / 2
        color: control.enabled ? Theme.placeholderTextColor : Theme.disabledTextColor
        opacity: control.active && control.size < 1 ? 1 : 0
    }
    background: Item {}
}
