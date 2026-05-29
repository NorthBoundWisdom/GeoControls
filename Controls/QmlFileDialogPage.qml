import QtQuick 2.15
import QtQuick.Dialogs

Item {
    id: root
    objectName: "qmlFileDialogPage"

    property string dialogTitle: qsTr("Select File")
    property var nameFilters: []
    property string dialogMode: "open" // "open", "save", "openFiles"
    property url currentFolder: ""
    property url initialSelectedFile: ""

    signal fileAccepted(string filePath, string selectedFilter, var filePaths)
    signal fileRejected
    signal dialogClosed

    FileDialog {
        id: fileDialog
        title: root.dialogTitle
        nameFilters: root.nameFilters
        currentFolder: root.currentFolder
        fileMode: root.dialogMode === "save" ? FileDialog.SaveFile : root.dialogMode === "openFiles" ? FileDialog.OpenFiles : FileDialog.OpenFile
        Binding {
            target: fileDialog
            property: "currentFile"
            value: root.initialSelectedFile
            when: root.dialogMode === "save" && root.initialSelectedFile.toString() !== ""
        }

        onAccepted: {
            var files = [];
            if (fileMode === FileDialog.OpenFiles) {
                for (var i = 0; i < selectedFiles.length; ++i) {
                    files.push(toLocalFile(selectedFiles[i]));
                }
            } else if (selectedFile) {
                files.push(toLocalFile(selectedFile));
            }
            root.fileAccepted(files.length > 0 ? files[0] : "", normalizeFilter(selectedNameFilter), files);
            fileDialog.close();
        }

        onRejected: {
            root.fileRejected();
            fileDialog.close();
        }

        onVisibleChanged: {
            if (!visible) {
                root.dialogClosed();
            }
        }
    }

    function toLocalFile(urlValue) {
        if (urlValue === undefined || urlValue === null)
            return "";
        if (typeof urlValue === "string") {
            return urlValue.startsWith("file://") ? Qt.urlToLocalFile(urlValue) : urlValue;
        }
        if (urlValue.toLocalFile)
            return urlValue.toLocalFile();
        return String(urlValue);
    }

    function normalizeFilter(filterValue) {
        if (filterValue === undefined || filterValue === null)
            return "";
        if (typeof filterValue === "string")
            return filterValue;

        var name = filterValue["name"];
        var filters = filterValue["filters"];
        var globs = filterValue["globs"];
        var extensions = filterValue["extensions"];

        if ((!filters || filters.length === 0) && extensions && extensions.length > 0) {
            filters = [];
            for (var i = 0; i < extensions.length; ++i) {
                filters.push("*." + extensions[i]);
            }
        }

        if ((!filters || filters.length === 0) && globs && globs.length > 0)
            filters = globs;

        if (name && filters && filters.length > 0)
            return name + " (" + filters.join(" ") + ")";
        if (filters && filters.length > 0)
            return filters.join(" ");
        return String(filterValue);
    }

    function openDialog() {
        fileDialog.open();
    }

    function closeDialog() {
        fileDialog.close();
    }
}
