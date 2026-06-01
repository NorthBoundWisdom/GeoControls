import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.impl 2.15
import GeoControls 1.0

Menu {
    id: control

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    font: Fonts.listFont
    leftPadding: Fonts.size4
    rightPadding: Fonts.size4
    topPadding: Fonts.size4
    bottomPadding: Fonts.size4
    implicitWidth: Math.max(control.popupMinWidth, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: (contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding

    background: Rectangle {
        implicitWidth: control.popupMinWidth
        color: control.popupSurfaceColor
        border.color: control.popupBorderColor
        border.width: Fonts.size1
        radius: control.popupRadius
        antialiasing: true
    }

    property color backgroundColor: "transparent"
    property color menuTextColor: Theme.textColor
    property color menuDisabledTextColor: Qt.alpha(Theme.textColor, 0.42)
    property color menuHoveredColor: Qt.alpha(Theme.accentColor, 0.16)
    property color menuPressedColor: Qt.alpha(Theme.accentColor, 0.18)
    property color menuHighlightColor: Theme.highlightColor
    property color menuDarkColor: Theme.darkColor
    property color menuMidColor: Theme.dividerColor
    property color popupSurfaceColor: Theme.popupSurfaceColor
    property color popupBorderColor: Qt.alpha(Theme.dividerColor, 0.88)
    property color popupHoverColor: Qt.alpha(Theme.accentColor, 0.16)
    property color popupIconPlateColor: Qt.alpha(Theme.buttonColor, 0.55)
    property int popupRadius: Fonts.size6
    property int popupItemInset: 1
    property int popupMinWidth: Math.max(Fonts.size180, Fonts.standardFontMetrics.averageCharacterWidth * 16)
    property int popupSidePadding: Fonts.size8
    property int popupIconSlotWidth: Fonts.size24
    property int popupArrowSlotWidth: Fonts.size16

    property var menuItems: []
    property var pendingAction: null
    property real iconSize: {
        return Theme.monoFont.pixelSize
    }
    readonly property var emptyMenuPlaceholderItems: [
        {
            display_name: qsTr("(none)"),
            enabled: false
        }
    ]

    property int menuBarHeight: Fonts.menuBarHeight
    property int popupItemHeight: Math.max(Fonts.menuBarHeight + Fonts.size4, Fonts.standardFontMetrics.height + Fonts.size16)
    property int menuFontSize: Fonts.listFont.pixelSize

    signal commandRequested(var actionConfig)

    function queuePendingCommand(actionConfig) {
        pendingAction = actionConfig
        close()
    }

    function executePendingCommand() {
        if (pendingAction) {
            commandRequested(pendingAction)
            pendingAction = null
        }
    }

    function resolvedMenuItems(items) {
        return (items && items.length > 0) ? items : emptyMenuPlaceholderItems
    }

    function labelTextForAction(actionObject) {
        if (!actionObject) {
            return ""
        }
        if (actionObject.translationContext && actionObject.translationSource) {
            var translated = qsTranslate(String(actionObject.translationContext), String(actionObject.translationSource))
            if (translated && translated.length > 0) {
                return translated
            }
        }
        if (actionObject.displayName && actionObject.displayName.length > 0) {
            return actionObject.displayName
        }
        if (actionObject.display_name && actionObject.display_name.length > 0) {
            return actionObject.display_name
        }
        if (actionObject.actionName && actionObject.actionName.length > 0) {
            return actionObject.actionName
        }
        if (actionObject.action && actionObject.action.length > 0) {
            return actionObject.action
        }
        return actionObject.cmd_id ? actionObject.cmd_id : ""
    }

    function iconPathForAction(actionObject) {
        if (actionObject && actionObject.iconPath && actionObject.iconPath.length > 0) {
            return actionObject.iconPath
        }
        return (actionObject && actionObject.icon_path && actionObject.icon_path.length > 0) ? actionObject.icon_path : ""
    }

    function childrenForAction(actionObject) {
        return (actionObject && actionObject.children) ? actionObject.children : []
    }

    function isActionEnabled(actionObject) {
        return !(actionObject && actionObject.enabled !== undefined) || !!actionObject.enabled
    }

    function insertResolvedObject(targetMenu, index, wrapper) {
        if (!wrapper || !wrapper.createdObject) {
            return
        }
        if (wrapper.hasSubMenu) {
            targetMenu.insertMenu(index, wrapper.createdObject)
        } else {
            targetMenu.insertItem(index, wrapper.createdObject)
        }
    }

    function removeResolvedObject(targetMenu, wrapper) {
        if (!wrapper || !wrapper.createdObject) {
            return
        }
        if (wrapper.hasSubMenu) {
            targetMenu.removeMenu(wrapper.createdObject)
        } else {
            targetMenu.removeItem(wrapper.createdObject)
        }
        wrapper.createdObject.destroy()
        wrapper.createdObject = null
    }

    Component {
        id: styledMenuDelegate

        MenuItem {
            id: styledMenuItem
            readonly property bool hasIcon: !!(icon.source && String(icon.source).length > 0)
            implicitHeight: control.popupItemHeight
            implicitWidth: Math.max(control.popupMinWidth, textLabel.implicitWidth + control.popupSidePadding * 2 + control.popupIconSlotWidth + (subMenu ? control.popupArrowSlotWidth + Fonts.size4 : 0) + Fonts.size8)

            background: Rectangle {
                anchors.fill: parent
                anchors.margins: control.popupItemInset
                radius: Fonts.size4
                color: styledMenuItem.highlighted ? control.popupHoverColor : "transparent"
            }

            contentItem: Item {
                anchors.fill: parent
                anchors.leftMargin: control.popupSidePadding
                anchors.rightMargin: control.popupSidePadding

                Item {
                    id: iconSlot
                    width: control.popupIconSlotWidth
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Rectangle {
                        visible: styledMenuItem.hasIcon
                        anchors.centerIn: parent
                        width: Fonts.scaledUiSize(22)
                        height: Fonts.scaledUiSize(22)
                        radius: Fonts.size5
                        color: styledMenuItem.highlighted ? Qt.alpha(control.popupHoverColor, 0.92) : control.popupIconPlateColor
                        border.width: 1
                        border.color: Qt.alpha(control.popupBorderColor, 0.82)
                    }

                    IconLabel {
                        icon: styledMenuItem.icon
                        visible: styledMenuItem.hasIcon
                        width: control.iconSize
                        height: control.iconSize
                        anchors.centerIn: parent
                    }
                }

                Text {
                    id: textLabel
                    anchors.left: iconSlot.right
                    anchors.right: subMenuArrow.visible ? subMenuArrow.left : parent.right
                    anchors.leftMargin: Fonts.size8
                    anchors.rightMargin: Fonts.size4
                    anchors.verticalCenter: parent.verticalCenter
                    text: styledMenuItem.text
                    color: styledMenuItem.enabled ? control.menuTextColor : control.menuDisabledTextColor
                    font.pixelSize: control.menuFontSize
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.NoWrap
                }

                Text {
                    id: subMenuArrow
                    visible: !!styledMenuItem.subMenu
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: ">"
                    color: styledMenuItem.enabled ? control.menuTextColor : control.menuDisabledTextColor
                    font.pixelSize: control.menuFontSize
                }
            }
        }
    }

    delegate: styledMenuDelegate

    Component {
        id: subMenuComponent

        Menu {
            id: nestedMenu
            property string menuTitle: ""
            property var menuItems: []
            title: menuTitle
            delegate: styledMenuDelegate
            modal: false
            closePolicy: control.closePolicy
            font: control.font
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            topPadding: control.topPadding
            bottomPadding: control.bottomPadding
            property color menuTextColor: control.menuTextColor
            property color menuHoveredColor: control.menuHoveredColor
            property color menuPressedColor: control.menuPressedColor
            property color menuHighlightColor: control.menuHighlightColor
            property color menuDarkColor: control.menuDarkColor
            property color menuMidColor: control.menuMidColor
            property color popupSurfaceColor: control.popupSurfaceColor
            property color popupBorderColor: control.popupBorderColor
            property color popupHoverColor: control.popupHoverColor
            property color popupIconPlateColor: control.popupIconPlateColor
            property int popupRadius: control.popupRadius
            property int popupItemInset: control.popupItemInset
            property int popupMinWidth: control.popupMinWidth
            property int popupSidePadding: control.popupSidePadding
            property int popupIconSlotWidth: control.popupIconSlotWidth
            property int popupArrowSlotWidth: control.popupArrowSlotWidth
            property int menuBarHeight: control.menuBarHeight
            property int popupItemHeight: control.popupItemHeight
            property int menuFontSize: control.menuFontSize

            implicitWidth: Math.max(nestedMenu.popupMinWidth, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding)
            implicitHeight: (contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding

            background: Rectangle {
                implicitWidth: nestedMenu.popupMinWidth
                color: nestedMenu.popupSurfaceColor
                border.color: nestedMenu.popupBorderColor
                border.width: Fonts.size1
                radius: nestedMenu.popupRadius
                antialiasing: true
            }

            Instantiator {
                model: control.resolvedMenuItems(nestedMenu.menuItems)
                delegate: menuDelegateFactory
                onObjectAdded: function (index, wrapper) {
                    control.insertResolvedObject(nestedMenu, index, wrapper)
                }
                onObjectRemoved: function (index, wrapper) {
                    control.removeResolvedObject(nestedMenu, wrapper)
                }
            }
        }
    }

    Component {
        id: menuDelegateFactory

        QtObject {
            id: wrapper
            property var actionObject: modelData
            readonly property string labelText: control.labelTextForAction(actionObject)
            readonly property var childMenuItems: control.childrenForAction(actionObject)
            readonly property bool hasSubMenu: (childMenuItems ? childMenuItems.length : 0) > 0
            property var createdObject: null
            property var triggeredHandler: null

            Component.onCompleted: {
                if (hasSubMenu) {
                    createdObject = subMenuComponent.createObject(null, {
                        menuTitle: labelText,
                        menuItems: childMenuItems
                    })
                } else {
                    createdObject = styledMenuDelegate.createObject(null, {
                        text: labelText,
                        enabled: control.isActionEnabled(actionObject)
                    })
                    if (createdObject) {
                        createdObject.icon.source = control.iconPathForAction(actionObject)
                        createdObject.icon.color = createdObject.enabled ? control.menuTextColor : control.menuDisabledTextColor
                        triggeredHandler = function () {
                            control.queuePendingCommand(actionObject)
                        }
                        createdObject.triggered.connect(triggeredHandler)
                    }
                }
            }
        }
    }

    Instantiator {
        id: rbInst
        model: control.resolvedMenuItems(control.menuItems)
        delegate: menuDelegateFactory
        onObjectAdded: function (index, wrapper) {
            control.insertResolvedObject(control, index, wrapper)
        }
        onObjectRemoved: function (index, wrapper) {
            control.removeResolvedObject(control, wrapper)
        }
    }

    onClosed: {
        executePendingCommand()
        menuItems = []
    }
}
