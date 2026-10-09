// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

Popup {
    popupType: Popup.Item
    focus: true
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
