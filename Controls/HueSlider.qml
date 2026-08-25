import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Item {
    id: control

    property alias title: slider.title
    property alias value: slider.value
    property alias showReset: slider.showReset
    property alias resetValue: slider.resetValue
    property alias delayedCommit: slider.delayedCommit
    property alias validatorDecimals: slider.validatorDecimals
    property alias showStepButton: slider.showStepButton
    property alias enabled: slider.enabled

    signal valueCommitted(double value)
    signal resetRequested

    width: parent.width
    implicitHeight: column.implicitHeight
    implicitWidth: column.implicitWidth
    height: implicitHeight

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Fonts.size4

        CustomSlider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 1
            stepSize: 0.01
            validatorDecimals: 2
            onValueCommitted: function (next) {
                control.valueCommitted(next)
            }
            onResetRequested: control.resetRequested()
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: Fonts.iconButtonSize
            Layout.rightMargin: Fonts.iconButtonSize
            height: Fonts.size8
            radius: height / 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: "#ff0000"
                }
                GradientStop {
                    position: 0.17
                    color: "#ffff00"
                }
                GradientStop {
                    position: 0.33
                    color: "#00ff00"
                }
                GradientStop {
                    position: 0.5
                    color: "#00ffff"
                }
                GradientStop {
                    position: 0.67
                    color: "#0000ff"
                }
                GradientStop {
                    position: 0.83
                    color: "#ff00ff"
                }
                GradientStop {
                    position: 1.0
                    color: "#ff0000"
                }
            }
        }
    }
}
