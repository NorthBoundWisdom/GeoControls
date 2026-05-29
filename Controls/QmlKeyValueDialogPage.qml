import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

DialogShell {
    id: root
    objectName: "QmlKeyValueDialogPage"

    // Unified sizing based on current font metrics - auto height
    property int contentCount: keyValueList ? keyValueList.length : 0
    property int baseWidth: contentCount <= 2 ? 300 : 400
    property int maxWidth: contentCount <= 2 ? 350 : 500

    width: Math.max(baseWidth, Math.min(maxWidth, unit * Fonts.size15 + Fonts.size80))
    height: Math.max(Fonts.size180, implicitHeight)

    headerHeight: Math.round(unit * 1.5)
    contentMargin: Math.round(unit * 0.75)
    topSpacerHeight: Math.round(unit * 0.5)
    bottomSpacerHeight: Math.round(unit * 0.5)
    footerTopMargin: Math.round(unit * 0.5)
    footerBottomMargin: Math.round(unit * 0.5)
    footerSpacing: Math.round(unit * 0.5)

    // Properties set by C++ - these will be overridden by context properties
    property string dialogTitle: "Edit Properties"
    property var keyValueList: [] // List of {name: string, value: variant}

    // Signals
    signal valuesSubmitted(variant keyValueList)
    signal cancelled

    titleText: dialogTitle

    onCloseRequested: root.cancelled()

    bodyItem: ColumnLayout {
        spacing: Math.round(unit * 0.3)

        Repeater {
            id: repeater
            model: root.keyValueList

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(unit * 0.4)

                Label {
                    text: modelData.name || ""
                    font: Fonts.standardFont
                    color: Theme.textColor
                    Layout.preferredWidth: Math.round(unit * Fonts.size6)
                    Layout.alignment: Qt.AlignVCenter
                    wrapMode: Text.Wrap
                }

                TextField {
                    id: valueField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(unit * 1.8)
                    text: (modelData.value === undefined || modelData.value === null) ? "" : String(modelData.value)
                    font: Fonts.standardFont
                    selectByMouse: true

                    validator: {
                        if (modelData.value === undefined || modelData.value === null) {
                            return null
                        }

                        var originalValue = modelData.value
                        if (typeof originalValue === "number" || (typeof originalValue === "string" && !isNaN(originalValue) && originalValue !== "")) {
                            return Qt.createQmlObject("import QtQuick 2.13; DoubleValidator { bottom: -999999999; top: 999999999; decimals: 6; notation: DoubleValidator.StandardNotation }", valueField)
                        }

                        return Qt.createQmlObject("import QtQuick 2.13; RegExpValidator { regExp: /.*/ }", valueField)
                    }

                    background: Rectangle {
                        color: Theme.baseColor
                        border.color: valueField.activeFocus ? Theme.highlightColor : Theme.midColor
                        border.width: Fonts.size1
                        radius: Fonts.size4
                    }

                    color: Theme.textColor
                    selectionColor: Theme.highlightColor
                    selectedTextColor: Theme.highlightedTextColor

                    onTextChanged: {
                        if (root.keyValueList && index < root.keyValueList.length) {
                            var newValue = text

                            var originalValue = root.keyValueList[index].value
                            if (typeof originalValue === "number" || (typeof originalValue === "string" && !isNaN(originalValue) && originalValue !== "")) {
                                var numValue = parseFloat(text)
                                if (!isNaN(numValue)) {
                                    newValue = numValue
                                }
                            }

                            root.keyValueList[index].value = newValue
                        }
                    }

                    Keys.onReturnPressed: {
                        if (index < repeater.count - 1) {
                            repeater.itemAt(index + 1).children[1].forceActiveFocus()
                        } else {
                            root.valuesSubmitted(root.keyValueList)
                            root.close()
                        }
                    }
                }
            }
        }
    }

    footerItem: RowLayout {
        spacing: root.footerSpacing

        Item {
            Layout.fillWidth: true
        }

        CustomButton {
            text: qsTr("OK")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            onClicked: {
                root.valuesSubmitted(root.keyValueList)
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
        if (repeater.count > 0) {
            var firstItem = repeater.itemAt(0)
            if (firstItem && firstItem.children.length > 1) {
                firstItem.children[1].forceActiveFocus()
            }
        }
    }
}
