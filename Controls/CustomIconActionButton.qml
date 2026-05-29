import QtQuick 2.15
import QtQuick.Controls 2.15
import GeoToy.Controls 1.0

CustomButton {
    id: control

    property string iconText: ""
    property bool active: false
    property color activeColor: Theme.highlightColor
    property color inactiveColor: Theme.buttonColor
    property color hoveredInactiveColor: Theme.buttonHoveredColor
    property color pressedBgColor: Theme.midColor
    property color borderColor: "transparent"
    property color hoveredBorderColor: borderColor
    property color pressedBorderColor: hoveredBorderColor
    property int borderWidth: 0
    property real activeTextFactor: 1.3
    property int iconPixelSize: Theme.cmdlineFont.pixelSize

    defaultHeight: Fonts.iconButtonSize
    defaultPadding: 0
    defaultRadius: Fonts.smallMargin
    implicitWidth: Fonts.iconButtonSize
    implicitHeight: Fonts.iconButtonSize
    text: ""

    contentItem: Text {
        text: control.iconText
        color: control.active ? Qt.lighter(control.buttonTextColor, control.activeTextFactor) : control.buttonTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: control.iconPixelSize
    }

    background: Rectangle {
        color: {
            if (!control.enabled) {
                return control.disabledColor;
            }
            if (control.pressed) {
                return control.pressedBgColor;
            }
            if (control.hovered) {
                return control.active ? Qt.lighter(control.activeColor, 1.1) : control.hoveredInactiveColor;
            }
            return control.active ? control.activeColor : control.inactiveColor;
        }
        border.color: {
            if (!control.enabled) {
                return control.borderColor;
            }
            if (control.pressed) {
                return control.pressedBorderColor;
            }
            if (control.hovered) {
                return control.hoveredBorderColor;
            }
            return control.borderColor;
        }
        border.width: control.borderWidth
        radius: control.defaultRadius
    }
}
