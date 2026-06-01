import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

RowLayout {
    id: control

    property int rating: 0
    property int maximum: 5
    property bool readOnly: false

    signal ratingChangedByUser(int rating)

    spacing: Fonts.size2

    Repeater {
        model: control.maximum

        Text {
            required property int index
            readonly property bool active: index < control.rating
            readonly property bool hovered: starMouse.containsMouse

            text: "\u2605"
            font.pixelSize: Fonts.size20
            color: active || hovered ? Theme.warningColor : Theme.midColor
            opacity: control.enabled ? 1.0 : 0.45

            MouseArea {
                id: starMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: control.enabled && !control.readOnly
                onClicked: {
                    control.rating = parent.index + 1
                    control.ratingChangedByUser(control.rating)
                }
            }
        }
    }
}
