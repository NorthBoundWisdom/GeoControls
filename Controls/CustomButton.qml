import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 2.15
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
    property int defaultHeight: Fonts.inputFieldHeight
    property int defaultRadius: Fonts.size2
    property int defaultPadding: Fonts.size6

    // Tooltip support
    property string tooltipText: ""
    property int tooltipDelay: ToolTipConfig.shortDelay

    font: Fonts.standardFont

    activeFocusOnTab: true

    // Clip overflowing content (text/icon) inside button bounds
    clip: true

    implicitHeight: defaultHeight
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

    padding: defaultPadding
    icon.width: defaultIconSize
    icon.height: defaultIconSize
    icon.color: !control.enabled ? control.disabledTextColor : control.pressed ? control.highlightedTextColor : control.buttonTextColor

    // Text
    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size4
        spacing: 0

        // left spacer
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // centered content
        Row {
            id: centerRow
            spacing: Fonts.size6
            Layout.alignment: Qt.AlignVCenter

            IconLabel {
                icon: control.icon
                visible: control.icon.source !== "" && (control.display !== AbstractButton.TextOnly)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                font: control.font
                color: !control.enabled ? control.disabledTextColor : control.buttonTextColor
                visible: (control.display !== AbstractButton.IconOnly)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: control.textElideMode
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // right spacer
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    // Background
    background: Rectangle {
        implicitHeight: control.defaultHeight
        color: !control.enabled ? control.disabledColor : control.pressed ? control.pressedColor : control.hovered ? control.hoveredColor : control.buttonColor
        border.color: control.pressed ? control.highlightColor : control.hovered ? control.darkColor : control.midColor
        border.width: control.visualFocus ? Fonts.size1 : 0
        radius: defaultRadius
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
        visible: tooltipText !== "" && tooltipMouseArea.containsMouse && control.enabled
        delay: tooltipDelay
        text: tooltipText
    }
}
