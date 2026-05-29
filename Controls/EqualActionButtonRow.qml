import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

RowLayout {
    id: root

    property bool enforceEqualWidths: true
    property int equalPreferredWidth: Fonts.size1
    property int equalMinimumWidth: 0

    function syncChildLayouts() {
        if (!enforceEqualWidths) {
            return;
        }

        for (var i = 0; i < children.length; ++i) {
            var child = children[i];
            if (!child || child.visible === false) {
                continue;
            }

            if (child.Layout !== undefined) {
                child.Layout.fillWidth = true;
                child.Layout.preferredWidth = equalPreferredWidth;
                if (equalMinimumWidth >= 0) {
                    child.Layout.minimumWidth = equalMinimumWidth;
                }
            }
        }
    }

    onChildrenChanged: Qt.callLater(syncChildLayouts)
    onVisibleChildrenChanged: Qt.callLater(syncChildLayouts)
    Component.onCompleted: syncChildLayouts()
}
