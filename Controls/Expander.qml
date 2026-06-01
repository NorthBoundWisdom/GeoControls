import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property string title: ""
    property bool expanded: true
    property bool collapsible: true
    default property alias content: body.data

    signal toggled(bool expanded)

    implicitWidth: contentColumn.implicitWidth + Fonts.size16
    implicitHeight: header.height + (expanded ? body.implicitHeight + Fonts.size12 : 0)
    radius: ControlState.radiusMedium
    color: Theme.baseColor
    border.color: Theme.midColor
    border.width: ControlState.borderThin
    clip: true

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            height: Math.max(ControlState.minInputHeight, titleLabel.implicitHeight + Fonts.size12)
            color: headerMouse.containsMouse && control.collapsible ? Theme.buttonHoveredColor : Theme.baseColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Fonts.size10
                anchors.rightMargin: Fonts.size10
                spacing: Fonts.size8

                Text {
                    text: ">"
                    visible: control.collapsible
                    rotation: control.expanded ? 90 : 0
                    color: Theme.textColor
                    font: Fonts.standardFont
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredWidth: Fonts.size12
                }

                CustomLabel {
                    id: titleLabel
                    Layout.fillWidth: true
                    text: control.title
                    font: Fonts.makeBoldFont(Fonts.standardFont)
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: control.collapsible
                onClicked: {
                    control.expanded = !control.expanded
                    control.toggled(control.expanded)
                }
            }
        }

        ColumnLayout {
            id: body
            visible: control.expanded
            Layout.fillWidth: true
            Layout.margins: Fonts.size10
            spacing: Fonts.size8
        }
    }
}
