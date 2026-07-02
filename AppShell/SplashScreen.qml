pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: splashScreen

    property string appName: Qt.application.name || "Application"
    property string appVersion: Qt.application.version || "0.0.0"
    property string appDescription: ""
    property string copyrightText: ""
    property string qtVersion: ""
    property url logoSource: "qrc:/GeoControls/icons/AppIcon.png"
    property string websiteLabel: ""
    property url websiteUrl: ""
    property bool darkMode: false
    property bool aboutMode: false
    property var detailModel: []
    property var systemInfoLines: []
    property var licenseModel: []

    signal closeRequested

    readonly property color textColor: darkMode ? "#ffffff" : Theme.textColor
    readonly property color surfaceColor: darkMode ? "#1e1e1e" : Theme.baseColor
    readonly property color secondaryTextColor: darkMode ? "#aaaaaa" : Theme.placeholderTextColor
    readonly property color sectionSurfaceColor: darkMode ? "#262626" : Theme.pageSurfaceColor
    readonly property color sectionBorderColor: darkMode ? "#3a3a3a" : Theme.dividerColor
    readonly property font titleFont: Fonts.makeScaledFont(Fonts.standardFont, aboutMode ? 1.25 : 2.0)
    readonly property font bodyFont: aboutMode ? Fonts.makeScaledFont(Fonts.standardFont, 0.82) : Fonts.standardFont
    readonly property font labelFont: Fonts.makeScaledFont(Fonts.standardFont, aboutMode ? 0.72 : 0.8)
    readonly property font bodyBoldFont: Fonts.makeBoldFont(bodyFont)
    readonly property int tabHeight: Math.max(24, Math.round(Fonts.resolvedFontPixelSize() * 1.25))
    readonly property string versionText: appVersion.length > 0 ? qsTr("Version") + " " + appVersion : ""
    readonly property string websiteText: String(websiteLabel)
    readonly property bool hasWebsite: websiteText.length > 0 && String(websiteUrl).length > 0
    readonly property string systemInfoText: {
        const lines = []
        if (appVersion.length > 0) {
            lines.push(qsTr("Version: ") + appVersion)
        }
        if (qtVersion.length > 0) {
            lines.push(qsTr("Qt: ") + qtVersion)
        }
        for (let i = 0; i < systemInfoLines.length; ++i) {
            lines.push(String(systemInfoLines[i]))
        }
        return lines.join("\n")
    }
    readonly property string diagnosticsText: {
        const lines = []
        lines.push(appName)
        if (versionText.length > 0) {
            lines.push(versionText)
        }
        if (appDescription.length > 0) {
            lines.push(appDescription)
        }
        if (copyrightText.length > 0) {
            lines.push(copyrightText)
        }
        for (let i = 0; i < detailModel.length; ++i) {
            const item = detailModel[i]
            const label = item && item.label ? String(item.label) : ""
            const value = item && item.value ? String(item.value) : ""
            if (label.length > 0 || value.length > 0) {
                lines.push(label.length > 0 ? label + ": " + value : value)
            }
        }
        if (systemInfoText.length > 0) {
            lines.push("")
            lines.push(systemInfoText)
        }
        return lines.join("\n")
    }

    width: aboutMode ? 660 : 480
    height: aboutMode ? 540 : 300
    color: surfaceColor
    border.width: aboutMode ? Fonts.size1 : 0
    border.color: aboutMode ? Theme.highlightColor : "transparent"
    visible: true

    function close() {
        closeRequested()
        visible = false
    }

    function copyDiagnostics() {
        clipboardText.text = diagnosticsText
        clipboardText.selectAll()
        clipboardText.copy()
    }

    TextEdit {
        id: clipboardText
        visible: false
    }

    Rectangle {
        id: closeButton
        z: 2
        width: Fonts.size24
        height: Fonts.size24
        radius: width / 2
        color: closeButtonMouseArea.containsMouse ? "#d83b01" : Theme.midColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Fonts.size8
        visible: splashScreen.aboutMode

        Text {
            text: "x"
            color: "#ffffff"
            font: splashScreen.bodyBoldFont
            anchors.centerIn: parent
        }

        MouseArea {
            id: closeButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: splashScreen.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: splashScreen.aboutMode ? Fonts.size16 : Fonts.size20
        spacing: splashScreen.aboutMode ? Fonts.size8 : Fonts.size10

        Image {
            id: logoImage
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: splashScreen.aboutMode ? Fonts.size70 : Fonts.size150
            Layout.preferredHeight: splashScreen.aboutMode ? Fonts.size70 : Fonts.size150
            source: splashScreen.logoSource
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width - Fonts.size30
            text: splashScreen.appName
            color: splashScreen.textColor
            font: splashScreen.titleFont
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width - Fonts.size30
            text: splashScreen.versionText
            color: splashScreen.secondaryTextColor
            font: splashScreen.bodyFont
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width - Fonts.size30
            text: splashScreen.appDescription
            color: splashScreen.secondaryTextColor
            font: splashScreen.labelFont
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            visible: splashScreen.aboutMode && text.length > 0
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Fonts.size6
            visible: splashScreen.aboutMode && (splashScreen.hasWebsite || splashScreen.diagnosticsText.length > 0)

            CustomButton {
                text: splashScreen.websiteText
                visible: splashScreen.hasWebsite
                font: splashScreen.bodyFont
                defaultHeight: Fonts.size24
                defaultPadding: Fonts.size4
                onClicked: Qt.openUrlExternally(splashScreen.websiteUrl)
            }

            CustomButton {
                text: qsTr("Copy Diagnostics")
                visible: splashScreen.diagnosticsText.length > 0
                font: splashScreen.bodyFont
                defaultHeight: Fonts.size24
                defaultPadding: Fonts.size4
                onClicked: splashScreen.copyDiagnostics()
            }
        }

        CustomTabBarEven {
            id: aboutTabBar
            Layout.fillWidth: true
            Layout.preferredHeight: splashScreen.tabHeight
            Layout.maximumHeight: splashScreen.tabHeight
            implicitHeight: splashScreen.tabHeight
            defaultHeight: splashScreen.tabHeight
            defaultPadding: Fonts.size4
            visible: splashScreen.aboutMode
            targetIndex: aboutPageStack.currentIndex
            onTargetIndexChanged: aboutPageStack.currentIndex = targetIndex

            CustomTabButton {
                text: qsTr("About")
                font: splashScreen.bodyFont
            }

            CustomTabButton {
                text: qsTr("System")
                font: splashScreen.bodyFont
            }

            CustomTabButton {
                text: qsTr("Licenses")
                font: splashScreen.bodyFont
            }
        }

        StackLayout {
            id: aboutPageStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: splashScreen.aboutMode

            ScrollView {
                contentWidth: availableWidth
                clip: true

                Column {
                    width: parent.width
                    spacing: Fonts.size6

                    Repeater {
                        model: splashScreen.detailModel

                        Rectangle {
                            id: detailCard
                            required property var modelData

                            width: parent ? parent.width : 0
                            radius: Fonts.size4
                            color: splashScreen.sectionSurfaceColor
                            border.width: Fonts.size1
                            border.color: splashScreen.sectionBorderColor
                            implicitHeight: detailRow.implicitHeight + Fonts.size12

                            RowLayout {
                                id: detailRow
                                anchors.fill: parent
                                anchors.margins: Fonts.size6
                                spacing: Fonts.size8

                                Text {
                                    Layout.preferredWidth: Fonts.size120
                                    text: detailCard.modelData.label || ""
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: splashScreen.labelFont
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: detailCard.modelData.value || ""
                                    wrapMode: Text.WrapAnywhere
                                    color: splashScreen.textColor
                                    font: splashScreen.bodyFont
                                }
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        text: splashScreen.copyrightText
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        color: splashScreen.secondaryTextColor
                        font: splashScreen.labelFont
                        visible: text.length > 0
                    }
                }
            }

            ScrollView {
                contentWidth: availableWidth
                clip: true

                TextArea {
                    width: parent.width
                    text: splashScreen.systemInfoText
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    color: splashScreen.secondaryTextColor
                    font: splashScreen.labelFont
                    leftPadding: Fonts.size8
                    rightPadding: Fonts.size8
                    topPadding: Fonts.size8
                    bottomPadding: Fonts.size8
                    background: Rectangle {
                        radius: Fonts.size4
                        color: splashScreen.sectionSurfaceColor
                        border.width: Fonts.size1
                        border.color: splashScreen.sectionBorderColor
                    }
                }
            }

            ScrollView {
                contentWidth: availableWidth
                clip: true

                Column {
                    width: parent.width
                    spacing: Fonts.size8

                    Repeater {
                        model: splashScreen.licenseModel

                        Rectangle {
                            id: licenseCard
                            required property var modelData

                            width: parent ? parent.width : 0
                            radius: Fonts.size4
                            color: splashScreen.sectionSurfaceColor
                            border.width: Fonts.size1
                            border.color: splashScreen.sectionBorderColor
                            implicitHeight: cardColumn.implicitHeight + Fonts.size16

                            Column {
                                id: cardColumn
                                anchors.fill: parent
                                anchors.margins: Fonts.size8
                                spacing: Fonts.size6

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.version ? licenseCard.modelData.name + " " + licenseCard.modelData.version : licenseCard.modelData.name
                                    wrapMode: Text.Wrap
                                    color: splashScreen.textColor
                                    font: splashScreen.bodyBoldFont
                                }

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.license || ""
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: splashScreen.labelFont
                                    visible: text.length > 0
                                }

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.notice || ""
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: splashScreen.labelFont
                                    visible: text.length > 0
                                }

                                CustomButton {
                                    property string linkUrl: licenseCard.modelData && licenseCard.modelData.url ? String(licenseCard.modelData.url) : ""

                                    text: qsTr("Open Link")
                                    visible: linkUrl.length > 0
                                    font: splashScreen.bodyFont
                                    defaultHeight: Fonts.size24
                                    defaultPadding: Fonts.size4
                                    onClicked: Qt.openUrlExternally(linkUrl)
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            visible: !splashScreen.aboutMode
        }
    }
}
