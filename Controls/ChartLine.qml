import QtQuick
import GeoToy.Controls 1.0

Item {
    id: root

    // Minimal data API
    property var labels: []
    property var values: [] // single-series fallback
    // Multi-series: [{ label: string, values: [], color: color }]
    property var series: []
    property string seriesLabel: ""
    property string title: ""
    property color lineColor: Theme.highlightColor
    property int lineWidth: Fonts.size2
    property int pointRadius: Fonts.size3
    property bool connectMissingWithDashed: true
    property var missingDashPattern: [1, 3]
    property int missingLineWidth: Math.max(1, root.lineWidth)
    property real missingLineOpacity: 0.9
    property bool fill: false
    property double tension: 0.1
    property int xLabelMinSpacingPx: Fonts.size40
    // Optional fixed Y-axis range
    property var yMin: undefined
    property var yMax: undefined
    property int ySteps: 10

    // Axis and legend styling for dark theme
    property color gridColor: Theme.midColor
    property color zeroLineColor: Theme.midlightColor
    property color tickColor: Theme.textColor
    property color legendColor: Theme.textColor
    property color titleColor: Theme.textColor
    property bool legendInteractive: true
    // Sparse map: { "<legendIndex>": true } means hidden.
    property var hiddenLegendIndices: ({})
    readonly property var rawLegendItems: (root.series && root.series.length > 0) ? root.series : ((root.seriesLabel && root.seriesLabel.length > 0) ? [
            {
                label: root.seriesLabel,
                color: root.lineColor
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
    property int headerChartSpacing: Fonts.size8
    readonly property var legendItems: (function () {
            var items = []
            var base = root.rawLegendItems || []
            for (var i = 0; i < base.length; i++) {
                var item = base[i] || {}
                items.push({
                    label: String(item.label || ""),
                    color: String(item.color || root.lineColor),
                    enabled: root.isLegendEnabled(i)
                })
            }
            return items
        })()

    function requestChartPaint() {
        canvas.requestPaint()
    }

    function isValidNumber(value) {
        return value !== null && value !== undefined && !isNaN(Number(value)) && isFinite(Number(value))
    }

    function normalizeSeriesValues(values, targetLen) {
        var source = values || []
        var result = []
        for (var i = 0; i < targetLen; i++) {
            var v = source[i]
            result.push(isValidNumber(v) ? Number(v) : null)
        }
        return result
    }

    function normalizedLabelsFrom(input, fallbackLen, useIndexFallback) {
        var result = []
        var hasInput = (input && input.length > 0)
        var length = hasInput ? input.length : fallbackLen
        for (var i = 0; i < length; i++) {
            if (hasInput) {
                result.push(String(input[i] !== undefined && input[i] !== null ? input[i] : ""))
            } else {
                result.push(useIndexFallback ? String(i + 1) : "")
            }
        }
        return result
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

    // Header placed above the chart area to avoid overlap
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
                    readonly property bool itemEnabled: !(modelData && modelData.enabled === false)
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
                            color: String((modelData && modelData.color) ? modelData.color : root.lineColor)
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
            var useMulti = (root.series && root.series.length > 0)
            var datasets = []
            var labels = []
            if (useMulti) {
                var maxLen = 0
                for (var i = 0; i < root.series.length; i++) {
                    var s = root.series[i] || {}
                    var arr = s.values || []
                    if (arr.length > maxLen)
                        maxLen = arr.length
                }
                labels = root.normalizedLabelsFrom(root.labels, maxLen, false)
                for (var j = 0; j < root.series.length; j++) {
                    if (!root.isLegendEnabled(j))
                        continue
                    var si = root.series[j] || {}
                    var color = String(si.color || Theme.highlightColor)
                    datasets.push({
                        data: root.normalizeSeriesValues(si.values, labels.length),
                        strokeColor: color,
                        fillColor: root.fill ? color : "rgba(0,0,0,0)",
                        pointColor: color,
                        pointStrokeColor: color
                    })
                }
            } else {
                var baseValues = root.values || []
                labels = root.normalizedLabelsFrom(root.labels, baseValues.length, true)
                if (root.isLegendEnabled(0)) {
                    datasets = [
                        {
                            data: root.normalizeSeriesValues(baseValues, labels.length),
                            strokeColor: String(root.lineColor),
                            fillColor: root.fill ? String(root.lineColor) : "rgba(0,0,0,0)",
                            pointColor: String(root.lineColor),
                            pointStrokeColor: String(root.lineColor)
                        }
                    ]
                } else {
                    datasets = []
                }
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
                datasetStrokeWidth: root.lineWidth,
                datasetFill: root.fill,
                bezierCurve: root.tension > 0,
                scaleGridLineColor: String(root.gridColor),
                scaleLineColor: String(root.zeroLineColor),
                scaleFontColor: String(root.tickColor),
                pointDot: root.pointRadius > 0,
                pointDotRadius: root.pointRadius,
                pointDotStrokeWidth: 1,
                spanGapsDashed: root.connectMissingWithDashed,
                spanGapsDashPattern: root.missingDashPattern,
                spanGapsStrokeWidth: root.missingLineWidth,
                spanGapsAlpha: root.missingLineOpacity,
                scaleFontSize: 12
            }
            var minY = Number(root.yMin)
            var maxY = Number(root.yMax)
            var steps = Number(root.ySteps)
            var stepCount = Math.floor(steps)
            var useFixed = root.isValidNumber(minY) && root.isValidNumber(maxY) && root.isValidNumber(steps) && stepCount >= 1 && maxY > minY
            if (useFixed) {
                config.scaleOverride = true
                config.scaleSteps = stepCount
                config.scaleStartValue = minY
                config.scaleStepWidth = (maxY - minY) / config.scaleSteps
            }
            line(data, config)
        }
    }

    onLabelsChanged: requestChartPaint()
    onValuesChanged: requestChartPaint()
    onSeriesChanged: requestChartPaint()
    onSeriesLabelChanged: requestChartPaint()
    onTitleChanged: requestChartPaint()
    onLineColorChanged: requestChartPaint()
    onLineWidthChanged: requestChartPaint()
    onPointRadiusChanged: requestChartPaint()
    onConnectMissingWithDashedChanged: requestChartPaint()
    onMissingDashPatternChanged: requestChartPaint()
    onMissingLineWidthChanged: requestChartPaint()
    onMissingLineOpacityChanged: requestChartPaint()
    onFillChanged: requestChartPaint()
    onTensionChanged: requestChartPaint()
    onYMinChanged: requestChartPaint()
    onYMaxChanged: requestChartPaint()
    onYStepsChanged: requestChartPaint()
    onGridColorChanged: requestChartPaint()
    onZeroLineColorChanged: requestChartPaint()
    onTickColorChanged: requestChartPaint()
    onXLabelMinSpacingPxChanged: requestChartPaint()
    onHeaderChartSpacingChanged: requestChartPaint()
    onLegendInteractiveChanged: requestChartPaint()
    onHiddenLegendIndicesChanged: requestChartPaint()
}
