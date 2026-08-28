import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

Button {
    id: control

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color disabledColor: Theme.buttonDisabledColor
    property color buttonColor: Theme.buttonColor
    property color buttonTextColor: Theme.buttonTextColor
    property color highlightColor: Theme.highlightColor
    property color darkColor: Theme.darkColor
    property color midColor: Theme.midColor
    property color lightColor: Theme.lightColor
    property color hoveredColor: Theme.buttonHoveredColor
    property color pressedColor: Theme.buttonPressedColor
    property color highlightedTextColor: Theme.highlightedTextColor
    property int textElideMode: Text.ElideRight
    property int defaultIconSize: Fonts.iconSize

    // custom properties
    property int defaultHeight: ControlState.minButtonHeight
    property int defaultRadius: ControlState.radiusSmall
    property int defaultPadding: ControlState.textPadding
    property int borderWidth: ControlState.borderThin

    // Tooltip support
    property string tooltipText: ""
    property int tooltipDelay: ToolTipConfig.shortDelay

    font: Fonts.standardFont

    activeFocusOnTab: true

    // Clip overflowing content (text/icon) inside button bounds
    clip: true

    implicitHeight: defaultHeight
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

    leftPadding: defaultPadding
    rightPadding: defaultPadding
    topPadding: defaultPadding
    bottomPadding: defaultPadding
    icon.width: defaultIconSize
    icon.height: defaultIconSize
    icon.color: !control.enabled ? control.disabledTextColor : (control.pressed || control.checked) ? control.highlightedTextColor : control.buttonTextColor

    // Do not anchor contentItem; Control sizes it from padding. Anchors.fill here
    // fights that geometry and shifts compact labels off the vertical center.
    contentItem: Item {
        implicitWidth: centerRow.implicitWidth
        implicitHeight: centerRow.implicitHeight

        Row {
            id: centerRow
            spacing: ControlState.iconGap
            anchors.centerIn: parent

            IconLabel {
                icon: control.icon
                visible: control.icon.source !== "" && (control.display !== AbstractButton.TextOnly)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                font: control.font
                color: ControlState.actionTextWithColors(control.enabled, control.pressed, false, control.buttonTextColor, control.disabledTextColor, control.highlightedTextColor)
                visible: (control.display !== AbstractButton.IconOnly)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: control.textElideMode
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Background
    background: Rectangle {
        implicitHeight: control.defaultHeight
        color: ControlState.actionFillWithColors(control.enabled, control.pressed, control.hovered, control.checked, control.buttonColor, control.hoveredColor, control.pressedColor, control.disabledColor, control.highlightColor)
        border.color: ControlState.actionBorder(control.enabled, control.pressed, control.hovered, control.visualFocus, false)
        border.width: control.borderWidth <= 0 ? 0 : (control.visualFocus ? Math.max(control.borderWidth, ControlState.borderFocus) : control.borderWidth)
        radius: control.defaultRadius

        Behavior on color {
            ColorAnimation {
                duration: ControlState.animationFast
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: ControlState.animationFast
            }
        }
    }

    MouseArea {
        id: tooltipMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: -1
    }

    CustomToolTip {
        visible: control.tooltipText !== "" && tooltipMouseArea.containsMouse && control.enabled
        delay: control.tooltipDelay
        text: control.tooltipText
    }
}
