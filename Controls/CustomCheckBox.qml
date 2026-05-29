import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoToy.Controls 1.0

CheckBox {
    id: control

    // custom properties
    property bool textClickable: true
    property int defaultHeight: Fonts.iconSize
    property int defaultRadius: Fonts.size1
    property int defaultPadding: Fonts.size4
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

    implicitHeight: Math.max(contentItem.implicitHeight, indicatorSize)
    implicitWidth: indicator.width + (text ? spacing + contentItem.implicitWidth : 0)

    padding: 0
    spacing: textSpacing

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
            leftPadding: control.indicator.width + textSpacing
            elide: Text.ElideRight
        }
    }

    // Checkbox indicator
    indicator: Rectangle {
        implicitWidth: indicatorSize
        implicitHeight: indicatorSize
        x: 0
        y: parent.height / 2 - height / 2

        // Add color change when hovered
        color: !control.enabled ? control.disabledTextColor : control.pressed ? control.highlightColor : control.baseColor

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

        border.color: !control.enabled ? control.midColor : control.pressed ? control.highlightColor : control.hovered ? control.highlightColor : control.midColor

        border.width: control.hovered ? Fonts.size2 : Fonts.size1
        radius: defaultRadius

        Image {
            id: checkMark
            source: "qrc:/icons/Check.svg"
            anchors.fill: parent
            anchors.margins: Fonts.size1
            visible: control.checkState === Qt.Checked
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 0.7 : 0.3
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
        visible: tooltipText !== "" && mouseArea.containsMouse && control.enabled
        delay: tooltipDelay
        text: tooltipText
    }
}
