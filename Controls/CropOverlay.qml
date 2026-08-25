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
    property real imageX: -1
    property real imageY: -1
    property real imageWidth: 0
    property real imageHeight: 0
    property real imageRotation: 0
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

    function photoLocal(sx, sy) {
        const cx = root.contentX + root.contentWidth / 2
        const cy = root.contentY + root.contentHeight / 2
        const dx = sx - cx
        const dy = sy - cy
        const rad = root.imageRotation * Math.PI / 180
        const c = Math.cos(rad)
        const s = Math.sin(rad)
        return {
            "x": dx * c + dy * s + cx,
            "y": -dx * s + dy * c + cy
        }
    }

    function frameInsidePhoto(nx, ny, nw, nh) {
        const slop = 0.75
        const corners = [[nx, ny], [nx + nw, ny], [nx + nw, ny + nh], [nx, ny + nh]]
        for (let i = 0; i < 4; ++i) {
            const local = photoLocal(corners[i][0], corners[i][1])
            if (local.x < root.contentX - slop || local.x > root.contentX + root.contentWidth + slop || local.y < root.contentY - slop || local.y > root.contentY + root.contentHeight + slop)
                return false
        }
        return true
    }

    function shrinkIntoPhoto(nx, ny, nw, nh, pinHx, pinHy) {
        if (Math.abs(root.imageRotation) < 0.04 || frameInsidePhoto(nx, ny, nw, nh))
            return {
                "x": nx,
                "y": ny,
                "w": nw,
                "h": nh
            }
        const hx = pinHx === 0 ? 1 : (pinHx === 1 ? 0 : 0.5)
        const hy = pinHy === 0 ? 1 : (pinHy === 1 ? 0 : 0.5)
        const pinX = nx + nw * hx
        const pinY = ny + nh * hy
        let lo = 0
        let hi = 1
        let best = {
            "x": nx,
            "y": ny,
            "w": Math.max(root.minFrame, nw * 0.5),
            "h": Math.max(root.minFrame, nh * 0.5)
        }
        for (let step = 0; step < 16; ++step) {
            const t = (lo + hi) / 2
            const tw = Math.max(root.minFrame, nw * t)
            const th = Math.max(root.minFrame, nh * t)
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

    function pixelAspect() {
        if (root.aspectRatio <= 0)
            return 0
        return root.aspectRatio
    }

    function clampFrame(nx, ny, nw, nh, pinHx, pinHy) {
        const left = root.clampLeft
        const top = root.clampTop
        const right = root.clampRight
        const bottom = root.clampBottom
        const target = pixelAspect()

        nw = Math.max(root.minFrame, nw)
        nh = Math.max(root.minFrame, nh)
        if (nx < left) {
            nw -= left - nx
            nx = left
        }
        if (ny < top) {
            nh -= top - ny
            ny = top
        }
        if (nx + nw > right)
            nw = right - nx
        if (ny + nh > bottom)
            nh = bottom - ny
        nw = Math.max(root.minFrame, nw)
        nh = Math.max(root.minFrame, nh)
        if (nx + nw > right)
            nx = right - nw
        if (ny + nh > bottom)
            ny = bottom - nh
        nx = Math.max(left, Math.min(nx, right - root.minFrame))
        ny = Math.max(top, Math.min(ny, bottom - root.minFrame))

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
            if (nx < left)
                nx = left
            if (ny < top)
                ny = top
            if (nx + nw > right)
                nx = right - nw
            if (ny + nh > bottom)
                ny = bottom - nh
        }
        return shrinkIntoPhoto(nx, ny, Math.max(root.minFrame, nw), Math.max(root.minFrame, nh), pinHx, pinHy)
    }

    function resizeFromHandle(hx, hy, posX, posY, startX, startY, startW, startH) {
        const left = root.clampLeft
        const top = root.clampTop
        const right = root.clampRight
        const bottom = root.clampBottom
        const startRight = startX + startW
        const startBottom = startY + startH
        let nx = startX
        let ny = startY
        let nw = startW
        let nh = startH

        if (hx === 0) {
            nx = Math.min(Math.max(left, posX), startRight - root.minFrame)
            nw = startRight - nx
        } else if (hx === 1) {
            nw = Math.max(root.minFrame, Math.min(posX, right) - startX)
            nx = startX
        }
        if (hy === 0) {
            ny = Math.min(Math.max(top, posY), startBottom - root.minFrame)
            nh = startBottom - ny
        } else if (hy === 1) {
            nh = Math.max(root.minFrame, Math.min(posY, bottom) - startY)
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
    Component.onCompleted: syncFrameFromCrop()

    MouseArea {
        id: straightenArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        preventStealing: true
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
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
        color: root.dimColor
    }
    Rectangle {
        x: frame.x + frame.width
        y: 0
        width: Math.max(0, root.width - x)
        height: root.height
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: 0
        width: frame.width
        height: Math.max(0, frame.y)
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: frame.y + frame.height
        width: frame.width
        height: Math.max(0, root.height - y)
        color: root.dimColor
    }

    Item {
        id: frame
        clip: false

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true
            preventStealing: true
            cursorShape: rotating ? Qt.ClosedHandCursor : Qt.SizeAllCursor
            property bool rotating: false
            property real startX
            property real startY
            property real originX
            property real originY
            property real originDegrees
            property real originMouseX

            onPressed: function (mouse) {
                rotating = (mouse.modifiers & Qt.AltModifier) !== 0
                if (rotating) {
                    originDegrees = root.straighten
                    originMouseX = mapToItem(root, mouse.x, mouse.y).x
                    return
                }
                root.beginInteraction()
                startX = mouse.x
                startY = mouse.y
                originX = frame.x
                originY = frame.y
            }
            onPositionChanged: function (mouse) {
                if (!pressed)
                    return
                if (rotating) {
                    root.straightenEdited(root.clampedStraighten(originDegrees, originMouseX, mapToItem(root, mouse.x, mouse.y).x))
                    return
                }
                const nextX = Math.min(Math.max(root.clampLeft, originX + mouse.x - startX), root.clampRight - frame.width)
                const nextY = Math.min(Math.max(root.clampTop, originY + mouse.y - startY), root.clampBottom - frame.height)
                const box = root.clampFrame(nextX, nextY, frame.width, frame.height, 0.5, 0.5)
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
            z: 2

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                cursorShape: modelData.cursor
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
