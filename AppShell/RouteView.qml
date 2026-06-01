pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property var routes: []
    property string activeRouteId: ""
    property string routeIdRole: "routeId"
    property string titleRole: "title"
    property string subtitleRole: "subtitle"
    property string iconRole: "iconSource"
    property string emptyText: qsTr("No routes")

    readonly property bool hasRoutes: Array.isArray(routes) && routes.length > 0

    signal routeActivated(string routeId, var route)

    color: Theme.pageSurfaceColor
    border.color: Theme.dividerColor
    border.width: ControlState.borderThin
    radius: ControlState.radiusMedium

    function valueFor(route, role, fallback) {
        if (route && typeof route === "object" && route[role] !== undefined)
            return route[role]
        return fallback
    }

    function routeIdFor(route) {
        return String(valueFor(route, routeIdRole, ""))
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Fonts.size6
        spacing: Fonts.size6

        InfoBar {
            visible: !control.hasRoutes
            Layout.fillWidth: true
            severity: "error"
            title: qsTr("Missing routes")
            message: control.emptyText
            closable: false
        }

        Repeater {
            model: control.hasRoutes ? control.routes : []

            ListTile {
                required property var modelData

                Layout.fillWidth: true
                enabled: !(modelData && modelData.enabled === false)
                title: control.valueFor(modelData, control.titleRole, control.routeIdFor(modelData))
                subtitle: control.valueFor(modelData, control.subtitleRole, "")
                iconSource: control.valueFor(modelData, control.iconRole, "")
                selected: control.routeIdFor(modelData) === control.activeRouteId
                showDisclosure: true
                onClicked: {
                    control.activeRouteId = control.routeIdFor(modelData)
                    control.routeActivated(control.activeRouteId, modelData)
                }
            }
        }
    }
}
