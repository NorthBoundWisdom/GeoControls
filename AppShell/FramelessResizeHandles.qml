import QtQuick 2.15
import QtQuick.Window 2.15
import GeoToy.Controls 1.0

Item {
    id: root

    property var windowHandle: null

    readonly property bool enabledHandles: Qt.platform.os !== "osx" && windowHandle !== null && windowHandle.visibility !== Window.Maximized && windowHandle.visibility !== Window.FullScreen
    readonly property int edgeThickness: Math.max(Fonts.size6, 6)
    readonly property int topThickness: Math.max(Fonts.size4, 4)
    readonly property int cornerSize: Math.max(Fonts.size12, edgeThickness * 2)

    visible: enabledHandles

    function startResize(edges, mouse) {
        if (!enabledHandles || !windowHandle || mouse.button !== Qt.LeftButton) {
            return
        }
        mouse.accepted = true
        windowHandle.startSystemResize(edges)
    }

    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeThickness
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.LeftEdge, mouse)
        }
    }

    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeThickness
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.RightEdge, mouse)
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.cornerSize
        anchors.rightMargin: root.cornerSize
        height: root.topThickness
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.TopEdge, mouse)
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.cornerSize
        anchors.rightMargin: root.cornerSize
        height: root.edgeThickness
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.BottomEdge, mouse)
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.cornerSize
        height: root.cornerSize
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.LeftEdge | Qt.TopEdge, mouse)
        }
    }

    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.cornerSize
        height: root.cornerSize
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.RightEdge | Qt.TopEdge, mouse)
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.cornerSize
        height: root.cornerSize
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.LeftEdge | Qt.BottomEdge, mouse)
        }
    }

    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.cornerSize
        height: root.cornerSize
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        onPressed: function (mouse) {
            root.startResize(Qt.RightEdge | Qt.BottomEdge, mouse)
        }
    }
}
