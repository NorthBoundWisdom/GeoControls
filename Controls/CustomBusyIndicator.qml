pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

BusyIndicator {
    id: control
    implicitWidth: Fonts.size40
    implicitHeight: Fonts.size40
    padding: Fonts.size4
    background: Item {}
    contentItem: Item {
        id: ring
        opacity: control.running ? 1 : 0
        Repeater {
            model: 8
            Rectangle {
                required property int index
                readonly property real angle: index * Math.PI / 4
                width: Math.max(2, Math.min(ring.width, ring.height) / 7)
                height: width
                radius: width / 2
                x: (ring.width - width) / 2 + Math.sin(angle) * (Math.min(ring.width, ring.height) - width) / 2
                y: (ring.height - height) / 2 - Math.cos(angle) * (Math.min(ring.width, ring.height) - height) / 2
                color: control.enabled ? Theme.highlightColor : Theme.disabledTextColor
                opacity: (index + 1) / 8
            }
        }
        RotationAnimator on rotation {
            running: control.running && control.visible && control.enabled
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
        }
    }
}
