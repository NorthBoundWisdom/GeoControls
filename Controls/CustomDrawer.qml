import QtQuick
import QtQuick.Controls
import GeoControls 1.0

Drawer {
    padding: 0
    background: Rectangle {
        color: Theme.railSurfaceColor
        border.color: Theme.dividerColor
        border.width: ControlState.borderThin
    }
    Overlay.modal: Rectangle {
        color: Theme.shadowColor
        opacity: 0.35
    }
    Overlay.modeless: Item {}
}
