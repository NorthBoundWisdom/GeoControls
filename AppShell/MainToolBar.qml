import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import GeoToy.Controls 1.0

ToolBar {
    id: toolBar
    property bool inCmd: false
    property var currentCmdToolBarItem: null
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
            text: docManager.curDocName
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
                    source: "qrc:/icons/Done.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: cmdPageItem.qmlDoneCmd()
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
                    source: "qrc:/icons/Cancel.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: cmdPageItem.qmlCancelCmd()
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

            Connections {
                target: cmdPageItem

                function onActivateCmdToolBarSig(toolBarItem) {
                    // Replace semantics: only keep current cmd toolbar item attached.
                    // Supports nested commands by detaching previous toolbar and reattaching on restore.
                    if (currentCmdToolBarItem && currentCmdToolBarItem !== toolBarItem) {
                        currentCmdToolBarItem.visible = false
                        currentCmdToolBarItem.parent = null
                    }
                    currentCmdToolBarItem = toolBarItem
                    if (toolBarItem) {
                        toolBarItem.parent = commandToolBarHost
                        toolBarItem.anchors.fill = commandToolBarHost
                        toolBarItem.visible = true
                    } else {
                        // New command has no toolbar: clear host to avoid showing previous toolbar.
                    }
                }

                function onCmdNameChangedSig(cmd_name) {
                    commandNameLabel.text = qsTr(cmd_name)
                }

                function onInCmdStatusChangedSig(in_cmd) {
                    toolBar.inCmd = in_cmd
                    if (!in_cmd) {
                        commandNameLabel.text = ""
                    }
                }
            }
        }

        Repeater {
            model: actionManager.topBarRightActions

            CustomToolButton {
                actionName: modelData.actionName
                iconSource: modelData.iconPath
                parameter: modelData.parameter
                display: AbstractButton.IconOnly
                shortcutSequence: modelData.shortcut
                displayName: modelData.displayName
                tooltip: modelData.tooltip
                onActionRequested: function (requestedParameter) {
                    actionManager.executeCommandFromQml(requestedParameter)
                }

                Layout.rightMargin: index === (actionManager.topBarRightActions.length - Fonts.size1) ? Fonts.standardMargin : 0
            }
        }

        CustomToolButton {
            actionName: "Shortcuts"
            iconSource: "qrc:/icons/Keyboard.svg"
            parameter: ""
            shortcutSequence: ""
            displayName: qsTr("Shortcuts")
            tooltip: qsTr("Show keyboard shortcuts")
            handleInCpp: false
            display: AbstractButton.IconOnly
            onClicked: shortcutsDialog.open()
            Layout.rightMargin: Fonts.standardMargin
        }
    }
}
