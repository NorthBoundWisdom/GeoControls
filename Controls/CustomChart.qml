import GeoToy.Controls 1.0
/*!
 * Changed from https://github.com/qyvlik/Chart.qml/blob/master/Chart.qml
 */

import QtQuick 2.15

Canvas {
    // Minimum horizontal pixel spacing between adjacent visible X-axis labels/gridlines.
    // Increase to reduce density. Can be overridden by the caller.
    property int xLabelMinSpacingPx: Fonts.size40
    readonly property string canvasFontFamily: buildCanvasFontFamily(Fonts.standardFont.family)

    function quoteCanvasFamily(family) {
        var raw = String(family || "").trim();
        if (raw.length === 0)
            return "\"sans-serif\"";
        var escaped = raw.replace(/\\/g, "\\\\").replace(/"/g, "\\\"");
        return "\"" + escaped + "\"";
    }

    function normalizeFamilyName(name) {
        var raw = String(name || "").trim();
        return raw;
    }

    function buildCanvasFontFamily(primaryFamily) {
        var name = normalizeFamilyName(primaryFamily);
        if (name.length === 0)
            name = "Noto Sans Mono CJK SC";
        return quoteCanvasFamily(name);
    }

    function polarArea(data, option) {
        return new __chart(getContext('2d')).PolarArea(data, option);
    }

    function radar(data, option) {
        return new __chart(getContext('2d')).Radar(data, option);
    }

    function pie(data, option) {
        return new __chart(getContext('2d')).Pie(data, option);
    }

    function doughnut(data, option) {
        return new __chart(getContext('2d')).Doughnut(data, option);
    }

    function line(data, option) {
        return new __chart(getContext('2d')).Line(data, option);
    }

    function bar(data, option) {
        return new __chart(getContext('2d')).Bar(data, option);
    }

    function __chart(context) {
        var chart = this;

        //Easing functions adapted from Robert Penner's easing equations
        //http://www.robertpenner.com/easing/

        var animationOptions = {
            linear: function (t) {
                return t;
            },
            easeInQuad: function (t) {
                return t * t;
            },
            easeOutQuad: function (t) {
                return -1 * t * (t - 2);
            },
            easeInOutQuad: function (t) {
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * t * t;
                return -1 / 2 * ((--t) * (t - 2) - 1);
            },
            easeInCubic: function (t) {
                return t * t * t;
            },
            easeOutCubic: function (t) {
                return 1 * ((t = t / 1 - 1) * t * t + 1);
            },
            easeInOutCubic: function (t) {
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * t * t * t;
                return 1 / 2 * ((t -= 2) * t * t + 2);
            },
            easeInQuart: function (t) {
                return t * t * t * t;
            },
            easeOutQuart: function (t) {
                return -1 * ((t = t / 1 - 1) * t * t * t - 1);
            },
            easeInOutQuart: function (t) {
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * t * t * t * t;
                return -1 / 2 * ((t -= 2) * t * t * t - 2);
            },
            easeInQuint: function (t) {
                return 1 * (t /= 1) * t * t * t * t;
            },
            easeOutQuint: function (t) {
                return 1 * ((t = t / 1 - 1) * t * t * t * t + 1);
            },
            easeInOutQuint: function (t) {
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * t * t * t * t * t;
                return 1 / 2 * ((t -= 2) * t * t * t * t + 2);
            },
            easeInSine: function (t) {
                return -1 * Math.cos(t / 1 * (Math.PI / 2)) + 1;
            },
            easeOutSine: function (t) {
                return 1 * Math.sin(t / 1 * (Math.PI / 2));
            },
            easeInOutSine: function (t) {
                return -1 / 2 * (Math.cos(Math.PI * t / 1) - 1);
            },
            easeInExpo: function (t) {
                return (t == 0) ? 1 : 1 * Math.pow(2, 10 * (t / 1 - 1));
            },
            easeOutExpo: function (t) {
                return (t == 1) ? 1 : 1 * (-Math.pow(2, -10 * t / 1) + 1);
            },
            easeInOutExpo: function (t) {
                if (t == 0)
                    return 0;
                if (t == 1)
                    return 1;
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * Math.pow(2, 10 * (t - 1));
                return 1 / 2 * (-Math.pow(2, -10 * --t) + 2);
            },
            easeInCirc: function (t) {
                if (t >= 1)
                    return t;
                return -1 * (Math.sqrt(1 - (t /= 1) * t) - 1);
            },
            easeOutCirc: function (t) {
                return 1 * Math.sqrt(1 - (t = t / 1 - 1) * t);
            },
            easeInOutCirc: function (t) {
                if ((t /= 1 / 2) < 1)
                    return -1 / 2 * (Math.sqrt(1 - t * t) - 1);
                return 1 / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1);
            },
            easeInElastic: function (t) {
                var s = 1.70158;
                var p = 0;
                var a = 1;
                if (t == 0)
                    return 0;
                if ((t /= 1) == 1)
                    return 1;
                if (!p)
                    p = 1 * .3;
                if (a < Math.abs(1)) {
                    a = 1;
                    var s = p / 4;
                } else
                    var s = p / (2 * Math.PI) * Math.asin(1 / a);
                return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * 1 - s) * (2 * Math.PI) / p));
            },
            easeOutElastic: function (t) {
                var s = 1.70158;
                var p = 0;
                var a = 1;
                if (t == 0)
                    return 0;
                if ((t /= 1) == 1)
                    return 1;
                if (!p)
                    p = 1 * .3;
                if (a < Math.abs(1)) {
                    a = 1;
                    var s = p / 4;
                } else
                    var s = p / (2 * Math.PI) * Math.asin(1 / a);
                return a * Math.pow(2, -10 * t) * Math.sin((t * 1 - s) * (2 * Math.PI) / p) + 1;
            },
            easeInOutElastic: function (t) {
                var s = 1.70158;
                var p = 0;
                var a = 1;
                if (t == 0)
                    return 0;
                if ((t /= 1 / 2) == 2)
                    return 1;
                if (!p)
                    p = 1 * (.3 * 1.5);
                if (a < Math.abs(1)) {
                    a = 1;
                    var s = p / 4;
                } else
                    var s = p / (2 * Math.PI) * Math.asin(1 / a);
                if (t < 1)
                    return -.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * 1 - s) * (2 * Math.PI) / p));
                return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * 1 - s) * (2 * Math.PI) / p) * .5 + 1;
            },
            easeInBack: function (t) {
                var s = 1.70158;
                return 1 * (t /= 1) * t * ((s + 1) * t - s);
            },
            easeOutBack: function (t) {
                var s = 1.70158;
                return 1 * ((t = t / 1 - 1) * t * ((s + 1) * t + s) + 1);
            },
            easeInOutBack: function (t) {
                var s = 1.70158;
                if ((t /= 1 / 2) < 1)
                    return 1 / 2 * (t * t * (((s *= (1.525)) + 1) * t - s));
                return 1 / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2);
            },
            easeInBounce: function (t) {
                return 1 - animationOptions.easeOutBounce(1 - t);
            },
            easeOutBounce: function (t) {
                if ((t /= 1) < (1 / 2.75)) {
                    return 1 * (7.5625 * t * t);
                } else if (t < (2 / 2.75)) {
                    return 1 * (7.5625 * (t -= (1.5 / 2.75)) * t + .75);
                } else if (t < (2.5 / 2.75)) {
                    return 1 * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375);
                } else {
                    return 1 * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375);
                }
            },
            easeInOutBounce: function (t) {
                if (t < 1 / 2)
                    return animationOptions.easeInBounce(t * 2) * .5;
                return animationOptions.easeOutBounce(t * 2 - 1) * .5 + 1 * .5;
            }
        };//Y

        //Variables global to the chart
        var width = context.canvas.width;
        var height = context.canvas.height;

        // ![0]
        /* // remove this block , because the qml haven't window object
        //High pixel density displays - multiply the size of the canvas height/width by the device pixel ratio, then scale.
        if (window.devicePixelRatio) {
            context.canvas.style.width = width + "px";
            context.canvas.style.height = height + "px";
            context.canvas.height = height * window.devicePixelRatio;
            context.canvas.width = width * window.devicePixelRatio;
            context.scale(window.devicePixelRatio, window.devicePixelRatio);
        }
        //*/
        // ![1]

        this.PolarArea = function (data, options) {
            chart.PolarArea.defaults = {
                scaleOverlay: true,
                scaleOverride: false,
                scaleSteps: null,
                scaleStepWidth: null,
                scaleStartValue: null,
                scaleShowLine: true,
                scaleLineColor: String(Theme.midlightColor),
                scaleLineWidth: 1,
                scaleShowLabels: true,
                scaleLabel: "<%=value%>",
                scaleFontFamily: context.canvas.canvasFontFamily,
                scaleFontSize: 12,
                scaleFontStyle: "normal",
                scaleFontColor: String(Theme.textColor),
                scaleShowLabelBackdrop: true,
                scaleBackdropColor: "rgba(255,255,255,0.75)",
                scaleBackdropPaddingY: 2,
                scaleBackdropPaddingX: 2,
                segmentShowStroke: true,
                segmentStrokeColor: "#fff",
                segmentStrokeWidth: 2,
                animation: true,
                animationSteps: 100,
                animationEasing: "easeOutBounce",
                animateRotate: true,
                animateScale: false,
                onAnimationComplete: null
            };

            var config = (options) ? mergeChartConfig(chart.PolarArea.defaults, options) : chart.PolarArea.defaults;

            return new PolarArea(data, config, context);
        };

        this.Radar = function (data, options) {
            chart.Radar.defaults = {
                scaleOverlay: false,
                scaleOverride: false,
                scaleSteps: null,
                scaleStepWidth: null,
                scaleStartValue: null,
                scaleShowLine: true,
                scaleLineColor: String(Theme.midlightColor),
                scaleLineWidth: 1,
                scaleShowLabels: false,
                scaleLabel: "<%=value%>",
                scaleFontFamily: context.canvas.canvasFontFamily,
                scaleFontSize: 12,
                scaleFontStyle: "normal",
                scaleFontColor: String(Theme.textColor),
                scaleShowLabelBackdrop: true,
                scaleBackdropColor: "rgba(255,255,255,0.75)",
                scaleBackdropPaddingY: 2,
                scaleBackdropPaddingX: 2,
                angleShowLineOut: true,
                angleLineColor: "rgba(0,0,0,.1)",
                angleLineWidth: 1,
                pointLabelFontFamily: context.canvas.canvasFontFamily,
                pointLabelFontStyle: "normal",
                pointLabelFontSize: 12,
                pointLabelFontColor: "#666",
                pointDot: true,
                pointDotRadius: 3,
                pointDotStrokeWidth: 1,
                datasetStroke: true,
                datasetStrokeWidth: 2,
                datasetFill: true,
                // Draw straight dashed bridges across null/undefined gaps.
                spanGapsDashed: false,
                spanGapsDashPattern: [1, 3],
                spanGapsStrokeWidth: null,
                spanGapsAlpha: 0.65,
                animation: true,
                animationSteps: 60,
                animationEasing: "easeOutQuart",
                onAnimationComplete: null
            };

            var config = (options) ? mergeChartConfig(chart.Radar.defaults, options) : chart.Radar.defaults;

            return new Radar(data, config, context);
        };

        this.Pie = function (data, options) {
            chart.Pie.defaults = {
                segmentShowStroke: true,
                segmentStrokeColor: "#fff",
                segmentStrokeWidth: 2,
                animation: true,
                animationSteps: 100,
                animationEasing: "easeOutBounce",
                animateRotate: true,
                animateScale: false,
                onAnimationComplete: null
            };

            var config = (options) ? mergeChartConfig(chart.Pie.defaults, options) : chart.Pie.defaults;

            return new Pie(data, config, context);
        };

        this.Doughnut = function (data, options) {
            chart.Doughnut.defaults = {
                segmentShowStroke: true,
                segmentStrokeColor: "#fff",
                segmentStrokeWidth: 2,
                percentageInnerCutout: 50,
                animation: true,
                animationSteps: 100,
                animationEasing: "easeOutBounce",
                animateRotate: true,
                animateScale: false,
                onAnimationComplete: null
            };

            var config = (options) ? mergeChartConfig(chart.Doughnut.defaults, options) : chart.Doughnut.defaults;

            return new Doughnut(data, config, context);
        };

        this.Line = function (data, options) {
            chart.Line.defaults = {
                scaleOverlay: false,
                scaleOverride: false,
                scaleSteps: null,
                scaleStepWidth: null,
                scaleStartValue: null,
                scaleLineColor: String(Theme.midlightColor),
                scaleLineWidth: 1,
                scaleShowLabels: true,
                scaleLabel: "<%=value%>",
                scaleFontFamily: context.canvas.canvasFontFamily,
                scaleFontSize: 12,
                scaleFontStyle: "normal",
                scaleFontColor: String(Theme.textColor),
                scaleShowGridLines: true,
                scaleGridLineColor: String(Theme.midColor),
                scaleGridLineWidth: 1,
                bezierCurve: true,
                pointDot: true,
                pointDotRadius: 4,
                pointDotStrokeWidth: 2,
                datasetStroke: true,
                datasetStrokeWidth: 2,
                datasetFill: true,
                animation: true,
                animationSteps: 60,
                animationEasing: "easeOutQuart",
                onAnimationComplete: null
            };
            var config = (options) ? mergeChartConfig(chart.Line.defaults, options) : chart.Line.defaults;

            return new Line(data, config, context);
        };

        this.Bar = function (data, options) {
            chart.Bar.defaults = {
                scaleOverlay: false,
                scaleOverride: false,
                scaleSteps: null,
                scaleStepWidth: null,
                scaleStartValue: null,
                scaleLineColor: String(Theme.midlightColor),
                scaleLineWidth: 1,
                scaleShowLabels: true,
                scaleLabel: "<%=value%>",
                scaleFontFamily: context.canvas.canvasFontFamily,
                scaleFontSize: 12,
                scaleFontStyle: "normal",
                scaleFontColor: String(Theme.textColor),
                scaleShowGridLines: true,
                scaleGridLineColor: String(Theme.midColor),
                scaleGridLineWidth: 1,
                barShowStroke: true,
                barStrokeWidth: 2,
                barValueSpacing: 5,
                barDatasetSpacing: 1,
                animation: true,
                animationSteps: 60,
                animationEasing: "easeOutQuart",
                onAnimationComplete: null
            };
            var config = (options) ? mergeChartConfig(chart.Bar.defaults, options) : chart.Bar.defaults;

            return new Bar(data, config, context);
        };

        var clear = function (c) {
            c.clearRect(0, 0, width, height);
        };

        function PolarArea(data, config, ctx) {
            var maxSize, scaleHop, calculatedScale, labelHeight, scaleHeight, valueBounds, labelTemplateString;

            calculateDrawingSizes();

            valueBounds = getValueBounds();

            labelTemplateString = (config.scaleShowLabels) ? config.scaleLabel : null;

            //Check and set the scale
            if (!config.scaleOverride) {
                calculatedScale = calculateScale(scaleHeight, valueBounds.maxSteps, valueBounds.minSteps, valueBounds.maxValue, valueBounds.minValue, labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                };
                for (var i = 1; i <= calculatedScale.steps; i++) {
                    if (labelTemplateString) {
                        calculatedScale.labels.push(tmpl(labelTemplateString, {
                            value: (config.scaleStartValue + (config.scaleStepWidth * i)).toFixed(getDecimalPlaces(config.scaleStepWidth))
                        }));
                    }
                }
            }

            scaleHop = maxSize / (calculatedScale.steps);

            //Wrap in an animation loop wrapper
            animationLoop(config, drawScale, drawAllSegments, ctx);

            function calculateDrawingSizes() {
                maxSize = (Min([width, height]) / 2);
                //Remove whatever is larger - the font size or line width.

                maxSize -= Max([config.scaleFontSize * 0.5, config.scaleLineWidth * 0.5]);

                labelHeight = config.scaleFontSize * 2;
                //If we're drawing the backdrop - add the Y padding to the label height and remove from drawing region.
                if (config.scaleShowLabelBackdrop) {
                    labelHeight += (2 * config.scaleBackdropPaddingY);
                    maxSize -= config.scaleBackdropPaddingY * 1.5;
                }

                scaleHeight = maxSize;
                //If the label height is less than 5, set it to 5 so we don't have lines on top of each other.
                labelHeight = Default(labelHeight, 5);
            }
            function drawScale() {
                for (var i = 0; i < calculatedScale.steps; i++) {
                    //If the line object is there
                    if (config.scaleShowLine) {
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2, scaleHop * (i + 1), 0, (Math.PI * 2), true);
                        ctx.strokeStyle = config.scaleLineColor;
                        ctx.lineWidth = config.scaleLineWidth;
                        ctx.stroke();
                    }

                    if (config.scaleShowLabels) {
                        ctx.textAlign = "center";
                        ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                        var label = calculatedScale.labels[i];
                        //If the backdrop object is within the font object
                        if (config.scaleShowLabelBackdrop) {
                            var textWidth = ctx.measureText(label).width;
                            ctx.fillStyle = config.scaleBackdropColor;
                            ctx.beginPath();
                            ctx.rect(Math.round(width / 2 - textWidth / 2 - config.scaleBackdropPaddingX)     //X
                            , Math.round(height / 2 - (scaleHop * (i + 1)) - config.scaleFontSize * 0.5 - config.scaleBackdropPaddingY)//Y
                            , Math.round(textWidth + (config.scaleBackdropPaddingX * 2)) //Width
                            , Math.round(config.scaleFontSize + (config.scaleBackdropPaddingY * 2)) //Height
                            );
                            ctx.fill();
                        }
                        ctx.textBaseline = "middle";
                        ctx.fillStyle = config.scaleFontColor;
                        ctx.fillText(label, width / 2, height / 2 - (scaleHop * (i + 1)));
                    }
                }
            }
            function drawAllSegments(animationDecimal) {
                var startAngle = -Math.PI / 2, angleStep = (Math.PI * 2) / data.length, scaleAnimation = 1, rotateAnimation = 1;
                if (config.animation) {
                    if (config.animateScale) {
                        scaleAnimation = animationDecimal;
                    }
                    if (config.animateRotate) {
                        rotateAnimation = animationDecimal;
                    }
                }

                for (var i = 0; i < data.length; i++) {
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, scaleAnimation * calculateOffset(data[i].value, calculatedScale, scaleHop), startAngle, startAngle + rotateAnimation * angleStep, false);
                    ctx.lineTo(width / 2, height / 2);
                    ctx.closePath();
                    ctx.fillStyle = data[i].color;
                    ctx.fill();

                    if (config.segmentShowStroke) {
                        ctx.strokeStyle = config.segmentStrokeColor;
                        ctx.lineWidth = config.segmentStrokeWidth;
                        ctx.stroke();
                    }
                    startAngle += rotateAnimation * angleStep;
                }
            }
            function getValueBounds() {
                var upperValue = Number.MIN_VALUE;
                var lowerValue = Number.MAX_VALUE;
                for (var i = 0; i < data.length; i++) {
                    if (data[i].value > upperValue) {
                        upperValue = data[i].value;
                    }
                    if (data[i].value < lowerValue) {
                        lowerValue = data[i].value;
                    }
                }

                var maxSteps = Math.floor((scaleHeight / (labelHeight * 0.66)));
                var minSteps = Math.floor((scaleHeight / labelHeight * 0.5));

                return {
                    maxValue: upperValue,
                    minValue: lowerValue,
                    maxSteps: maxSteps,
                    minSteps: minSteps
                };
            }
        }

        function Radar(data, config, ctx) {
            var maxSize, scaleHop, calculatedScale, labelHeight, scaleHeight, valueBounds, labelTemplateString;

            //If no labels are defined set to an empty array, so referencing length for looping doesn't blow up.
            if (!data.labels)
                data.labels = [];

            calculateDrawingSizes();

            var valueBounds = getValueBounds();

            labelTemplateString = (config.scaleShowLabels) ? config.scaleLabel : null;

            //Check and set the scale
            if (!config.scaleOverride) {
                calculatedScale = calculateScale(scaleHeight, valueBounds.maxSteps, valueBounds.minSteps, valueBounds.maxValue, valueBounds.minValue, labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                };
                for (var i = 1; i <= calculatedScale.steps; i++) {
                    if (labelTemplateString) {
                        calculatedScale.labels.push(tmpl(labelTemplateString, {
                            value: (config.scaleStartValue + (config.scaleStepWidth * i)).toFixed(getDecimalPlaces(config.scaleStepWidth))
                        }));
                    }
                }
            }

            scaleHop = maxSize / (calculatedScale.steps);

            animationLoop(config, drawScale, drawAllDataPoints, ctx);

            //Radar specific functions.
            function drawAllDataPoints(animationDecimal) {
                var rotationDegree = (2 * Math.PI) / data.datasets[0].data.length;

                ctx.save();
                //translate to the centre of the canvas.
                ctx.translate(width / 2, height / 2);

                //We accept multiple data sets for radar charts, so show loop through each set
                for (var i = 0; i < data.datasets.length; i++) {
                    ctx.beginPath();

                    ctx.moveTo(0, animationDecimal * (-1 * calculateOffset(data.datasets[i].data[0], calculatedScale, scaleHop)));
                    for (var j = 1; j < data.datasets[i].data.length; j++) {
                        ctx.rotate(rotationDegree);
                        ctx.lineTo(0, animationDecimal * (-1 * calculateOffset(data.datasets[i].data[j], calculatedScale, scaleHop)));
                    }
                    ctx.closePath();

                    ctx.fillStyle = data.datasets[i].fillColor;
                    ctx.strokeStyle = data.datasets[i].strokeColor;
                    ctx.lineWidth = config.datasetStrokeWidth;
                    ctx.fill();
                    ctx.stroke();

                    if (config.pointDot) {
                        ctx.fillStyle = data.datasets[i].pointColor;
                        ctx.strokeStyle = data.datasets[i].pointStrokeColor;
                        ctx.lineWidth = config.pointDotStrokeWidth;
                        for (var k = 0; k < data.datasets[i].data.length; k++) {
                            ctx.rotate(rotationDegree);
                            ctx.beginPath();
                            ctx.arc(0, animationDecimal * (-1 * calculateOffset(data.datasets[i].data[k], calculatedScale, scaleHop)), config.pointDotRadius, 2 * Math.PI, false);
                            ctx.fill();
                            ctx.stroke();
                        }
                    }
                    ctx.rotate(rotationDegree);
                }
                ctx.restore();
            }
            function drawScale() {
                var rotationDegree = (2 * Math.PI) / data.datasets[0].data.length;
                ctx.save();
                ctx.translate(width / 2, height / 2);

                if (config.angleShowLineOut) {
                    ctx.strokeStyle = config.angleLineColor;
                    ctx.lineWidth = config.angleLineWidth;
                    for (var h = 0; h < data.datasets[0].data.length; h++) {
                        ctx.rotate(rotationDegree);
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(0, -maxSize);
                        ctx.stroke();
                    }
                }

                for (var i = 0; i < calculatedScale.steps; i++) {
                    ctx.beginPath();

                    if (config.scaleShowLine) {
                        ctx.strokeStyle = config.scaleLineColor;
                        ctx.lineWidth = config.scaleLineWidth;
                        ctx.moveTo(0, -scaleHop * (i + 1));
                        for (var j = 0; j < data.datasets[0].data.length; j++) {
                            ctx.rotate(rotationDegree);
                            ctx.lineTo(0, -scaleHop * (i + 1));
                        }
                        ctx.closePath();
                        ctx.stroke();
                    }

                    if (config.scaleShowLabels) {
                        ctx.textAlign = 'center';
                        ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                        ctx.textBaseline = "middle";

                        if (config.scaleShowLabelBackdrop) {
                            var textWidth = ctx.measureText(calculatedScale.labels[i]).width;
                            ctx.fillStyle = config.scaleBackdropColor;
                            ctx.beginPath();
                            ctx.rect(Math.round(-textWidth / 2 - config.scaleBackdropPaddingX)     //X
                            , Math.round((-scaleHop * (i + 1)) - config.scaleFontSize * 0.5 - config.scaleBackdropPaddingY)//Y
                            , Math.round(textWidth + (config.scaleBackdropPaddingX * 2)) //Width
                            , Math.round(config.scaleFontSize + (config.scaleBackdropPaddingY * 2)) //Height
                            );
                            ctx.fill();
                        }
                        ctx.fillStyle = config.scaleFontColor;
                        ctx.fillText(calculatedScale.labels[i], 0, -scaleHop * (i + 1));
                    }
                }
                for (var k = 0; k < data.labels.length; k++) {
                    ctx.font = config.pointLabelFontStyle + " " + config.pointLabelFontSize + "px " + config.pointLabelFontFamily;
                    ctx.fillStyle = config.pointLabelFontColor;
                    var opposite = Math.sin(rotationDegree * k) * (maxSize + config.pointLabelFontSize);
                    var adjacent = Math.cos(rotationDegree * k) * (maxSize + config.pointLabelFontSize);

                    if (rotationDegree * k == Math.PI || rotationDegree * k == 0) {
                        ctx.textAlign = "center";
                    } else if (rotationDegree * k > Math.PI) {
                        ctx.textAlign = "right";
                    } else {
                        ctx.textAlign = "left";
                    }

                    ctx.textBaseline = "middle";

                    ctx.fillText(data.labels[k], opposite, -adjacent);
                }
                ctx.restore();
            }
            function calculateDrawingSizes() {
                maxSize = (Min([width, height]) / 2);

                labelHeight = config.scaleFontSize * 2;

                var labelLength = 0;
                for (var i = 0; i < data.labels.length; i++) {
                    ctx.font = config.pointLabelFontStyle + " " + config.pointLabelFontSize + "px " + config.pointLabelFontFamily;
                    var textMeasurement = ctx.measureText(data.labels[i]).width;
                    if (textMeasurement > labelLength)
                        labelLength = textMeasurement;
                }

                //Figure out whats the largest - the height of the text or the width of what's there, and minus it from the maximum usable size.
                maxSize -= Max([labelLength, ((config.pointLabelFontSize / 2) * 1.5)]);

                maxSize -= config.pointLabelFontSize;
                maxSize = CapValue(maxSize, null, 0);
                scaleHeight = maxSize;
                //If the label height is less than 5, set it to 5 so we don't have lines on top of each other.
                labelHeight = Default(labelHeight, 5);
            }
            function getValueBounds() {
                var upperValue = Number.MIN_VALUE;
                var lowerValue = Number.MAX_VALUE;

                for (var i = 0; i < data.datasets.length; i++) {
                    for (var j = 0; j < data.datasets[i].data.length; j++) {
                        if (data.datasets[i].data[j] > upperValue) {
                            upperValue = data.datasets[i].data[j];
                        }
                        if (data.datasets[i].data[j] < lowerValue) {
                            lowerValue = data.datasets[i].data[j];
                        }
                    }
                }

                var maxSteps = Math.floor((scaleHeight / (labelHeight * 0.66)));
                var minSteps = Math.floor((scaleHeight / labelHeight * 0.5));

                return {
                    maxValue: upperValue,
                    minValue: lowerValue,
                    maxSteps: maxSteps,
                    minSteps: minSteps
                };
            }
        }

        function Pie(data, config, ctx) {
            var segmentTotal = 0;

            //In case we have a canvas that is not a square. Minus 5 pixels as padding round the edge.
            var pieRadius = Min([height / 2, width / 2]) - 5;

            for (var i = 0; i < data.length; i++) {
                segmentTotal += data[i].value;
            }
            if (!(segmentTotal > 0)) {
                clear(ctx);
                return;
            }

            animationLoop(config, null, drawPieSegments, ctx);

            function drawPieSegments(animationDecimal) {
                var cumulativeAngle = -Math.PI / 2, scaleAnimation = 1, rotateAnimation = 1;
                if (config.animation) {
                    if (config.animateScale) {
                        scaleAnimation = animationDecimal;
                    }
                    if (config.animateRotate) {
                        rotateAnimation = animationDecimal;
                    }
                }
                for (var i = 0; i < data.length; i++) {
                    var segmentAngle = rotateAnimation * ((data[i].value / segmentTotal) * (Math.PI * 2));
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, scaleAnimation * pieRadius, cumulativeAngle, cumulativeAngle + segmentAngle);
                    ctx.lineTo(width / 2, height / 2);
                    ctx.closePath();
                    ctx.fillStyle = data[i].color;
                    ctx.fill();

                    if (config.segmentShowStroke) {
                        ctx.lineWidth = config.segmentStrokeWidth;
                        ctx.strokeStyle = config.segmentStrokeColor;
                        ctx.stroke();
                    }
                    cumulativeAngle += segmentAngle;
                }
            }
        }

        function Doughnut(data, config, ctx) {
            var segmentTotal = 0;

            //In case we have a canvas that is not a square. Minus 5 pixels as padding round the edge.
            var doughnutRadius = Min([height / 2, width / 2]) - 5;

            var cutoutRadius = doughnutRadius * (config.percentageInnerCutout / 100);

            for (var i = 0; i < data.length; i++) {
                segmentTotal += data[i].value;
            }
            if (!(segmentTotal > 0)) {
                clear(ctx);
                return;
            }

            animationLoop(config, null, drawPieSegments, ctx);

            function drawPieSegments(animationDecimal) {
                var cumulativeAngle = -Math.PI / 2, scaleAnimation = 1, rotateAnimation = 1;
                if (config.animation) {
                    if (config.animateScale) {
                        scaleAnimation = animationDecimal;
                    }
                    if (config.animateRotate) {
                        rotateAnimation = animationDecimal;
                    }
                }
                for (var i = 0; i < data.length; i++) {
                    var segmentAngle = rotateAnimation * ((data[i].value / segmentTotal) * (Math.PI * 2));
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, scaleAnimation * doughnutRadius, cumulativeAngle, cumulativeAngle + segmentAngle, false);
                    ctx.arc(width / 2, height / 2, scaleAnimation * cutoutRadius, cumulativeAngle + segmentAngle, cumulativeAngle, true);
                    ctx.closePath();
                    ctx.fillStyle = data[i].color;
                    ctx.fill();

                    if (config.segmentShowStroke) {
                        ctx.lineWidth = config.segmentStrokeWidth;
                        ctx.strokeStyle = config.segmentStrokeColor;
                        ctx.stroke();
                    }
                    cumulativeAngle += segmentAngle;
                }
            }
        }

        function Line(data, config, ctx) {
            var maxSize, scaleHop, calculatedScale, labelHeight, scaleHeight, valueBounds, labelTemplateString, valueHop, widestXLabel, xAxisLength, yAxisPosX, xAxisPosY, rotateLabels = 0;

            calculateDrawingSizes();

            valueBounds = getValueBounds();
            //Check and set the scale
            labelTemplateString = (config.scaleShowLabels) ? config.scaleLabel : "";
            if (!config.scaleOverride) {
                calculatedScale = calculateScale(scaleHeight, valueBounds.maxSteps, valueBounds.minSteps, valueBounds.maxValue, valueBounds.minValue, labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                };
                for (var i = 1; i <= calculatedScale.steps; i++) {
                    if (labelTemplateString) {
                        calculatedScale.labels.push(tmpl(labelTemplateString, {
                            value: (config.scaleStartValue + (config.scaleStepWidth * i)).toFixed(getDecimalPlaces(config.scaleStepWidth))
                        }));
                    }
                }
            }

            scaleHop = Math.floor(scaleHeight / calculatedScale.steps);
            calculateXAxisSize();
            animationLoop(config, drawScale, drawLines, ctx);

            function drawLines(animPc) {
                for (var i = 0; i < data.datasets.length; i++) {
                    var dataset = data.datasets[i];
                    ctx.strokeStyle = data.datasets[i].strokeColor;
                    ctx.lineWidth = config.datasetStrokeWidth;
                    var segmentOpen = false;
                    var segmentStartX = 0;
                    var prevX = 0;
                    var prevY = 0;
                    var prevValidIndex = -1;
                    var prevValidX = 0;
                    var prevValidY = 0;
                    var gapBridges = [];

                    for (var j = 0; j < dataset.data.length; j++) {
                        var value = dataset.data[j];
                        if (!isRenderableValue(value)) {
                            if (segmentOpen) {
                                commitSegment(dataset, segmentStartX, prevX);
                                segmentOpen = false;
                            }
                            continue;
                        }

                        var x = xPos(j);
                        var y = valueYPos(animPc, value);
                        if (prevValidIndex >= 0 && (j - prevValidIndex > 1)) {
                            gapBridges.push({
                                x1: prevValidX,
                                y1: prevValidY,
                                x2: x,
                                y2: y
                            });
                        }
                        if (!segmentOpen) {
                            ctx.beginPath();
                            ctx.moveTo(x, y);
                            segmentOpen = true;
                            segmentStartX = x;
                            prevX = x;
                            prevY = y;
                            // Treat segment start as latest valid point so gap bridging
                            // is only generated once per real missing interval.
                            prevValidIndex = j;
                            prevValidX = x;
                            prevValidY = y;
                            continue;
                        }

                        if (config.bezierCurve) {
                            var controlX = xPos(j - 0.5);
                            ctx.bezierCurveTo(controlX, prevY, controlX, y, x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                        prevX = x;
                        prevY = y;
                        prevValidIndex = j;
                        prevValidX = x;
                        prevValidY = y;
                    }

                    if (segmentOpen) {
                        commitSegment(dataset, segmentStartX, prevX);
                    }

                    if (config.spanGapsDashed && gapBridges.length > 0) {
                        ctx.save();
                        var bridgeWidth = isNumber(config.spanGapsStrokeWidth) ? Number(config.spanGapsStrokeWidth) : config.datasetStrokeWidth;
                        ctx.lineWidth = bridgeWidth > 0 ? bridgeWidth : config.datasetStrokeWidth;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = dataset.strokeColor;
                        var bridgeAlpha = Number(config.spanGapsAlpha);
                        if (isFinite(bridgeAlpha))
                            ctx.globalAlpha = CapValue(bridgeAlpha, 1, 0);
                        var dash = config.spanGapsDashPattern;
                        var hasDashApi = (typeof ctx.setLineDash === "function");
                        if (hasDashApi && dash && dash.length > 0)
                            ctx.setLineDash(dash);
                        for (var b = 0; b < gapBridges.length; b++) {
                            var bridge = gapBridges[b];
                            ctx.beginPath();
                            ctx.moveTo(bridge.x1, bridge.y1);
                            ctx.lineTo(bridge.x2, bridge.y2);
                            ctx.stroke();
                        }
                        if (hasDashApi)
                            ctx.setLineDash([]);
                        ctx.restore();
                    }

                    if (config.pointDot) {
                        ctx.fillStyle = data.datasets[i].pointColor;
                        ctx.strokeStyle = data.datasets[i].pointStrokeColor;
                        ctx.lineWidth = config.pointDotStrokeWidth;
                        for (var k = 0; k < dataset.data.length; k++) {
                            if (!isRenderableValue(dataset.data[k]))
                                continue;
                            ctx.beginPath();
                            ctx.arc(xPos(k), valueYPos(animPc, dataset.data[k]), config.pointDotRadius, 0, Math.PI * 2, true);
                            ctx.fill();
                            ctx.stroke();
                        }
                    }
                }

                function commitSegment(dataset, startX, endX) {
                    ctx.stroke();
                    if (config.datasetFill) {
                        ctx.lineTo(endX, xAxisPosY);
                        ctx.lineTo(startX, xAxisPosY);
                        ctx.closePath();
                        ctx.fillStyle = dataset.fillColor;
                        ctx.fill();
                    } else {
                        ctx.closePath();
                    }
                }
                function xPos(iteration) {
                    return yAxisPosX + (valueHop * iteration);
                }
                function valueYPos(animPcValue, v) {
                    return xAxisPosY - animPcValue * (calculateOffset(Number(v), calculatedScale, scaleHop));
                }
                function isRenderableValue(v) {
                    return v !== null && v !== undefined && !isNaN(Number(v)) && isFinite(Number(v));
                }
            }
            function drawScale() {
                //X axis line
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleLineColor;
                ctx.beginPath();
                ctx.moveTo(yAxisPosX, xAxisPosY);
                ctx.lineTo(yAxisPosX + xAxisLength, xAxisPosY);
                ctx.stroke();

                if (rotateLabels > 0) {
                    ctx.save();
                    ctx.textAlign = "right";
                } else {
                    ctx.textAlign = "center";
                }
                ctx.fillStyle = config.scaleFontColor;
                var lastLabelX = -1e9;
                var minLabelSpacingPx = context.canvas.xLabelMinSpacingPx; // pixel-based spacing from QML property
                for (var i = 0; i < data.labels.length; i++) {
                    var hasLabelText = (data.labels[i] !== undefined && data.labels[i] !== null);
                    var labelText = hasLabelText ? String(data.labels[i]) : "";
                    var xLabel = yAxisPosX + i * valueHop;
                    var shouldDraw = (labelText.length > 0) && (xLabel - lastLabelX >= minLabelSpacingPx);
                    if (shouldDraw) {
                        ctx.save();
                        if (rotateLabels > 0) {
                            ctx.translate(xLabel, xAxisPosY + config.scaleFontSize);
                            ctx.rotate(-(rotateLabels * (Math.PI / 180)));
                            ctx.fillText(labelText, 0, 0);
                            ctx.restore();
                        } else {
                            ctx.fillText(labelText, xLabel, xAxisPosY + config.scaleFontSize + 3);
                        }

                        ctx.beginPath();
                        ctx.moveTo(xLabel, xAxisPosY + 3);
                        if (config.scaleShowGridLines && i > 0) {
                            ctx.lineWidth = config.scaleGridLineWidth;
                            ctx.strokeStyle = config.scaleGridLineColor;
                            ctx.lineTo(xLabel, 5);
                        } else {
                            ctx.lineTo(xLabel, xAxisPosY + 3);
                        }
                        ctx.stroke();

                        lastLabelX = xLabel;
                    }
                }

                //Y axis
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleLineColor;
                ctx.beginPath();
                ctx.moveTo(yAxisPosX, xAxisPosY + 5);
                ctx.lineTo(yAxisPosX, 5);
                ctx.stroke();

                ctx.textAlign = "right";
                ctx.textBaseline = "middle";
                ctx.fillStyle = config.scaleFontColor;
                for (var j = 0; j < calculatedScale.steps; j++) {
                    ctx.beginPath();
                    ctx.moveTo(yAxisPosX - 3, xAxisPosY - ((j + 1) * scaleHop));
                    if (config.scaleShowGridLines) {
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(yAxisPosX + xAxisLength, xAxisPosY - ((j + 1) * scaleHop));
                    } else {
                        ctx.lineTo(yAxisPosX - 0.5, xAxisPosY - ((j + 1) * scaleHop));
                    }

                    ctx.stroke();

                    if (config.scaleShowLabels) {
                        ctx.fillText(calculatedScale.labels[j], yAxisPosX - 8, xAxisPosY - ((j + 1) * scaleHop));
                    }
                }
                // Draw border box around plotting area
                var left = yAxisPosX;
                var top = 5;
                var right = yAxisPosX + xAxisLength + 5;
                var bottom = xAxisPosY;
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleGridLineColor;
                ctx.beginPath();
                ctx.moveTo(left, bottom);
                ctx.lineTo(right, bottom);
                ctx.lineTo(right, top);
                ctx.lineTo(left, top);
                ctx.closePath();
                ctx.stroke();
            }
            function calculateXAxisSize() {
                var longestText = 1;
                var chartHorizontalPadding = 6;
                //if we are showing the labels
                if (config.scaleShowLabels) {
                    ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                    for (var i = 0; i < calculatedScale.labels.length; i++) {
                        var measuredText = ctx.measureText(calculatedScale.labels[i]).width;
                        longestText = (measuredText > longestText) ? measuredText : longestText;
                    }
                    //Add a little extra padding from the y axis
                    longestText += 10;
                }
                xAxisLength = Math.max(1, width - longestText - chartHorizontalPadding * 2);
                // Use floating step to avoid collapsing when samples >> pixels
                valueHop = xAxisLength / Math.max(1, (data.labels.length - 1));

                yAxisPosX = longestText + chartHorizontalPadding;
                xAxisPosY = scaleHeight + config.scaleFontSize / 2;
            }
            function calculateDrawingSizes() {
                maxSize = height;

                //Need to check the X axis first - measure the length of each text metric, and figure out if we need to rotate by 45 degrees.
                ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                widestXLabel = 1;
                for (var i = 0; i < data.labels.length; i++) {
                    var textLength = ctx.measureText(String(data.labels[i] !== undefined && data.labels[i] !== null ? data.labels[i] : "")).width;
                    //If the text length is longer - make that equal to longest text!
                    widestXLabel = (textLength > widestXLabel) ? textLength : widestXLabel;
                }
                var visibleCount = 0;
                for (var vi = 0; vi < data.labels.length; vi++) {
                    if (data.labels[vi])
                        visibleCount++;
                }
                var labelsForRotation = Math.max(visibleCount, 1);
                if (width / labelsForRotation < widestXLabel) {
                    rotateLabels = 45;
                    var rad = rotateLabels * (Math.PI / 180);
                    if (width / labelsForRotation < Math.cos(rad) * widestXLabel) {
                        rotateLabels = 90;
                        maxSize -= widestXLabel;
                    } else {
                        maxSize -= Math.sin(rad) * widestXLabel;
                    }
                } else {
                    maxSize -= config.scaleFontSize;
                }

                //Add a little padding between the x line and the text
                maxSize -= 5;

                labelHeight = config.scaleFontSize;

                maxSize -= labelHeight;
                //Set 5 pixels greater than the font size to allow for a little padding from the X axis.

                scaleHeight = maxSize;

            //Then get the area above we can safely draw on.

            }
            function getValueBounds() {
                var upperValue = -Number.MAX_VALUE;
                var lowerValue = Number.MAX_VALUE;
                var hasValue = false;
                for (var i = 0; i < data.datasets.length; i++) {
                    for (var j = 0; j < data.datasets[i].data.length; j++) {
                        var raw = data.datasets[i].data[j];
                        if (raw === null || raw === undefined || isNaN(Number(raw)) || !isFinite(Number(raw)))
                            continue;
                        var value = Number(raw);
                        if (value > upperValue)
                            upperValue = value;
                        if (value < lowerValue)
                            lowerValue = value;
                        hasValue = true;
                    }
                }

                if (!hasValue) {
                    upperValue = 1;
                    lowerValue = 0;
                }

                var maxSteps = Math.floor((scaleHeight / (labelHeight * 0.66)));
                var minSteps = Math.floor((scaleHeight / labelHeight * 0.5));

                return {
                    maxValue: upperValue,
                    minValue: lowerValue,
                    maxSteps: maxSteps,
                    minSteps: minSteps
                };
            }
        }

        function Bar(data, config, ctx) {
            var maxSize, scaleHop, calculatedScale, labelHeight, scaleHeight, valueBounds, labelTemplateString, valueHop, widestXLabel, xAxisLength, yAxisPosX, xAxisPosY, barWidth, rotateLabels = 0;

            calculateDrawingSizes();

            valueBounds = getValueBounds();
            //Check and set the scale
            labelTemplateString = (config.scaleShowLabels) ? config.scaleLabel : "";
            if (!config.scaleOverride) {
                calculatedScale = calculateScale(scaleHeight, valueBounds.maxSteps, valueBounds.minSteps, valueBounds.maxValue, valueBounds.minValue, labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                };
                for (var i = 1; i <= calculatedScale.steps; i++) {
                    if (labelTemplateString) {
                        calculatedScale.labels.push(tmpl(labelTemplateString, {
                            value: (config.scaleStartValue + (config.scaleStepWidth * i)).toFixed(getDecimalPlaces(config.scaleStepWidth))
                        }));
                    }
                }
            }

            scaleHop = Math.floor(scaleHeight / calculatedScale.steps);
            calculateXAxisSize();
            animationLoop(config, drawScale, drawBars, ctx);

            function drawBars(animPc) {
                ctx.lineWidth = config.barStrokeWidth;
                for (var i = 0; i < data.datasets.length; i++) {
                    ctx.fillStyle = data.datasets[i].fillColor;
                    ctx.strokeStyle = data.datasets[i].strokeColor;
                    for (var j = 0; j < data.datasets[i].data.length; j++) {
                        var barOffset = yAxisPosX + config.barValueSpacing + valueHop * j + barWidth * i + config.barDatasetSpacing * i + config.barStrokeWidth * i;

                        ctx.beginPath();
                        ctx.moveTo(barOffset, xAxisPosY);
                        ctx.lineTo(barOffset, xAxisPosY - animPc * calculateOffset(data.datasets[i].data[j], calculatedScale, scaleHop) + (config.barStrokeWidth / 2));
                        ctx.lineTo(barOffset + barWidth, xAxisPosY - animPc * calculateOffset(data.datasets[i].data[j], calculatedScale, scaleHop) + (config.barStrokeWidth / 2));
                        ctx.lineTo(barOffset + barWidth, xAxisPosY);
                        if (config.barShowStroke) {
                            ctx.stroke();
                        }
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }
            function drawScale() {
                //X axis line
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleLineColor;
                ctx.beginPath();
                ctx.moveTo(width - widestXLabel / 2 + 5, xAxisPosY);
                ctx.lineTo(width - (widestXLabel / 2) - xAxisLength - 5, xAxisPosY);
                ctx.stroke();

                if (rotateLabels > 0) {
                    ctx.save();
                    ctx.textAlign = "right";
                } else {
                    ctx.textAlign = "center";
                }
                ctx.fillStyle = config.scaleFontColor;
                var lastLabelXBar = -1e9;
                var minLabelSpacingPxBar = context.canvas.xLabelMinSpacingPx;
                for (var i = 0; i < data.labels.length; i++) {
                    var hasLabelTextBar = data.labels[i] && data.labels[i] !== "";
                    var xTick = yAxisPosX + (i + 1) * valueHop; // tick at bar boundary
                    var shouldDrawBar = hasLabelTextBar && (xTick - lastLabelXBar >= minLabelSpacingPxBar);

                    if (shouldDrawBar) {
                        ctx.save();
                        if (rotateLabels > 0) {
                            ctx.translate(yAxisPosX + i * valueHop + valueHop / 2, xAxisPosY + config.scaleFontSize);
                            ctx.rotate(-(rotateLabels * (Math.PI / 180)));
                            ctx.fillText(data.labels[i], 0, 0);
                            ctx.restore();
                        } else {
                            ctx.fillText(data.labels[i], yAxisPosX + i * valueHop + valueHop / 2, xAxisPosY + config.scaleFontSize + 3);
                        }

                        ctx.beginPath();
                        ctx.moveTo(xTick, xAxisPosY + 3);
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(xTick, 5);
                        ctx.stroke();

                        lastLabelXBar = xTick;
                    }
                }

                //Y axis
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleLineColor;
                ctx.beginPath();
                ctx.moveTo(yAxisPosX, xAxisPosY + 5);
                ctx.lineTo(yAxisPosX, 5);
                ctx.stroke();

                ctx.textAlign = "right";
                ctx.textBaseline = "middle";
                for (var j = 0; j < calculatedScale.steps; j++) {
                    ctx.beginPath();
                    ctx.moveTo(yAxisPosX - 3, xAxisPosY - ((j + 1) * scaleHop));
                    if (config.scaleShowGridLines) {
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(yAxisPosX + xAxisLength + 5, xAxisPosY - ((j + 1) * scaleHop));
                    } else {
                        ctx.lineTo(yAxisPosX - 0.5, xAxisPosY - ((j + 1) * scaleHop));
                    }

                    ctx.stroke();
                    if (config.scaleShowLabels) {
                        ctx.fillText(calculatedScale.labels[j], yAxisPosX - 8, xAxisPosY - ((j + 1) * scaleHop));
                    }
                }
            }
            function calculateXAxisSize() {
                var longestText = 1;
                //if we are showing the labels
                if (config.scaleShowLabels) {
                    ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                    for (var i = 0; i < calculatedScale.labels.length; i++) {
                        var measuredText = ctx.measureText(calculatedScale.labels[i]).width;
                        longestText = (measuredText > longestText) ? measuredText : longestText;
                    }
                    //Add a little extra padding from the y axis
                    longestText += 10;
                }
                xAxisLength = Math.max(1, width - longestText - widestXLabel);
                // Allow fractional hop to support many bars; barWidth below adapts
                valueHop = xAxisLength / Math.max(1, data.labels.length);

                barWidth = (valueHop - config.scaleGridLineWidth * 2 - (config.barValueSpacing * 2) - (config.barDatasetSpacing * data.datasets.length - 1) - ((config.barStrokeWidth / 2) * data.datasets.length - 1)) / data.datasets.length;

                yAxisPosX = width - widestXLabel / 2 - xAxisLength;
                xAxisPosY = scaleHeight + config.scaleFontSize / 2;
            }
            function calculateDrawingSizes() {
                maxSize = height;

                //Need to check the X axis first - measure the length of each text metric, and figure out if we need to rotate by 45 degrees.
                ctx.font = config.scaleFontStyle + " " + config.scaleFontSize + "px " + config.scaleFontFamily;
                widestXLabel = 1;
                for (var i = 0; i < data.labels.length; i++) {
                    var textLength = ctx.measureText(data.labels[i]).width;
                    //If the text length is longer - make that equal to longest text!
                    widestXLabel = (textLength > widestXLabel) ? textLength : widestXLabel;
                }
                if (width / data.labels.length < widestXLabel) {
                    rotateLabels = 45;
                    var rad2 = rotateLabels * (Math.PI / 180);
                    if (width / data.labels.length < Math.cos(rad2) * widestXLabel) {
                        rotateLabels = 90;
                        maxSize -= widestXLabel;
                    } else {
                        maxSize -= Math.sin(rad2) * widestXLabel;
                    }
                } else {
                    maxSize -= config.scaleFontSize;
                }

                //Add a little padding between the x line and the text
                maxSize -= 5;

                labelHeight = config.scaleFontSize;

                maxSize -= labelHeight;
                //Set 5 pixels greater than the font size to allow for a little padding from the X axis.

                scaleHeight = maxSize;

            //Then get the area above we can safely draw on.

            }
            function getValueBounds() {
                var upperValue = Number.MIN_VALUE;
                var lowerValue = Number.MAX_VALUE;
                for (var i = 0; i < data.datasets.length; i++) {
                    for (var j = 0; j < data.datasets[i].data.length; j++) {
                        if (data.datasets[i].data[j] > upperValue) {
                            upperValue = data.datasets[i].data[j];
                        }
                        if (data.datasets[i].data[j] < lowerValue) {
                            lowerValue = data.datasets[i].data[j];
                        }
                    }
                }

                var maxSteps = Math.floor((scaleHeight / (labelHeight * 0.66)));
                var minSteps = Math.floor((scaleHeight / labelHeight * 0.5));

                return {
                    maxValue: upperValue,
                    minValue: lowerValue,
                    maxSteps: maxSteps,
                    minSteps: minSteps
                };
            }
        }

        function calculateOffset(val, calculatedScale, scaleHop) {
            var outerValue = calculatedScale.steps * calculatedScale.stepValue;
            var adjustedValue = val - calculatedScale.graphMin;
            var scalingFactor = CapValue(adjustedValue / outerValue, 1, 0);
            return (scaleHop * calculatedScale.steps) * scalingFactor;
        }

        function animationLoop(config, drawScale, drawData, ctx) {
            var animFrameAmount = (config.animation) ? 1 / CapValue(config.animationSteps, Number.MAX_VALUE, 1) : 1, easingFunction = animationOptions[config.animationEasing], percentAnimComplete = (config.animation) ? 0 : 1;

            if (typeof drawScale !== "function")
                drawScale = function () {};

            requestAnimFrame(animLoop);

            function animateFrame() {
                var easeAdjustedAnimationPercent = (config.animation) ? CapValue(easingFunction(percentAnimComplete), null, 0) : 1;
                clear(ctx);
                if (config.scaleOverlay) {
                    drawData(easeAdjustedAnimationPercent);
                    drawScale();
                } else {
                    drawScale();
                    drawData(easeAdjustedAnimationPercent);
                }
            }
            function animLoop() {
                //We need to check if the animation is incomplete (less than 1), or complete (1).
                percentAnimComplete += animFrameAmount;
                animateFrame();
                //Stop the loop continuing forever
                if (percentAnimComplete <= 1) {
                    requestAnimFrame(animLoop);
                } else {
                    if (typeof config.onAnimationComplete == "function")
                        config.onAnimationComplete();
                }
            }
        }

        //![1]
        //Declare global functions to be called within this namespace here.

        /* // replace this block, because the qml hasn't window object
        // shim layer with setTimeout fallback
        var requestAnimFrame = (function(){
            return window.requestAnimationFrame ||
                window.webkitRequestAnimationFrame ||
                window.mozRequestAnimationFrame ||
                window.oRequestAnimationFrame ||
                window.msRequestAnimationFrame ||
                function(callback) {
                    window.setTimeout(callback, 1000 / 60);
                };
        })();
        //*/
        //![1]

        //![2]
        //* // this block code runs synchronously inside onPaint to keep drawing within paint cycle
        function requestAnimFrame(call) {
            call();
        }
        //*/
        //![2]

        function calculateScale(drawingHeight, maxSteps, minSteps, maxValue, minValue, labelTemplateString) {
            var graphMin, graphMax, graphRange, stepValue, numberOfSteps, valueRange, rangeOrderOfMagnitude, decimalNum;

            valueRange = maxValue - minValue;

            rangeOrderOfMagnitude = calculateOrderOfMagnitude(valueRange);

            graphMin = Math.floor(minValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);

            graphMax = Math.ceil(maxValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);

            graphRange = graphMax - graphMin;

            stepValue = Math.pow(10, rangeOrderOfMagnitude);

            numberOfSteps = Math.round(graphRange / stepValue);

            //Compare number of steps to the max and min for that size graph, and add in half steps if need be.
            while (numberOfSteps < minSteps || numberOfSteps > maxSteps) {
                if (numberOfSteps < minSteps) {
                    stepValue /= 2;
                    numberOfSteps = Math.round(graphRange / stepValue);
                } else {
                    stepValue *= 2;
                    numberOfSteps = Math.round(graphRange / stepValue);
                }
            }

            //Create an array of all the labels by interpolating the string.

            var labels = [];

            if (labelTemplateString) {
                //Fix floating point errors by setting to fixed the on the same decimal as the stepValue.
                for (var i = 1; i < numberOfSteps + 1; i++) {
                    labels.push(tmpl(labelTemplateString, {
                        value: (graphMin + (stepValue * i)).toFixed(getDecimalPlaces(stepValue))
                    }));
                }
            }

            return {
                steps: numberOfSteps,
                stepValue: stepValue,
                graphMin: graphMin,
                labels: labels
            };

            function calculateOrderOfMagnitude(val) {
                return Math.floor(Math.log(val) / Math.LN10);
            }
        }

        //Max value from array
        function Max(array) {
            return Math.max.apply(Math, array);
        }
        //Min value from array
        function Min(array) {
            return Math.min.apply(Math, array);
        }
        //Default if undefined
        function Default(userDeclared, valueIfFalse) {
            if (!userDeclared) {
                return valueIfFalse;
            } else {
                return userDeclared;
            }
        }
        //Is a number function
        function isNumber(n) {
            return !isNaN(parseFloat(n)) && isFinite(n);
        }
        //Apply cap a value at a high or low number
        function CapValue(valueToCap, maxValue, minValue) {
            if (isNumber(maxValue)) {
                if (valueToCap > maxValue) {
                    return maxValue;
                }
            }
            if (isNumber(minValue)) {
                if (valueToCap < minValue) {
                    return minValue;
                }
            }
            return valueToCap;
        }
        function getDecimalPlaces(num) {
            var numberOfDecimalPlaces;
            if (num % 1 != 0) {
                return num.toString().split(".")[1].length;
            } else {
                return 0;
            }
        }

        function mergeChartConfig(defaults, userDefined) {
            var returnObj = {};
            for (var attrname in defaults) {
                returnObj[attrname] = defaults[attrname];
            }
            for (var attrname in userDefined) {
                returnObj[attrname] = userDefined[attrname];
            }
            return returnObj;
        }

        //Javascript micro templating by John Resig - source at http://ejohn.org/blog/javascript-micro-templating/
        var cache = {};

        function tmpl(str, data) {
            // Figure out if we're getting a template, or if we need to
            // load the template - and be sure to cache the result.
            var fn = !/\W/.test(str) ? cache[str] = cache[str] || tmpl(document.getElementById(str).innerHTML) :

            // Generate a reusable function that will serve as a template
            // generator (and which will be cached).
            new Function("obj", "var p=[],print=function(){p.push.apply(p,arguments);};" +

            // Introduce the data as local variables using with(){}
            "with(obj){p.push('" +

            // Convert the template into pure JavaScript
            str.replace(/[\r\t\n]/g, " ").split("<%").join("\t").replace(/((^|%>)[^\t]*)'/g, "$1\r").replace(/\t=(.*?)%>/g, "',$1,'").split("\t").join("');").split("%>").join("p.push('").split("\r").join("\\'") + "');}return p.join('');");

            // Provide some basic currying to the user
            return data ? fn(data) : fn;
        }
    }
}
