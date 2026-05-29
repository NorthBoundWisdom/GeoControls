import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import GeoToy.Controls 1.0

Rectangle {
    id: inputArea
    color: Theme.baseColor
    radius: Fonts.size2
    border.color: Theme.midColor
    border.width: Fonts.size1
    property var fontFamily
    property bool inputMode: false
    property bool submitEnabled: true
    property bool acceptPlainText: false
    property bool requireSlashForCommand: true
    property string commandPrefix: "/"
    property string placeholderText: qsTr("Enter /command...")
    property bool showPromptPrefix: true

    property alias text: commandInput.text
    signal commandSubmitted(string command)
    signal textSubmitted(string text)
    signal plainTextRejected(string text)

    function ensureCompletionSelection() {
        if (!commandInput.completionModel || commandInput.completionModel.length <= 0) {
            completionList.currentIndex = -1
            return
        }
        if (completionList.currentIndex < 0 || completionList.currentIndex >= commandInput.completionModel.length) {
            completionList.currentIndex = 0
        }
        completionList.positionViewAtIndex(completionList.currentIndex, ListView.Contain)
    }

    function moveCompletionSelection(step) {
        if (!completionPopup.visible || !commandInput.completionModel || commandInput.completionModel.length <= 0) {
            return false
        }

        const count = commandInput.completionModel.length
        let next_index = completionList.currentIndex
        if (next_index < 0 || next_index >= count) {
            next_index = 0
        } else {
            next_index = next_index + step
        }

        if (next_index < 0) {
            next_index = count - 1
        } else if (next_index >= count) {
            next_index = 0
        }

        completionList.currentIndex = next_index
        completionList.positionViewAtIndex(next_index, ListView.Contain)
        return true
    }

    function applyCompletionSelection() {
        if (!completionPopup.visible || !commandInput.completionModel || commandInput.completionModel.length <= 0) {
            return false
        }

        let selected_index = completionList.currentIndex
        if (selected_index < 0 || selected_index >= commandInput.completionModel.length) {
            selected_index = 0
        }

        const selected_text = String(commandInput.completionModel[selected_index])
        if (requireSlashForCommand) {
            commandInput.text = commandPrefix + selected_text
        } else {
            commandInput.text = selected_text
        }
        completionPopup.close()
        return true
    }

    function focusAndInsertText(text_to_insert) {
        if (!submitEnabled) {
            return false
        }
        const value = String(text_to_insert)
        if (value.length === 0) {
            inputMode = true
            return true
        }

        const had_focus = commandInput.activeFocus
        inputMode = true
        commandInput.forceActiveFocus()

        var insert_pos = had_focus ? commandInput.cursorPosition : commandInput.text.length
        if (insert_pos < 0 || insert_pos > commandInput.text.length) {
            insert_pos = commandInput.text.length
        }
        commandInput.insert(insert_pos, value)
        commandInput.cursorPosition = insert_pos + value.length
        refreshCompletions()
        return true
    }

    function submitInput() {
        if (!submitEnabled) {
            return false
        }
        const trimmed = commandInput.text.trim()
        if (trimmed === "") {
            return false
        }

        let is_command = true
        let command_text = trimmed
        if (requireSlashForCommand) {
            is_command = trimmed.startsWith(commandPrefix)
            command_text = is_command ? trimmed.substring(commandPrefix.length).trim() : ""
        }

        if (is_command) {
            if (command_text === "") {
                return false
            }
            inputArea.commandSubmitted(command_text)
            commandInput.text = ""
            completionPopup.close()
            return true
        }

        if (acceptPlainText) {
            inputArea.textSubmitted(trimmed)
            commandInput.text = ""
            completionPopup.close()
            return true
        }

        inputArea.plainTextRejected(trimmed)
        return false
    }

    function refreshCompletions() {
        if (!submitEnabled) {
            commandInput.completionModel = []
            completionPopup.close()
            return
        }

        const trimmed = commandInput.text.trim()
        let completion_prefix = trimmed

        if (requireSlashForCommand) {
            if (!trimmed.startsWith(commandPrefix)) {
                commandInput.completionModel = []
                completionPopup.close()
                return
            }
            completion_prefix = trimmed.substring(commandPrefix.length).trim()
        }

        const should_fetch = completion_prefix.length > 0 || requireSlashForCommand
        if (!should_fetch) {
            commandInput.completionModel = []
            completionPopup.close()
            return
        }

        const completions = commandConsole.getCompletions(completion_prefix);
        // Keep completionModel as plain strings. Object model + modelData role mapping
        // can regress into blank popup rows when delegate role injection changes.
        const normalized_completions = []
        for (let i = 0; i < completions.length; ++i) {
            normalized_completions.push(String(completions[i]))
        }
        commandInput.completionModel = normalized_completions

        if (commandInput.completionModel.length > 0) {
            inputArea.ensureCompletionSelection()
            completionPopup.open()
            return
        }
        completionPopup.close()
    }

    onInputModeChanged: {
        if (inputMode) {
            commandInput.forceActiveFocus()
        } else {
            commandInput.focus = false
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: inputArea.submitEnabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.IBeamCursor

        onClicked: {
            inputArea.inputMode = true
            commandInput.cursorPosition = commandInput.text.length
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size2
        spacing: Fonts.size5

        Text {
            visible: showPromptPrefix
            text: " >"
            color: Theme.textColor
            Layout.alignment: Qt.AlignVCenter
        }

        CustomTextField {
            id: commandInput

            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: submitEnabled
            placeholderText: inputArea.placeholderText
            color: Theme.textColor
            placeholderTextColor: Theme.placeholderTextColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: TextInput.AlignLeft
            background: null
            autoAcceptOnMouseExit: false

            property var completionModel: []

            onTextChanged: {
                inputArea.refreshCompletions()
            }

            onAccepted: {
                const trimmed = commandInput.text.trim()
                if (inputArea.requireSlashForCommand && trimmed === inputArea.commandPrefix && completionPopup.visible && commandInput.completionModel && commandInput.completionModel.length > 0) {
                    inputArea.ensureCompletionSelection()
                    inputArea.applyCompletionSelection();
                    // CustomTextField handles Enter by dropping focus after accepted.
                    // Re-focus on next tick so Enter behaves like Tab for "/".
                    Qt.callLater(function () {
                        if (!inputArea.submitEnabled) {
                            return
                        }
                        inputArea.inputMode = true
                        commandInput.forceActiveFocus()
                        commandInput.cursorPosition = commandInput.text.length
                    })
                    return
                }
                inputArea.submitInput()
            }

            Keys.onTabPressed: function (event) {
                if (inputArea.applyCompletionSelection()) {
                    event.accepted = true
                    return
                }
                event.accepted = true
            }

            Keys.onUpPressed: function (event) {
                if (inputArea.moveCompletionSelection(-1)) {
                    event.accepted = true
                }
            }

            Keys.onDownPressed: function (event) {
                if (inputArea.moveCompletionSelection(1)) {
                    event.accepted = true
                }
            }

            Keys.onEscapePressed: function (event) {
                inputArea.inputMode = false
                completionPopup.close()
                event.accepted = true
            }

            onActiveFocusChanged: {
                inputArea.inputMode = activeFocus
            }

            Popup {
                id: completionPopup
                readonly property int completionWidthChars: 200
                readonly property real contextMenuWidth: Fonts.size180
                readonly property real desiredPopupWidth: Math.max(contextMenuWidth, completionWidthChars * completionFontMetrics.averageCharacterWidth + Fonts.size20)
                readonly property real maxPopupWidth: {
                    if (inputArea.Window && inputArea.Window.width > 0) {
                        return Math.max(0, inputArea.Window.width - Fonts.size20)
                    }
                    return desiredPopupWidth
                }
                width: Math.min(desiredPopupWidth, maxPopupWidth)
                padding: Fonts.size1

                function updatePosition() {
                    y = -completionList.implicitHeight - commandInput.height * 0.1
                }

                Connections {
                    target: completionList
                    function onImplicitHeightChanged() {
                        completionPopup.updatePosition()
                    }
                }

                onOpened: updatePosition()

                enter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "y"
                        from: -completionList.implicitHeight + 10
                        to: -completionList.implicitHeight - commandInput.height * 0.1
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }

                exit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 80
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "y"
                        from: -completionList.implicitHeight - commandInput.height * 0.1
                        to: -completionList.implicitHeight + 10
                        duration: 80
                        easing.type: Easing.InCubic
                    }
                }

                contentItem: ListView {
                    id: completionList
                    clip: true
                    width: completionPopup.availableWidth
                    implicitHeight: Math.min(contentHeight, Fonts.size200)
                    model: commandInput.completionModel
                    spacing: Fonts.size1

                    signal itemSelected(string text)

                    onItemSelected: function (text) {
                        if (inputArea.requireSlashForCommand) {
                            commandInput.text = inputArea.commandPrefix + text
                        } else {
                            commandInput.text = text
                        }
                        completionPopup.close()
                    }

                    delegate: ItemDelegate {
                        id: completionDelegate
                        width: completionList.width
                        height: Fonts.size25
                        hoverEnabled: true
                        highlighted: ListView.isCurrentItem

                        // Read by index from completionModel instead of modelData to avoid
                        // delegate role ambiguity causing empty visible text.
                        readonly property string completionText: (index >= 0 && commandInput.completionModel && index < commandInput.completionModel.length) ? String(commandInput.completionModel[index]) : ""

                        contentItem: Text {
                            anchors.fill: parent
                            text: completionDelegate.completionText
                            color: {
                                if (completionDelegate.highlighted)
                                    return Theme.highlightedTextColor
                                if (completionDelegate.hovered)
                                    return Theme.highlightedTextColor
                                return Theme.textColor
                            }
                            font: commandInput.font
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Fonts.size6
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            color: {
                                if (completionDelegate.highlighted)
                                    return Theme.highlightColor
                                if (completionDelegate.hovered)
                                    return Theme.highlightColor
                                return Theme.alternateBaseColor
                            }
                            opacity: completionDelegate.hovered ? 0.2 : 1.0
                            Behavior on color {
                                ColorAnimation {
                                    duration: 50
                                }
                            }
                        }

                        onClicked: {
                            completionList.itemSelected(completionText)
                        }
                    }

                    ScrollIndicator.vertical: ScrollIndicator {
                        active: true
                        background: Rectangle {
                            color: "transparent"
                            width: Fonts.size8
                        }
                    }
                }

                background: Rectangle {
                    color: Theme.baseColor
                    border.color: Theme.midColor
                    border.width: Fonts.size1
                    radius: Fonts.size3
                }
            }

            FontMetrics {
                id: completionFontMetrics
                font: commandInput.font
            }
        }
    }
}
