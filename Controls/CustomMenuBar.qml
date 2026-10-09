// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

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
