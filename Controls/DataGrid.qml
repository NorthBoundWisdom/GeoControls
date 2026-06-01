pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: control

    property var columns: []
    property var rows: []
    property var selectedRows: []
    property int currentIndex: -1
    property string sortRole: ""
    property bool sortAscending: true
    property string emptyText: qsTr("No rows")
    property string errorText: qsTr("DataGrid requires a non-empty columns array.")
    property int rowHeight: Math.max(Fonts.size34, ControlState.minInputHeight)
    property int headerHeight: Math.max(Fonts.size36, ControlState.minInputHeight)

    readonly property bool hasColumns: Array.isArray(columns) && columns.length > 0
    readonly property bool hasRows: Array.isArray(rows) && rows.length > 0

    signal activated(int index, var row)
    signal sortRequested(string role, bool ascending)
    signal selectionChanged(int index, var row, bool selected)

    color: Theme.contentSurfaceColor
    border.color: Theme.dividerColor
    border.width: ControlState.borderThin
    radius: ControlState.radiusMedium
    clip: true

    function columnTitle(column) {
        if (column && column.title !== undefined)
            return column.title
        if (column && column.role !== undefined)
            return column.role
        return String(column)
    }

    function columnRole(column) {
        if (column && column.role !== undefined)
            return column.role
        return String(column)
    }

    function columnWidth(column) {
        if (column && column.width !== undefined)
            return Math.max(Fonts.size60, column.width)
        return Fonts.size140
    }

    function columnSortable(column) {
        return !(column && column.sortable === false)
    }

    function cellText(row, column) {
        if (!row)
            return ""
        var role = columnRole(column)
        if (row[role] === undefined || row[role] === null)
            return ""
        return String(row[role])
    }

    function isSelected(index) {
        return Array.isArray(selectedRows) && selectedRows.indexOf(index) >= 0
    }

    function toggleSelection(index, row) {
        var next = Array.isArray(selectedRows) ? selectedRows.slice() : []
        var existing = next.indexOf(index)
        var selected = existing < 0
        if (selected)
            next.push(index)
        else
            next.splice(existing, 1)
        selectedRows = next
        currentIndex = index
        selectionChanged(index, row, selected)
    }

    function requestSort(column) {
        if (!columnSortable(column))
            return
        var role = columnRole(column)
        sortAscending = sortRole === role ? !sortAscending : true
        sortRole = role
        sortRequested(role, sortAscending)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        InfoBar {
            visible: !control.hasColumns
            Layout.fillWidth: true
            severity: "error"
            title: qsTr("Invalid DataGrid")
            message: control.errorText
            closable: false
        }

        Flickable {
            visible: control.hasColumns
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: headerRow.implicitWidth
            contentHeight: headerRow.height + rowList.contentHeight
            clip: true

            Column {
                width: Math.max(parent.width, headerRow.implicitWidth)

                Row {
                    id: headerRow
                    height: control.headerHeight

                    Repeater {
                        model: control.columns

                        Rectangle {
                            required property var modelData

                            width: control.columnWidth(modelData)
                            height: headerRow.height
                            color: Theme.pageSurfaceColor
                            border.color: Theme.dividerColor
                            border.width: ControlState.borderThin

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Fonts.size8
                                anchors.rightMargin: Fonts.size8
                                spacing: Fonts.size4

                                CustomLabel {
                                    Layout.fillWidth: true
                                    text: control.columnTitle(parent.modelData)
                                    font: Fonts.makeBoldFont(Fonts.standardFont)
                                    elide: Text.ElideRight
                                }

                                CustomLabel {
                                    visible: control.sortRole === control.columnRole(parent.modelData)
                                    text: control.sortAscending ? "^" : "v"
                                    color: Theme.placeholderTextColor
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: control.columnSortable(parent.modelData)
                                hoverEnabled: true
                                onClicked: control.requestSort(parent.modelData)
                            }
                        }
                    }
                }

                ListView {
                    id: rowList
                    width: Math.max(parent.width, headerRow.implicitWidth)
                    height: Math.max(0, control.height - headerRow.height)
                    interactive: false
                    model: control.hasRows ? control.rows : []

                    delegate: Rectangle {
                        id: rowDelegate

                        required property int index
                        required property var modelData

                        width: rowList.width
                        height: control.rowHeight
                        color: control.isSelected(index) ? Theme.railSurfaceColor : (index % 2 === 0 ? "transparent" : Theme.pageSurfaceColor)
                        border.color: Theme.dividerColor
                        border.width: ControlState.borderThin

                        Row {
                            anchors.fill: parent

                            Repeater {
                                model: control.columns

                                Item {
                                    required property var modelData

                                    width: control.columnWidth(modelData)
                                    height: rowDelegate.height

                                    CustomLabel {
                                        anchors.fill: parent
                                        anchors.leftMargin: Fonts.size8
                                        anchors.rightMargin: Fonts.size8
                                        text: control.cellText(rowDelegate.modelData, parent.modelData)
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: control.toggleSelection(rowDelegate.index, rowDelegate.modelData)
                            onDoubleClicked: control.activated(rowDelegate.index, rowDelegate.modelData)
                        }
                    }
                }
            }
        }

        InfoBar {
            visible: control.hasColumns && !control.hasRows
            Layout.fillWidth: true
            severity: "info"
            title: qsTr("Empty")
            message: control.emptyText
            closable: false
        }
    }
}
