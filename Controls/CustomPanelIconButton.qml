import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import GeoToy.Controls 1.0

CustomButton {
    id: control

    property int buttonSize: Fonts.size20
    property int iconContentSize: Math.max(Fonts.size10, buttonSize - Fonts.size8)

    defaultHeight: buttonSize
    defaultPadding: 0
    defaultRadius: Fonts.size3
    implicitWidth: buttonSize
    implicitHeight: buttonSize
    text: ""
    display: AbstractButton.IconOnly

    icon.width: iconContentSize
    icon.height: iconContentSize

    contentItem: Item {
        IconImage {
            anchors.centerIn: parent
            width: control.iconContentSize
            height: control.iconContentSize
            source: control.icon.source
            color: control.icon.color
            visible: control.icon.source !== ""
        }
    }
}
