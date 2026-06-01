pragma ComponentBehavior: Bound

import QtQuick 2.15
import GeoControls 1.0

DataGrid {
    id: control

    property string keyRole: "id"
    property string childrenRole: "children"
    property var expandedKeys: []
    property var sourceRows: []
    property int indentWidth: Fonts.size20

    signal expanded(string key, bool isExpanded)

    rows: flattenedRows()

    function keyFor(row) {
        if (row && row[keyRole] !== undefined)
            return String(row[keyRole])
        return ""
    }

    function isExpandedKey(key) {
        return Array.isArray(expandedKeys) && expandedKeys.indexOf(key) >= 0
    }

    function toggleExpanded(index, row) {
        var key = keyFor(row)
        if (key.length === 0 || !row || !Array.isArray(row[childrenRole]) || row[childrenRole].length === 0)
            return
        var next = Array.isArray(expandedKeys) ? expandedKeys.slice() : []
        var existing = next.indexOf(key)
        var opened = existing < 0
        if (opened)
            next.push(key)
        else
            next.splice(existing, 1)
        expandedKeys = next
        expanded(key, opened)
    }

    function flattenedRows() {
        var result = []
        if (!Array.isArray(sourceRows))
            return result

        function appendRows(items, depth) {
            for (var i = 0; i < items.length; ++i) {
                var item = items[i]
                if (!item)
                    continue
                var copy = {}
                for (var key in item) {
                    if (key !== childrenRole)
                        copy[key] = item[key]
                }
                copy.__depth = depth
                copy.__hasChildren = Array.isArray(item[childrenRole]) && item[childrenRole].length > 0
                copy.__expanded = isExpandedKey(keyFor(item))
                result.push(copy)

                if (copy.__hasChildren && copy.__expanded)
                    appendRows(item[childrenRole], depth + 1)
            }
        }

        appendRows(sourceRows, 0)
        return result
    }

    function cellText(row, column) {
        var role = control.columnRole(column)
        var text = row && row[role] !== undefined && row[role] !== null ? String(row[role]) : ""
        if (control.columns.length > 0 && role === control.columnRole(control.columns[0])) {
            var marker = row && row.__hasChildren ? (row.__expanded ? "- " : "+ ") : "  "
            var depthText = ""
            for (var i = 0; i < (row.__depth || 0); ++i)
                depthText += "    "
            return depthText + marker + text
        }
        return text
    }

    onActivated: function (index, row) {
        control.toggleExpanded(index, row)
    }
}
