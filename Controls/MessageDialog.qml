import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoControls 1.0

DialogShell {
    id: root
    objectName: "MessageDialog"

    // Unified sizing via Fonts (kept fixed for maintainability)
    width: Fonts.messageDialogWidth

    titleText: qsTr("Confirm")
    property string messageText: ""
    // Generic API like QMessageBox
    property var buttons: [qsTr("Cancel"), qsTr("Exit")]
    property string defaultButtonText: ""
    property string resultText: ""
    signal finished(string buttonText)

    signal accepted
    signal rejected

    onCloseRequested: function (reason) {
        root.resultText = qsTr("Cancel")
        root.finished(qsTr("Cancel"))
        if (reason === "escape") {
            root.rejected()
        }
    }

    bodyItem: ColumnLayout {
        spacing: 0

        Keys.onReturnPressed: {
            root.accepted()
            root.close()
        }
        Keys.onEnterPressed: {
            root.accepted()
            root.close()
        }

        Label {
            text: root.messageText
            wrapMode: Text.Wrap
            color: Theme.textColor
            font: Fonts.standardFont
            Layout.fillWidth: true
        }
    }

    footerItem: RowLayout {
        spacing: Fonts.size10

        Item {
            Layout.fillWidth: true
        }

        Repeater {
            model: buttons
            delegate: CustomButton {
                id: dynBtn
                readonly property bool isDefault: (defaultButtonText !== "" && text === defaultButtonText) || (defaultButtonText === "" && index === (buttons.length - 1))
                text: modelData
                buttonColor: (text === qsTr("Exit") || text === qsTr("OK") || text === qsTr("Yes")) ? Theme.highlightColor : Theme.buttonColor
                buttonTextColor: (text === qsTr("Exit") || text === qsTr("OK") || text === qsTr("Yes")) ? Theme.highlightedTextColor : Theme.buttonTextColor
                activeFocusOnTab: true
                Component.onCompleted: {
                    if (isDefault) {
                        Qt.callLater(function () {
                            dynBtn.forceActiveFocus()
                        })
                    }
                }
                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        root.resultText = text
                        root.finished(text)
                        root.close()
                        event.accepted = true
                    }
                }
                onClicked: function () {
                    root.resultText = text
                    root.finished(text)
                    root.close()
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }

    function openWithButtons() {
        open()
    }

    // (Keys moved into keyScope Item to avoid attaching to non-Item Popup)

    // Global fallback: Enter / Return to accept when popup is visible
    Shortcut {
        sequences: [Qt.Key_Return, Qt.Key_Enter]
        context: Qt.WindowShortcut
        enabled: root.visible
        onActivated: {
            root.accepted()
            root.close()
        }
    }
}
