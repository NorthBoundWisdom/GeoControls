import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import GeoControls 1.0

Item {
    id: root
    property bool needReverse: true

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: axisRow
            spacing: 0
            Layout.fillWidth: true
            ButtonGroup {
                id: axisGroup
            }

            Repeater {
                Layout.fillWidth: true
                model: ["X", "Y", "Z"]
                CustomButton {
                    text: modelData
                    checkable: true
                    Layout.fillWidth: true
                    ButtonGroup.group: axisGroup
                    onClicked: axisChanged(index) // send index 0,1,2
                }
            }
        }

        CustomButton {
            id: reverseButton
            text: "⇄"
            visible: root.needReverse
            checkable: true
            Layout.fillWidth: true
            onCheckedChanged: root.reverseChanged(checked)
        }
    }

    signal axisChanged(int index)

    signal reverseChanged(bool reversed)
}
