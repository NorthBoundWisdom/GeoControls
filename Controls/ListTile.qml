import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property string title: ""
    property string subtitle: ""
    property string iconSource: ""
    property bool selected: false
    property bool checkable: false
    property bool checked: false
    property bool hovered: mouseArea.containsMouse
    property bool showDisclosure: false

    signal clicked

    implicitWidth: tileLayout.implicitWidth + Fonts.size20
    implicitHeight: Math.max(tileLayout.implicitHeight + Fonts.size12, Fonts.size40)
    radius: ControlState.radiusMedium
    color: ControlState.actionFillWithColors(control.enabled, mouseArea.pressed, control.hovered, control.selected || control.checked, "transparent", Theme.buttonHoveredColor, Theme.buttonPressedColor, Theme.buttonDisabledColor, Theme.railSurfaceColor)
    border.color: ControlState.actionBorder(control.enabled, mouseArea.pressed, control.hovered, activeFocus, control.selected || control.checked)
    border.width: activeFocus ? ControlState.borderFocus : 0
    opacity: control.enabled ? 1.0 : 0.65
    activeFocusOnTab: true

    RowLayout {
        id: tileLayout
        anchors.fill: parent
        anchors.leftMargin: Fonts.size10
        anchors.rightMargin: Fonts.size10
        spacing: Fonts.size10

        Image {
            visible: control.iconSource.length > 0
            source: control.iconSource
            sourceSize.width: Fonts.iconSize
            sourceSize.height: Fonts.iconSize
            Layout.preferredWidth: visible ? Fonts.iconSize : 0
            Layout.preferredHeight: Fonts.iconSize
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Fonts.size2

            CustomLabel {
                Layout.fillWidth: true
                text: control.title
                elide: Text.ElideRight
                font: control.selected ? Fonts.makeBoldFont(Fonts.standardFont) : Fonts.standardFont
            }

            CustomLabel {
                visible: control.subtitle.length > 0
                Layout.fillWidth: true
                text: control.subtitle
                color: Theme.placeholderTextColor
                font: Fonts.annotationFont
                elide: Text.ElideRight
            }
        }

        CustomLabel {
            visible: control.showDisclosure
            text: ">"
            color: Theme.placeholderTextColor
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
