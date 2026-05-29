import QtQuick 2.15
import GeoToy.Controls 1.0

Item {
    id: miniViewer

    signal hoverStateChanged(bool hovered)

    property var viewerItem: null
    property rect normalizedViewRect: Qt.rect(0, 0, 1, 1)
    property real sceneAspect: 1.0
    // Keep mini viewer size in DIP to avoid overgrowth on high-DPI/font-scaled setups.
    property int panelWidth: Fonts.scaledUiSize(80)
    property int panelHeight: Fonts.scaledUiSize(60)
    property int panelMargin: Fonts.scaledUiSize(6)
    property int contentPadding: 0
    property color frameColor: Theme.highlightColor
    property color viewRectStrokeColor: Theme.textColor
    property color viewRectFillColor: Qt.rgba(viewRectStrokeColor.r, viewRectStrokeColor.g, viewRectStrokeColor.b, 0.12)

    anchors.left: parent ? parent.left : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.leftMargin: panelMargin
    anchors.bottomMargin: panelMargin

    width: panelWidth
    height: panelHeight
    visible: false
    enabled: visible

    function clamp01(v) {
        return Math.max(0, Math.min(1, v))
    }

    function resolveContentRect() {
        var contentX = miniViewer.contentPadding
        var contentY = miniViewer.contentPadding
        var contentW = Math.max(1, miniViewer.width - 2 * miniViewer.contentPadding)
        var contentH = Math.max(1, miniViewer.height - 2 * miniViewer.contentPadding)

        var aspect = miniViewer.sceneAspect
        if (!(aspect > 0) || !isFinite(aspect)) {
            aspect = 1.0
        }

        var contentAspect = contentW / contentH
        if (aspect >= contentAspect) {
            var fitH = contentW / aspect
            contentY += (contentH - fitH) * 0.5
            contentH = fitH
        } else {
            var fitW = contentH * aspect
            contentX += (contentW - fitW) * 0.5
            contentW = fitW
        }

        return {
            "x": contentX,
            "y": contentY,
            "w": Math.max(1, contentW),
            "h": Math.max(1, contentH)
        }
    }

    function normalizedPointFromLocal(localX, localY) {
        var rect = resolveContentRect()
        var nx = clamp01((localX - rect.x) / rect.w)
        var ny = clamp01(1.0 - (localY - rect.y) / rect.h)
        return Qt.point(nx, ny)
    }

    Rectangle {
        anchors.fill: parent
        radius: Fonts.scaledUiSize(6)
        color: Qt.rgba(Theme.baseColor.r, Theme.baseColor.g, Theme.baseColor.b, 0.55)
        border.width: 1
        border.color: Qt.rgba(frameColor.r, frameColor.g, frameColor.b, 0.45)
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var contentRect = miniViewer.resolveContentRect()
            var contentX = contentRect.x
            var contentY = contentRect.y
            var contentW = contentRect.w
            var contentH = contentRect.h

            ctx.fillStyle = Qt.rgba(0, 0, 0, 0.15)
            ctx.fillRect(contentX, contentY, contentW, contentH)

            ctx.strokeStyle = Qt.rgba(frameColor.r, frameColor.g, frameColor.b, 0.65)
            ctx.lineWidth = 1
            ctx.strokeRect(contentX + 0.5, contentY + 0.5, Math.max(1, contentW - 1), Math.max(1, contentH - 1))

            var nx = miniViewer.clamp01(miniViewer.normalizedViewRect.x)
            var ny = miniViewer.clamp01(miniViewer.normalizedViewRect.y)
            var nw = miniViewer.clamp01(miniViewer.normalizedViewRect.width)
            var nh = miniViewer.clamp01(miniViewer.normalizedViewRect.height)
            if (nw <= 0 || nh <= 0) {
                return
            }

            nx = Math.min(nx, 1.0 - nw)
            ny = Math.min(ny, 1.0 - nh)

            var viewX = contentX + nx * contentW
            var viewY = contentY + (1.0 - ny - nh) * contentH
            var viewW = nw * contentW
            var viewH = nh * contentH

            ctx.fillStyle = miniViewer.viewRectFillColor
            ctx.fillRect(viewX, viewY, viewW, viewH)

            ctx.strokeStyle = viewRectStrokeColor
            ctx.lineWidth = 1.5
            ctx.strokeRect(viewX + 0.75, viewY + 0.75, Math.max(1, viewW - 1.5), Math.max(1, viewH - 1.5))
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: miniViewer.visible
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        preventStealing: true
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        onEntered: miniViewer.hoverStateChanged(true)
        onExited: miniViewer.hoverStateChanged(false)
        onCanceled: {
            miniViewer.hoverStateChanged(false)
        }

        onPressed: function (mouse) {
            if (!miniViewer.viewerItem) {
                return
            }
            if (mouse.button === Qt.RightButton) {
                miniViewer.viewerItem.fitAllFromMiniViewer()
                return
            }
            if (mouse.button === Qt.LeftButton) {
                var pos = miniViewer.normalizedPointFromLocal(mouse.x, mouse.y)
                miniViewer.viewerItem.moveCameraToMiniViewerNormalized(pos.x, pos.y)
            }
        }

        onPositionChanged: function (mouse) {
            if (!miniViewer.viewerItem || !(mouse.buttons & Qt.LeftButton)) {
                return
            }
            var pos = miniViewer.normalizedPointFromLocal(mouse.x, mouse.y)
            miniViewer.viewerItem.moveCameraToMiniViewerNormalized(pos.x, pos.y)
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onVisibleChanged: {
        canvas.requestPaint()
        if (!visible) {
            hoverStateChanged(false)
        }
    }
    onNormalizedViewRectChanged: canvas.requestPaint()
    onSceneAspectChanged: canvas.requestPaint()
    onFrameColorChanged: canvas.requestPaint()
    onViewRectStrokeColorChanged: canvas.requestPaint()
    onViewRectFillColorChanged: canvas.requestPaint()
}
