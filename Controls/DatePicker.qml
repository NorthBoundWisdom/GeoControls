import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property int minYear: 1970
    property int maxYear: 2100
    property int year: new Date().getFullYear()
    property int month: new Date().getMonth() + 1
    property int day: new Date().getDate()
    readonly property bool validRange: minYear <= maxYear
    readonly property date selectedDate: new Date(year, month - 1, day)

    signal dateSelected(date value)

    implicitWidth: dateLayout.implicitWidth + Fonts.size16
    implicitHeight: dateLayout.implicitHeight + Fonts.size12
    radius: ControlState.radiusMedium
    color: Theme.contentSurfaceColor
    border.color: validRange ? Theme.dividerColor : Theme.errorColor
    border.width: ControlState.borderThin

    function years() {
        var values = []
        if (!validRange)
            return values
        for (var value = minYear; value <= maxYear; ++value)
            values.push(String(value))
        return values
    }

    function months() {
        var values = []
        for (var value = 1; value <= 12; ++value)
            values.push(String(value))
        return values
    }

    function days() {
        var values = []
        var maxDay = new Date(year, month, 0).getDate()
        for (var value = 1; value <= maxDay; ++value)
            values.push(String(value))
        return values
    }

    function clampDay() {
        day = Math.max(1, Math.min(day, new Date(year, month, 0).getDate()))
    }

    function emitSelection() {
        clampDay()
        dateSelected(selectedDate)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size6
        spacing: Fonts.size6

        RowLayout {
            id: dateLayout
            Layout.fillWidth: true
            spacing: Fonts.size8

            CustomComboBox {
                Layout.preferredWidth: Fonts.size90
                enabled: control.validRange
                model: control.years()
                currentIndex: Math.max(0, control.year - control.minYear)
                onActivated: function (index) {
                    control.year = Number(model[index])
                    control.emitSelection()
                }
            }

            CustomComboBox {
                Layout.preferredWidth: Fonts.size70
                enabled: control.validRange
                model: control.months()
                currentIndex: control.month - 1
                onActivated: function (index) {
                    control.month = Number(model[index])
                    control.emitSelection()
                }
            }

            CustomComboBox {
                Layout.preferredWidth: Fonts.size70
                enabled: control.validRange
                model: control.days()
                currentIndex: Math.max(0, control.day - 1)
                onActivated: function (index) {
                    control.day = Number(model[index])
                    control.emitSelection()
                }
            }
        }

        InfoBar {
            visible: !control.validRange
            Layout.fillWidth: true
            severity: "error"
            title: qsTr("Invalid date range")
            message: qsTr("minYear must be less than or equal to maxYear.")
            closable: false
        }
    }
}
