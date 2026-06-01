import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

RowLayout {
    id: control

    property var model: []
    property int currentIndex: Array.isArray(model) ? model.length - 1 : -1

    signal activated(int index)

    spacing: Fonts.size4

    Repeater {
        model: Array.isArray(control.model) ? control.model : []

        RowLayout {
            required property int index
            required property var modelData

            spacing: Fonts.size4

            CustomButton {
                text: String(parent.modelData)
                enabled: parent.index !== control.currentIndex
                defaultHeight: Fonts.iconButtonSize
                defaultPadding: Fonts.size6
                buttonColor: "transparent"
                hoveredColor: Theme.buttonHoveredColor
                midColor: "transparent"
                onClicked: control.activated(parent.index)
            }

            CustomLabel {
                visible: parent.index < control.model.length - 1
                text: "/"
                color: Theme.placeholderTextColor
            }
        }
    }
}
