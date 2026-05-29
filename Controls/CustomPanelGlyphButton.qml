import QtQuick 2.15
import GeoToy.Controls 1.0

CustomPanelIconButton {
    id: control

    property string glyphText: ""
    property int glyphPixelSize: Fonts.scaledFontPixelSize(10)
    property real glyphRotation: 0
    property int glyphSize: Fonts.size10

    contentItem: Text {
        text: control.glyphText
        font.family: Fonts.listFont.family
        font.pixelSize: control.glyphPixelSize
        width: control.glyphSize
        height: control.glyphSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: !control.enabled ? control.disabledTextColor : control.pressed ? control.highlightedTextColor : control.buttonTextColor
        anchors.centerIn: parent
        transformOrigin: Item.Center
        rotation: control.glyphRotation
        renderType: Text.NativeRendering
    }
}
