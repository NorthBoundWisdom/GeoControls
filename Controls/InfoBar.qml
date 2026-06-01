import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property string severity: "info"
    property string title: ""
    property string message: ""
    property string actionText: ""
    property bool closable: true

    signal actionTriggered
    signal closed

    function accentForSeverity() {
        if (severity === "success")
            return Theme.successColor
        if (severity === "warning")
            return Theme.warningColor
        if (severity === "error")
            return Theme.errorColor
        return Theme.infoColor
    }

    function surfaceForSeverity() {
        return Qt.rgba(accentForSeverity().r, accentForSeverity().g, accentForSeverity().b, Theme.appearance === 0 ? 0.10 : 0.20)
    }

    implicitWidth: contentLayout.implicitWidth + Fonts.size24
    implicitHeight: Math.max(contentLayout.implicitHeight + Fonts.size16, ControlState.minInputHeight)
    radius: ControlState.radiusMedium
    color: surfaceForSeverity()
    border.color: accentForSeverity()
    border.width: ControlState.borderThin

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: Fonts.size8
        spacing: Fonts.size8

        Badge {
            text: control.severity.length > 0 ? control.severity.charAt(0).toUpperCase() : "I"
            color: control.accentForSeverity()
            textColor: Theme.highlightedTextColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Fonts.size2

            CustomLabel {
                visible: control.title.length > 0
                Layout.fillWidth: true
                text: control.title
                font: Fonts.makeBoldFont(Fonts.standardFont)
                elide: Text.ElideRight
            }

            CustomLabel {
                visible: control.message.length > 0
                Layout.fillWidth: true
                text: control.message
                color: Theme.placeholderTextColor
                wrapMode: Text.WordWrap
            }
        }

        CustomButton {
            visible: control.actionText.length > 0
            text: control.actionText
            defaultHeight: Fonts.iconButtonSize
            defaultPadding: Fonts.size6
            onClicked: control.actionTriggered()
        }

        CustomToolButton {
            visible: control.closable
            iconSource: "qrc:/GeoControls/icons/Close.svg"
            tooltip: qsTr("Close")
            onClicked: control.closed()
        }
    }
}
