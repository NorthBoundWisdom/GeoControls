// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ScrollView {
    id: control
    clip: true
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
