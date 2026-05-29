import QtQuick 2.15

Rectangle {
    id: selectionBox

    visible: false
    color: "transparent"

    property color strokeColor: Theme.textColor
    property color fillColor: Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.08)

    Canvas {
        id: canvas
        anchors.fill: parent

        Connections {
            target: Theme
            function onTextColorChanged() {
                canvas.requestPaint();
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            ctx.strokeStyle = selectionBox.strokeColor;
            ctx.lineWidth = 1;
            ctx.setLineDash([5, 3]);
            ctx.strokeRect(0, 0, width, height);

            ctx.fillStyle = selectionBox.fillColor;
            ctx.fillRect(0, 0, width, height);
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onVisibleChanged: if (visible)
        canvas.requestPaint()
    onStrokeColorChanged: canvas.requestPaint()
    onFillColorChanged: canvas.requestPaint()
}
