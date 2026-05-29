import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

CustomGroupBox {
    id: root
    property var serverConfiger: null
    property var serverName: "Server Configuration"
    property string defaultServerIP: "192.168.1.181"
    property string defaultServerPort: "3333"
    property var useComboBox: false
    property alias expandedByDefault: root.initialExpanded

    title: serverName
    Layout.fillWidth: true

    onServerConfigerChanged: {
        if (serverConfiger) {
            serverConfiger.serverConfigChangedSig.connect(refreshComboBoxDisplay)
        }
    }

    function isValidIP(ip) {
        if (!ip || typeof ip !== 'string')
            return false

        let parts = ip.split('.')
        if (parts.length !== 4)
            return false

        for (let i = 0; i < 4; i++) {
            let part = parts[i]
            if (!part || part.length === 0)
                return false

            let num = parseInt(part, 10)
            if (isNaN(num))
                return false

            if (num < 0 || num > 255)
                return false

            if (part.length > 1 && part[0] === '0')
                return false
        }

        return true
    }

    function refreshComboBoxDisplay() {
        if (useComboBox && serverIPComboBoxLoader.item && serverConfiger) {
            let currentEditText = serverIPComboBoxLoader.item.editText
            let currentServerIP = serverConfiger.serverIP
            if (currentEditText !== currentServerIP) {
                serverIPComboBoxLoader.item.editText = currentServerIP
            }
        }
    }

    function acceptCurrentIP() {
        if (useComboBox && serverIPComboBoxLoader.item && serverConfiger) {
            let currentEditText = serverIPComboBoxLoader.item.editText.trim()
            if (isValidIP(currentEditText)) {
                serverIPComboBoxLoader.item.appendItem(currentEditText)

                let newIndex = serverIPComboBoxLoader.item.model.indexOf(currentEditText)
                if (newIndex === -1) {
                    newIndex = 0
                }

                serverIPComboBoxLoader.item.isProgrammaticUpdate = true
                serverIPComboBoxLoader.item.currentIndex = newIndex
                serverIPComboBoxLoader.item.isProgrammaticUpdate = false

                serverConfiger.serverIP = currentEditText
                serverConfiger.addServerIP(currentEditText)
                return true
            }
        } else if (!useComboBox && serverIPComboBoxLoader.item && serverConfiger) {
            let currentText = serverIPComboBoxLoader.item.text.trim()
            if (isValidIP(currentText)) {
                serverConfiger.serverIP = currentText
                serverConfiger.addServerIP(currentText)
                return true
            }
        }
        return false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Fonts.size10

        RowLayout {
            Layout.fillWidth: true
            spacing: Fonts.size10

            Text {
                text: qsTr("Server IP:")
                color: Theme.textColor
                font: Fonts.standardFont
                Layout.preferredWidth: Fonts.size70
            }
            Loader {
                id: serverIPComboBoxLoader
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size80
                sourceComponent: useComboBox ? serverIPComboBox : serverIPField
            }

            Component {
                id: serverIPComboBox
                CustomComboBox {
                    id: serverIPComboBox
                    Layout.fillWidth: true
                    Layout.preferredWidth: Fonts.size80
                    model: serverConfiger ? serverConfiger.serverIPList : []
                    editable: true

                    property bool isProgrammaticUpdate: false
                    property bool isInitialized: false
                    property string lastKnownIP: ""

                    onCurrentIndexChanged: {
                        if (isProgrammaticUpdate || !isInitialized) {
                            return
                        }

                        if (currentIndex >= 0 && serverConfiger) {
                            let value = model[currentIndex]

                            if (value !== lastKnownIP) {
                                lastKnownIP = value
                                serverConfiger.serverIP = value
                            }
                        }
                    }

                    onAccepted: {
                        let inputText = editText.trim()
                        if (isValidIP(inputText)) {
                            appendItem(inputText)

                            let newIndex = model.indexOf(inputText)
                            if (newIndex === -1) {
                                newIndex = 0
                            }

                            isProgrammaticUpdate = true
                            currentIndex = newIndex
                            isProgrammaticUpdate = false

                            lastKnownIP = inputText
                            serverConfiger.serverIP = inputText
                            serverConfiger.addServerIP(inputText)

                            focus = false
                        } else {
                            editText = serverConfiger.serverIP
                        }
                    }

                    Component.onCompleted: {
                        Qt.callLater(function () {
                            if (serverConfiger && model.length > 0) {
                                let currentIP = serverConfiger.serverIP
                                lastKnownIP = currentIP

                                let index = model.indexOf(currentIP)
                                if (index >= 0) {
                                    isProgrammaticUpdate = true
                                    currentIndex = index
                                    isProgrammaticUpdate = false
                                }

                                isInitialized = true
                            }
                        })
                    }
                }
            }

            Component {
                id: serverIPField
                CustomTextField {
                    id: serverIPTextField
                    text: serverConfiger ? serverConfiger.serverIP : ""
                    Layout.fillWidth: true
                    placeholderText: defaultServerIP

                    property bool isValidInput: true
                    property string lastValidText: ""

                    onTextChanged: {
                        if (text.trim() === "") {
                            isValidInput = true
                            return
                        }

                        isValidInput = isValidIP(text.trim())

                        if (isValidInput) {
                            lastValidText = text.trim()
                        }
                    }

                    onFocusChanged: {
                        if (!focus) {
                            let trimmedText = text.trim()
                            if (trimmedText === "") {
                                if (lastValidText !== "") {
                                    text = lastValidText
                                } else if (serverConfiger && serverConfiger.serverIP) {
                                    text = serverConfiger.serverIP
                                } else {
                                    text = defaultServerIP
                                }
                                isValidInput = true
                            } else if (isValidIP(trimmedText)) {
                                if (serverConfiger && trimmedText !== serverConfiger.serverIP) {
                                    serverConfiger.serverIP = trimmedText
                                    serverConfiger.addServerIP(trimmedText)
                                }
                                lastValidText = trimmedText
                                isValidInput = true
                            } else {
                                if (lastValidText !== "") {
                                    text = lastValidText
                                } else if (serverConfiger && serverConfiger.serverIP) {
                                    text = serverConfiger.serverIP
                                } else {
                                    text = defaultServerIP
                                }
                                isValidInput = true
                            }
                        }
                    }

                    onAccepted: {
                        let trimmedText = text.trim()
                        if (trimmedText === "") {
                            text = defaultServerIP
                            isValidInput = true
                            focus = false
                        } else if (isValidIP(trimmedText)) {
                            if (serverConfiger && trimmedText !== serverConfiger.serverIP) {
                                serverConfiger.serverIP = trimmedText
                                serverConfiger.addServerIP(trimmedText)
                            }
                            lastValidText = trimmedText
                            isValidInput = true
                            focus = false
                        } else {
                            if (lastValidText !== "") {
                                text = lastValidText
                            } else if (serverConfiger && serverConfiger.serverIP) {
                                text = serverConfiger.serverIP
                            } else {
                                text = defaultServerIP
                            }
                            isValidInput = true
                        }
                    }

                    color: isValidInput ? Theme.textColor : "#F44336"

                    Component.onCompleted: {
                        if (serverConfiger && serverConfiger.serverIP) {
                            lastValidText = serverConfiger.serverIP
                        } else {
                            lastValidText = defaultServerIP
                        }
                    }
                }
            }

            Text {
                Layout.preferredWidth: Fonts.size20
                text: "•"
                color: serverConfiger ? (serverConfiger.serverReachable ? "#4CAF50" : "#F44336") : "#cccccc"
                font: Fonts.makeBoldFont(Fonts.annotationFont)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Fonts.size10

            Text {
                text: qsTr("Port:")
                color: Theme.textColor
                font: Fonts.standardFont
                Layout.preferredWidth: Fonts.size70
            }

            CustomTextField {
                id: serverPortField
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size80
                text: serverConfiger ? serverConfiger.serverPort : ""
                placeholderText: defaultServerPort
                validator: IntValidator {
                    bottom: 1
                }
                onEditingFinished: {
                    if (serverConfiger && text !== serverConfiger.serverPort) {
                        serverConfiger.serverPort = text
                    }
                }
            }

            Text {
                Layout.preferredWidth: Fonts.size20
                text: "•"
                color: serverConfiger ? (serverConfiger.portReachable ? "#4CAF50" : "#F44336") : "#cccccc"
                font: Fonts.makeBoldFont(Fonts.annotationFont)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Fonts.size10

            CustomButton {
                text: serverConfiger && serverConfiger.isTesting ? "Testing..." : "Test Connection"
                enabled: !(serverConfiger && serverConfiger.isTesting)
                onClicked: {
                    if (serverConfiger) {
                        acceptCurrentIP()

                        refreshComboBoxDisplay()
                        serverConfiger.testConnection()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (serverConfiger) {
                        if (serverConfiger.isTesting) {
                            return "Testing..."
                        } else {
                            return serverConfiger.isConnected ? "Connected" : "Disconnected"
                        }
                    } else {
                        return "Unknown"
                    }
                }
                color: {
                    if (serverConfiger) {
                        if (serverConfiger.isTesting) {
                            return "#FF9800"
                        } else if (serverConfiger.isConnected) {
                            return "#4CAF50"
                        } else {
                            return "#F44336"
                        }
                    } else {
                        return "#cccccc"
                    }
                }
                font: Fonts.makeBoldFont(Fonts.annotationFont)
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
