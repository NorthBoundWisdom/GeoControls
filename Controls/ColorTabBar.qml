import QtQuick 2.15
import QtQuick.Controls 2.15
import GeoToy.Controls 1.0

TabBar {
    id: control

    property int defaultHeight: Fonts.iconButtonSize

    property color backgroundColor: Theme.buttonColor
    property color activeBackgroundColor: Theme.baseColor
    property color hoverBackgroundColor: Theme.buttonHoveredColor
    property color disabledBackgroundColor: Theme.buttonDisabledColor

    property color textColor: Theme.textColor
    property color activeTextColor: Theme.textColor
    property color disabledTextColor: Theme.disabledTextColor

    property color borderColor: Theme.midColor
    property color activeBorderColor: Theme.highlightColor
    property color hoverBorderColor: Theme.highlightColor

    implicitHeight: defaultHeight

    background: Rectangle {
        color: backgroundColor
        border.color: borderColor
        border.width: Fonts.size1
    }
}
