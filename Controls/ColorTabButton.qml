import QtQuick 2.15
import QtQuick.Controls 2.15
import GeoControls 1.0

TabButton {
    id: control

    property color backgroundColor: parent && parent.backgroundColor ? parent.backgroundColor : Theme.buttonColor
    property color activeBackgroundColor: parent && parent.activeBackgroundColor ? parent.activeBackgroundColor : Theme.baseColor
    property color hoverBackgroundColor: parent && parent.hoverBackgroundColor ? parent.hoverBackgroundColor : Theme.buttonHoveredColor
    property color disabledBackgroundColor: parent && parent.disabledBackgroundColor ? parent.disabledBackgroundColor : Theme.buttonDisabledColor

    property color textColor: parent && parent.textColor ? parent.textColor : Theme.textColor
    property color activeTextColor: parent && parent.activeTextColor ? parent.activeTextColor : Theme.textColor
    property color disabledTextColor: parent && parent.disabledTextColor ? parent.disabledTextColor : Theme.disabledTextColor

    property color borderColor: parent && parent.borderColor ? parent.borderColor : Theme.midColor
    property color activeBorderColor: parent && parent.activeBorderColor ? parent.activeBorderColor : Theme.highlightColor
    property color hoverBorderColor: parent && parent.hoverBorderColor ? parent.hoverBorderColor : Theme.highlightColor

    font: Fonts.standardFont
    height: parent && parent.defaultHeight ? parent.defaultHeight : Fonts.iconButtonSize
    padding: Fonts.size8

    background: Rectangle {
        color: "transparent"
        border.width: 0

        Rectangle {
            anchors.centerIn: parent
            width: Math.max(0, parent.width - Fonts.size4)
            height: Math.max(0, parent.height - Fonts.size4)
            radius: Fonts.size4
            color: {
                if (!control.enabled)
                    return control.disabledBackgroundColor
                if (control.checked)
                    return control.activeBackgroundColor
                if (control.hovered)
                    return control.hoverBackgroundColor
                return control.backgroundColor
            }

            border.color: {
                if (!control.enabled)
                    return control.borderColor
                if (control.checked)
                    return control.activeBorderColor
                if (control.hovered)
                    return control.hoverBorderColor
                return control.borderColor
            }
            border.width: control.checked ? Fonts.size1 : 0
        }

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
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: {
            if (!control.enabled)
                return control.disabledTextColor
            if (control.checked)
                return control.activeTextColor
            return control.textColor
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
