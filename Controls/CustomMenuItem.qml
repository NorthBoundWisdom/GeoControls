// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import GeoControls 1.0

MenuItem {
    id: root

    property string displayText: ""
    readonly property string resolvedText: displayText.length > 0 ? displayText : text

    implicitHeight: Math.max(Fonts.listItemHeight, Fonts.size24)
    leftPadding: Fonts.size12
    rightPadding: Fonts.size12
    spacing: Fonts.size8

    // All rows reserve the same check column, including plain and submenu rows.
    // Replace the style indicators because the content below draws both glyphs.
    indicator: Item {
        implicitWidth: 0
        implicitHeight: 0
    }
    arrow: Item {
        implicitWidth: 0
        implicitHeight: 0
        visible: false
    }

    contentItem: Item {
        implicitWidth: checkmark.width + Fonts.size8 + label.implicitWidth + (shortcut.visible ? shortcut.implicitWidth + Fonts.size20 : 0) + (submenuArrow.visible ? submenuArrow.implicitWidth + Fonts.size8 : 0)
        implicitHeight: Math.max(label.implicitHeight, Fonts.size16)

        Text {
            id: checkmark
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Fonts.size20
            text: root.checkable && root.checked ? "\u2713" : ""
            font: Fonts.makeBoldFont(Fonts.standardFont)
            color: root.enabled ? Theme.textColor : Theme.disabledTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: label
            anchors.left: checkmark.right
            anchors.right: shortcut.visible ? shortcut.left : submenuArrow.visible ? submenuArrow.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Fonts.size8
            anchors.rightMargin: shortcut.visible ? Fonts.size20 : submenuArrow.visible ? Fonts.size8 : 0
            text: root.resolvedText.split("\t")[0]
            font: Fonts.standardFont
            color: root.enabled ? Theme.textColor : Theme.disabledTextColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Text {
            id: shortcut
            visible: text.length > 0
            anchors.right: submenuArrow.visible ? submenuArrow.left : parent.right
            anchors.rightMargin: submenuArrow.visible ? Fonts.size8 : 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.resolvedText.indexOf("\t") >= 0 ? root.resolvedText.slice(root.resolvedText.indexOf("\t") + 1) : ""
            font: Fonts.annotationFont
            color: root.enabled ? Theme.placeholderTextColor : Theme.disabledTextColor
        }

        Text {
            id: submenuArrow
            visible: root.subMenu !== null
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: ">"
            font: Fonts.standardFont
            color: root.enabled ? Theme.textColor : Theme.disabledTextColor
        }
    }

    background: Rectangle {
        color: root.highlighted ? Theme.buttonHoveredColor : Theme.popupSurfaceColor
    }

    Accessible.name: root.resolvedText
}
