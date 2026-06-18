import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: root

    property var model: []
    property int currentIndex: 0

    signal activated(int index)

    readonly property real buttonTextPadding: Fonts.size8
    readonly property real fallbackButtonWidth: Fonts.scaledUiSize(96)
    readonly property int optionCount: Array.isArray(model) ? model.length : 0
    readonly property real minimumButtonWidth: Fonts.size24
    readonly property real resolvedButtonWidth: {
        var maxWidth = fallbackButtonWidth
        if (!Array.isArray(model)) {
            return maxWidth
        }
        for (var i = 0; i < model.length; ++i) {
            var label = String(model[i])
            var estimate = Math.max(fallbackButtonWidth, label.length * Fonts.size8 + buttonTextPadding * 2)
            maxWidth = Math.max(maxWidth, estimate)
        }
        return maxWidth
    }

    implicitWidth: {
        if (optionCount <= 0) {
            return 0
        }
        return optionCount * resolvedButtonWidth + Math.max(0, optionCount - 1) * Fonts.size4 + Fonts.size12
    }
    Layout.minimumWidth: {
        if (optionCount <= 0) {
            return 0
        }
        return optionCount * minimumButtonWidth + Math.max(0, optionCount - 1) * Fonts.size4 + Fonts.size12
    }
    implicitHeight: Fonts.inputFieldHeight
    radius: ControlState.radiusSmall
    color: Theme.baseColor
    border.color: Theme.midColor
    border.width: ControlState.borderThin

    RowLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size4
        spacing: Fonts.size4

        Repeater {
            model: Array.isArray(root.model) ? root.model : []

            CustomButton {
                id: optionButton
                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.minimumWidth: root.minimumButtonWidth
                implicitWidth: Math.max(root.resolvedButtonWidth, contentItem.implicitWidth + leftPadding + rightPadding)
                text: String(modelData)
                defaultHeight: Fonts.inputFieldHeight * 0.8
                defaultPadding: Fonts.size4
                defaultRadius: ControlState.radiusSmall
                buttonColor: root.currentIndex === index ? Theme.highlightColor : "transparent"
                hoveredColor: root.currentIndex === index ? Theme.highlightColor : Theme.buttonHoveredColor
                pressedColor: Theme.highlightColor
                buttonTextColor: root.currentIndex === index ? Theme.highlightedTextColor : Theme.textColor
                midColor: "transparent"
                darkColor: root.currentIndex === index ? Theme.highlightColor : Theme.midColor
                highlightColor: Theme.highlightColor

                contentItem: Text {
                    text: optionButton.text
                    anchors.centerIn: parent
                    font: optionButton.font
                    color: !optionButton.enabled ? optionButton.disabledTextColor : optionButton.buttonTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }

                onClicked: {
                    if (root.currentIndex === index) {
                        return
                    }
                    root.currentIndex = index
                    root.activated(index)
                }
            }
        }
    }
}
