import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

RadioButton {
    id: control

    // custom properties
    property bool textClickable: true
    property int defaultHeight: ControlState.minInputHeight
    property int indicatorSize: defaultHeight // increase indicator size
    property int defaultPadding: ControlState.textPadding  // increase default spacing
    font: Fonts.standardFont

    implicitHeight: Math.max(contentItem.implicitHeight, control.indicatorSize)
    implicitWidth: indicator.width + (text ? spacing + contentItem.implicitWidth : 0)

    padding: control.defaultPadding  // set overall padding
    spacing: control.defaultPadding * Fonts.size2  // increase spacing between text and indicator

    signal textClicked

    indicator: Rectangle {
        id: indicatorRect
        implicitWidth: control.indicatorSize
        implicitHeight: control.indicatorSize
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: width / 2

        // track hovered state
        property bool isHovered: false

        // background color
        color: {
            return ControlState.selectionFill(control.enabled, control.checked, control.pressed, indicatorRect.isHovered)
        }
        opacity: control.enabled ? 1.0 : 0.65

        border.color: ControlState.selectionBorder(control.enabled, control.checked, control.pressed, indicatorRect.isHovered, control.visualFocus)
        border.width: (control.checked || control.visualFocus || indicatorRect.isHovered) ? ControlState.borderFocus : ControlState.borderThin

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Rectangle {
            width: parent.width - Fonts.size8
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: control.enabled ? Theme.highlightedTextColor : Theme.midColor
            visible: control.checked
            opacity: control.enabled ? 0.8 : 0.5

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        Connections {
            target: control
            function onPaletteChanged() {
                indicatorRect.isHovered = false
            }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font

        color: control.enabled ? Theme.textColor : Theme.disabledTextColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            indicatorRect.isHovered = true
        }

        onExited: {
            indicatorRect.isHovered = false
        }

        function handleClick(mouseX) {
            if (mouseX <= (control.indicator.width + control.leftPadding)) {
                if (!control.checked) {
                    control.toggle()
                    control.clicked()
                }
            } else if (!control.textClickable) {
                control.textClicked()
            } else {
                if (!control.checked) {
                    control.toggle()
                    control.clicked()
                }
            }
        }

        onClicked: mouse => handleClick(mouse.x)
    }
}
