import QtQuick
import QtQuick.Controls
import GeoControls 1.0

Popup {
    padding: Fonts.size8
    background: Rectangle {
        color: Theme.popupSurfaceColor
        border.color: Theme.dividerColor
        border.width: ControlState.borderThin
        radius: ControlState.radiusSmall
    }
    Overlay.modal: Rectangle {
        color: Theme.shadowColor
        opacity: 0.35
    }
    Overlay.modeless: Item {}
}
