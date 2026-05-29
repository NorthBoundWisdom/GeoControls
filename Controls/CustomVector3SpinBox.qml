import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Rectangle {
    id: control
    color: "transparent"

    // Properties for the 3D vector values
    property var vector: [0.0, 0.0, 0.0]  // Default to [0, 0, 0]

    // SpinBox properties that will be applied to all three spinboxes
    property double from: -999999.0
    property double to: 999999.0
    property double stepSize: 1.0
    property int decimals: 3
    property bool editable: true
    property bool enabled: true

    // Layout properties
    property int spacing: Fonts.size4
    property bool showLabels: true
    property var labels: ["X", "Y", "Z"]  // Default labels for X, Y, Z components

    // Signal emitted when any value changes
    signal vectorValueChanged(var newVector)
    signal valueChanged(int index, double newValue)

    // Implicit size based on content
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Internal properties for proper updating
    property bool _internal_updating: false

    // Watch for external vector changes and update spinboxes
    onVectorChanged: {
        if (!_internal_updating && vector && vector.length >= 3) {
            _internal_updating = true;
            spinBoxX.realValue = vector[0];
            spinBoxY.realValue = vector[1];
            spinBoxZ.realValue = vector[2];
            _internal_updating = false;
        }
    }

    // Main layout
    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: control.spacing

        // X component
        ColumnLayout {
            spacing: Fonts.size2
            Layout.alignment: Qt.AlignTop

            Text {
                text: control.labels[0]
                color: Theme.textColor
                font.family: Fonts.standardFont.family
                visible: control.showLabels
                Layout.alignment: Qt.AlignHCenter
            }

            CustomSpinBox {
                id: spinBoxX
                Layout.fillWidth: true
                realValue: control.vector[0] || 0.0
                realFrom: control.from
                realTo: control.to
                realStepSize: control.stepSize
                decimals: control.decimals
                editable: control.editable
                enabled: control.enabled

                onRealValueChanged: {
                    if (!control._internal_updating && control.vector[0] !== realValue) {
                        control._internal_updating = true;
                        var newVector = [realValue, control.vector[1] || 0.0, control.vector[2] || 0.0];
                        control.vector = newVector;
                        control.valueChanged(0, realValue);
                        control.vectorValueChanged(newVector);
                        control._internal_updating = false;
                    }
                }
            }
        }

        // Y component
        ColumnLayout {
            spacing: Fonts.size2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            Text {
                text: control.labels[1]
                color: Theme.textColor
                font.family: Fonts.standardFont.family
                visible: control.showLabels
                Layout.alignment: Qt.AlignHCenter
            }

            CustomSpinBox {
                id: spinBoxY
                Layout.fillWidth: true

                realValue: control.vector[1] || 0.0
                realFrom: control.from
                realTo: control.to
                realStepSize: control.stepSize
                decimals: control.decimals
                editable: control.editable
                enabled: control.enabled

                onRealValueChanged: {
                    if (!control._internal_updating && control.vector[1] !== realValue) {
                        control._internal_updating = true;
                        var newVector = [control.vector[0] || 0.0, realValue, control.vector[2] || 0.0];
                        control.vector = newVector;
                        control.valueChanged(1, realValue);
                        control.vectorValueChanged(newVector);
                        control._internal_updating = false;
                    }
                }
            }
        }

        // Z component
        ColumnLayout {
            spacing: Fonts.size2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            Text {
                text: control.labels[2]
                color: Theme.textColor
                font: Fonts.standardFont
                visible: control.showLabels
                Layout.alignment: Qt.AlignHCenter
            }

            CustomSpinBox {
                id: spinBoxZ
                Layout.fillWidth: true

                realValue: control.vector[2] || 0.0
                realFrom: control.from
                realTo: control.to
                realStepSize: control.stepSize
                decimals: control.decimals
                editable: control.editable
                enabled: control.enabled

                onRealValueChanged: {
                    if (!control._internal_updating && control.vector[2] !== realValue) {
                        control._internal_updating = true;
                        var newVector = [control.vector[0] || 0.0, control.vector[1] || 0.0, realValue];
                        control.vector = newVector;
                        control.valueChanged(2, realValue);
                        control.vectorValueChanged(newVector);
                        control._internal_updating = false;
                    }
                }
            }
        }
    }

    // Function to set the entire vector at once
    function setVector(newVector) {
        if (newVector && newVector.length >= 3) {
            _internal_updating = true;
            control.vector = [newVector[0], newVector[1], newVector[2]];
            spinBoxX.realValue = control.vector[0];
            spinBoxY.realValue = control.vector[1];
            spinBoxZ.realValue = control.vector[2];
            _internal_updating = false;
            vectorValueChanged(control.vector);
        }
    }

    // Function to get the current vector
    function getVector() {
        return [control.vector[0] || 0.0, control.vector[1] || 0.0, control.vector[2] || 0.0];
    }

    // Function to set individual component
    function setComponent(index, value) {
        if (index >= 0 && index < 3) {
            _internal_updating = true;
            var newVector = [control.vector[0] || 0.0, control.vector[1] || 0.0, control.vector[2] || 0.0];
            newVector[index] = value;
            control.vector = newVector;

            switch (index) {
            case 0:
                spinBoxX.realValue = value;
                break;
            case 1:
                spinBoxY.realValue = value;
                break;
            case 2:
                spinBoxZ.realValue = value;
                break;
            }
            _internal_updating = false;
            valueChanged(index, value);
            vectorValueChanged(control.vector);
        }
    }

    // Function to reset all values to zero
    function reset() {
        setVector([0.0, 0.0, 0.0]);
    }

    // Additional utility functions
    function setX(value) {
        setComponent(0, value);
    }
    function setY(value) {
        setComponent(1, value);
    }
    function setZ(value) {
        setComponent(2, value);
    }

    function getX() {
        return control.vector[0] || 0.0;
    }
    function getY() {
        return control.vector[1] || 0.0;
    }
    function getZ() {
        return control.vector[2] || 0.0;
    }
}
