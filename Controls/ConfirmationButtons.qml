import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

RowLayout {
    id: root

    property alias okEnabled: okBtn.enabled
    property alias cancelEnabled: cancelBtn.enabled
    property alias okText: okBtn.text
    property alias cancelText: cancelBtn.text

    signal toggled(bool yes)

    Item {
        Layout.fillWidth: true
    }

    CustomButton {
        id: okBtn
        text: qsTr("OK")

        onClicked: {
            root.toggled(true)
        }
    }

    CustomButton {
        id: cancelBtn
        text: qsTr("Cancel")
        onClicked: {
            root.toggled(false)
        }
    }
}
