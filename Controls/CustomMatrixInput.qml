import GeoToy.Controls 1.0
// MatrixInput.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    property string label: qsTr("Matrix:")
    property alias inputGrid: inputGridLayout
    property alias rows: inputGridLayout.rows
    property alias columns: inputGridLayout.columns
    property var defaultValue: []
    property var sliderTitle: []
    property var internalData: []
    property bool useSlider: false

    property var matrix: []

    Layout.fillWidth: true
    implicitHeight: columnLayout.implicitHeight

    signal matrixDataChanged(var matrix)

    onDefaultValueChanged: {
        internalData = defaultValue.slice()
    }

    ColumnLayout {
        id: columnLayout
        Layout.fillWidth: true
        spacing: Fonts.size8
        width: root.width

        CustomLabel {
            id: label
            text: root.label
            Layout.preferredWidth: implicitWidth
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font: Fonts.standardFont
            color: Theme.textColor
        }

        GridLayout {
            id: inputGridLayout
            Layout.fillWidth: true
            columns: root.columns
            rows: root.rows
            rowSpacing: Fonts.size4
            columnSpacing: Fonts.size4

            Repeater {
                id: matrixInputModel
                model: internalData

                ColumnLayout {
                    Layout.fillWidth: true

                    CustomTextField {
                        Layout.fillWidth: true
                        visible: !useSlider
                        text: Number(modelData).toPrecision(6)
                        validator: DoubleValidator {
                            decimals: 12
                        }
                        verticalAlignment: Text.AlignVCenter
                        onEditingFinished: {
                            let val = parseFloat(text)
                            internalData[index] = isNaN(val) ? 0.0 : val
                            root.getMatrix()
                        }
                    }

                    CustomSlider {
                        title: sliderTitle.count > index ? sliderTitle[index] : ""
                        Layout.fillWidth: true
                        from: -5000
                        to: 5000
                        visible: useSlider
                        stepSize: 1
                        validatorDecimals: 2
                        value: modelData
                        onValueChanged: {
                            internalData[index] = value
                            root.getMatrix()
                        }
                    }
                }
            }
        }
    }

    function getMatrix() {
        matrix = []
        if (rows === 1 || columns === 1) {
            matrix = internalData.slice()
        } else {
            for (let r = 0; r < rows; ++r) {
                let row = []
                for (let c = 0; c < columns; ++c) {
                    row.push(internalData[r * columns + c])
                }
                matrix.push(row)
            }
        }
        matrixDataChanged(matrix)
    }
}
