import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Rectangle {
    id: root
    width: 1120
    height: 760
    color: Theme.windowColor

    Component.onCompleted: {
        Theme.helper = themeHelper;
    }

    MessageDialog {
        id: messageDialog
        objectName: "messageDialog"
        parentItem: root
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 16
        clip: true

        ColumnLayout {
            width: Math.max(0, scrollView.availableWidth - 12)
            spacing: 16

            CustomLabel {
                text: "GeoToy.Controls Demo"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            CustomRectangle {
                Layout.fillWidth: true
                implicitHeight: 190

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 12

                    CustomLabel {
                        text: "Buttons"
                    }
                    CustomButton {
                        text: "Primary"
                        onClicked: {
                            messageDialog.titleText = "Demo";
                            messageDialog.messageText = "CustomButton clicked";
                            messageDialog.buttons = ["OK"];
                            messageDialog.openWithButtons();
                        }
                    }
                    CustomToolButton {
                        text: "Tool"
                        ToolTip.visible: hovered
                        ToolTip.text: "CustomToolButton"
                    }
                    CustomCheckBox {
                        text: "Check"
                        checked: true
                    }

                    CustomLabel {
                        text: "Inputs"
                    }
                    CustomTextField {
                        text: "Editable text"
                        Layout.fillWidth: true
                    }
                    CustomComboBox {
                        model: ["Alpha", "Beta", "Gamma"]
                        Layout.fillWidth: true
                    }
                    CustomSwitch {
                        checked: true
                    }

                    CustomLabel {
                        text: "Numeric"
                    }
                    CustomSpinBox {
                        id: demoSpin
                        from: -100
                        to: 100
                        realValue: 12.5
                        decimals: 1
                        stepSize: 0.5
                        editable: true
                        Layout.fillWidth: true
                    }
                    CustomSlider {
                        from: 0
                        to: 100
                        value: demoSpin.realValue
                        Layout.fillWidth: true
                    }
                    CustomBinarySwitch {
                        checked: true
                    }
                }
            }

            CustomRectangle {
                Layout.fillWidth: true
                implicitHeight: 150

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    CustomLabel {
                        text: "Vector3SpinBox"
                        font.bold: true
                    }
                    CustomVector3SpinBox {
                        id: positionVector
                        objectName: "positionVector"
                        Layout.fillWidth: true
                        vector: [10.5, 20.3, 30.7]
                        decimals: 2
                        stepSize: 0.5
                    }
                }
            }

            CustomRectangle {
                Layout.fillWidth: true
                implicitHeight: 330

                ColumnLayout {
                    id: chartSection
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        CustomLabel {
                            text: "Dynamic Chart"
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        CustomCheckBox {
                            id: realTimeCheck
                            text: "Realtime"
                            onCheckedChanged: checked ? chartTimer.start() : chartTimer.stop()
                        }
                    }

                    CustomChart {
                        id: demoChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property var chartData: ({
                            labels: [],
                            datasets: [{
                                strokeColor: "#1f7a8c",
                                fillColor: "rgba(31,122,140,0.12)",
                                pointColor: "#1f7a8c",
                                pointStrokeColor: "#ffffff",
                                data: []
                            }]
                        })

                        function render() {
                            line(chartData, {
                                animation: false,
                                bezierCurve: false,
                                scaleShowLabels: true,
                                datasetFill: false,
                                pointDot: false
                            });
                        }

                        onPaint: render()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }

                    function resetData() {
                        const data = [];
                        const labels = [];
                        for (let i = 0; i < 120; ++i) {
                            const x = i / 12;
                            data.push(Math.sin(x) * 40 + Math.cos(x * 0.5) * 15);
                            labels.push(i % 15 === 0 ? String(i) : "");
                        }
                        demoChart.chartData.labels = labels;
                        demoChart.chartData.datasets[0].data = data;
                        demoChart.requestPaint();
                    }

                    function tick() {
                        const data = demoChart.chartData.datasets[0].data;
                        const labels = demoChart.chartData.labels;
                        const t = Date.now() * 0.001;
                        data.push(Math.sin(t * 2.0) * 45 + Math.cos(t * 0.9) * 18);
                        labels.push(labels.length % 15 === 0 ? String(labels.length) : "");
                        while (data.length > 120)
                            data.shift();
                        while (labels.length > 120)
                            labels.shift();
                        demoChart.requestPaint();
                    }

                    Timer {
                        id: chartTimer
                        interval: 80
                        repeat: true
                        onTriggered: chartSection.tick()
                    }

                    Component.onCompleted: resetData()
                }
            }

            CustomRectangle {
                Layout.fillWidth: true
                implicitHeight: 118

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    CustomLabel {
                        text: "Dialogs"
                        font.bold: true
                    }
                    CustomButton {
                        text: "Message"
                        onClicked: {
                            messageDialog.titleText = "GeoControls";
                            messageDialog.messageText = "MessageDialog is available.";
                            messageDialog.buttons = ["OK"];
                            messageDialog.openWithButtons();
                        }
                    }
                    CustomButton {
                        text: "Tooltip"
                        ToolTip.visible: hovered
                        ToolTip.text: "ToolTipConfig is provided by the Controls module."
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
