import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

TabBar {
    id: control

    property int defaultHeight: Fonts.titleBarHeight
    property int defaultPadding: Fonts.size6
    property bool useLegacyTabStyle: true

    property color backgroundColor: Theme.buttonColor
    property color activeColor: Theme.buttonColor
    property color hoverColor: Theme.buttonHoveredColor
    property color disabledColor: Theme.buttonDisabledColor
    property color highlightColor: Theme.highlightColor
    property color midColor: Theme.midColor

    property int targetIndex: 0
    implicitHeight: defaultHeight

    // Override implicitWidth to prevent binding loops
    // Use a fixed calculation based on contentModel count instead of child widths
    implicitWidth: {
        if (contentModel.count === 0) {
            return 0;
        }
        // Use a reasonable default width per tab to avoid binding loops
        var defaultTabWidth = Fonts.scaledUiSize(80); // Default width per tab
        var spacing = (contentModel.count - 1) * Fonts.size1; // spacing between tabs
        return contentModel.count * defaultTabWidth + spacing;
    }

    background: Rectangle {
        color: backgroundColor
        border.color: Theme.midColor
        border.width: Fonts.size1
    }

    contentItem: Item {
        anchors.fill: parent

        ListView {
            id: tabListView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            model: control.contentModel
            currentIndex: control.targetIndex

            // Prevent position updates on currentIndex changes
            highlightFollowsCurrentItem: false

            spacing: 0
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.AutoFlickIfNeeded
            snapMode: ListView.SnapToItem

            highlightMoveDuration: 0
            highlightRangeMode: ListView.NoHighlightRange

            clip: true

            // Flag to prevent binding loops
            property bool updatingWidths: false

            function updateTabWidths() {
                if (updatingWidths || contentModel.count === 0 || width <= 0) {
                    return;
                }

                updatingWidths = true;

                // Calculate average width for all tabs
                // Available width minus spacing between tabs
                var totalSpacing = (contentModel.count - 1) * tabListView.spacing;
                var averageWidth = Math.max(0, (tabListView.width - totalSpacing) / contentModel.count);
                // Ensure all tabs have the same height as the ListView
                var tabHeight = tabListView.height;

                // Set width and height for all tabs and ensure tabBar and targetIndex are set
                for (var i = 0; i < contentModel.count; i++) {
                    var tab = contentModel.get(i);
                    if (tab) {
                        // Set width
                        if (Math.abs(tab.width - averageWidth) > 0.1) {
                            tab.width = averageWidth;
                        }
                        // Ensure height is consistent (match ListView height)
                        if (Math.abs(tab.height - tabHeight) > 0.1) {
                            tab.height = tabHeight;
                        }
                        // Ensure tabBar reference is set for CustomTabButton
                        if (tab.tabBar !== control) {
                            tab.tabBar = control;
                        }
                        // Ensure targetIndex is set (use ListView index as targetIndex)
                        if (tab.targetIndex !== i) {
                            tab.targetIndex = i;
                        }
                    }
                }

                updatingWidths = false;
            }

            // Update tab widths when size changes
            // Use Qt.callLater to defer execution and avoid binding loops
            onWidthChanged: {
                Qt.callLater(function () {
                    tabListView.updateTabWidths();
                });
            }

            onCountChanged: {
                Qt.callLater(function () {
                    tabListView.updateTabWidths();
                });
            }

            onHeightChanged: {
                Qt.callLater(function () {
                    tabListView.updateTabWidths();
                });
            }

            Component.onCompleted: {
                Qt.callLater(function () {
                    tabListView.updateTabWidths();
                });
            }

            // Listen to contentModel changes
            Connections {
                target: control.contentModel
                function onCountChanged() {
                    Qt.callLater(function () {
                        tabListView.updateTabWidths();
                    });
                }
            }

            // Update tab selection state when targetIndex changes
            Connections {
                target: control
                function onTargetIndexChanged() {
                    // Update all tabs to reflect selection state
                    Qt.callLater(function () {
                        for (var i = 0; i < contentModel.count; i++) {
                            var tab = contentModel.get(i);
                            if (tab) {
                                // Force property update by reassigning
                                var currentSelected = tab.isSelected;
                                // This will trigger the binding to re-evaluate
                                tab.targetIndex = tab.targetIndex;
                            }
                        }
                    });
                }
            }
        }
    }

    function setTargetIndex(index) {
        if (targetIndex !== index) {
            targetIndex = index;
        }
    }

    onDefaultHeightChanged: {
        Qt.callLater(function () {
            if (tabListView) {
                tabListView.updateTabWidths();
            }
        });
    }
}
