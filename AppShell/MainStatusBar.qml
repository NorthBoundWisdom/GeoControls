import QtQuick 2.15
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.15
import GeoControls 1.0

ToolBar {
    id: statusBar

    height: Fonts.statusBarHeight
    background: Rectangle {
        color: Qt.lighter(Theme.windowColor, 1.1)
    }

    property string statusText: ""
    property string viewerText: ""
    readonly property bool showStatusSeparator: statusText !== "" && viewerText !== ""

    function setStatusText(text) {
        statusText = text || ""
    }

    function setViewerText(text) {
        viewerText = text || ""
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Fonts.size10
        anchors.rightMargin: Fonts.size10

        CustomLabel {
            id: statusLabel
            objectName: "statusLabel"
            text: statusBar.statusText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
        }

        CustomLabel {
            id: spLabel
            text: " | "
            visible: statusBar.showStatusSeparator
            Layout.preferredWidth: visible ? Fonts.separatorWidth : 0
            Layout.minimumWidth: visible ? Fonts.separatorWidth : 0
            Layout.maximumWidth: visible ? Fonts.separatorWidth : 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
        }

        CustomLabel {
            id: viewerLabel
            objectName: "viewerLabel"
            text: statusBar.viewerText
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
        }
    }
}
