import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

DialogShell {
    id: root
    objectName: "QmlInputDialogPage"

    // Unified sizing based on current font metrics
    width: Math.max(Fonts.size350, unit * Fonts.size20)
    // Let dialog shrink-wrap its content
    bodyFillHeight: false
    bottomSpacerHeight: Math.round(unit * 0.5)

    // Properties set by C++ - these will be overridden by context properties
    property string dialogTitle: "Input Text"
    property string placeholderText: ""
    property string initialText: ""

    // Signals
    signal textSubmitted(string text)
    signal cancelled

    titleText: dialogTitle

    onCloseRequested: root.cancelled()

    bodyItem: ColumnLayout {
        spacing: Math.round(unit * 0.5)

        Label {
            text: qsTr("Enter text:")
            font: Fonts.standardFont
            color: Theme.textColor
            Layout.fillWidth: true
        }

        TextField {
            id: inputField
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(unit * 2.0)
            placeholderText: root.placeholderText
            text: root.initialText
            font: Fonts.standardFont
            selectByMouse: true
            focus: true

            background: Rectangle {
                color: Theme.baseColor
                border.color: inputField.activeFocus ? Theme.highlightColor : Theme.midColor
                border.width: Fonts.size1
                radius: Fonts.size4
            }

            color: Theme.textColor
            selectionColor: Theme.highlightColor
            selectedTextColor: Theme.highlightedTextColor

            Keys.onReturnPressed: {
                if (text.trim().length > 0) {
                    root.textSubmitted(text.trim());
                    root.close();
                }
            }

            Keys.onEnterPressed: {
                if (text.trim().length > 0) {
                    root.textSubmitted(text.trim());
                    root.close();
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
            text: qsTr("OK")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            enabled: inputField.text.trim().length > 0
            onClicked: {
                if (inputField.text.trim().length > 0) {
                    root.textSubmitted(inputField.text.trim());
                    root.close();
                }
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
        inputField.forceActiveFocus();
        inputField.selectAll();
    }
}
