import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

CheckBox {
    id: control

    // custom properties
    property bool textClickable: true
    property int defaultHeight: Fonts.iconSize
    property int defaultRadius: ControlState.radiusSmall
    property int defaultPadding: ControlState.compactPadding
    property int indicatorSize: Math.round(defaultHeight * 0.75)
    property int textSpacing: defaultPadding

    property string tooltipText: ""
    property int tooltipDelay: ToolTipConfig.shortDelay

    property color textColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor
    property color baseColor: Theme.baseColor
    property color midColor: Theme.midColor
    property color highlightColor: Theme.highlightColor
    font: Fonts.standardFont

    implicitHeight: Math.max(contentItem.implicitHeight, control.indicatorSize)
    implicitWidth: indicator.width + (text ? spacing + contentItem.implicitWidth : 0)

    padding: 0
    spacing: control.textSpacing

    signal textClicked

    // Text
    contentItem: Item {
        implicitWidth: textLabel.implicitWidth
        implicitHeight: textLabel.implicitHeight

        Text {
            id: textLabel
            anchors.fill: parent
            text: control.text
            font: control.font

            color: control.enabled ? control.textColor : control.disabledTextColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.textSpacing
            elide: Text.ElideRight
        }
    }

    // Checkbox indicator
    indicator: Rectangle {
        implicitWidth: control.indicatorSize
        implicitHeight: control.indicatorSize
        x: 0
        y: parent.height / 2 - height / 2

        // Add color change when hovered
        color: ControlState.selectionFill(control.enabled, control.checked, control.pressed, control.hovered)

        // Hovered
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.width {
            NumberAnimation {
                duration: 150
            }
        }

        border.color: ControlState.selectionBorder(control.enabled, control.checked, control.pressed, control.hovered, control.visualFocus)

        border.width: (control.hovered || control.visualFocus) ? ControlState.borderFocus : ControlState.borderThin
        radius: control.defaultRadius

        Image {
            id: checkMark
            source: "qrc:/GeoControls/icons/Check.svg"
            anchors.fill: parent
            anchors.margins: Fonts.size1
            visible: control.checkState === Qt.Checked
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 0.9 : 0.3
        }

        Rectangle {
            visible: control.checkState === Qt.PartiallyChecked
            width: parent.width - Fonts.size6
            height: Fonts.size2
            color: control.enabled ? control.textColor : control.disabledTextColor
            anchors.centerIn: parent
            antialiasing: true
        }
    }

    // Mouse area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        function handleClick(mouseX) {
            if (mouseX <= control.indicator.width) {
                // Click checkbox area
                control.toggle()
                control.clicked()
            } else if (!control.textClickable) {
                // Click text area and textClickable is false
                control.textClicked()
            } else {
                // Click text area and textClickable is true
                control.toggle()
                control.clicked()
            }
        }

        onClicked: mouse => handleClick(mouse.x)
    }

    CustomToolTip {
        visible: control.tooltipText !== "" && mouseArea.containsMouse && control.enabled
        delay: control.tooltipDelay
        text: control.tooltipText
    }
}
