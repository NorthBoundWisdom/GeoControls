import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property int hour: 9
    property int minute: 0
    property int second: 0
    property bool showSeconds: false

    readonly property string selectedTime: pad(hour) + ":" + pad(minute) + (showSeconds ? ":" + pad(second) : "")

    signal timeSelected(string value)

    implicitWidth: timeLayout.implicitWidth + Fonts.size16
    implicitHeight: Math.max(timeLayout.implicitHeight + Fonts.size12, ControlState.minInputHeight)
    radius: ControlState.radiusMedium
    color: Theme.contentSurfaceColor
    border.color: Theme.dividerColor
    border.width: ControlState.borderThin

    function pad(value) {
        return value < 10 ? "0" + value : String(value)
    }

    function range(count) {
        var values = []
        for (var value = 0; value < count; ++value)
            values.push(pad(value))
        return values
    }

    RowLayout {
        id: timeLayout
        anchors.fill: parent
        anchors.margins: Fonts.size6
        spacing: Fonts.size6

        CustomComboBox {
            Layout.preferredWidth: Fonts.size70
            model: control.range(24)
            currentIndex: control.hour
            onActivated: function (index) {
                control.hour = index
                control.timeSelected(control.selectedTime)
            }
        }

        CustomLabel {
            text: ":"
            font: Fonts.makeBoldFont(Fonts.standardFont)
        }

        CustomComboBox {
            Layout.preferredWidth: Fonts.size70
            model: control.range(60)
            currentIndex: control.minute
            onActivated: function (index) {
                control.minute = index
                control.timeSelected(control.selectedTime)
            }
        }

        CustomLabel {
            visible: control.showSeconds
            text: ":"
            font: Fonts.makeBoldFont(Fonts.standardFont)
        }

        CustomComboBox {
            visible: control.showSeconds
            Layout.preferredWidth: visible ? Fonts.size70 : 0
            model: control.range(60)
            currentIndex: control.second
            onActivated: function (index) {
                control.second = index
                control.timeSelected(control.selectedTime)
            }
        }
    }
}
