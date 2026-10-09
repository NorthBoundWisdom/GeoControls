// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ItemDelegate {
    id: control
    font: Fonts.standardFont
    contentItem: CustomLabel {
        text: control.text
        font: control.font
        color: control.enabled ? Theme.textColor : Theme.disabledTextColor
        elide: Text.ElideRight
    }
    background: Rectangle {
        color: control.down ? Theme.buttonPressedColor : control.highlighted || control.hovered ? Theme.buttonHoveredColor : "transparent"
        radius: Fonts.size4
    }
}
