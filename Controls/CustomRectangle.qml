import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Rectangle {
    id: control

    function expandedPreferredHeight() {
        return contentColumn.implicitHeight + titleBar.height + (control.padding * 2)
    }

    readonly property real collapsedPreferredHeight: titleBar.height
    readonly property real preferredPanelHeight: expanded ? expandedPreferredHeight() : collapsedPreferredHeight

    // Layout properties
    Layout.fillWidth: true
    Layout.preferredHeight: preferredPanelHeight
    implicitHeight: preferredPanelHeight
    Layout.alignment: Qt.AlignTop

    // Style properties
    property color borderColor: Theme.midColor
    property color titleColor: Theme.textColor
    property int borderWidth: Fonts.size1
    property int borderRadius: Fonts.panelBorderRadius
    property int titleFontSize: Fonts.standardFont.pixelSize
    property bool titleFontBold: true
    property int padding: Fonts.panelPadding
    property int arrowSize: Math.round(titleFontSize * 1.1)
    property bool animateContentResize: true

    // Title and collapse properties
    property string title: ""
    property bool collapsible: true
    property bool initialExpanded: true
    property bool expanded: initialExpanded
    readonly property bool collapsed: !expanded
    property bool initialized: false
    property bool _expandedTransitionAnimating: false

    // Content height tracking
    property real contentHeight: contentColumn.implicitHeight

    signal toggled(bool expanded)

    // Default styling
    color: Theme.baseColor
    border.color: borderColor
    border.width: borderWidth
    radius: borderRadius
    clip: true // Clip content that goes outside bounds

    // Animation for height changes
    Behavior on Layout.preferredHeight {
        enabled: control.initialized && (control.animateContentResize || control._expandedTransitionAnimating)
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    onExpandedChanged: {
        if (!control.initialized) {
            return
        }
        control._expandedTransitionAnimating = true
        expandedTransitionResetTimer.restart()
    }

    // Initialize expanded/collapsed state
    Component.onCompleted: {
        Qt.callLater(function () {
            control.initialized = true
        })
    }

    Timer {
        id: expandedTransitionResetTimer
        interval: 180
        repeat: false
        onTriggered: {
            control._expandedTransitionAnimating = false
        }
    }

    // Title bar
    Rectangle {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: titleLabel.implicitHeight + Fonts.smallMargin * Fonts.size2
        color: control.color
        border.color: control.borderColor
        border.width: control.borderWidth
        radius: control.borderRadius
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
                visible: control.collapsible && control.title.length > 0
                color: control.titleColor
                font.pixelSize: control.titleFontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transformOrigin: Item.Center
                rotation: control.expanded ? 90 : 0
                Layout.preferredWidth: visible ? control.arrowSize : 0
                Layout.preferredHeight: control.arrowSize
            }

            // Title label
            Text {
                id: titleLabel
                text: control.title
                color: control.enabled ? control.titleColor : Theme.disabledTextColor
                font.pixelSize: control.titleFontSize
                font.bold: control.titleFontBold
                font.family: Fonts.standardFont.family
                elide: Text.ElideRight
                Layout.fillWidth: true
                renderType: Text.NativeRendering
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: control.collapsible ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: control.collapsible
            onClicked: {
                if (!control.collapsible)
                    return
                control.expanded = !control.expanded
                control.toggled(control.expanded)
            }
        }
    }

    // Content area - this is where children will be placed
    Item {
        id: contentContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: control.padding
        anchors.rightMargin: control.padding
        anchors.topMargin: control.padding
        anchors.bottomMargin: control.padding
        clip: true
        visible: control.expanded

        implicitHeight: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 0
        }
    }

    // Default property - children will be placed in contentColumn
    default property alias children: contentColumn.data
}
