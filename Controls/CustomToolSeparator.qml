// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ToolSeparator {
    id: control
    padding: Fonts.size4
    contentItem: Rectangle {
        implicitWidth: control.orientation === Qt.Vertical ? 1 : Fonts.size20
        implicitHeight: control.orientation === Qt.Vertical ? Fonts.size20 : 1
        color: Theme.midColor
    }
}
