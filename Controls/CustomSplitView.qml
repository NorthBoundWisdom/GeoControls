pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

SplitView {
    id: control
    handle: Rectangle {
        id: splitHandle
        implicitWidth: Fonts.size4
        implicitHeight: Fonts.size4
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: control.orientation === Qt.Horizontal ? Fonts.size1 : splitHandle.width
            height: control.orientation === Qt.Horizontal ? splitHandle.height : Fonts.size1
            color: splitHandle.SplitHandle.pressed || splitHandle.SplitHandle.hovered ? Theme.highlightColor : Theme.splitHandleColor
        }
    }
}
