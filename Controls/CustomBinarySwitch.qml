import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

Rectangle {
    id: root

    property string leftText: qsTr("On")
    property string rightText: qsTr("Off")
    property bool leftActive: false
    property bool rightActive: false

    signal leftClicked
    signal rightClicked

    readonly property real buttonTextPadding: Fonts.size8
    readonly property real buttonMinWidth: Math.max(leftTextMetrics.advanceWidth, rightTextMetrics.advanceWidth) + buttonTextPadding * 2

    implicitWidth: leftButton.implicitWidth + rightButton.implicitWidth + Fonts.size12
    Layout.minimumWidth: implicitWidth
    implicitHeight: Math.max(leftButton.implicitHeight, rightButton.implicitHeight) + Fonts.size8
    radius: Fonts.size2
    color: Theme.baseColor
    border.color: Theme.midColor
    border.width: Fonts.size1

    TextMetrics {
        id: leftTextMetrics
        font: leftButton.font
        text: root.leftText
    }

    TextMetrics {
        id: rightTextMetrics
        font: rightButton.font
        text: root.rightText
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size4
        spacing: Fonts.size4

        CustomButton {
            id: leftButton
            Layout.fillWidth: true
            Layout.minimumWidth: root.buttonMinWidth
            implicitWidth: Math.max(root.buttonMinWidth, contentItem.implicitWidth + leftPadding + rightPadding)
            text: root.leftText
            defaultHeight: Fonts.inputFieldHeight * 0.8
            defaultPadding: Fonts.size4
            defaultRadius: Fonts.size2
            buttonColor: root.leftActive ? Theme.highlightColor : "transparent"
            hoveredColor: root.leftActive ? Theme.highlightColor : Theme.buttonHoveredColor
            pressedColor: Theme.highlightColor
            buttonTextColor: root.leftActive ? Theme.highlightedTextColor : Theme.textColor
            midColor: "transparent"
            darkColor: root.leftActive ? Theme.highlightColor : Theme.midColor
            highlightColor: Theme.highlightColor

            contentItem: Text {
                text: leftButton.text
                anchors.centerIn: parent
                font: leftButton.font
                color: !leftButton.enabled ? leftButton.disabledTextColor : leftButton.buttonTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                elide: Text.ElideNone
            }

            onClicked: root.leftClicked()
        }

        CustomButton {
            id: rightButton
            Layout.fillWidth: true
            Layout.minimumWidth: root.buttonMinWidth
            implicitWidth: Math.max(root.buttonMinWidth, contentItem.implicitWidth + leftPadding + rightPadding)
            text: root.rightText
            defaultHeight: Fonts.inputFieldHeight * 0.8
            defaultPadding: Fonts.size4
            defaultRadius: Fonts.size2
            buttonColor: root.rightActive ? Theme.highlightColor : "transparent"
            hoveredColor: root.rightActive ? Theme.highlightColor : Theme.buttonHoveredColor
            pressedColor: Theme.highlightColor
            buttonTextColor: root.rightActive ? Theme.highlightedTextColor : Theme.textColor
            midColor: "transparent"
            darkColor: root.rightActive ? Theme.highlightColor : Theme.midColor
            highlightColor: Theme.highlightColor

            contentItem: Text {
                text: rightButton.text
                anchors.centerIn: parent
                font: rightButton.font
                color: !rightButton.enabled ? rightButton.disabledTextColor : rightButton.buttonTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                elide: Text.ElideNone
            }

            onClicked: root.rightClicked()
        }
    }
}
