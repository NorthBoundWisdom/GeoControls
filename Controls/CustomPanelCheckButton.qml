import QtQuick 2.15
import GeoToy.Controls 1.0

CustomPanelIconButton {
    id: control

    property int checkSize: Fonts.size12
    property real checkLineWidthFactor: 0.16

    contentItem: Item {
        Canvas {
            id: checkCanvas
            anchors.centerIn: parent
            width: control.checkSize
            height: control.checkSize

            function repaint() {
                requestPaint();
            }

            onWidthChanged: repaint()
            onHeightChanged: repaint()
            Component.onCompleted: repaint()
            Connections {
                target: control

                function onEnabledChanged() {
                    checkCanvas.repaint();
                }

                function onPressedChanged() {
                    checkCanvas.repaint();
                }

                function onButtonTextColorChanged() {
                    checkCanvas.repaint();
                }

                function onDisabledTextColorChanged() {
                    checkCanvas.repaint();
                }

                function onHighlightedTextColorChanged() {
                    checkCanvas.repaint();
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = !control.enabled ? control.disabledTextColor : control.pressed ? control.highlightedTextColor : control.buttonTextColor;
                ctx.lineWidth = Math.max(1.8, width * control.checkLineWidthFactor);
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.beginPath();
                ctx.moveTo(width * 0.14, height * 0.56);
                ctx.lineTo(width * 0.40, height * 0.82);
                ctx.lineTo(width * 0.88, height * 0.18);
                ctx.stroke();
            }
        }
    }
}
