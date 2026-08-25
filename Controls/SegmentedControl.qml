import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0

    signal activated(int index)

    implicitWidth: segmentLayout.implicitWidth + ControlState.borderThin * 2
    implicitHeight: ControlState.minInputHeight
    radius: ControlState.radiusSmall
    color: Theme.baseColor
    border.color: Theme.midColor
    border.width: ControlState.borderThin
    clip: false

    Item {
        id: segmentClip
        anchors.fill: parent
        anchors.margins: control.border.width
        clip: true

        RowLayout {
            id: segmentLayout
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: Array.isArray(control.model) ? control.model : []

                SegmentedButton {
                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 1
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
}
