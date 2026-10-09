// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

ProgressBar {
    id: control
    implicitWidth: 180
    implicitHeight: 6
    padding: 0
    background: Rectangle {
        radius: height / 2
        color: Theme.alternateBaseColor
    }
    contentItem: Item {
        clip: true
        Rectangle {
            id: indicator
            width: control.indeterminate ? parent.width * 0.3 : parent.width * control.visualPosition
            height: parent.height
            radius: height / 2
            color: control.enabled ? Theme.accentColor : Theme.disabledTextColor
            x: control.indeterminate ? -width : control.mirrored ? parent.width - width : 0
            NumberAnimation on x {
                running: control.indeterminate && control.visible
                from: -indicator.width
                to: indicator.parent.width
                duration: 1200
                loops: Animation.Infinite
            }
        }
    }
}
