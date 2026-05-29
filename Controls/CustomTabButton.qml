import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import GeoToy.Controls 1.0

TabButton {
    id: control

    property var tabBar: null
    property int defaultHeight: (tabBar && tabBar.defaultHeight !== undefined) ? tabBar.defaultHeight : Fonts.titleBarHeight
    property int defaultPadding: (tabBar && tabBar.defaultPadding !== undefined) ? tabBar.defaultPadding : Fonts.size6
    property string iconSource: ""
    property int iconSize: Math.round(height * 0.6)
    property bool isOverflowItem: false
    property bool flatStyle: false
    property bool isSelected: {
        if (!tabBar || targetIndex < 0) {
            return false
        }
        var current = (tabBar.targetIndex !== undefined && tabBar.targetIndex !== null) ? tabBar.targetIndex : tabBar.currentIndex
        if (current === undefined || current === null) {
            return false
        }
        return current === targetIndex
    }
    property var viewerItem: null
    readonly property bool useLegacyStyle: !!(tabBar && tabBar.useLegacyTabStyle)
    property bool forceHidden: false

    property int targetIndex: -1

    property color buttonTextColor: Theme.buttonTextColor
    property color disabledTextColor: Theme.disabledTextColor
    property color windowColor: Theme.baseColor
    property color buttonHoveredColor: Theme.buttonHoveredColor
    property color buttonDisabledColor: Theme.buttonDisabledColor
    property color buttonColor: Theme.buttonColor
    property color darkColor: Theme.darkColor
    property color midColor: Theme.midColor
    property color surfaceColor: windowColor
    property color dividerColor: Theme.chromeDividerColor
    readonly property bool useFlatStyle: flatStyle && !useLegacyStyle
    readonly property color foregroundColor: control.isSelected ? control.buttonTextColor : (control.hovered ? Qt.alpha(control.buttonTextColor, 0.9) : Qt.alpha(control.buttonTextColor, 0.72))

    font: Fonts.standardFont
    padding: defaultPadding
    topPadding: 0
    bottomPadding: 0
    implicitWidth: {
        var iconWidth = (display === AbstractButton.TextOnly || !iconSource || iconSource.length === 0) ? 0 : iconSize
        var textWidth = (display === AbstractButton.IconOnly) ? 0 : textMetrics.width
        var spacingWidth = (iconWidth > 0 && textWidth > 0) ? spacing : 0
        var total = iconWidth + textWidth + spacingWidth + leftPadding + rightPadding
        return Math.max(total, height * 1.5)
    }
    implicitHeight: defaultHeight
    width: implicitWidth
    height: defaultHeight

    icon.width: iconSize
    icon.height: iconSize
    icon.source: iconSource
    icon.color: control.foregroundColor

    display: AbstractButton.TextBesideIcon

    contentItem: Row {
        spacing: control.spacing
        anchors.centerIn: parent

        IconLabel {
            icon: control.icon
            visible: control.display !== AbstractButton.TextOnly
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.text
            font: control.font
            color: control.enabled ? control.foregroundColor : control.disabledTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideNone
            visible: control.display !== AbstractButton.IconOnly
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        color: control.useLegacyStyle ? (control.isSelected ? control.windowColor : (control.hovered ? control.buttonHoveredColor : control.buttonDisabledColor)) : "transparent"
        border.color: control.useLegacyStyle ? (control.isSelected ? control.buttonColor : (control.hovered ? control.darkColor : control.midColor)) : "transparent"
        border.width: control.useLegacyStyle ? (control.isSelected ? 0 : Fonts.size1) : 0

        Rectangle {
            visible: !control.useLegacyStyle && !control.useFlatStyle
            anchors.centerIn: parent
            width: Math.max(0, parent.width - Fonts.size4)
            height: Math.max(0, parent.height - Fonts.size4)
            radius: Fonts.size4
            color: control.isSelected ? control.windowColor : (control.hovered ? control.buttonHoveredColor : control.buttonDisabledColor)
            border.color: control.isSelected ? control.midColor : (control.hovered ? control.darkColor : control.midColor)
            border.width: control.isSelected ? Fonts.size1 : 0
        }

        Rectangle {
            visible: control.useLegacyStyle && control.isSelected
            anchors.bottom: parent.bottom
            width: parent.width
            height: Fonts.size2
            color: control.buttonColor
        }

        Rectangle {
            visible: control.useFlatStyle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 1
            anchors.bottomMargin: 1
            radius: control.isSelected ? Fonts.size4 : 0
            color: control.isSelected ? control.surfaceColor : (control.hovered ? Qt.alpha(control.buttonHoveredColor, 0.24) : "transparent")
            border.color: control.isSelected ? control.dividerColor : "transparent"
            border.width: control.isSelected ? 1 : 0
        }
    }

    onClicked: {
        if (tabBar && targetIndex >= 0) {
            if (tabBar.setTargetIndex) {
                tabBar.setTargetIndex(targetIndex)
            } else {
                tabBar.currentIndex = targetIndex
            }
        }
    }

    CustomToolTip {
        visible: control.hovered
        delay: ToolTipConfig.longDelay
        text: control.text
    }

    TextMetrics {
        id: textMetrics
        text: control.text
        font: control.font
    }
}
