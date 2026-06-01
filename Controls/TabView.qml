pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

ColumnLayout {
    id: control

    property var model: []
    property int currentIndex: 0
    property bool tabsClosable: true
    property bool tabsMovable: true
    property string emptyText: qsTr("TabView requires a non-empty model.")
    readonly property bool hasModel: Array.isArray(model) && model.length > 0

    signal activated(int index)
    signal closeRequested(int index)
    signal moveRequested(int from, int to)

    spacing: 0

    function titleAt(index) {
        if (!Array.isArray(control.model) || index < 0 || index >= control.model.length)
            return ""

        var item = control.model[index]
        if (item && item.title !== undefined)
            return item.title

        return String(item)
    }

    CustomTabBar {
        id: tabBar
        visible: control.hasModel
        Layout.fillWidth: true
        targetIndex: control.currentIndex

        Repeater {
            model: control.hasModel ? control.model : []

            CustomTabButton {
                required property int index
                required property var modelData

                tabBar: tabBar
                targetIndex: index
                text: modelData && modelData.title !== undefined ? modelData.title : String(modelData)
                iconSource: modelData && modelData.iconSource !== undefined ? modelData.iconSource : ""
                closeable: control.tabsClosable && !(modelData && modelData.closeable === false)
                movable: control.tabsMovable
                onClicked: {
                    control.currentIndex = index
                    control.activated(index)
                }
                onCloseRequested: control.closeRequested(index)
                onMoveRequested: function (toIndex) {
                    control.moveRequested(index, toIndex)
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.contentSurfaceColor
        border.color: Theme.dividerColor
        border.width: ControlState.borderThin

        CustomLabel {
            anchors.centerIn: parent
            text: control.hasModel ? control.titleAt(control.currentIndex) : control.emptyText
            color: Theme.placeholderTextColor
        }
    }
}
