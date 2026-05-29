import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Rectangle {
    id: root

    function expandedPreferredHeight() {
        return contentColumn.implicitHeight + titleBar.height + (root.padding * 2)
    }

    // Layout properties
    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? expandedPreferredHeight() : titleBar.height
    implicitHeight: Layout.preferredHeight
    Layout.alignment: Qt.AlignTop

    // Style properties
    property color panelColor: Theme.baseColor
    property color titleBarColor: Theme.alternateBaseColor
    property color contentColor: Theme.alternateBaseColor
    property color borderColor: Theme.midColor
    property color titleColor: Theme.textColor
    property int borderWidth: Fonts.size1
    property int borderRadius: Fonts.panelBorderRadius
    property int titleFontSize: Fonts.standardFont.pixelSize
    property bool titleFontBold: true
    property int padding: Fonts.panelPadding
    property int arrowSize: Math.round(titleFontSize * 1.1)
    property bool animateHeight: true

    // Title and collapse properties
    property string title: ""
    property bool collapsible: true
    property bool initialExpanded: true
    property bool expanded: initialExpanded
    property bool initialized: false

    // Content height tracking
    property real contentHeight: contentColumn.implicitHeight
    property real prevHeight: 0

    // Properties from original component
    property bool editing: false
    property bool showAddButton: true
    property bool showDeleteButton: true
    property bool actionButtonsEnabled: true
    property string addTooltip: "Activate editing with current parameters"
    property string deleteTooltip: "Delete current item"
    property string resetTooltip: "Reset parameters to default"
    property string applyTooltip: "Apply and create a new snapshot"

    // Callback functions
    property var onAdd: function () {
    // Override this to provide add logic
    }
    property var onDelete: function () {
    // Override this to provide delete logic
    }
    property var onReset: function () {
    // Override this to provide reset logic
    }
    property var onApply: function () {
    // Override this to provide apply logic
    }

    signal toggled(bool expanded)

    // Default styling
    color: panelColor
    border.color: borderColor
    border.width: borderWidth
    radius: borderRadius
    clip: true

    // Track the last expanded height for smooth collapse/expand behavior.
    onContentHeightChanged: {
        if (root.expanded && root.initialized) {
            prevHeight = expandedPreferredHeight()
        }
    }

    onExpandedChanged: {
        if (root.expanded) {
            prevHeight = expandedPreferredHeight()
        }
    }

    // Animation for height changes
    Behavior on Layout.preferredHeight {
        enabled: root.initialized && root.animateHeight
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    // Initialize expanded/collapsed state
    Component.onCompleted: {
        Qt.callLater(function () {
            root.prevHeight = root.expandedPreferredHeight()
            root.initialized = true
        })
    }

    // Title bar
    Rectangle {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: titleLabel.implicitHeight + Fonts.smallMargin * Fonts.size2
        color: root.titleBarColor
        border.color: root.borderColor
        border.width: root.borderWidth
        radius: root.borderRadius
        z: 1

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Fonts.smallMargin
            anchors.rightMargin: Fonts.smallMargin
            spacing: Fonts.standardSpacing

            // Collapse arrow
            Text {
                id: arrow
                text: "▶"
                visible: root.collapsible && root.title.length > 0
                color: root.titleColor
                font.pixelSize: root.titleFontSize
                width: root.arrowSize
                height: root.arrowSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transformOrigin: Item.Center
                rotation: root.expanded ? 90 : 0
                Layout.preferredWidth: visible ? root.arrowSize : 0
                Layout.preferredHeight: root.arrowSize
            }

            // Activation indicator
            Rectangle {
                id: activeIndicator
                width: Fonts.iconButtonSize * 0.5
                height: width
                radius: width / 2
                color: root.editing ? "green" : Theme.disabledTextColor
                border.color: Theme.midColor
                border.width: Fonts.size1
                Layout.preferredWidth: width
                Layout.preferredHeight: height
                visible: root.title.length > 0
            }

            // Title label
            Text {
                id: titleLabel
                text: root.title
                color: root.enabled ? root.titleColor : Theme.disabledTextColor
                font.pixelSize: root.titleFontSize
                font.bold: root.titleFontBold
                font.family: Fonts.standardFont.family
                elide: Text.ElideRight
                Layout.fillWidth: true
                renderType: Text.NativeRendering
            }

            // Icon buttons row
            Row {
                id: iconButtonsRow
                spacing: Fonts.iconButtonSpacing
                Layout.alignment: Qt.AlignRight

                // Add button icon
                CustomPanelIconButton {
                    id: addButton
                    visible: root.showAddButton
                    enabled: root.actionButtonsEnabled && !root.editing
                    buttonSize: Fonts.iconButtonSize
                    iconContentSize: Math.round(Fonts.iconButtonSize * 0.9)
                    icon.source: "qrc:/icons/Plus.svg"
                    icon.color: !addButton.enabled ? Theme.disabledTextColor : (addButton.pressed ? Theme.highlightedTextColor : (addButton.hovered ? Theme.highlightColor : Theme.textColor))
                    tooltipText: root.addTooltip
                    tooltipDelay: ToolTipConfig.shortDelay

                    onClicked: {
                        if (!root.editing) {
                            root.editing = true
                            if (root.onAdd) {
                                root.onAdd()
                            }
                        }
                    }

                    background: Rectangle {
                        color: Theme.highlightColor
                        opacity: addButton.pressed ? 0.4 : addButton.hovered ? 0.2 : 0
                        radius: Fonts.buttonBorderRadius
                    }
                }

                // Delete button icon
                CustomPanelIconButton {
                    id: deleteButton
                    visible: root.showDeleteButton
                    enabled: root.actionButtonsEnabled && root.editing
                    buttonSize: Fonts.iconButtonSize
                    iconContentSize: Math.round(Fonts.iconButtonSize * 0.9)
                    icon.source: "qrc:/icons/Trash.svg"
                    icon.color: !deleteButton.enabled ? Theme.disabledTextColor : (deleteButton.pressed ? Theme.highlightedTextColor : (deleteButton.hovered ? Theme.highlightColor : Theme.textColor))
                    tooltipText: root.deleteTooltip
                    tooltipDelay: ToolTipConfig.shortDelay

                    onClicked: {
                        if (root.onDelete) {
                            root.onDelete()
                        }
                        root.editing = false
                    }

                    background: Rectangle {
                        color: Theme.highlightColor
                        opacity: deleteButton.pressed ? 0.4 : deleteButton.hovered ? 0.2 : 0
                        radius: Fonts.buttonBorderRadius
                    }
                }

                // Reset button icon
                CustomPanelIconButton {
                    id: resetButton
                    enabled: root.actionButtonsEnabled && root.editing
                    buttonSize: Fonts.iconButtonSize
                    iconContentSize: Math.round(Fonts.iconButtonSize * 0.9)
                    icon.source: "qrc:/icons/Restart.svg"
                    icon.color: !resetButton.enabled ? Theme.disabledTextColor : (resetButton.pressed ? Theme.highlightedTextColor : (resetButton.hovered ? Theme.highlightColor : Theme.textColor))
                    tooltipText: root.resetTooltip
                    tooltipDelay: ToolTipConfig.shortDelay

                    onClicked: {
                        if (root.onReset) {
                            root.onReset()
                        }
                        // Reset does not exit editing state, only resets parameters
                    }

                    background: Rectangle {
                        color: Theme.highlightColor
                        opacity: resetButton.pressed ? 0.4 : resetButton.hovered ? 0.2 : 0
                        radius: Fonts.buttonBorderRadius
                    }
                }

                // Apply button icon
                CustomPanelCheckButton {
                    id: applyButton
                    enabled: root.actionButtonsEnabled && root.editing
                    buttonSize: Fonts.iconButtonSize
                    checkSize: Math.round(Fonts.iconButtonSize * 0.65)
                    buttonTextColor: applyButton.hovered ? Theme.highlightColor : Theme.textColor
                    tooltipText: root.applyTooltip
                    tooltipDelay: ToolTipConfig.shortDelay

                    onClicked: {
                        if (root.onApply) {
                            root.onApply()
                        }
                        root.editing = false
                    }

                    background: Rectangle {
                        color: Theme.highlightColor
                        opacity: applyButton.pressed ? 0.4 : applyButton.hovered ? 0.2 : 0
                        radius: Fonts.buttonBorderRadius
                    }
                }
            }
        }

        // Collapse/expand mouse area
        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: iconButtonsRow.width + iconButtonsRow.spacing * Fonts.size2
            cursorShape: root.collapsible ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: root.collapsible
            onClicked: {
                if (!root.collapsible)
                    return
                root.expanded = !root.expanded
                root.toggled(root.expanded)
                root.prevHeight = root.expandedPreferredHeight()
            }
        }
    }

    // Content area - this is where children will be placed
    Item {
        id: contentContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        anchors.topMargin: root.padding
        clip: true
        visible: root.expanded
        height: root.expanded ? implicitHeight : 0

        implicitHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0
        }
    }

    // Default property - children will be placed in contentColumn
    default property alias children: contentColumn.data
}
