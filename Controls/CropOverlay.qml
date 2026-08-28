import QtQuick 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

Item {
    id: root

    property real cropX: 0
    property real cropY: 0
    property real cropWidth: 1
    property real cropHeight: 1
    property real aspectRatio: 0
    property real straighten: 0
    property real minStraighten: -45
    property real maxStraighten: 45
    property real straightenDegreesPerPixel: 0.2
    property color dimColor: Qt.rgba(0, 0, 0, 0.45)
    property color frameLight: Qt.rgba(1, 1, 1, 0.94)
    property color frameDark: Qt.rgba(0, 0, 0, 0.55)
    property color gridColor: Qt.rgba(1, 1, 1, 0.38)
    property real bracketLength: 22
    property bool interactive: true
    property bool interacting: false
    property int handleHoverCount: 0
    property real imageX: -1
    property real imageY: -1
    property real imageWidth: 0
    property real imageHeight: 0
    property real imageRotation: 0
    property Item photoItem: null
    property real sourceWidth: 0
    property real sourceHeight: 0
    property real minShortEdgePixels: 300
    property real minShortEdgeFraction: 0.5
    property real limitX: 0
    property real limitY: 0
    property real limitWidth: 1
    property real limitHeight: 1

    signal cropEdited(real x, real y, real width, real height)
    signal cropCommitted(real x, real y, real width, real height)
    signal straightenEdited(real degrees)
    signal straightenCommitted(real degrees)

    readonly property bool hostPainted: imageWidth > 1 && imageHeight > 1
    readonly property bool parentPainted: !hostPainted && parent && parent.paintedWidth !== undefined && parent.paintedWidth > 1 && parent.paintedHeight > 1
    readonly property real contentWidth: hostPainted ? imageWidth : (parentPainted ? parent.paintedWidth : width)
    readonly property real contentHeight: hostPainted ? imageHeight : (parentPainted ? parent.paintedHeight : height)
    readonly property real contentX: hostPainted ? imageX : (parentPainted ? (width - parent.paintedWidth) / 2 : 0)
    readonly property real contentY: hostPainted ? imageY : (parentPainted ? (height - parent.paintedHeight) / 2 : 0)
    readonly property real clampLeft: contentX + limitX * contentWidth
    readonly property real clampTop: contentY + limitY * contentHeight
    readonly property real clampRight: clampLeft + limitWidth * contentWidth
    readonly property real clampBottom: clampTop + limitHeight * contentHeight
    readonly property real minFrame: 8
    readonly property real dpr: Screen.devicePixelRatio > 0 ? Screen.devicePixelRatio : 1
    readonly property real hair: 1 / dpr
    readonly property real grab: 16

    function snap(value) {
        return Math.round(value * root.dpr) / root.dpr
    }

    function normalizedFromFrame() {
        return {
            "x": (frame.x - contentX) / Math.max(contentWidth, 1),
            "y": (frame.y - contentY) / Math.max(contentHeight, 1),
            "w": frame.width / Math.max(contentWidth, 1),
            "h": frame.height / Math.max(contentHeight, 1)
        }
    }

    function emitCropEdited() {
        const box = normalizedFromFrame()
        root.cropEdited(box.x, box.y, box.w, box.h)
    }

    function emitCropCommitted() {
        root.interacting = false
        const box = normalizedFromFrame()
        root.cropCommitted(box.x, box.y, box.w, box.h)
    }

    function clampedStraighten(originDegrees, originMouseX, mouseX) {
        return Math.max(root.minStraighten, Math.min(root.maxStraighten, originDegrees + (mouseX - originMouseX) * root.straightenDegreesPerPixel))
    }

    function beginInteraction() {
        root.interacting = true
    }

    function applyFrame(nx, ny, nw, nh) {
        frame.x = nx
        frame.y = ny
        frame.width = nw
        frame.height = nh
        emitCropEdited()
    }

    function mapOverlayToPhoto(sx, sy) {
        if (root.photoItem)
            return root.photoItem.mapFromItem(root, sx, sy)
        return Qt.point(sx - root.contentX, sy - root.contentY)
    }

    function mapPhotoDeltaToOverlay(ldx, ldy) {
        if (root.photoItem) {
            const origin = root.photoItem.mapToItem(root, 0, 0)
            const shifted = root.photoItem.mapToItem(root, ldx, ldy)
            return Qt.point(shifted.x - origin.x, shifted.y - origin.y)
        }
        return Qt.point(ldx, ldy)
    }

    function photoLocalRect() {
        const inset = root.hair
        const w = root.photoItem && root.photoItem.width > 1 ? root.photoItem.width : root.contentWidth
        const h = root.photoItem && root.photoItem.height > 1 ? root.photoItem.height : root.contentHeight
        return {
            "left": inset,
            "top": inset,
            "right": Math.max(inset, w - inset),
            "bottom": Math.max(inset, h - inset)
        }
    }

    function rotatedPhotoBounds() {
        if (root.photoItem && root.photoItem.width > 1) {
            const w = root.photoItem.width
            const h = root.photoItem.height
            const p00 = root.photoItem.mapToItem(root, 0, 0)
            const p10 = root.photoItem.mapToItem(root, w, 0)
            const p11 = root.photoItem.mapToItem(root, w, h)
            const p01 = root.photoItem.mapToItem(root, 0, h)
            return {
                "left": Math.min(p00.x, p10.x, p11.x, p01.x),
                "top": Math.min(p00.y, p10.y, p11.y, p01.y),
                "right": Math.max(p00.x, p10.x, p11.x, p01.x),
                "bottom": Math.max(p00.y, p10.y, p11.y, p01.y)
            }
        }
        return {
            "left": root.contentX,
            "top": root.contentY,
            "right": root.contentX + root.contentWidth,
            "bottom": root.contentY + root.contentHeight
        }
    }

    function frameLocalBounds(nx, ny, nw, nh) {
        const corners = [[nx, ny], [nx + nw, ny], [nx + nw, ny + nh], [nx, ny + nh]]
        let minX = Infinity
        let maxX = -Infinity
        let minY = Infinity
        let maxY = -Infinity
        for (let i = 0; i < 4; ++i) {
            const local = mapOverlayToPhoto(corners[i][0], corners[i][1])
            minX = Math.min(minX, local.x)
            maxX = Math.max(maxX, local.x)
            minY = Math.min(minY, local.y)
            maxY = Math.max(maxY, local.y)
        }
        return {
            "minX": minX,
            "maxX": maxX,
            "minY": minY,
            "maxY": maxY
        }
    }

    function frameInsidePhoto(nx, ny, nw, nh) {
        const slop = 0.25
        const rect = photoLocalRect()
        const bounds = frameLocalBounds(nx, ny, nw, nh)
        return bounds.minX >= rect.left - slop && bounds.maxX <= rect.right + slop && bounds.minY >= rect.top - slop && bounds.maxY <= rect.bottom + slop
    }

    function translateFrameIntoPhoto(nx, ny, nw, nh) {
        const rect = photoLocalRect()
        const bounds = frameLocalBounds(nx, ny, nw, nh)
        let ldx = 0
        let ldy = 0
        if (bounds.minX < rect.left)
            ldx = rect.left - bounds.minX
        if (bounds.maxX + ldx > rect.right)
            ldx = rect.right - bounds.maxX
        if (bounds.minY < rect.top)
            ldy = rect.top - bounds.minY
        if (bounds.maxY + ldy > rect.bottom)
            ldy = rect.bottom - bounds.maxY
        if (Math.abs(ldx) < 1e-9 && Math.abs(ldy) < 1e-9)
            return {
                "x": nx,
                "y": ny,
                "w": nw,
                "h": nh
            }
        const delta = mapPhotoDeltaToOverlay(ldx, ldy)
        return {
            "x": nx + delta.x,
            "y": ny + delta.y,
            "w": nw,
            "h": nh
        }
    }

    function shrinkIntoPhoto(nx, ny, nw, nh, pinHx, pinHy) {
        if (frameInsidePhoto(nx, ny, nw, nh))
            return {
                "x": nx,
                "y": ny,
                "w": nw,
                "h": nh
            }
        const minSize = minOverlayExtent()
        const hx = pinHx === 0 ? 1 : (pinHx === 1 ? 0 : 0.5)
        const hy = pinHy === 0 ? 1 : (pinHy === 1 ? 0 : 0.5)
        const pinX = nx + nw * hx
        const pinY = ny + nh * hy
        let lo = 0
        let hi = 1
        let best = {
            "x": pinX - minSize.w * hx,
            "y": pinY - minSize.h * hy,
            "w": minSize.w,
            "h": minSize.h
        }
        for (let step = 0; step < 16; ++step) {
            const t = (lo + hi) / 2
            const tw = Math.max(minSize.w, nw * t)
            const th = Math.max(minSize.h, nh * t)
            const tx = pinX - tw * hx
            const ty = pinY - th * hy
            if (frameInsidePhoto(tx, ty, tw, th)) {
                lo = t
                best = {
                    "x": tx,
                    "y": ty,
                    "w": tw,
                    "h": th
                }
            } else {
                hi = t
            }
        }
        return best
    }

    function containFrame(nx, ny, nw, nh, pinHx, pinHy) {
        let box = {
            "x": nx,
            "y": ny,
            "w": nw,
            "h": nh
        }
        if (frameInsidePhoto(box.x, box.y, box.w, box.h))
            return box
        box = translateFrameIntoPhoto(box.x, box.y, box.w, box.h)
        if (frameInsidePhoto(box.x, box.y, box.w, box.h))
            return box
        box = shrinkIntoPhoto(box.x, box.y, box.w, box.h, pinHx, pinHy)
        return translateFrameIntoPhoto(box.x, box.y, box.w, box.h)
    }

    function pixelAspect() {
        if (root.aspectRatio <= 0)
            return 0
        return root.aspectRatio
    }

    function minShortEdgePx() {
        const srcW = Math.max(root.sourceWidth, 0)
        const srcH = Math.max(root.sourceHeight, 0)
        const shortSrc = Math.min(srcW, srcH)
        if (!(shortSrc > 0))
            return 0
        return Math.min(root.minShortEdgePixels, shortSrc * root.minShortEdgeFraction)
    }

    function minOverlayExtent() {
        const minPx = minShortEdgePx()
        if (!(minPx > 0) || !(root.sourceWidth > 0) || !(root.sourceHeight > 0) || !(contentWidth > 1) || !(contentHeight > 1))
            return {
                "w": root.minFrame,
                "h": root.minFrame
            }
        return {
            "w": Math.max(root.minFrame, minPx / root.sourceWidth * contentWidth),
            "h": Math.max(root.minFrame, minPx / root.sourceHeight * contentHeight)
        }
    }

    function enforceMinShortEdge(nx, ny, nw, nh, pinHx, pinHy) {
        const minSize = minOverlayExtent()
        let tw = nw
        let th = nh
        const target = pixelAspect()
        if (target > 0) {
            tw = Math.max(nw, minSize.w, minSize.h * target)
            th = tw / target
            if (th < minSize.h) {
                th = minSize.h
                tw = th * target
            }
        } else {
            tw = Math.max(nw, minSize.w)
            th = Math.max(nh, minSize.h)
        }
        let tx = nx
        let ty = ny
        if (pinHx === 0)
            tx = nx + nw - tw
        else if (pinHx === 0.5)
            tx = nx + (nw - tw) / 2
        if (pinHy === 0)
            ty = ny + nh - th
        else if (pinHy === 0.5)
            ty = ny + (nh - th) / 2
        return {
            "x": tx,
            "y": ty,
            "w": tw,
            "h": th
        }
    }

    function clampFrame(nx, ny, nw, nh, pinHx, pinHy) {
        const target = pixelAspect()
        const minSize = minOverlayExtent()

        nw = Math.max(minSize.w, nw)
        nh = Math.max(minSize.h, nh)

        if (target > 0) {
            let tw = nw
            let th = nw / target
            if (th > nh + 0.01) {
                th = nh
                tw = nh * target
            }
            if (pinHx === 0)
                nx += nw - tw
            else if (pinHx === 0.5)
                nx += (nw - tw) / 2
            if (pinHy === 0)
                ny += nh - th
            else if (pinHy === 0.5)
                ny += (nh - th) / 2
            nw = tw
            nh = th
        }
        const sized = enforceMinShortEdge(nx, ny, nw, nh, pinHx, pinHy)
        return containFrame(sized.x, sized.y, Math.max(minSize.w, sized.w), Math.max(minSize.h, sized.h), pinHx, pinHy)
    }

    function resizeFromHandle(hx, hy, posX, posY, startX, startY, startW, startH) {
        const bounds = rotatedPhotoBounds()
        const left = bounds.left
        const top = bounds.top
        const right = bounds.right
        const bottom = bounds.bottom
        const minSize = minOverlayExtent()
        const startRight = startX + startW
        const startBottom = startY + startH
        let nx = startX
        let ny = startY
        let nw = startW
        let nh = startH

        if (hx === 0) {
            nx = Math.min(Math.max(left, posX), startRight - minSize.w)
            nw = startRight - nx
        } else if (hx === 1) {
            nw = Math.max(minSize.w, Math.min(posX, right) - startX)
            nx = startX
        }
        if (hy === 0) {
            ny = Math.min(Math.max(top, posY), startBottom - minSize.h)
            nh = startBottom - ny
        } else if (hy === 1) {
            nh = Math.max(minSize.h, Math.min(posY, bottom) - startY)
            ny = startY
        }

        const target = pixelAspect()
        const isCorner = hx !== 0.5 && hy !== 0.5
        if (target > 0) {
            const preferWidth = hx !== 0.5 && (isCorner ? Math.abs(nw - startW) >= Math.abs(nh - startH) : hy === 0.5)
            if (preferWidth) {
                nh = nw / target
                if (hy === 0)
                    ny = startBottom - nh
                else if (hy === 0.5)
                    ny = startY + (startH - nh) / 2
            } else {
                nw = nh * target
                if (hx === 0)
                    nx = startRight - nw
                else if (hx === 0.5)
                    nx = startX + (startW - nw) / 2
            }
        }

        const pinHx = hx === 0.5 ? 0.5 : (hx === 0 ? 1 : 0)
        const pinHy = hy === 0.5 ? 0.5 : (hy === 0 ? 1 : 0)
        return clampFrame(nx, ny, nw, nh, pinHx, pinHy)
    }

    function syncFrameFromCrop() {
        if (root.interacting)
            return
        const box = clampFrame(root.contentX + root.cropX * root.contentWidth, root.contentY + root.cropY * root.contentHeight, Math.max(root.minFrame, root.cropWidth * root.contentWidth), Math.max(root.minFrame, root.cropHeight * root.contentHeight), 0.5, 0.5)
        frame.x = box.x
        frame.y = box.y
        frame.width = box.w
        frame.height = box.h
    }

    onCropXChanged: syncFrameFromCrop()
    onCropYChanged: syncFrameFromCrop()
    onCropWidthChanged: syncFrameFromCrop()
    onCropHeightChanged: syncFrameFromCrop()
    onWidthChanged: syncFrameFromCrop()
    onHeightChanged: syncFrameFromCrop()
    onContentWidthChanged: syncFrameFromCrop()
    onContentHeightChanged: syncFrameFromCrop()
    onContentXChanged: syncFrameFromCrop()
    onContentYChanged: syncFrameFromCrop()
    onLimitXChanged: syncFrameFromCrop()
    onLimitYChanged: syncFrameFromCrop()
    onLimitWidthChanged: syncFrameFromCrop()
    onLimitHeightChanged: syncFrameFromCrop()
    onVisibleChanged: syncFrameFromCrop()
    onImageRotationChanged: syncFrameFromCrop()
    onPhotoItemChanged: syncFrameFromCrop()
    onSourceWidthChanged: syncFrameFromCrop()
    onSourceHeightChanged: syncFrameFromCrop()
    Component.onCompleted: syncFrameFromCrop()

    readonly property bool rotateCursorActive: root.interactive && straightenArea.containsMouse && !dragArea.containsMouse && root.handleHoverCount === 0

    MouseArea {
        id: straightenArea
        anchors.fill: parent
        z: 1
        enabled: root.interactive
        hoverEnabled: true
        preventStealing: true
        cursorShape: rotateCursor.status === Image.Ready ? Qt.BlankCursor : Qt.OpenHandCursor
        property real originDegrees
        property real originMouseX

        onPressed: function (mouse) {
            originDegrees = root.straighten
            originMouseX = mouse.x
        }
        onPositionChanged: function (mouse) {
            if (!pressed)
                return
            root.straightenEdited(root.clampedStraighten(originDegrees, originMouseX, mouse.x))
        }
        onReleased: function (mouse) {
            root.straightenCommitted(root.clampedStraighten(originDegrees, originMouseX, mouse.x))
        }
    }

    Rectangle {
        x: 0
        y: 0
        width: Math.max(0, frame.x)
        height: root.height
        enabled: false
        color: root.dimColor
    }
    Rectangle {
        x: frame.x + frame.width
        y: 0
        width: Math.max(0, root.width - x)
        height: root.height
        enabled: false
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: 0
        width: frame.width
        height: Math.max(0, frame.y)
        enabled: false
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: frame.y + frame.height
        width: frame.width
        height: Math.max(0, root.height - y)
        enabled: false
        color: root.dimColor
    }

    Item {
        id: frame
        z: 2
        clip: false

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true
            preventStealing: true
            cursorShape: rotating ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            property bool rotating: false
            property real originX
            property real originY
            property real originDegrees
            property real originMouseX
            property real originMouseY

            onPressed: function (mouse) {
                rotating = (mouse.modifiers & Qt.AltModifier) !== 0
                const pos = mapToItem(root, mouse.x, mouse.y)
                originMouseX = pos.x
                originMouseY = pos.y
                if (rotating) {
                    originDegrees = root.straighten
                    return
                }
                root.beginInteraction()
                originX = frame.x
                originY = frame.y
            }
            onPositionChanged: function (mouse) {
                if (!pressed)
                    return
                const pos = mapToItem(root, mouse.x, mouse.y)
                if (rotating) {
                    root.straightenEdited(root.clampedStraighten(originDegrees, originMouseX, pos.x))
                    return
                }
                // MouseArea is a child of the moving frame; deltas must be in overlay space.
                const box = root.clampFrame(originX + pos.x - originMouseX, originY + pos.y - originMouseY, frame.width, frame.height, 0.5, 0.5)
                root.applyFrame(box.x, box.y, box.w, box.h)
            }
            onReleased: function (mouse) {
                if (rotating) {
                    root.straightenCommitted(root.clampedStraighten(originDegrees, originMouseX, mapToItem(root, mouse.x, mouse.y).x))
                    rotating = false
                    return
                }
                root.emitCropCommitted()
            }
        }
    }

    Rectangle {
        x: frame.x - root.hair
        y: frame.y - root.hair
        width: frame.width + 2 * root.hair
        height: root.hair
        color: root.frameDark
        antialiasing: false
    }
    Rectangle {
        x: frame.x - root.hair
        y: frame.y + frame.height
        width: frame.width + 2 * root.hair
        height: root.hair
        color: root.frameDark
        antialiasing: false
    }
    Rectangle {
        x: frame.x - root.hair
        y: frame.y
        width: root.hair
        height: frame.height
        color: root.frameDark
        antialiasing: false
    }
    Rectangle {
        x: frame.x + frame.width
        y: frame.y
        width: root.hair
        height: frame.height
        color: root.frameDark
        antialiasing: false
    }
    Rectangle {
        x: frame.x
        y: frame.y
        width: frame.width
        height: root.hair
        color: root.frameLight
        antialiasing: false
    }
    Rectangle {
        x: frame.x
        y: frame.y + frame.height - root.hair
        width: frame.width
        height: root.hair
        color: root.frameLight
        antialiasing: false
    }
    Rectangle {
        x: frame.x
        y: frame.y
        width: root.hair
        height: frame.height
        color: root.frameLight
        antialiasing: false
    }
    Rectangle {
        x: frame.x + frame.width - root.hair
        y: frame.y
        width: root.hair
        height: frame.height
        color: root.frameLight
        antialiasing: false
    }

    Repeater {
        model: 2
        delegate: Rectangle {
            required property int index
            x: frame.x + frame.width * (index + 1) / 3
            y: frame.y
            width: root.hair
            height: frame.height
            color: root.gridColor
            antialiasing: false
        }
    }
    Repeater {
        model: 2
        delegate: Rectangle {
            required property int index
            x: frame.x
            y: frame.y + frame.height * (index + 1) / 3
            width: frame.width
            height: root.hair
            color: root.gridColor
            antialiasing: false
        }
    }

    Repeater {
        model: [
            {
                "hx": 0,
                "hy": 0
            },
            {
                "hx": 1,
                "hy": 0
            },
            {
                "hx": 0,
                "hy": 1
            },
            {
                "hx": 1,
                "hy": 1
            }
        ]
        delegate: Item {
            required property var modelData
            readonly property real cx: frame.x + modelData.hx * frame.width
            readonly property real cy: frame.y + modelData.hy * frame.height
            readonly property real dirX: modelData.hx === 0 ? 1 : -1
            readonly property real dirY: modelData.hy === 0 ? 1 : -1
            readonly property real thick: root.hair * 2

            Rectangle {
                x: parent.cx - (parent.dirX < 0 ? root.bracketLength : 0)
                y: parent.cy - (parent.dirY < 0 ? parent.thick : 0)
                width: root.bracketLength
                height: parent.thick
                color: root.frameDark
                antialiasing: false
            }
            Rectangle {
                x: parent.cx - (parent.dirX < 0 ? parent.thick : 0)
                y: parent.cy - (parent.dirY < 0 ? root.bracketLength : 0)
                width: parent.thick
                height: root.bracketLength
                color: root.frameDark
                antialiasing: false
            }
            Rectangle {
                x: parent.cx - (parent.dirX < 0 ? root.bracketLength - root.hair : root.hair)
                y: parent.cy + (parent.dirY < 0 ? -parent.thick + root.hair : 0)
                width: root.bracketLength - root.hair
                height: parent.thick
                color: root.frameLight
                antialiasing: false
            }
            Rectangle {
                x: parent.cx + (parent.dirX < 0 ? -parent.thick + root.hair : 0)
                y: parent.cy - (parent.dirY < 0 ? root.bracketLength - root.hair : -root.hair)
                width: parent.thick
                height: root.bracketLength - root.hair
                color: root.frameLight
                antialiasing: false
            }
        }
    }

    Repeater {
        model: [
            {
                "hx": 0,
                "hy": 0,
                "cursor": Qt.SizeFDiagCursor
            },
            {
                "hx": 0.5,
                "hy": 0,
                "cursor": Qt.SizeVerCursor
            },
            {
                "hx": 1,
                "hy": 0,
                "cursor": Qt.SizeBDiagCursor
            },
            {
                "hx": 0,
                "hy": 0.5,
                "cursor": Qt.SizeHorCursor
            },
            {
                "hx": 1,
                "hy": 0.5,
                "cursor": Qt.SizeHorCursor
            },
            {
                "hx": 0,
                "hy": 1,
                "cursor": Qt.SizeBDiagCursor
            },
            {
                "hx": 0.5,
                "hy": 1,
                "cursor": Qt.SizeVerCursor
            },
            {
                "hx": 1,
                "hy": 1,
                "cursor": Qt.SizeFDiagCursor
            }
        ]
        delegate: Item {
            required property var modelData
            readonly property bool edge: modelData.hx === 0.5 || modelData.hy === 0.5
            width: edge ? (modelData.hy === 0.5 ? root.grab : Math.max(root.grab * 2, frame.width - root.grab * 2)) : root.grab * 1.6
            height: edge ? (modelData.hx === 0.5 ? root.grab : Math.max(root.grab * 2, frame.height - root.grab * 2)) : root.grab * 1.6
            x: {
                if (modelData.hx === 0)
                    return frame.x - width / 2
                if (modelData.hx === 1)
                    return frame.x + frame.width - width / 2
                return frame.x + (frame.width - width) / 2
            }
            y: {
                if (modelData.hy === 0)
                    return frame.y - height / 2
                if (modelData.hy === 1)
                    return frame.y + frame.height - height / 2
                return frame.y + (frame.height - height) / 2
            }
            visible: root.interactive
            z: 3

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                cursorShape: modelData.cursor
                onEntered: root.handleHoverCount += 1
                onExited: root.handleHoverCount = Math.max(0, root.handleHoverCount - 1)
                property real startFrameX
                property real startFrameY
                property real startFrameW
                property real startFrameH

                onPressed: function (mouse) {
                    root.beginInteraction()
                    startFrameX = frame.x
                    startFrameY = frame.y
                    startFrameW = frame.width
                    startFrameH = frame.height
                }
                onPositionChanged: function (mouse) {
                    if (!pressed)
                        return
                    const pos = mapToItem(root, mouse.x, mouse.y)
                    const box = root.resizeFromHandle(modelData.hx, modelData.hy, pos.x, pos.y, startFrameX, startFrameY, startFrameW, startFrameH)
                    root.applyFrame(box.x, box.y, box.w, box.h)
                }
                onReleased: root.emitCropCommitted()
            }
        }
    }

    Image {
        id: rotateCursor
        width: 32
        height: 32
        z: 50
        enabled: false
        visible: root.rotateCursorActive
        x: straightenArea.mouseX - width / 2
        y: straightenArea.mouseY - height / 2
        source: "qrc:/GeoControls/icons/CropRotate.svg"
        smooth: true
        mipmap: true
    }

    Rectangle {
        visible: straightenArea.pressed || dragArea.rotating
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.contentY + Fonts.size8
        width: angleLabel.implicitWidth + Fonts.size16
        height: angleLabel.implicitHeight + Fonts.size8
        radius: 4
        color: Qt.rgba(0, 0, 0, 0.7)

        Text {
            id: angleLabel
            anchors.centerIn: parent
            text: qsTr("%1°").arg(root.straighten.toFixed(1))
            color: "white"
            font.pixelSize: Fonts.size14
        }
    }
}
