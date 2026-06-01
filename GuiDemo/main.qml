import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0
import GeoControls.AppShell 1.0

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
    property string selectedDateText: ""
    property string selectedTimeText: "09:00"

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
            border.color: Theme.dividerColor
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
                onClicked: showMessage("GeoControls", "MessageDialog is loaded from GeoControls.")
            }
        }
    }

    footer: Rectangle {
        height: 30
        color: Theme.baseColor
        border.color: Theme.dividerColor
        border.width: 1

        CustomLabel {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: "URI: GeoControls 1.0 / GeoControls.AppShell 1.0"
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

                                    CustomButton {
                                        Layout.fillWidth: true
                                        text: "Disabled"
                                        enabled: false
                                    }

                                    CustomButton {
                                        Layout.fillWidth: true
                                        Layout.maximumWidth: 112
                                        text: "Long button label for elide"
                                        tooltipText: text
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

                                    CustomCheckBox {
                                        text: "Disabled check"
                                        checked: true
                                        enabled: false
                                    }

                                    CustomRadioButton {
                                        text: "Radio"
                                        checked: true
                                    }

                                    CustomRadioButton {
                                        text: "Disabled radio"
                                        checked: true
                                        enabled: false
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

                                    CustomSwitch {
                                        Layout.columnSpan: 2
                                        model: ["Short", "Much longer option", "Third"]
                                        currentIndex: 1
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

                            CustomRectangle {
                                Layout.fillWidth: true
                                title: "Fluent-inspired light controls"
                                collapsible: false

                                ColumnLayout {
                                    spacing: 12

                                    InfoBar {
                                        Layout.fillWidth: true
                                        severity: "success"
                                        title: "Dependency-neutral absorption"
                                        message: "These controls use GeoControls Theme and ControlState only."
                                        actionText: "Details"
                                        onActionTriggered: showMessage("InfoBar", "InfoBar action clicked.")
                                        onClosed: visible = false
                                    }

                                    RowLayout {
                                        spacing: 10

                                        Badge {
                                            count: 7
                                        }

                                        Badge {
                                            text: "NEW"
                                            color: Theme.successColor
                                        }

                                        Chip {
                                            text: "Selectable chip"
                                            checkable: true
                                            checked: true
                                        }

                                        Chip {
                                            text: "Closable chip"
                                            closable: true
                                            onCloseRequested: visible = false
                                        }
                                    }

                                    SegmentedControl {
                                        model: ["Overview", "Details", "History"]
                                        currentIndex: 0
                                        onActivated: appShellLog.text = "Segment: " + index
                                    }

                                    Breadcrumb {
                                        model: ["Project", "Scene", "Layer"]
                                        onActivated: showMessage("Breadcrumb", "Clicked index " + index + ".")
                                    }

                                    Expander {
                                        Layout.fillWidth: true
                                        title: "Expander"

                                        CustomLabel {
                                            Layout.fillWidth: true
                                            text: "Expandable content stays inside ordinary GeoControls layouts."
                                            color: Theme.placeholderTextColor
                                        }
                                    }

                                    RowLayout {
                                        spacing: 14

                                        Pagination {
                                            page: 3
                                            pageCount: 12
                                            onPageRequested: appShellLog.text = "Page requested: " + page
                                        }

                                        RatingControl {
                                            rating: 3
                                            onRatingChangedByUser: appShellLog.text = "Rating: " + rating
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
                                        text: "Disabled text"
                                        font.bold: true
                                    }

                                    CustomTextField {
                                        Layout.fillWidth: true
                                        text: "Disabled value"
                                        enabled: false
                                    }

                                    CustomLabel {
                                        text: "Narrow text"
                                        font.bold: true
                                    }

                                    CustomTextField {
                                        Layout.maximumWidth: 150
                                        text: "A very long editable value that shows clipping"
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
                                        text: "Disabled combo"
                                        font.bold: true
                                    }

                                    CustomComboBox {
                                        Layout.fillWidth: true
                                        model: ["Alpha", "Beta", "Gamma"]
                                        currentIndex: 0
                                        enabled: false
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
                                        onClicked: showMessage("Dialog", "This message uses MessageDialog from GeoControls.")
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
                                        completionProvider: completionProvider
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
                                title: "Endpoint config"
                                collapsible: false

                                ServerConfigSection {
                                    Layout.fillWidth: true
                                    endpointConfig: demoEndpointConfig
                                    useComboBox: true
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 430
                                title: "Navigation and page patterns"
                                collapsible: false

                                NavigationView {
                                    id: demoNavigationView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    model: [
                                        {
                                            title: "Dashboard",
                                            subtitle: "Summary page",
                                            iconSource: "qrc:/GeoControls/icons/Home.svg",
                                            section: "Workspace"
                                        },
                                        {
                                            title: "Data",
                                            subtitle: "List and table entry",
                                            iconSource: "qrc:/GeoControls/icons/Table.svg"
                                        },
                                        {
                                            title: "Review",
                                            subtitle: "Tabbed detail view",
                                            iconSource: "qrc:/GeoControls/icons/Eye.svg",
                                            section: "Flow"
                                        }
                                    ]
                                    onActivated: appShellLog.text = "Navigation index: " + index

                                    ScrollablePage {
                                        anchors.fill: parent
                                        pageTitle: demoNavigationView.model[demoNavigationView.currentIndex].title
                                        subtitle: demoNavigationView.model[demoNavigationView.currentIndex].subtitle

                                        ListTile {
                                            Layout.fillWidth: true
                                            title: "ListTile"
                                            subtitle: "Host-provided data, no route singleton."
                                            iconSource: "qrc:/GeoControls/icons/Tree.svg"
                                            selected: true
                                        }

                                        TabView {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 180
                                            model: [
                                                {
                                                    title: "General",
                                                    closeable: false
                                                },
                                                {
                                                    title: "Preview"
                                                },
                                                {
                                                    title: "History"
                                                }
                                            ]
                                            onActivated: appShellLog.text = "Tab index: " + index
                                            onCloseRequested: appShellLog.text = "Close requested: " + index
                                            onMoveRequested: function (from, to) {
                                                appShellLog.text = "Move requested: " + from + " -> " + to
                                            }
                                        }
                                    }
                                }
                            }

                            CustomRectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 360
                                title: "Advanced candidates"
                                collapsible: false

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 12

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 10

                                        DataGrid {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 150
                                            columns: [
                                                {
                                                    role: "name",
                                                    title: "Name",
                                                    width: 150
                                                },
                                                {
                                                    role: "status",
                                                    title: "Status",
                                                    width: 110
                                                },
                                                {
                                                    role: "owner",
                                                    title: "Owner",
                                                    width: 120
                                                }
                                            ]
                                            rows: [
                                                {
                                                    name: "Terrain import",
                                                    status: "Ready",
                                                    owner: "Geo"
                                                },
                                                {
                                                    name: "Point cloud",
                                                    status: "Review",
                                                    owner: "QA"
                                                }
                                            ]
                                            onSortRequested: function (role, ascending) {
                                                appShellLog.text = "Sort requested: " + role + " " + ascending
                                            }
                                            onSelectionChanged: function (index, row, selected) {
                                                appShellLog.text = "Grid row " + index + " selected: " + selected
                                            }
                                        }

                                        TreeDataGrid {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            columns: [
                                                {
                                                    role: "name",
                                                    title: "Node",
                                                    width: 180
                                                },
                                                {
                                                    role: "kind",
                                                    title: "Kind",
                                                    width: 120
                                                }
                                            ]
                                            sourceRows: [
                                                {
                                                    id: "root",
                                                    name: "Project",
                                                    kind: "Folder",
                                                    children: [
                                                        {
                                                            id: "mesh",
                                                            name: "Mesh",
                                                            kind: "Layer"
                                                        },
                                                        {
                                                            id: "survey",
                                                            name: "Survey",
                                                            kind: "Layer"
                                                        }
                                                    ]
                                                }
                                            ]
                                            onExpanded: function (key, opened) {
                                                appShellLog.text = "Tree node " + key + " expanded: " + opened
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.preferredWidth: 330
                                        Layout.fillHeight: true
                                        spacing: 10

                                        ColorPicker {
                                            Layout.fillWidth: true
                                            dialogHost: contentRoot
                                            selectedColor: window.selectedColor
                                            onAccepted: function (color) {
                                                window.selectedColor = color
                                            }
                                        }

                                        DatePicker {
                                            Layout.fillWidth: true
                                            minYear: 2024
                                            maxYear: 2028
                                            onDateSelected: function (value) {
                                                window.selectedDateText = value.toLocaleDateString()
                                            }
                                        }

                                        TimePicker {
                                            Layout.fillWidth: true
                                            showSeconds: true
                                            onTimeSelected: function (value) {
                                                window.selectedTimeText = value
                                            }
                                        }

                                        RouteView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            activeRouteId: "overview"
                                            routes: [
                                                {
                                                    routeId: "overview",
                                                    title: "Overview",
                                                    subtitle: "Explicit route id",
                                                    iconSource: "qrc:/GeoControls/icons/Home.svg"
                                                },
                                                {
                                                    routeId: "details",
                                                    title: "Details",
                                                    subtitle: "Host handles activation",
                                                    iconSource: "qrc:/GeoControls/icons/Table.svg"
                                                }
                                            ]
                                            onRouteActivated: function (routeId) {
                                                appShellLog.text = "Route activated: " + routeId
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ColorPicker {
            id: colorPicker
            dialogHost: contentRoot
            selectedColor: window.selectedColor
            onAccepted: function (color) {
                window.selectedColor = color
            }
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
