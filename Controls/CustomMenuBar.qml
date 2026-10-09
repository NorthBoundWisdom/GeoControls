import QtQuick
import QtQuick.Controls
import GeoControls 1.0

MenuBar {
    background: Rectangle {
        color: Theme.windowColor
        implicitHeight: Fonts.menuBarHeight
    }
    delegate: MenuBarItem {
        id: control
        implicitHeight: Fonts.menuBarHeight
        contentItem: Text {
            text: control.text
            font: Fonts.standardFont
            color: control.enabled ? Theme.textColor : Theme.disabledTextColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: control.highlighted || control.down ? Theme.buttonHoveredColor : "transparent"
        }
    }
}
