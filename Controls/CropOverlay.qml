import QtQuick 2.15
import GeoControls 1.0

Item {
    id: root

    property real cropX: 0
    property real cropY: 0
    property real cropWidth: 1
    property real cropHeight: 1
    property real sourceWidth: parent && parent.implicitWidth > 0 ? parent.implicitWidth : width
    property real sourceHeight: parent && parent.implicitHeight > 0 ? parent.implicitHeight : height
    property color dimColor: Qt.rgba(0, 0, 0, 0.6)
    property color frameColor: Theme.highlightColor
    property int handleSize: 10
    property bool interactive: true

    signal cropCommitted(real x, real y, real width, real height)

    readonly property real imageAspect: sourceWidth / Math.max(sourceHeight, 1)
    readonly property real boxAspect: width / Math.max(height, 1)
    readonly property real contentWidth: boxAspect > imageAspect ? height * imageAspect : width
    readonly property real contentHeight: boxAspect > imageAspect ? height : width / Math.max(imageAspect, 0.0001)
    readonly property real contentX: (width - contentWidth) / 2
    readonly property real contentY: (height - contentHeight) / 2

    function commitFromFrame() {
        const nx = (frame.x - contentX) / Math.max(contentWidth, 1)
        const ny = (frame.y - contentY) / Math.max(contentHeight, 1)
        const nw = frame.width / Math.max(contentWidth, 1)
        const nh = frame.height / Math.max(contentHeight, 1)
        root.cropCommitted(nx, ny, nw, nh)
    }

    function syncFrameFromCrop() {
        if (dragArea.pressed)
            return
        frame.x = root.contentX + root.cropX * root.contentWidth
        frame.y = root.contentY + root.cropY * root.contentHeight
        frame.width = Math.max(8, root.cropWidth * root.contentWidth)
        frame.height = Math.max(8, root.cropHeight * root.contentHeight)
    }

    onCropXChanged: syncFrameFromCrop()
    onCropYChanged: syncFrameFromCrop()
    onCropWidthChanged: syncFrameFromCrop()
    onCropHeightChanged: syncFrameFromCrop()
    onWidthChanged: syncFrameFromCrop()
    onHeightChanged: syncFrameFromCrop()
    Component.onCompleted: syncFrameFromCrop()

    Rectangle {
        x: root.contentX
        y: root.contentY
        width: Math.max(0, frame.x - root.contentX)
        height: root.contentHeight
        color: root.dimColor
    }
    Rectangle {
        x: frame.x + frame.width
        y: root.contentY
        width: Math.max(0, root.contentX + root.contentWidth - x)
        height: root.contentHeight
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: root.contentY
        width: frame.width
        height: Math.max(0, frame.y - root.contentY)
        color: root.dimColor
    }
    Rectangle {
        x: frame.x
        y: frame.y + frame.height
        width: frame.width
        height: Math.max(0, root.contentY + root.contentHeight - y)
        color: root.dimColor
    }

    Rectangle {
        id: frame
        color: "transparent"
        border.color: root.frameColor
        border.width: 2

        MouseArea {
            id: dragArea
            anchors.fill: parent
            enabled: root.interactive
            cursorShape: Qt.SizeAllCursor
            property real startX
            property real startY
            property real originX
            property real originY
            onPressed: function (mouse) {
                startX = mouse.x
                startY = mouse.y
                originX = frame.x
                originY = frame.y
            }
            onPositionChanged: function (mouse) {
                if (!pressed)
                    return
                const nextX = Math.min(Math.max(root.contentX, originX + mouse.x - startX), root.contentX + root.contentWidth - frame.width)
                const nextY = Math.min(Math.max(root.contentY, originY + mouse.y - startY), root.contentY + root.contentHeight - frame.height)
                frame.x = nextX
                frame.y = nextY
            }
            onReleased: root.commitFromFrame()
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
                "hx": 1,
                "hy": 0,
                "cursor": Qt.SizeBDiagCursor
            },
            {
                "hx": 0,
                "hy": 1,
                "cursor": Qt.SizeBDiagCursor
            },
            {
                "hx": 1,
                "hy": 1,
                "cursor": Qt.SizeFDiagCursor
            }
        ]
        delegate: Rectangle {
            required property var modelData
            width: root.handleSize
            height: root.handleSize
            radius: 2
            color: root.frameColor
            x: frame.x + modelData.hx * frame.width - width / 2
            y: frame.y + modelData.hy * frame.height - height / 2
            visible: root.interactive

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: modelData.cursor
                property real startMouseX
                property real startMouseY
                property real startFrameX
                property real startFrameY
                property real startFrameW
                property real startFrameH
                onPressed: function (mouse) {
                    const pos = mapToItem(root, mouse.x, mouse.y)
                    startMouseX = pos.x
                    startMouseY = pos.y
                    startFrameX = frame.x
                    startFrameY = frame.y
                    startFrameW = frame.width
                    startFrameH = frame.height
                }
                onPositionChanged: function (mouse) {
                    if (!pressed)
                        return
                    const pos = mapToItem(root, mouse.x, mouse.y)
                    const dx = pos.x - startMouseX
                    const dy = pos.y - startMouseY
                    let nx = startFrameX
                    let ny = startFrameY
                    let nw = startFrameW
                    let nh = startFrameH
                    if (modelData.hx === 0) {
                        nx = Math.min(startFrameX + dx, startFrameX + startFrameW - 8)
                        nw = startFrameW - (nx - startFrameX)
                    } else {
                        nw = Math.max(8, startFrameW + dx)
                    }
                    if (modelData.hy === 0) {
                        ny = Math.min(startFrameY + dy, startFrameY + startFrameH - 8)
                        nh = startFrameH - (ny - startFrameY)
                    } else {
                        nh = Math.max(8, startFrameH + dy)
                    }
                    const minX = root.contentX
                    const minY = root.contentY
                    const maxX = root.contentX + root.contentWidth
                    const maxY = root.contentY + root.contentHeight
                    nx = Math.max(minX, nx)
                    ny = Math.max(minY, ny)
                    nw = Math.min(nw, maxX - nx)
                    nh = Math.min(nh, maxY - ny)
                    frame.x = nx
                    frame.y = ny
                    frame.width = nw
                    frame.height = nh
                }
                onReleased: root.commitFromFrame()
            }
        }
    }
}
