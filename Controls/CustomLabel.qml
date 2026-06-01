import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Label {
    id: control

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor

    // Allow shrinking inside Layout containers without forcing parent minimum width.
    Layout.minimumWidth: 0
    // Prevent painting outside when width is constrained by parent layout.
    clip: true

    font: Fonts.standardFont
    color: control.enabled ? control.textColor : control.disabledTextColor
}
