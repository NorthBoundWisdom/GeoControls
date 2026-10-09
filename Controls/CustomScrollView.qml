import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ScrollView {
    id: control
    background: Item {}
    ScrollBar.vertical: CustomScrollBar {
        parent: control
        x: control.mirrored ? 0 : control.width - width
        y: control.topPadding
        height: control.availableHeight
    }
    ScrollBar.horizontal: CustomScrollBar {
        parent: control
        x: control.leftPadding
        y: control.height - height
        width: control.availableWidth
    }
}
