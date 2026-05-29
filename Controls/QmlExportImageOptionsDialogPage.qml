import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.15
import GeoToy.Controls 1.0

DialogShell {
    id: root
    objectName: "QmlExportImageOptionsDialogPage"

    width: Math.max(Fonts.size420, unit * Fonts.size24)
    bodyFillHeight: false
    bottomSpacerHeight: Math.round(unit * 0.5)

    property string dialogTitle: "Export Image Options"
    property string initialFormat: "png"
    property string initialMode: "viewport"
    property int initialLongEdgePx: 4096
    property bool initialIncludeAxis: false
    property bool initialIncludeOverlayText: false

    property string selectedFormat: "png"
    property string selectedMode: "viewport"
    property int selectedLongEdgePx: 4096
    property bool includeAxis: false
    property bool includeOverlayText: false

    signal optionsAccepted(string format, string mode, int longEdgePx, bool includeAxis, bool includeOverlayText)
    signal cancelled

    titleText: dialogTitle
    onCloseRequested: root.cancelled()

    function normalizeFormat(inputFormat) {
        const normalized = (inputFormat || "").toLowerCase().trim();
        if (normalized === "pdf") {
            return "pdf";
        }
        return "png";
    }

    function normalizeMode(inputMode) {
        const normalized = (inputMode || "").toLowerCase().trim();
        if (normalized === "fitall" || normalized === "fit_all") {
            return "fitall";
        }
        return "viewport";
    }

    function normalizeLongEdge(inputLongEdge) {
        if (inputLongEdge >= 8192) {
            return 8192;
        }
        if (inputLongEdge <= 2048) {
            return 2048;
        }
        return 4096;
    }

    function resolutionIndexByLongEdge(inputLongEdge) {
        const normalizedLongEdge = normalizeLongEdge(inputLongEdge);
        if (normalizedLongEdge === 2048) {
            return 0;
        }
        if (normalizedLongEdge === 8192) {
            return 2;
        }
        return 1;
    }

    function longEdgeByResolutionIndex(index) {
        if (index === 0) {
            return 2048;
        }
        if (index === 2) {
            return 8192;
        }
        return 4096;
    }

    bodyItem: ColumnLayout {
        spacing: Math.round(unit * 0.75)

        Label {
            text: qsTr("Format")
            font: Fonts.standardFont
            color: Theme.textColor
            Layout.fillWidth: true
        }

        CustomComboBox {
            id: formatCombo
            Layout.fillWidth: true
            editable: false
            model: [qsTr("PNG"), qsTr("PDF")]
            currentIndex: root.selectedFormat === "pdf" ? 1 : 0
            onActivated: function (index) {
                root.selectedFormat = index === 1 ? "pdf" : "png";
            }
        }

        Label {
            text: qsTr("Export Mode")
            font: Fonts.standardFont
            color: Theme.textColor
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Fonts.size16
            Layout.fillWidth: true

            ButtonGroup {
                id: modeGroup
            }

            CustomRadioButton {
                id: viewportRadio
                text: qsTr("Viewport")
                ButtonGroup.group: modeGroup
                checked: root.selectedMode === "viewport"
                onClicked: root.selectedMode = "viewport"
            }

            CustomRadioButton {
                id: fitallRadio
                text: qsTr("FitAll")
                ButtonGroup.group: modeGroup
                checked: root.selectedMode === "fitall"
                onClicked: root.selectedMode = "fitall"
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Label {
            text: qsTr("Resolution (Long Edge)")
            font: Fonts.standardFont
            color: Theme.textColor
            Layout.fillWidth: true
        }

        CustomComboBox {
            id: resolutionCombo
            Layout.fillWidth: true
            editable: false
            model: [qsTr("2K (2048)"), qsTr("4K (4096)"), qsTr("8K (8192)")]
            currentIndex: root.resolutionIndexByLongEdge(root.selectedLongEdgePx)
            onActivated: function (index) {
                root.selectedLongEdgePx = root.longEdgeByResolutionIndex(index);
            }
        }

        Label {
            text: qsTr("Overlays")
            font: Fonts.standardFont
            color: Theme.textColor
            Layout.fillWidth: true
        }

        CustomCheckBox {
            text: qsTr("Export Axis Lines")
            checked: root.includeAxis
            onCheckedChanged: root.includeAxis = checked
        }

        CustomCheckBox {
            text: qsTr("Export Edge Label Text")
            checked: root.includeOverlayText
            onCheckedChanged: root.includeOverlayText = checked
        }
    }

    footerItem: RowLayout {
        spacing: Fonts.size10

        Item {
            Layout.fillWidth: true
        }

        CustomButton {
            text: qsTr("OK")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            onClicked: {
                root.optionsAccepted(root.selectedFormat, root.selectedMode, root.selectedLongEdgePx, root.includeAxis, root.includeOverlayText);
                root.close();
            }
        }

        CustomButton {
            text: qsTr("Cancel")
            buttonColor: Theme.buttonColor
            buttonTextColor: Theme.buttonTextColor
            activeFocusOnTab: true
            onClicked: root.requestClose("cancel")
        }
    }

    Component.onCompleted: {
        root.selectedFormat = root.normalizeFormat(root.initialFormat);
        root.selectedMode = root.normalizeMode(root.initialMode);
        root.selectedLongEdgePx = root.normalizeLongEdge(root.initialLongEdgePx);
        root.includeAxis = root.initialIncludeAxis;
        root.includeOverlayText = root.initialIncludeOverlayText;
    }
}
