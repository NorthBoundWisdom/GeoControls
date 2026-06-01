import QtQuick 2.15
import QtQuick.Controls 2.15
import GeoControls 1.0

ToolTip {
    id: control
    delay: ToolTipConfig.shortDelay
    timeout: ToolTipConfig.persistentTimeout
    contentItem: Text {
        text: control.text
        font: Fonts.annotationFont
        color: Theme.textColor
        wrapMode: Text.Wrap
    }

    background: Rectangle {
        color: Theme.buttonColor
        border.color: Theme.midColor
        border.width: Fonts.size1
        radius: Fonts.smallMargin
    }
}
