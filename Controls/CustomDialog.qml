// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

Dialog {
    id: control
    popupType: Popup.Item
    font: Fonts.standardFont
    padding: Fonts.size12
    focus: true
    background: Rectangle {
        color: Theme.popupSurfaceColor
        border.color: Theme.actionButtonBorderColor
        radius: Fonts.size8
    }
    header: CustomLabel {
        text: control.title
        leftPadding: Fonts.size12
        rightPadding: Fonts.size12
        topPadding: Fonts.size12
        bottomPadding: Fonts.size12
        font.bold: true
        visible: text.length > 0
    }
    footer: DialogButtonBox {
        padding: Fonts.size12
        spacing: Fonts.size8
        standardButtons: control.standardButtons
        delegate: CustomButton {}
        background: Rectangle {
            color: "transparent"
        }
    }
    Overlay.modal: Rectangle {
        color: Theme.shadowColor
    }
}
