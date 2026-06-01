pragma ComponentBehavior: Bound
import QtQuick 2.15

import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property color selectedColor: "#ffffff"
    property Item dialogHost: null
    property bool requireDialogHost: true
    property string missingHostText: qsTr("ColorPicker requires dialogHost before opening.")

    signal accepted(color color)
    signal rejected

    implicitWidth: pickerLayout.implicitWidth + Fonts.size16
    implicitHeight: Math.max(pickerLayout.implicitHeight + Fonts.size12, ControlState.minInputHeight)
    radius: ControlState.radiusMedium
    color: Theme.contentSurfaceColor
    border.color: Theme.dividerColor
    border.width: ControlState.borderThin

    function open() {
        if (control.requireDialogHost && control.dialogHost === null) {
            missingHostBar.visible = true
            return
        }
        if (pickerDialog)
            pickerDialog.open()
    }

    RowLayout {
        id: pickerLayout
        anchors.fill: parent
        anchors.margins: Fonts.size6
        spacing: Fonts.size8

        Rectangle {
            Layout.preferredWidth: Fonts.size40
            Layout.preferredHeight: Fonts.size24
            radius: ControlState.radiusSmall
            color: control.selectedColor
            border.color: Theme.midColor
            border.width: ControlState.borderThin
        }

        CustomButton {
            text: qsTr("Pick")
            defaultHeight: Fonts.iconButtonSize
            onClicked: control.open()
        }
    }

    InfoBar {
        id: missingHostBar
        visible: false
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: Fonts.size4
        severity: "error"
        title: qsTr("Missing host")
        message: control.missingHostText
        closable: true
        onClosed: visible = false
    }

    CustomColorPicker {
        id: pickerDialog
        parent: control.dialogHost ? control.dialogHost : control
        selectedColor: control.selectedColor
        onAccepted: {
            control.selectedColor = selectedColor
            control.accepted(selectedColor)
        }
        onRejected: control.rejected()
    }
}
