import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import GeoControls 1.0

ColumnLayout {
    id: root
    spacing: 0
    Layout.fillWidth: true
    property var presets: 0
    property var step: 0
    property alias title: slider.title

    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    property alias validatorDecimals: slider.validatorDecimals
    property bool needButton: false
    property string buttonText: "Set"

    signal presetsCurrentIndexChanged(int index)
    signal sliderValueChanged(var value)
    signal buttonClicked

    RowLayout {
        id: presets
        Layout.fillWidth: true
        spacing: 0

        property int selectedIndex: -1

        function setByPreset(idx) {
            var val
            if (Array.isArray(root.presets)) {
                val = root.presets[idx]
            } else if (typeof root.presets === "number") {
                val = idx * root.step
            }

            slider.value = val

            presetsCurrentIndexChanged(idx)
        }

        Repeater {
            model: {
                if (Array.isArray(root.presets)) {
                    return root.presets
                } else if (typeof root.presets === "number") {
                    return root.presets
                }
                return 0
            }

            ColorTabButton {
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size1
                Layout.alignment: Qt.AlignVCenter

                text: (typeof root.presets === "number") ? (index * root.step).toString() : root.presets[index].toString()

                checked: false

                onClicked: {
                    checked = false;
                    // presets.selectedIndex = index;
                    presets.setByPreset(index)
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        CustomSlider {
            id: slider
            Layout.fillWidth: true

            onValueChanged: {
                sliderValueChanged(value)
            }
        }

        CustomButton {
            visible: root.needButton
            text: root.buttonText
            onClicked: {
                buttonClicked()
            }
        }
    }
}
