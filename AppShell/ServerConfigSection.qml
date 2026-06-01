import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

CustomGroupBox {
    id: root
    property var endpointConfig: null
    property var sectionTitle: "Endpoint Configuration"
    property string defaultHost: "192.168.1.181"
    property string defaultPort: "3333"
    property var useComboBox: false
    property alias expandedByDefault: root.initialExpanded

    title: sectionTitle
    Layout.fillWidth: true

    onEndpointConfigChanged: {
        if (endpointConfig) {
            endpointConfig.endpointConfigChanged.connect(refreshComboBoxDisplay)
        }
    }

    function isValidHost(hostName) {
        if (!hostName || typeof hostName !== 'string')
            return false

        return hostName.trim().length > 0
    }

    function refreshComboBoxDisplay() {
        if (useComboBox && hostComboBoxLoader.item && endpointConfig) {
            let currentEditText = hostComboBoxLoader.item.editText
            let currentHost = endpointConfig.host
            if (currentEditText !== currentHost) {
                hostComboBoxLoader.item.editText = currentHost
            }
        }
    }

    function acceptCurrentHost() {
        if (useComboBox && hostComboBoxLoader.item && endpointConfig) {
            let currentEditText = hostComboBoxLoader.item.editText.trim()
            if (isValidHost(currentEditText)) {
                hostComboBoxLoader.item.appendItem(currentEditText)

                let newIndex = hostComboBoxLoader.item.model.indexOf(currentEditText)
                if (newIndex === -1) {
                    newIndex = 0
                }

                hostComboBoxLoader.item.isProgrammaticUpdate = true
                hostComboBoxLoader.item.currentIndex = newIndex
                hostComboBoxLoader.item.isProgrammaticUpdate = false

                endpointConfig.host = currentEditText
                endpointConfig.addHost(currentEditText)
                return true
            }
        } else if (!useComboBox && hostComboBoxLoader.item && endpointConfig) {
            let currentText = hostComboBoxLoader.item.text.trim()
            if (isValidHost(currentText)) {
                endpointConfig.host = currentText
                endpointConfig.addHost(currentText)
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
                text: qsTr("Host:")
                color: Theme.textColor
                font: Fonts.standardFont
                Layout.preferredWidth: Fonts.size70
            }
            Loader {
                id: hostComboBoxLoader
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size80
                sourceComponent: useComboBox ? hostComboBox : hostField
            }

            Component {
                id: hostComboBox
                CustomComboBox {
                    id: hostComboBox
                    Layout.fillWidth: true
                    Layout.preferredWidth: Fonts.size80
                    model: endpointConfig ? endpointConfig.hostList : []
                    editable: true

                    property bool isProgrammaticUpdate: false
                    property bool isInitialized: false
                    property string lastKnownHost: ""

                    onCurrentIndexChanged: {
                        if (isProgrammaticUpdate || !isInitialized) {
                            return
                        }

                        if (currentIndex >= 0 && endpointConfig) {
                            let value = model[currentIndex]

                            if (value !== lastKnownHost) {
                                lastKnownHost = value
                                endpointConfig.host = value
                            }
                        }
                    }

                    onAccepted: {
                        let inputText = editText.trim()
                        if (isValidHost(inputText)) {
                            appendItem(inputText)

                            let newIndex = model.indexOf(inputText)
                            if (newIndex === -1) {
                                newIndex = 0
                            }

                            isProgrammaticUpdate = true
                            currentIndex = newIndex
                            isProgrammaticUpdate = false

                            lastKnownHost = inputText
                            endpointConfig.host = inputText
                            endpointConfig.addHost(inputText)

                            focus = false
                        } else {
                            editText = endpointConfig.host
                        }
                    }

                    Component.onCompleted: {
                        Qt.callLater(function () {
                            if (endpointConfig && model.length > 0) {
                                let currentHost = endpointConfig.host
                                lastKnownHost = currentHost

                                let index = model.indexOf(currentHost)
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
                id: hostField
                CustomTextField {
                    id: hostTextField
                    text: endpointConfig ? endpointConfig.host : ""
                    Layout.fillWidth: true
                    placeholderText: defaultHost

                    property bool isValidInput: true
                    property string lastValidText: ""

                    onTextChanged: {
                        if (text.trim() === "") {
                            isValidInput = true
                            return
                        }

                        isValidInput = isValidHost(text.trim())

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
                                } else if (endpointConfig && endpointConfig.host) {
                                    text = endpointConfig.host
                                } else {
                                    text = defaultHost
                                }
                                isValidInput = true
                            } else if (isValidHost(trimmedText)) {
                                if (endpointConfig && trimmedText !== endpointConfig.host) {
                                    endpointConfig.host = trimmedText
                                    endpointConfig.addHost(trimmedText)
                                }
                                lastValidText = trimmedText
                                isValidInput = true
                            } else {
                                if (lastValidText !== "") {
                                    text = lastValidText
                                } else if (endpointConfig && endpointConfig.host) {
                                    text = endpointConfig.host
                                } else {
                                    text = defaultHost
                                }
                                isValidInput = true
                            }
                        }
                    }

                    onAccepted: {
                        let trimmedText = text.trim()
                        if (trimmedText === "") {
                            text = defaultHost
                            isValidInput = true
                            focus = false
                        } else if (isValidHost(trimmedText)) {
                            if (endpointConfig && trimmedText !== endpointConfig.host) {
                                endpointConfig.host = trimmedText
                                endpointConfig.addHost(trimmedText)
                            }
                            lastValidText = trimmedText
                            isValidInput = true
                            focus = false
                        } else {
                            if (lastValidText !== "") {
                                text = lastValidText
                            } else if (endpointConfig && endpointConfig.host) {
                                text = endpointConfig.host
                            } else {
                                text = defaultHost
                            }
                            isValidInput = true
                        }
                    }

                    color: isValidInput ? Theme.textColor : "#F44336"

                    Component.onCompleted: {
                        if (endpointConfig && endpointConfig.host) {
                            lastValidText = endpointConfig.host
                        } else {
                            lastValidText = defaultHost
                        }
                    }
                }
            }

            Text {
                Layout.preferredWidth: Fonts.size20
                text: "•"
                color: endpointConfig ? (endpointConfig.hostReachable ? "#4CAF50" : "#F44336") : "#cccccc"
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
                id: portField
                Layout.fillWidth: true
                Layout.preferredWidth: Fonts.size80
                text: endpointConfig ? endpointConfig.port : ""
                placeholderText: defaultPort
                validator: IntValidator {
                    bottom: 1
                }
                onEditingFinished: {
                    if (endpointConfig && text !== endpointConfig.port) {
                        endpointConfig.port = text
                    }
                }
            }

            Text {
                Layout.preferredWidth: Fonts.size20
                text: "•"
                color: endpointConfig ? (endpointConfig.portReachable ? "#4CAF50" : "#F44336") : "#cccccc"
                font: Fonts.makeBoldFont(Fonts.annotationFont)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Fonts.size10

            CustomButton {
                text: endpointConfig && endpointConfig.isTesting ? "Testing..." : "Test Endpoint"
                enabled: !(endpointConfig && endpointConfig.isTesting)
                onClicked: {
                    if (endpointConfig) {
                        acceptCurrentHost()

                        refreshComboBoxDisplay()
                        endpointConfig.testConnection()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (endpointConfig) {
                        if (endpointConfig.isTesting) {
                            return "Testing..."
                        } else {
                            return endpointConfig.isConnected ? "Connected" : "Disconnected"
                        }
                    } else {
                        return "Unknown"
                    }
                }
                color: {
                    if (endpointConfig) {
                        if (endpointConfig.isTesting) {
                            return "#FF9800"
                        } else if (endpointConfig.isConnected) {
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
