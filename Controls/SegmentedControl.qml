import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0

    signal activated(int index)

    implicitWidth: segmentLayout.implicitWidth + Fonts.size8
    implicitHeight: ControlState.minInputHeight + Fonts.size8
    radius: ControlState.radiusSmall
    color: Theme.baseColor
    border.color: Theme.midColor
    border.width: ControlState.borderThin

    RowLayout {
        id: segmentLayout
        anchors.fill: parent
        anchors.margins: Fonts.size4
        spacing: Fonts.size4

        Repeater {
            model: Array.isArray(control.model) ? control.model : []

            SegmentedButton {
                required property int index
                required property var modelData

                Layout.fillWidth: true
                text: String(modelData)
                selected: control.currentIndex === index
                onClicked: {
                    if (control.currentIndex === index)
                        return
                    control.currentIndex = index
                    control.activated(index)
                }
            }
        }
    }
}
