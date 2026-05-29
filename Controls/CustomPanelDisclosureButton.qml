import QtQuick 2.15
import GeoToy.Controls 1.0

CustomPanelGlyphButton {
    property bool expanded: false

    glyphText: "\u25b6"
    glyphRotation: expanded ? 90 : 0
}
