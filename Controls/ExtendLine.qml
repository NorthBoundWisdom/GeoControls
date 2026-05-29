import QtQuick 2.15

Rectangle {
    id: extendLine

    visible: false
    color: "transparent"

    property real lineX: 0
    property real lineY: 0

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = "#00FF00"
            ctx.lineWidth = 1
            ctx.setLineDash([5, 3])
            ctx.beginPath()
            ctx.moveTo(lineX, 0)
            ctx.lineTo(lineX, height)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(0, lineY)
            ctx.lineTo(width, lineY)
            ctx.stroke()
        }
    }

    onLineXChanged: {
        canvas.requestPaint()
    }
    onLineYChanged: {
        canvas.requestPaint()
    }
    onVisibleChanged: {
        if (visible)
            canvas.requestPaint()
    }
}
