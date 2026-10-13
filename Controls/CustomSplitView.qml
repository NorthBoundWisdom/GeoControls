pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

SplitView {
    id: control
    property real handleHitSize: Math.max(12, Fonts.size12)
    handle: Rectangle {
        id: splitHandle
        implicitWidth: Fonts.size4
        implicitHeight: Fonts.size4
        color: "transparent"
        containmentMask: Item {
            width: control.orientation === Qt.Horizontal ? Math.max(splitHandle.width, control.handleHitSize) : splitHandle.width
            height: control.orientation === Qt.Vertical ? Math.max(splitHandle.height, control.handleHitSize) : splitHandle.height
            x: (splitHandle.width - width) / 2
            y: (splitHandle.height - height) / 2
        }
        Rectangle {
            anchors.centerIn: parent
            width: control.orientation === Qt.Horizontal ? Fonts.size1 : splitHandle.width
            height: control.orientation === Qt.Horizontal ? splitHandle.height : Fonts.size1
            color: splitHandle.SplitHandle.pressed || splitHandle.SplitHandle.hovered ? Theme.highlightColor : Theme.splitHandleColor
        }
    }
}
