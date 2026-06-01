import QtQuick
import GeoControls 1.0

Item {
    id: root

    // Minimal API
    // Multi-series: [ { label, data: [{x,y}], color, yAxisId: "y-axis-1"|"y-axis-2" } ]
    property var series: []
    // Single-series fallback for easier C++ integration
    property var points: []              // [{x,y}]
    property string seriesLabel: ""
    property color seriesColor: Theme.highlightColor
    property bool useRightAxis: false
    property string title: ""

    // Styling via theme helper
    property color gridColor: Theme.midColor
    property color zeroLineColor: Theme.midlightColor
    property color tickColor: Theme.textColor
    property color legendColor: Theme.textColor
    property color titleColor: Theme.textColor
    property bool legendInteractive: true
    // Sparse map: { "<legendIndex>": true } means hidden.
    property var hiddenLegendIndices: ({})
    readonly property var rawLegendItems: (root.series && root.series.length > 0) ? root.series : ((root.points && root.points.length > 0) ? [
            {
                label: root.seriesLabel,
                color: root.seriesColor
            }
        ] : [])
    readonly property int legendItemCount: (root.rawLegendItems || []).length
    readonly property var visibleLegendIndices: (function () {
            var result = []
            for (var i = 0; i < root.legendItemCount; i++) {
                if (root.isLegendEnabled(i))
                    result.push(i)
            }
            return result
        })()
    readonly property int visibleSeriesCount: root.visibleLegendIndices.length
    readonly property bool allowLegendToggle: root.legendItemCount > 1

    // Appearance
    property int titleFontSize: Fonts.scaledFontPixelSize(14)
    property int legendFontSize: Fonts.scaledFontPixelSize(12)
    property int pointRadius: Fonts.size3
    property int pointStrokeWidth: Fonts.size1
    property int xLabelMinSpacingPx: Fonts.size40
    property int headerChartSpacing: Fonts.size8
    readonly property var legendItems: root.rawLegendItems

    function requestChartPaint() {
        canvas.requestPaint()
    }

    function isValidNumber(value) {
        return value !== null && value !== undefined && !isNaN(Number(value)) && isFinite(Number(value))
    }

    function normalizeYValues(points, targetLen) {
        var source = points || []
        var values = []
        for (var i = 0; i < targetLen; i++) {
            var p = source[i]
            values.push((p && isValidNumber(p.y)) ? Number(p.y) : null)
        }
        return values
    }

    function animateToNewData() {
        requestChartPaint()
    }

    function isLegendEnabled(index) {
        if (!allowLegendToggle)
            return true
        return !hiddenLegendIndices[index]
    }

    function toggleLegendIndex(index) {
        if (!allowLegendToggle)
            return
        var currentlyEnabled = root.isLegendEnabled(index)
        if (currentlyEnabled && root.visibleSeriesCount <= 1)
            return
        var next = {}
        for (var k in hiddenLegendIndices)
            next[k] = hiddenLegendIndices[k]
        if (next[index]) {
            delete next[index]
        } else {
            next[index] = true
        }
        hiddenLegendIndices = next
        requestChartPaint()
    }

    function isolateLegendIndex(index) {
        if (!allowLegendToggle)
            return
        var count = (root.legendItems || []).length
        if (index < 0 || index >= count)
            return
        var hasOtherVisible = false
        for (var i = 0; i < count; i++) {
            if (i !== index && root.isLegendEnabled(i)) {
                hasOtherVisible = true
                break
            }
        }
        if (!hasOtherVisible) {
            hiddenLegendIndices = ({})
            requestChartPaint()
            return
        }
        var next = {}
        for (var j = 0; j < count; j++) {
            if (j !== index)
                next[j] = true
        }
        hiddenLegendIndices = next
        requestChartPaint()
    }

    // Force redraw when theme colors change
    onTitleColorChanged: requestChartPaint()

    // Listen for theme changes
    Connections {
        target: Theme
        function onColorsChanged() {
            root.requestChartPaint()
        }
    }

    // Compute whether a right axis is needed
    readonly property bool needsRightAxis: (series || []).some(function (s) {
        return (s && s.yAxisId === "y-axis-2")
    })

    // Header above canvas to prevent overlap
    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Fonts.size8
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
            width: parent.width
            spacing: Fonts.size8
            visible: root.legendItems && root.legendItems.length > 0

            Repeater {
                model: root.legendItems || []
                delegate: Item {
                    readonly property bool itemEnabled: root.isLegendEnabled(index)
                    opacity: itemEnabled ? 1.0 : 0.45
                    implicitWidth: legendRow.implicitWidth
                    implicitHeight: legendRow.implicitHeight

                    Row {
                        id: legendRow
                        spacing: Fonts.size6

                        Rectangle {
                            width: Fonts.size10
                            height: Fonts.size10
                            radius: Fonts.size2
                            color: String((modelData && modelData.color) ? modelData.color : root.seriesColor)
                        }

                        Text {
                            text: String((modelData && modelData.label !== undefined && modelData.label !== null) ? modelData.label : "")
                            color: root.legendColor
                            font.family: Fonts.standardFont.family
                            font.pixelSize: root.legendFontSize
                            renderType: Text.NativeRendering
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.legendInteractive && root.allowLegendToggle
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.toggleLegendIndex(index)
                        onDoubleClicked: root.isolateLegendIndex(index)
                    }
                }
            }
        }
    }

    CustomChart {
        id: canvas
        anchors.top: header.visible ? header.bottom : parent.top
        anchors.topMargin: header.visible ? root.headerChartSpacing : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        antialiasing: true
        renderTarget: Canvas.FramebufferObject
        xLabelMinSpacingPx: root.xLabelMinSpacingPx

        onPaint: {
            if (width <= 0 || height <= 0)
                return
            // Build series from either multi-series or single-series fallback
            var series = (root.series && root.series.length > 0) ? root.series : (root.points && root.points.length > 0 ? [
                    {
                        label: root.seriesLabel,
                        data: root.points,
                        color: root.seriesColor,
                        yAxisId: (root.useRightAxis ? "y-axis-2" : "y-axis-1")
                    }
                ] : [])
            var maxLen = 0
            for (var i = 0; i < series.length; i++) {
                var pts = (series[i] && series[i].data) ? series[i].data : []
                if (pts.length > maxLen)
                    maxLen = pts.length
            }
            // Build x-axis labels using x-values from the first series (fallback to index)
            var labels = []
            var base = (series.length > 0 && (series[0].data || []).length > 0) ? series[0].data : []
            for (var j = 0; j < maxLen; j++) {
                var xv = (base[j] && base[j].x !== undefined) ? base[j].x : (j + 1)
                labels.push(String(xv))
            }
            var datasets = []
            for (var k = 0; k < series.length; k++) {
                if (!root.isLegendEnabled(k))
                    continue
                var s = series[k] || {}
                var color = String(s.color || Theme.highlightColor)
                datasets.push({
                    data: root.normalizeYValues(s.data, labels.length),
                    strokeColor: "rgba(0,0,0,0)",
                    fillColor: "rgba(0,0,0,0)",
                    pointColor: color,
                    pointStrokeColor: color
                })
            }
            if (datasets.length === 0) {
                var ctx = getContext("2d")
                if (ctx)
                    ctx.clearRect(0, 0, width, height)
                return
            }
            var data = {
                labels: labels,
                datasets: datasets
            }
            var config = {
                animation: false,
                datasetStrokeWidth: 0,
                datasetFill: false,
                pointDot: root.pointRadius > 0,
                pointDotRadius: root.pointRadius,
                pointDotStrokeWidth: root.pointStrokeWidth,
                scaleGridLineColor: String(root.gridColor),
                scaleLineColor: String(root.zeroLineColor),
                scaleFontColor: String(root.tickColor)
            }
            line(data, config)
        }
    }

    onSeriesChanged: requestChartPaint()
    onPointsChanged: requestChartPaint()
    onSeriesLabelChanged: requestChartPaint()
    onSeriesColorChanged: requestChartPaint()
    onUseRightAxisChanged: requestChartPaint()
    onTitleChanged: requestChartPaint()
    onGridColorChanged: requestChartPaint()
    onZeroLineColorChanged: requestChartPaint()
    onTickColorChanged: requestChartPaint()
    onLegendColorChanged: requestChartPaint()
    onPointRadiusChanged: requestChartPaint()
    onPointStrokeWidthChanged: requestChartPaint()
    onXLabelMinSpacingPxChanged: requestChartPaint()
    onHeaderChartSpacingChanged: requestChartPaint()
    onLegendInteractiveChanged: requestChartPaint()
    onHiddenLegendIndicesChanged: requestChartPaint()
}
