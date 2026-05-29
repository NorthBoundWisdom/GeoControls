import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

TabBar {
    id: control

    property int defaultHeight: Fonts.toolbarHeight
    property int defaultPadding: Fonts.size6
    property bool showOverflowButton: false
    property var hiddenTabs: []
    property bool alignRight: false
    property bool compactContentWidth: false

    property color backgroundColor: Theme.buttonColor
    property color activeColor: Theme.buttonColor
    property color hoverColor: Theme.buttonHoveredColor
    property color disabledColor: Theme.buttonDisabledColor
    property color highlightColor: Theme.highlightColor
    property color midColor: Theme.midColor

    property int targetIndex: 0
    implicitHeight: defaultHeight

    background: Rectangle {
        color: backgroundColor
        border.color: Theme.midColor
        border.width: Fonts.size1
    }

    contentItem: Item {
        anchors.fill: parent

        ListView {
            id: tabListView
            // Anchor to avoid overlapping with overflow button and keep content visually centered
            anchors.left: parent.left
            anchors.right: overflowButton.left
            height: parent.height
            model: control.contentModel
            currentIndex: control.targetIndex

            // Prevent position updates on currentIndex changes
            highlightFollowsCurrentItem: false

            spacing: Fonts.size1
            orientation: ListView.Horizontal
            layoutDirection: control.alignRight ? Qt.RightToLeft : Qt.LeftToRight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.AutoFlickIfNeeded
            snapMode: ListView.SnapToItem

            highlightMoveDuration: 0
            // Do not auto-scroll to keep current item centered; we will position manually
            highlightRangeMode: ListView.NoHighlightRange

            // Prevent overflow to the left
            clip: true

            onContentWidthChanged: {
                // Check if all tabs fit in the available width
                checkVisibleTabs();
            }

            onWidthChanged: {
                checkVisibleTabs();
            }
        }

        Button {
            id: overflowButton
            visible: showOverflowButton
            width: visible ? height : 0
            height: parent.height
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "⋮"

            background: Rectangle {
                color: overflowButton.pressed ? control.highlightColor : overflowButton.hovered ? control.hoverColor : control.disabledColor
                border.color: Theme.midColor
                border.width: Fonts.size1
            }

            onClicked: {
                overflowMenu.popup(overflowButton, 0, overflowButton.height);
            }

            Menu {
                id: overflowMenu
                modal: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                font: Fonts.listFont
                padding: 0
                implicitWidth: Math.max(Fonts.size180, contentItem ? contentItem.implicitWidth : 0)
                implicitHeight: contentItem ? contentItem.implicitHeight : 0

                background: Rectangle {
                    color: Theme.windowColor
                    border.color: Theme.midColor
                    border.width: Fonts.size1
                    radius: Fonts.size4
                    antialiasing: true
                }

                Repeater {
                    model: hiddenTabs
                    MenuItem {
                        id: mi
                        property var tabObject: contentModel.get(modelData)
                        text: tabObject && tabObject.text ? tabObject.text : ""
                        icon.source: tabObject && tabObject.iconSource ? tabObject.iconSource : ""
                        icon.color: Theme.windowTextColor
                        implicitHeight: Fonts.menuBarHeight

                        // Check if this is the currently selected tab
                        property bool isSelected: modelData === control.targetIndex

                        contentItem: Row {
                            spacing: Fonts.size8
                            anchors.fill: parent
                            anchors.leftMargin: Fonts.size8
                            anchors.rightMargin: Fonts.size8

                            // Selection indicator
                            Rectangle {
                                width: Fonts.size4
                                height: parent.height * 0.6
                                color: mi.isSelected ? control.highlightColor : "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                radius: Fonts.size2
                            }

                            IconLabel {
                                icon: mi.icon
                                width: Fonts.size18
                                height: Fonts.size18
                                visible: mi.icon.source && mi.icon.source.toString().length > 0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Label {
                                id: textLabel
                                text: mi.text
                                color: Theme.windowTextColor
                                font: Fonts.listFont
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                            }
                        }
                        background: Rectangle {
                            color: mi.highlighted ? Theme.buttonHoveredColor : Theme.windowColor

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: Fonts.size1
                                color: Theme.midColor
                                visible: index < (hiddenTabs.length - 1)
                            }
                        }
                        onTriggered: {
                            control.setTargetIndex(modelData);
                        }
                    }
                }
            }
        }
    }

    function setTargetIndex(index) {
        if (targetIndex !== index) {
            targetIndex = index;
        }
    }

    function checkVisibleTabs() {
        function computeVisibility(availableWidth) {
            var usedWidth = 0;
            var shown = [];
            var hidden = [];
            for (var i = 0; i < contentModel.count; i++) {
                var tab = contentModel.get(i);
                if (!tab)
                    continue;
                if (tab.forceHidden === true) {
                    continue;
                }

                var tabWidth = (tab.implicitWidth || tab.width || 0);
                var extra = shown.length > 0 ? tabListView.spacing : 0;
                if (usedWidth + extra + tabWidth <= availableWidth) {
                    usedWidth += extra + tabWidth;
                    shown.push(i);
                } else {
                    hidden.push(i);
                }
            }
            return {
                shown: shown,
                hidden: hidden
            };
        }

        // First pass without reserving overflow space
        var pass1 = computeVisibility(control.width);
        var needsOverflow = pass1.hidden.length > 0;

        // Second pass: reserve overflow button space if needed
        var availableWidth = control.width - (needsOverflow ? control.height : 0);
        var pass2 = computeVisibility(availableWidth);

        // Apply visibility without changing width to preserve layout
        for (var i = 0; i < contentModel.count; i++) {
            var tab = contentModel.get(i);
            if (!tab)
                continue;
            if (tab.forceHidden === true) {
                tab.visible = false;
                continue;
            }
            var isShown = pass2.shown.indexOf(i) !== -1;
            tab.visible = isShown;
            // Don't set tab.width to 0 - this breaks the layout
        }

        hiddenTabs = pass2.hidden;
        showOverflowButton = pass2.hidden.length > 0;
        if (!showOverflowButton) {
            // When tabs fully fit again, reset viewport offset to avoid clipped first tab.
            tabListView.cancelFlick();
            tabListView.contentX = tabListView.originX;
            tabListView.returnToBounds();
            if (overflowMenu.visible) {
                overflowMenu.close();
            }
        }
    }

    onWidthChanged: {
        checkVisibleTabs();
    }
    onCompactContentWidthChanged: checkVisibleTabs()
    onHeightChanged: checkVisibleTabs()
    onDefaultHeightChanged: checkVisibleTabs()
    Component.onCompleted: checkVisibleTabs()
}
