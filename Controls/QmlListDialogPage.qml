import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoControls 1.0

DialogShell {
    id: root
    objectName: "QmlListDialogPage"

    // Unified sizing based on current font metrics
    width: Math.max(Fonts.size300, unit * Fonts.size18)
    height: Math.max(Fonts.size300, unit * Fonts.size18)

    // Properties set by C++ - these will be overridden by context properties
    property string dialogTitle: "Select Item"
    property var dialogItems: []
    property bool allowMultipleSelection: false

    // Internal state
    property var selectedItems: []
    property var selectedIndices: []

    // Signals for different selection modes
    signal itemSelected(string item, int index)
    signal itemsSelected(var items, var indices)
    signal cancelled

    titleText: dialogTitle

    onCloseRequested: root.cancelled()

    function requestInitialFocus() {
        root.requestDialogFocus()
        itemList.forceActiveFocus(Qt.ActiveWindowFocusReason)
    }

    bodyItem: ScrollView {
        clip: true

        ListView {
            id: itemList
            focus: true
            model: dialogItems
            spacing: Fonts.size2

            delegate: Rectangle {
                width: itemList.width
                height: Math.round(unit * 1.5)
                color: {
                    if (root.allowMultipleSelection) {
                        return selected ? Theme.highlightColor : (mouseArea.containsMouse ? Theme.buttonHoveredColor : "transparent")
                    }
                    return mouseArea.containsMouse ? Theme.highlightColor : "transparent"
                }
                radius: Fonts.size4
                border.width: selected ? Fonts.size1 : 0
                border.color: Theme.highlightColor

                property bool selected: allowMultipleSelection && root.selectedIndices.indexOf(index) !== -1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: unit * 0.5
                    anchors.rightMargin: unit * 0.5

                    CheckBox {
                        visible: allowMultipleSelection
                        checked: parent.parent.selected
                        onToggled: {
                            if (checked) {
                                if (root.selectedIndices.indexOf(index) === -1) {
                                    root.selectedIndices.push(index)
                                    root.selectedItems.push(modelData)
                                }
                            } else {
                                var idx = root.selectedIndices.indexOf(index)
                                if (idx !== -1) {
                                    root.selectedIndices.splice(idx, 1)
                                    root.selectedItems.splice(idx, 1)
                                }
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData
                        font: Fonts.standardFont
                        color: {
                            if (allowMultipleSelection) {
                                return parent.parent.selected ? Theme.highlightedTextColor : Theme.textColor
                            }
                            return mouseArea.containsMouse ? Theme.highlightedTextColor : Theme.textColor
                        }
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (allowMultipleSelection) {
                            var idx = root.selectedIndices.indexOf(index)
                            if (idx === -1) {
                                root.selectedIndices.push(index)
                                root.selectedItems.push(modelData)
                            } else {
                                root.selectedIndices.splice(idx, 1)
                                root.selectedItems.splice(idx, 1)
                            }
                        } else {
                            root.itemSelected(modelData, index)
                            root.close()
                        }
                    }
                }
            }
        }
    }

    footerItem: RowLayout {
        spacing: Fonts.size10

        Item {
            Layout.fillWidth: true
        }

        CustomButton {
            visible: allowMultipleSelection
            text: qsTr("OK")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            enabled: root.selectedItems.length > 0
            onClicked: {
                root.itemsSelected(root.selectedItems, root.selectedIndices)
                root.close()
            }
        }

        CustomButton {
            text: qsTr("Cancel")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            onClicked: root.requestClose("cancel")
        }
    }

    onOpened: {
        requestInitialFocus()
    }
}
