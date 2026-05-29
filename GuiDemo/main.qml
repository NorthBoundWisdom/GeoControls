import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0
import GeoToy.AppShell 1.0

ApplicationWindow {
    id: window

    width: 1180
    height: 780
    minimumWidth: 860
    minimumHeight: 620
    visible: true
    title: "GeoControls GuiDemo"

    property int currentPage: 0
    property color selectedColor: "#2f80ed"

    Component.onCompleted: {
        raise()
        requestActivate()
    }

    background: Rectangle {
        color: Theme.windowColor
    }

    header: ToolBar {
        id: topBar
        height: 52

        background: Rectangle {
            color: Theme.baseColor
            border.color: Theme.chromeDividerColor
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            CustomLabel {
                text: "GeoControls"
                font.pixelSize: 20
                font.bold: true
            }

            CustomLabel {
                text: "Controls, AppShell, icons"
                color: Theme.placeholderTextColor
            }

            Item {
                Layout.fillWidth: true
            }

            CustomButton {
                text: "Message"
                onClicked: showMessage("GeoControls", "MessageDialog is loaded from GeoToy.Controls.")
            }
        }
    }

    footer: Rectangle {
        height: 30
        color: Theme.baseColor
        border.color: Theme.chromeDividerColor
        border.width: 1

        CustomLabel {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: "URI: GeoToy.Controls 1.0 / GeoToy.AppShell 1.0"
            color: Theme.placeholderTextColor
        }
    }

    Rectangle {
        id: contentRoot
        anchors.fill: parent
        color: Theme.windowColor

        MessageDialog {
            id: messageDialog
            objectName: "messageDialog"
            parentItem: contentRoot
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            TabBar {
                id: navigation
                Layout.fillWidth: true
                currentIndex: window.currentPage
                onCurrentIndexChanged: window.currentPage = currentIndex

                TabButton {
                    text: "Controls"
                }

                TabButton {
                    text: "Inputs"
                }

                TabButton {
                    text: "Charts & Dialogs"
                }

                TabButton {
                    text: "AppShell"
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: window.currentPage

                Page {
                    background: Rectangle {
                        color: "transparent"
                    }

                    ScrollView {
                        id: controlsScroll
                        anchors.fill: parent
                        contentWidth: availableWidth
                        clip: true

                        ColumnLayout {
                            width: controlsScroll.availableWidth
                            spacing: 14

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Buttons"
                                collapsible: false

                                GridLayout {
                                    columns: 4
                                    rowSpacing: 12
                                    columnSpacing: 12

                                    CustomButton {
                                        Layout.fillWidth: true
                                        text: "Primary"
                                        onClicked: showMessage("Button", "CustomButton clicked.")
                                    }

                                    CustomToolButton {
                                        display: AbstractButton.TextOnly
                                        displayName: "Tool"
                                        tooltip: "CustomToolButton with GeoControls tooltip"
                                    }

                                    EqualActionButtonRow {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 2
                                        equalPreferredWidth: 90

                                        CustomButton {
                                            text: "Apply"
                                            onClicked: showMessage("Action", "Apply clicked.")
                                        }

                                        CustomButton {
                                            text: "Reset"
                                            onClicked: showMessage("Action", "Reset clicked.")
                                        }
                                    }

                                    CustomLabel {
                                        text: "Choice"
                                        font.bold: true
                                    }

                                    CustomCheckBox {
                                        text: "Check"
                                        checked: true
                                    }

                                    CustomRadioButton {
                                        text: "Radio"
                                        checked: true
                                    }

                                    CustomBinarySwitch {
                                        leftText: "On"
                                        rightText: "Off"
                                        leftActive: true
                                        onLeftClicked: {
                                            leftActive = true
                                            rightActive = false
                                        }
                                        onRightClicked: {
                                            leftActive = false
                                            rightActive = true
                                        }
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Custom tabs"
                                collapsible: false

                                ColumnLayout {
                                    spacing: 12

                                    CustomTabBar {
                                        id: demoTabs
                                        Layout.fillWidth: true
                                        targetIndex: demoTabStack.currentIndex

                                        CustomTabButton {
                                            text: "General"
                                            targetIndex: 0
                                            tabBar: demoTabs
                                            onClicked: demoTabStack.currentIndex = 0
                                        }

                                        CustomTabButton {
                                            text: "Advanced"
                                            targetIndex: 1
                                            tabBar: demoTabs
                                            onClicked: demoTabStack.currentIndex = 1
                                        }

                                        CustomTabButton {
                                            text: "Preview"
                                            targetIndex: 2
                                            tabBar: demoTabs
                                            onClicked: demoTabStack.currentIndex = 2
                                        }
                                    }

                                    StackLayout {
                                        id: demoTabStack
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        CustomLabel {
                                            text: "General controls share Theme and Fonts singletons."
                                        }

                                        CustomLabel {
                                            text: "Advanced panel content can use the same tab primitives."
                                        }

                                        CustomLabel {
                                            text: "Preview pages stay inside ordinary Qt Quick layouts."
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Page {
                    background: Rectangle {
                        color: "transparent"
                    }

                    ScrollView {
                        id: inputsScroll
                        anchors.fill: parent
                        contentWidth: availableWidth
                        clip: true

                        ColumnLayout {
                            width: inputsScroll.availableWidth
                            spacing: 14

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Form controls"
                                collapsible: false

                                GridLayout {
                                    columns: 2
                                    rowSpacing: 12
                                    columnSpacing: 16

                                    CustomLabel {
                                        text: "Text"
                                        font.bold: true
                                    }

                                    CustomTextField {
                                        Layout.fillWidth: true
                                        text: "Editable value"
                                    }

                                    CustomLabel {
                                        text: "Combo"
                                        font.bold: true
                                    }

                                    CustomComboBox {
                                        Layout.fillWidth: true
                                        model: ["Alpha", "Beta", "Gamma"]
                                        currentIndex: 1
                                    }

                                    CustomLabel {
                                        text: "Switch"
                                        font.bold: true
                                    }

                                    CustomSwitch {
                                        model: ["Design", "Inspect", "Ship"]
                                        currentIndex: 0
                                    }

                                    CustomLabel {
                                        text: "Spin"
                                        font.bold: true
                                    }

                                    CustomSpinBox {
                                        id: spin
                                        Layout.fillWidth: true
                                        decimals: 1
                                        realFrom: -100
                                        realTo: 100
                                        realValue: 12.5
                                        realStepSize: 0.5
                                        editable: true
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Numeric ranges"
                                collapsible: false

                                ColumnLayout {
                                    spacing: 12

                                    CustomSlider {
                                        Layout.fillWidth: true
                                        title: "Slider"
                                        from: -100
                                        to: 100
                                        value: spin.realValue
                                        delayedCommit: true
                                    }

                                    CustomRangeSlider {
                                        Layout.fillWidth: true
                                        title: "Accepted range"
                                        from: -50
                                        to: 50
                                        fromValue: -12
                                        toValue: 28
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Vector3SpinBox"
                                collapsible: false

                                ColumnLayout {
                                    spacing: 12

                                    CustomVector3SpinBox {
                                        id: positionVector
                                        objectName: "positionVector"
                                        Layout.fillWidth: true
                                        vector: [10.5, 20.3, 30.7]
                                        decimals: 2
                                        stepSize: 0.5
                                    }
                                }
                            }
                        }
                    }
                }

                Page {
                    background: Rectangle {
                        color: "transparent"
                    }

                    ScrollView {
                        id: chartScroll
                        anchors.fill: parent
                        contentWidth: availableWidth
                        clip: true

                        ColumnLayout {
                            width: chartScroll.availableWidth
                            spacing: 14

                            CustomRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 360
                                title: "CustomChart"
                                collapsible: false

                                ColumnLayout {
                                    id: chartSection
                                    spacing: 12

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        CustomCheckBox {
                                            id: realtimeToggle
                                            text: "Realtime"
                                            onCheckedChanged: checked ? chartTimer.start() : chartTimer.stop()
                                        }
                                    }

                                    CustomChart {
                                        id: demoChart
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        property var chartData: ({
                                                labels: [],
                                                datasets: [
                                                    {
                                                        strokeColor: "#2f80ed",
                                                        fillColor: "rgba(47,128,237,0.12)",
                                                        pointColor: "#2f80ed",
                                                        pointStrokeColor: "#ffffff",
                                                        data: []
                                                    }
                                                ]
                                            })

                                        function render() {
                                            line(chartData, {
                                                animation: false,
                                                bezierCurve: false,
                                                scaleShowLabels: true,
                                                datasetFill: false,
                                                pointDot: false
                                            })
                                        }

                                        onPaint: render()
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                    }

                                    Timer {
                                        id: chartTimer
                                        interval: 90
                                        repeat: true
                                        onTriggered: chartSection.tick()
                                    }

                                    function resetData() {
                                        const data = []
                                        const labels = []
                                        for (let i = 0; i < 100; ++i) {
                                            const x = i / 10
                                            data.push(Math.sin(x) * 35 + Math.cos(x * 0.45) * 18)
                                            labels.push(i % 20 === 0 ? String(i) : "")
                                        }
                                        demoChart.chartData.labels = labels
                                        demoChart.chartData.datasets[0].data = data
                                        demoChart.requestPaint()
                                    }

                                    function tick() {
                                        const data = demoChart.chartData.datasets[0].data
                                        const labels = demoChart.chartData.labels
                                        const t = Date.now() * 0.001
                                        data.push(Math.sin(t * 2.2) * 34 + Math.cos(t * 0.8) * 16)
                                        labels.push(labels.length % 20 === 0 ? String(labels.length) : "")
                                        while (data.length > 100)
                                            data.shift()
                                        while (labels.length > 100)
                                            labels.shift()
                                        demoChart.requestPaint()
                                    }

                                    Component.onCompleted: resetData()
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Dialogs and tooltips"
                                collapsible: false

                                RowLayout {
                                    spacing: 12

                                    CustomButton {
                                        text: "Open Message"
                                        onClicked: showMessage("Dialog", "This message uses MessageDialog from GeoToy.Controls.")
                                    }

                                    CustomButton {
                                        text: "Pick Color"
                                        onClicked: colorPicker.open()
                                    }

                                    CustomToolButton {
                                        display: AbstractButton.TextOnly
                                        displayName: "Hover"
                                        tooltip: "Tooltip delay comes from ToolTipConfig."
                                    }

                                    Rectangle {
                                        width: 42
                                        height: 30
                                        radius: 4
                                        color: window.selectedColor
                                        border.color: Theme.midColor
                                        border.width: 1
                                    }
                                }
                            }
                        }
                    }
                }

                Page {
                    background: Rectangle {
                        color: "transparent"
                    }

                    ScrollView {
                        id: appShellScroll
                        anchors.fill: parent
                        contentWidth: availableWidth
                        clip: true

                        ColumnLayout {
                            width: appShellScroll.availableWidth
                            spacing: 14

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Window caption buttons"
                                collapsible: false

                                RowLayout {
                                    spacing: 12

                                    WindowCaptionButtons {
                                        windowHandle: window
                                        showClose: false
                                        chromeHeightOverride: 32
                                    }

                                    CustomLabel {
                                        Layout.fillWidth: true
                                        text: "Caption controls use GeoControls icons and Theme."
                                        color: Theme.placeholderTextColor
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Command input"
                                collapsible: false

                                ColumnLayout {
                                    spacing: 10

                                    CmdInputArea {
                                        id: demoCommandInput
                                        Layout.fillWidth: true
                                        requireSlashForCommand: true
                                        placeholderText: qsTr("Enter /help, /box, /measure...")
                                        onCommandSubmitted: function (command) {
                                            appShellLog.text = "Command submitted: " + command
                                        }
                                        onPlainTextRejected: function (text) {
                                            appShellLog.text = "Plain text rejected: " + text
                                        }
                                    }

                                    CustomLabel {
                                        id: appShellLog
                                        text: "Try command completion with /"
                                        color: Theme.placeholderTextColor
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Server config"
                                collapsible: false

                                ServerConfigSection {
                                    Layout.fillWidth: true
                                    serverConfiger: demoServerConfiger
                                    useComboBox: true
                                }
                            }
                        }
                    }
                }
            }
        }

        CustomColorPicker {
            id: colorPicker
            parent: contentRoot
            selectedColor: window.selectedColor
            onAccepted: window.selectedColor = selectedColor
        }
    }

    function showMessage(title, body) {
        messageDialog.titleText = title
        messageDialog.messageText = body
        messageDialog.buttons = ["OK"]
        messageDialog.defaultButtonText = "OK"
        messageDialog.openWithButtons()
    }
}
