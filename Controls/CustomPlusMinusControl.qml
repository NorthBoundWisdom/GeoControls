import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import GeoControls 1.0

RowLayout {
    id: root
    spacing: 0
    Layout.fillWidth: true
    implicitHeight: Math.max(minusButton.implicitHeight, valueField.implicitHeight, plusButton.implicitHeight)

    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    property int defaultValue: 1

    signal valueChanged(int delta)

    CustomButton {
        id: minusButton
        text: "-"
        Layout.preferredWidth: Fonts.size50
        onClicked: {
            let val = parseInt(valueField.text) || 0
            root.valueChanged(-val)
        }
    }

    CustomTextField {
        id: valueField
        Layout.preferredWidth: Fonts.size20
        text: root.defaultValue.toString()
        validator: IntValidator {
            bottom: 1
        }
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }

    CustomButton {
        id: plusButton
        text: "+"
        Layout.preferredWidth: Fonts.size50
        onClicked: {
            let val = parseInt(valueField.text) || 0
            root.valueChanged(val)
        }
    }
}
