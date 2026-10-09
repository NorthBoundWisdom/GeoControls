import QtQuick
import QtQuick.Controls
import GeoControls 1.0

Menu {
    id: control
    property int menuWidth: Fonts.size200
    property bool fitToContent: false
    padding: Fonts.size4
    overlap: 0
    font: Fonts.standardFont
    palette.window: Theme.popupSurfaceColor
    palette.windowText: Theme.textColor
    palette.base: Theme.popupSurfaceColor
    palette.text: Theme.textColor
    palette.button: Theme.popupSurfaceColor
    palette.buttonText: Theme.textColor
    palette.highlight: Theme.buttonHoveredColor
    palette.highlightedText: Theme.textColor
    palette.mid: Theme.dividerColor
    delegate: CustomMenuItem {}
    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        currentIndex: control.currentIndex
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        ScrollIndicator.vertical: CustomScrollIndicator {}
    }
    background: Rectangle {
        implicitWidth: control.fitToContent ? Math.max(Fonts.size120, control.implicitContentWidth) : control.menuWidth
        implicitHeight: Fonts.size40
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
