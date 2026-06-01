import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import GeoControls 1.0

ToolBar {
    id: toolBar
    property bool inCmd: false
    property var currentCmdToolBarItem: null
    property string documentTitle: ""
    property var commandController: null
    property var actionModel: []
    property bool showShortcutsButton: false

    signal actionRequested(var actionData, var parameter)
    signal shortcutsRequested

    onCommandControllerChanged: {
        if (!commandController) {
            inCmd = false
            currentCmdToolBarItem = null
            commandNameLabel.text = ""
            return
        }
        if (commandController.commandActive !== undefined) {
            inCmd = commandController.commandActive
        }
        if (commandController.commandName !== undefined) {
            commandNameLabel.text = commandController.commandName
        }
        if (commandController.commandToolBarItem !== undefined) {
            commandToolBarHost.attachToolBarItem(commandController.commandToolBarItem)
        }
    }
    implicitHeight: {
        if (!toolBar.inCmd || !currentCmdToolBarItem) {
            return Fonts.toolbarHeight
        }
        const cmdHeight = currentCmdToolBarItem.implicitHeight > 0 ? currentCmdToolBarItem.implicitHeight : Math.round(Fonts.toolbarHeight * 1.8)
        return Math.max(Fonts.toolbarHeight, cmdHeight + Fonts.size6)
    }
    padding: 0
    z: 99

    background: Rectangle {
        color: Qt.lighter(Theme.windowColor, 1.1)
    }

    RowLayout {
        id: toolButtonRow
        anchors.fill: parent
        spacing: Fonts.smallSpacing
        height: parent.height

        CustomLabel {
            width: Fonts.standardMargin
        }

        CustomLabel {
            text: toolBar.documentTitle
            visible: text.length > 0
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            background: Rectangle {
                color: Theme.midColor
                border.color: Theme.midColor
                border.width: Fonts.size1
                radius: Fonts.panelBorderRadius
            }

            padding: Fonts.smallMargin
        }

        RowLayout {
            id: commandDisplayArea
            spacing: Fonts.smallSpacing
            visible: toolBar.inCmd

            CustomLabel {
                id: commandNameLabel
                text: ""
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Control {
                id: okButton

                width: Fonts.iconSize
                height: Fonts.iconSize
                visible: toolBar.inCmd

                background: Rectangle {
                    color: okButton.down ? Qt.darker(Theme.buttonColor, 1.1) : Theme.buttonColor
                    border.color: okButton.activeFocus ? Theme.highlightColor : Theme.midColor
                    border.width: okButton.activeFocus ? Fonts.size2 : Fonts.size1
                    radius: Fonts.buttonBorderRadius
                }

                contentItem: Image {
                    source: "qrc:/GeoControls/icons/Done.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!toolBar.commandController || typeof toolBar.commandController.acceptCommand !== "function") {
                            throw new Error("MainToolBar requires commandController.acceptCommand()")
                        }
                        toolBar.commandController.acceptCommand()
                    }
                }
            }

            Control {
                id: cancelButton
                width: Fonts.iconSize
                height: Fonts.iconSize
                visible: toolBar.inCmd

                background: Rectangle {
                    color: cancelButton.down ? Qt.darker(Theme.buttonColor, 1.1) : Theme.buttonColor
                    border.color: cancelButton.activeFocus ? Theme.highlightColor : Theme.midColor
                    border.width: cancelButton.activeFocus ? Fonts.size2 : Fonts.size1
                    radius: Fonts.buttonBorderRadius
                }

                contentItem: Image {
                    source: "qrc:/GeoControls/icons/Cancel.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!toolBar.commandController || typeof toolBar.commandController.cancelCommand !== "function") {
                            throw new Error("MainToolBar requires commandController.cancelCommand()")
                        }
                        toolBar.commandController.cancelCommand()
                    }
                }
            }

            Item {
                width: Fonts.size6
                height: 1
                visible: toolBar.inCmd
            }
        }

        Item {
            id: commandToolBarHost
            Layout.fillWidth: true
            Layout.fillHeight: true

            function attachToolBarItem(toolBarItem) {
                if (currentCmdToolBarItem && currentCmdToolBarItem !== toolBarItem) {
                    currentCmdToolBarItem.visible = false
                    currentCmdToolBarItem.parent = null
                }
                currentCmdToolBarItem = toolBarItem
                if (toolBarItem) {
                    toolBarItem.parent = commandToolBarHost
                    toolBarItem.anchors.fill = commandToolBarHost
                    toolBarItem.visible = true
                }
            }

            Connections {
                target: toolBar.commandController

                function onCommandToolBarChanged(toolBarItem) {
                    commandToolBarHost.attachToolBarItem(toolBarItem)
                }

                function onCommandNameChanged(commandName) {
                    commandNameLabel.text = qsTr(commandName)
                }

                function onCommandActiveChanged(commandActive) {
                    toolBar.inCmd = commandActive
                    if (!commandActive) {
                        commandNameLabel.text = ""
                    }
                }
            }
        }

        Repeater {
            model: toolBar.actionModel

            CustomToolButton {
                actionName: modelData.actionName
                iconSource: modelData.iconPath
                parameter: modelData.parameter
                display: AbstractButton.IconOnly
                shortcutSequence: modelData.shortcut
                displayName: modelData.displayName
                tooltip: modelData.tooltip
                onActionRequested: function (requestedParameter) {
                    toolBar.actionRequested(modelData, requestedParameter)
                }

                Layout.rightMargin: index === (toolBar.actionModel.length - Fonts.size1) ? Fonts.standardMargin : 0
            }
        }

        CustomToolButton {
            actionName: "Shortcuts"
            iconSource: "qrc:/GeoControls/icons/Keyboard.svg"
            parameter: ""
            shortcutSequence: ""
            displayName: qsTr("Shortcuts")
            tooltip: qsTr("Show keyboard shortcuts")
            handleInCpp: false
            display: AbstractButton.IconOnly
            visible: toolBar.showShortcutsButton
            onClicked: toolBar.shortcutsRequested()
            Layout.rightMargin: Fonts.standardMargin
        }
    }
}
