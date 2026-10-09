// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ScrollBar {
    id: control
    padding: Fonts.size2
    implicitWidth: orientation === Qt.Vertical ? Fonts.size10 : Fonts.size40
    implicitHeight: orientation === Qt.Horizontal ? Fonts.size10 : Fonts.size40
    minimumSize: Math.min(1, (orientation === Qt.Vertical ? width : height) / Math.max(1, orientation === Qt.Vertical ? height : width))
    hoverEnabled: true

    contentItem: Rectangle {
        implicitWidth: Fonts.size6
        implicitHeight: Fonts.size6
        radius: Math.min(width, height) / 2
        color: !control.enabled ? Theme.disabledTextColor : control.pressed ? Theme.highlightColor : control.hovered ? Theme.textColor : Theme.placeholderTextColor
        opacity: control.policy === ScrollBar.AlwaysOff || control.size >= 1 ? 0 : control.policy === ScrollBar.AlwaysOn || control.active || control.hovered ? 1 : 0.45
    }

    background: Rectangle {
        color: control.hovered || control.pressed ? Theme.railSurfaceColor : "transparent"
        radius: Math.min(width, height) / 2
    }
}
