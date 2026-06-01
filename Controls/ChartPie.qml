import QtQuick
import QtQuick.Layouts
import GeoControls 1.0

Item {
    id: root

    property var labels: []
    property var values: []
    property string seriesLabel: ""
    property string title: ""
    property var colors: ["#FF6384", "#36A2EB", "#FFCD56", "#4BC0C0", "#9966FF", "#FF9F40"]
    // "vertical" or "horizontal"
    property string layoutMode: "vertical"

    property int chartPadding: Fonts.size8
    property string centerTopText: ""
    property string centerBottomText: ""

    property color legendColor: Theme.textColor
    property color titleColor: Theme.textColor

    property int titleFontSize: Fonts.scaledFontPixelSize(14)
    property int legendFontSize: Fonts.scaledFontPixelSize(12)
    readonly property var legendItems: (function () {
            var items = []
            var count = root.legendCount()
            for (var i = 0; i < count; i++) {
                items.push({
                    label: String((root.labels && root.labels[i] !== undefined) ? root.labels[i] : (i + 1)),
                    color: root.colorAt(i)
                })
            }
            return items
        })()

    function isValidNumber(value) {
        return value !== null && value !== undefined && !isNaN(Number(value)) && isFinite(Number(value))
    }

    function normalizedValue(value) {
        if (!isValidNumber(value))
            return 0
        var n = Number(value)
        return n > 0 ? n : 0
    }

    function legendCount() {
        var labelsLen = (root.labels || []).length
        var valuesLen = (root.values || []).length
        return Math.max(labelsLen, valuesLen)
    }

    function colorAt(index) {
        var palette = root.colors || []
        if (palette.length <= 0)
            return String(Theme.highlightColor)
        var c = palette[index % palette.length]
        return String(c !== undefined && c !== null ? c : Theme.highlightColor)
    }

    function requestPaintSafe() {
        if (canvas)
            canvas.requestPaint()
    }

    function animateToNewData() {
        requestPaintSafe()
    }

    onValuesChanged: requestPaintSafe()
    onColorsChanged: requestPaintSafe()
    onChartPaddingChanged: requestPaintSafe()
    onLayoutModeChanged: requestPaintSafe()
    onTitleColorChanged: requestPaintSafe()

    Connections {
        target: Theme
        function onColorsChanged() {
            requestPaintSafe()
        }
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size2
        columns: root.layoutMode === "horizontal" ? 2 : 1
        rowSpacing: Fonts.size4
        columnSpacing: Fonts.size8

        Item {
            id: chartContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: root.layoutMode === "horizontal" ? Math.max(120, root.width * 0.45) : -1
            Layout.preferredHeight: root.layoutMode === "horizontal" ? -1 : Math.max(110, root.height * 0.65)

            CustomChart {
                id: canvas
                anchors.fill: parent
                anchors.margins: Math.max(4, root.chartPadding - 8)
                antialiasing: true
                renderTarget: Canvas.FramebufferObject

                onPaint: {
                    if (width <= 0 || height <= 0)
                        return
                    var vals = root.values || []
                    var segments = []
                    var total = 0
                    for (var i = 0; i < vals.length; i++) {
                        var v = root.normalizedValue(vals[i])
                        total += v
                        segments.push({
                            value: v,
                            color: root.colorAt(i)
                        })
                    }
                    if (total <= 0) {
                        var ctx = getContext("2d")
                        if (ctx)
                            ctx.clearRect(0, 0, width, height)
                        return
                    }
                    doughnut(segments, {
                        animation: false
                    })
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: Fonts.size4
                visible: (root.centerTopText.length > 0 || root.centerBottomText.length > 0)

                Text {
                    visible: root.centerTopText.length > 0
                    color: root.legendColor
                    font: Fonts.standardFont
                    horizontalAlignment: Text.AlignHCenter
                    text: root.centerTopText
                }

                Text {
                    visible: root.centerBottomText.length > 0
                    color: root.legendColor
                    font: Fonts.standardFont
                    horizontalAlignment: Text.AlignHCenter
                    text: root.centerBottomText
                }
            }
        }

        Column {
            id: legendContainer
            Layout.fillWidth: true
            Layout.fillHeight: root.layoutMode === "horizontal"
            Layout.alignment: root.layoutMode === "horizontal" ? (Qt.AlignLeft | Qt.AlignVCenter) : Qt.AlignTop
            spacing: Fonts.size6
            visible: (root.title && root.title.length > 0) || (root.legendItems && root.legendItems.length > 0)

            Text {
                visible: root.title && root.title.length > 0
                text: root.title
                color: root.titleColor
                font.family: Fonts.standardFont.family
                font.pixelSize: root.titleFontSize
                font.bold: true
                renderType: Text.NativeRendering
            }

            Flow {
                width: legendContainer.width
                spacing: Fonts.size8
                visible: root.legendItems && root.legendItems.length > 0

                Repeater {
                    model: root.legendItems || []
                    delegate: Item {
                        implicitWidth: legendRow.implicitWidth
                        implicitHeight: legendRow.implicitHeight

                        Row {
                            id: legendRow
                            spacing: Fonts.size6

                            Rectangle {
                                width: Fonts.size10
                                height: Fonts.size10
                                radius: Fonts.size2
                                color: String((modelData && modelData.color) ? modelData.color : Theme.highlightColor)
                            }

                            Text {
                                text: String((modelData && modelData.label !== undefined && modelData.label !== null) ? modelData.label : "")
                                color: root.legendColor
                                font.family: Fonts.standardFont.family
                                font.pixelSize: root.legendFontSize
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
