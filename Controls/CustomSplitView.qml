pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

SplitView {
    id: control
    property real handleHitSize: Math.max(12, Fonts.size12)
    handle: Rectangle {
        id: splitHandle
        implicitWidth: control.orientation === Qt.Horizontal ? control.handleHitSize : Fonts.size4
        implicitHeight: control.orientation === Qt.Vertical ? control.handleHitSize : Fonts.size4
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: control.orientation === Qt.Horizontal ? Fonts.size1 : splitHandle.width
            height: control.orientation === Qt.Horizontal ? splitHandle.height : Fonts.size1
            color: splitHandle.SplitHandle.pressed || splitHandle.SplitHandle.hovered ? Theme.highlightColor : Theme.splitHandleColor
        }
    }
}
