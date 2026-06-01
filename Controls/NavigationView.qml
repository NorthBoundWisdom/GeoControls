pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0
    property int paneWidth: Fonts.size200
    property bool compact: width < Fonts.size600
    property string titleRole: "title"
    property string subtitleRole: "subtitle"
    property string iconRole: "iconSource"
    property string sectionRole: "section"
    default property alias content: contentHost.data

    signal activated(int index, var item)

    color: Theme.pageSurfaceColor

    function valueFor(item, role, fallback) {
        if (item && typeof item === "object" && role.length > 0 && item[role] !== undefined)
            return item[role]
        return fallback
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: control.compact ? Fonts.size80 : control.paneWidth
            Layout.fillHeight: true
            color: Theme.contentSurfaceColor
            border.color: Theme.dividerColor
            border.width: ControlState.borderThin

            ListView {
                id: navigationList
                anchors.fill: parent
                anchors.margins: Fonts.size8
                spacing: Fonts.size4
                clip: true
                model: Array.isArray(control.model) ? control.model : []
                currentIndex: control.currentIndex

                delegate: ColumnLayout {
                    required property int index
                    required property var modelData

                    width: navigationList.width
                    spacing: Fonts.size2

                    CustomLabel {
                        visible: !control.compact && control.valueFor(parent.modelData, control.sectionRole, "").length > 0
                        Layout.fillWidth: true
                        text: control.valueFor(parent.modelData, control.sectionRole, "")
                        color: Theme.placeholderTextColor
                        font: Fonts.annotationFont
                        leftPadding: Fonts.size8
                    }

                    ListTile {
                        Layout.fillWidth: true
                        title: control.compact ? "" : control.valueFor(parent.modelData, control.titleRole, String(parent.modelData))
                        subtitle: control.compact ? "" : control.valueFor(parent.modelData, control.subtitleRole, "")
                        iconSource: control.valueFor(parent.modelData, control.iconRole, "")
                        selected: control.currentIndex === parent.index
                        showDisclosure: !control.compact
                        onClicked: {
                            control.currentIndex = parent.index
                            control.activated(parent.index, parent.modelData)
                        }
                    }
                }
            }
        }

        Item {
            id: contentHost
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
