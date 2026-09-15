import QtQuick 2.15
import QtQuick.Layouts 1.13
import GeoControls 1.0

Rectangle {
    id: statusBar

    implicitHeight: Math.max(Fonts.statusBarHeight, metrics.height + Fonts.size12)
    height: implicitHeight
    color: Theme.toolbarSurfaceColor

    property string statusText: ""
    property string viewerText: ""
    property var trailingTexts: []
    property int statusElide: Text.ElideMiddle
    readonly property bool showStatusSeparator: statusText !== "" && viewerText !== ""
    readonly property var resolvedTrailingTexts: {
        var texts = []
        var source = statusBar.trailingTexts
        if (source && source.length !== undefined) {
            for (var i = 0; i < source.length; ++i) {
                var item = source[i]
                if (item !== undefined && item !== null && String(item).length > 0)
                    texts.push(String(item))
            }
        }
        return texts
    }

    function setStatusText(text) {
        statusText = text || ""
    }

    function setViewerText(text) {
        viewerText = text || ""
    }

    FontMetrics {
        id: metrics
        font: Fonts.listFont
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Fonts.size1
        color: Theme.dividerColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Fonts.size10
        anchors.rightMargin: Fonts.size10
        spacing: Fonts.size10

        CustomLabel {
            id: statusLabel
            objectName: "statusLabel"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            font: Fonts.listFont
            text: statusBar.statusText
            elide: statusBar.statusElide
            verticalAlignment: Text.AlignVCenter
        }

        CustomLabel {
            id: spLabel
            Layout.fillHeight: true
            font: Fonts.listFont
            text: " | "
            visible: statusBar.showStatusSeparator
            Layout.preferredWidth: visible ? Fonts.separatorWidth : 0
            Layout.minimumWidth: visible ? Fonts.separatorWidth : 0
            Layout.maximumWidth: visible ? Fonts.separatorWidth : 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        CustomLabel {
            id: viewerLabel
            objectName: "viewerLabel"
            Layout.fillWidth: statusBar.resolvedTrailingTexts.length === 0
            Layout.fillHeight: true
            Layout.preferredWidth: visible ? implicitWidth : 0
            font: Fonts.listFont
            text: statusBar.viewerText
            visible: statusBar.viewerText !== ""
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            model: statusBar.resolvedTrailingTexts

            CustomLabel {
                required property string modelData

                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: implicitWidth
                font: Fonts.listFont
                text: modelData
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
