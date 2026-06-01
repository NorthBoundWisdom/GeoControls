import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Page {
    id: control

    property string pageTitle: ""
    property string subtitle: ""
    property int contentSpacing: Fonts.size12
    property int contentPadding: Fonts.size16
    default property alias content: contentColumn.data

    background: Rectangle {
        color: Theme.pageSurfaceColor
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent ? parent.availableWidth : 0
            spacing: control.contentSpacing
            anchors.margins: control.contentPadding

            CustomLabel {
                visible: control.pageTitle.length > 0
                Layout.fillWidth: true
                text: control.pageTitle
                font: Fonts.makeBoldFont(Fonts.makeScaledFont(Fonts.standardFont, 1.35))
                elide: Text.ElideRight
            }

            CustomLabel {
                visible: control.subtitle.length > 0
                Layout.fillWidth: true
                text: control.subtitle
                color: Theme.placeholderTextColor
                wrapMode: Text.WordWrap
            }
        }
    }
}
