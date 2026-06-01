import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property string text: ""
    property bool checkable: false
    property bool checked: false
    property bool closable: false
    property bool hovered: mouseArea.containsMouse

    signal clicked
    signal closeRequested

    implicitWidth: chipLayout.implicitWidth + Fonts.size16
    implicitHeight: Math.max(chipLayout.implicitHeight + Fonts.size8, Fonts.iconButtonSize)
    radius: implicitHeight / 2
    color: ControlState.actionFillWithColors(control.enabled, mouseArea.pressed, control.hovered, control.checked, Theme.railSurfaceColor, Theme.buttonHoveredColor, Theme.highlightColor, Theme.buttonDisabledColor, Theme.highlightColor)
    border.color: ControlState.actionBorder(control.enabled, mouseArea.pressed, control.hovered, activeFocus, control.checked)
    border.width: activeFocus ? ControlState.borderFocus : ControlState.borderThin
    opacity: control.enabled ? 1.0 : 0.65

    activeFocusOnTab: true

    RowLayout {
        id: chipLayout
        anchors.centerIn: parent
        spacing: Fonts.size6

        CustomLabel {
            text: control.text
            color: ControlState.actionTextWithColors(control.enabled, mouseArea.pressed, control.checked, Theme.textColor, Theme.disabledTextColor, Theme.highlightedTextColor)
            elide: Text.ElideRight
        }

        CustomToolButton {
            visible: control.closable
            iconSource: "qrc:/GeoControls/icons/Close.svg"
            defaultHeight: Fonts.iconButtonSize
            tooltip: qsTr("Remove")
            onClicked: control.closeRequested()
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: {
            control.forceActiveFocus()
            if (control.checkable)
                control.checked = !control.checked
            control.clicked()
        }
    }
}
