import QtQuick 2.15
import GeoControls 1.0

Rectangle {
    id: control

    property string text: ""
    property int count: -1
    property int maxCount: 99
    property bool showZero: false
    property color textColor: Theme.highlightedTextColor

    readonly property string displayText: {
        if (control.count >= 0) {
            if (control.count === 0 && !control.showZero)
                return ""
            return control.count > control.maxCount ? control.maxCount + "+" : String(control.count)
        }
        return control.text
    }

    visible: displayText.length > 0
    implicitWidth: Math.max(implicitHeight, label.implicitWidth + Fonts.size10)
    implicitHeight: Math.max(Fonts.size16, Fonts.standardFontMetrics.height)
    radius: implicitHeight / 2
    color: Theme.highlightColor

    Text {
        id: label
        anchors.centerIn: parent
        text: control.displayText
        color: control.textColor
        font: Fonts.annotationFont
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
