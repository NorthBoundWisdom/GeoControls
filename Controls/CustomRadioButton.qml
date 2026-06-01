import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

RadioButton {
    id: control

    // custom properties
    property bool textClickable: true
    property int defaultHeight: Fonts.inputFieldHeight
    property int indicatorSize: defaultHeight // increase indicator size
    property int defaultPadding: Fonts.size6  // increase default spacing
    font: Fonts.standardFont

    implicitHeight: Math.max(contentItem.implicitHeight, indicatorSize)
    implicitWidth: indicator.width + (text ? spacing + contentItem.implicitWidth : 0)

    padding: defaultPadding  // set overall padding
    spacing: defaultPadding * Fonts.size2  // increase spacing between text and indicator

    signal textClicked

    indicator: Rectangle {
        id: indicatorRect
        implicitWidth: indicatorSize
        implicitHeight: indicatorSize
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: width / 2

        // track hovered state
        property bool isHovered: false

        // background color
        color: {
            if (!control.enabled)
                return Theme.buttonDisabledColor
            // forbidden
            if (control.pressed)
                return Theme.buttonPressedColor
            // pressed
            if (isHovered)
                return Theme.highlightColor
            // hovered
            return Theme.buttonColor
            // default
        }
        opacity: isHovered ? 0.2 : 1.0

        border.color: {
            if (!control.enabled)
                return Theme.midColor
            // forbidden
            if (control.pressed || control.checked)
                return Theme.highlightColor
            // selected or pressed
            if (isHovered)
                return Theme.highlightColor
            // hovered
            return Theme.midColor
            // default
        }
        border.width: control.checked ? Fonts.size2 : Fonts.size1

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
            color: control.enabled ? Theme.highlightColor : Theme.midColor
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
