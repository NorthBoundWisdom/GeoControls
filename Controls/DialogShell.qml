import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Popup {
    id: root

    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.NoAutoClose

    // Optional parent item injected by C++ via context property.
    // Must be declared to avoid ReferenceError when not provided.
    property var parentItem: null

    parent: parentItem || Overlay.overlay
    anchors.centerIn: parent

    property int unit: (typeof fontMetrics !== "undefined" && fontMetrics ? Fonts.standardFontMetrics.height : Fonts.size16)

    property string titleText: ""

    property int cornerRadius: Fonts.size8
    property int headerHeight: Math.round(unit * 1.8)
    property int contentMargin: unit
    property int topSpacerHeight: Math.round(unit * 0.75)
    property int bottomSpacerHeight: unit

    property int footerTopMargin: Math.round(unit * 0.75)
    property int footerBottomMargin: Math.round(unit * 0.75)
    property int footerSpacing: Fonts.size10

    property bool showHeader: true
    property bool showCloseButton: true
    property bool showFooter: true
    property bool showFooterSeparator: true

    // Layout behavior for body area
    // - When `bodyFillHeight` is true, body expands to fill remaining space (good for scrollable content).
    // - When false, dialog height can shrink-wrap to `bodyItem.implicitHeight`.
    property bool bodyFillHeight: true
    // Optional fixed/preferred body height. Set to >=0 to override shrink-wrap behavior.
    property int bodyPreferredHeight: -1

    property Item bodyItem: null
    property Item footerItem: null

    signal closeRequested(string reason)

    function activateHostWindow() {
        if (parentItem && parentItem.window) {
            parentItem.window.raise();
            parentItem.window.requestActivate();
        }
    }

    function requestClose(reason) {
        closeRequested(reason || "");
        close();
    }

    function requestDialogFocus() {
        activateHostWindow();
        keyScope.forceActiveFocus(Qt.ActiveWindowFocusReason);
    }

    function openDialog() {
        activateHostWindow();
        open();
        requestDialogFocus();
        Qt.callLater(function () {
            requestDialogFocus();
        });
    }

    implicitHeight: dialogCol.implicitHeight

    Overlay.modal: Rectangle {
        color: Theme.shadowColor
        opacity: 0.35
    }

    background: Rectangle {
        radius: root.cornerRadius
        color: Theme.windowColor
        border.width: 0
        antialiasing: true
    }

    contentItem: Item {
        id: keyScope
        focus: true
        clip: true
        width: root.width
        height: root.height

        Keys.onEscapePressed: function (event) {
            root.requestClose("escape");
            event.accepted = true;
        }

        ColumnLayout {
            id: dialogCol
            anchors.fill: parent
            spacing: 0

            Rectangle {
                visible: root.showHeader
                Layout.fillWidth: true
                height: root.headerHeight
                color: Theme.alternateBaseColor
                radius: root.cornerRadius
                antialiasing: true

                // Keep only the top corners rounded; square off the bottom.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: root.contentMargin
                    anchors.rightMargin: root.contentMargin

                    Label {
                        text: root.titleText
                        font: Fonts.standardFont
                        color: Theme.textColor
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    ToolButton {
                        id: closeBtn
                        visible: root.showCloseButton
                        height: parent.height
                        width: height
                        padding: 0
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        icon.source: "qrc:/icons/Close.svg"
                        icon.width: Math.round(root.unit * 1.0)
                        icon.height: Math.round(root.unit * 1.0)
                        icon.color: Theme.textColor
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            color: closeBtn.pressed ? Theme.buttonPressedColor : (closeBtn.hovered ? Theme.buttonHoveredColor : "transparent")
                        }
                        onClicked: root.requestClose("button")
                    }
                }
            }

            Item {
                visible: root.topSpacerHeight > 0
                height: root.topSpacerHeight
                Layout.fillWidth: true
            }

            Item {
                id: bodyHost
                Layout.fillWidth: true
                Layout.fillHeight: root.bodyFillHeight
                Layout.preferredHeight: root.bodyPreferredHeight >= 0 ? root.bodyPreferredHeight : (root.bodyItem ? root.bodyItem.implicitHeight : 0)
                Layout.leftMargin: root.contentMargin
                Layout.rightMargin: root.contentMargin
            }

            Item {
                visible: root.bottomSpacerHeight > 0
                height: root.bottomSpacerHeight
                Layout.fillWidth: true
            }

            Rectangle {
                visible: root.showFooter && root.showFooterSeparator
                Layout.fillWidth: true
                height: Fonts.size1
                color: Theme.midColor
            }

            Item {
                id: footerHost
                visible: root.showFooter
                Layout.fillWidth: true
                Layout.preferredHeight: root.footerItem ? root.footerItem.implicitHeight : 0
                Layout.topMargin: root.footerTopMargin
                Layout.bottomMargin: root.footerBottomMargin
                Layout.leftMargin: root.contentMargin
                Layout.rightMargin: root.contentMargin
            }
        }
    }

    onBodyItemChanged: {
        if (!bodyItem) {
            return;
        }
        bodyItem.parent = bodyHost;
        if (bodyItem.anchors) {
            bodyItem.anchors.fill = bodyHost;
        }
    }

    onFooterItemChanged: {
        if (!footerItem) {
            return;
        }
        footerItem.parent = footerHost;
        if (footerItem.anchors) {
            footerItem.anchors.fill = footerHost;
        }
    }

    onOpened: {
        requestDialogFocus();
    }
}
