// SPDX-FileCopyrightText: Shanghai Astroform Software Ltd.
// SPDX-License-Identifier: LicenseRef-Astroform-Proprietary
//
// This notice must not be removed or altered without explicit authorization.

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import GeoControls 1.0

T.TextArea {
    id: control
    font: Fonts.standardFont
    color: enabled ? Theme.textColor : Theme.disabledTextColor
    placeholderTextColor: Theme.placeholderTextColor
    selectionColor: Theme.highlightColor
    selectedTextColor: Theme.highlightedTextColor
    selectByMouse: true
    padding: Fonts.inputPadding
    implicitWidth: Math.max(180, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight, placeholder.implicitHeight) + topPadding + bottomPadding
    Text {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        wrapMode: control.wrapMode
        visible: control.text.length === 0 && control.preeditText.length === 0
    }
    background: Rectangle {
        color: ControlState.inputFill(control.enabled, control.readOnly, control.hovered)
        border.color: ControlState.inputBorder(control.enabled, control.activeFocus, control.hovered, control.readOnly)
        border.width: ControlState.borderThin
        radius: ControlState.radiusSmall
    }
    RButtonMenu {
        id: editMenu
        objectName: "textEditContextMenu"
        onAboutToShow: menuItems = [
            {
                display_name: qsTr("Cut"),
                cmd_id: "cut",
                enabled: control.selectedText.length > 0 && !control.readOnly
            },
            {
                display_name: qsTr("Copy"),
                cmd_id: "copy",
                enabled: control.selectedText.length > 0
            },
            {
                display_name: qsTr("Paste"),
                cmd_id: "paste",
                enabled: control.canPaste && !control.readOnly
            },
            {
                display_name: qsTr("Select All"),
                cmd_id: "selectAll",
                enabled: control.text.length > 0
            }
        ]
        onCommandRequested: function (command) {
            if (command.cmd_id === "cut")
                control.cut()
            else if (command.cmd_id === "copy")
                control.copy()
            else if (command.cmd_id === "paste")
                control.paste()
            else if (command.cmd_id === "selectAll")
                control.selectAll()
        }
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: function (point) {
            editMenu.popup(control, point.position.x, point.position.y)
        }
    }
}
