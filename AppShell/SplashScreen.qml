pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

Rectangle {
    id: splashScreen

    property string appName: Qt.application.displayName || Qt.application.name || "Application"
    property string appVersion: Qt.application.version || "0.0.0"
    property url logoSource: "qrc:/GeoControls/icons/AppIcon.png"
    property string websiteLabel: ""
    property url websiteUrl: ""
    property bool darkMode: false
    property bool aboutMode: false
    property var systemInfoLines: []
    property var licenseModel: []

    signal closeRequested

    readonly property color textColor: darkMode ? "#ffffff" : Theme.textColor
    readonly property color surfaceColor: darkMode ? "#1e1e1e" : Theme.baseColor
    readonly property color secondaryTextColor: darkMode ? "#aaaaaa" : Theme.placeholderTextColor
    readonly property color sectionSurfaceColor: darkMode ? "#262626" : Theme.pageSurfaceColor
    readonly property color sectionBorderColor: darkMode ? "#3a3a3a" : Theme.dividerColor
    readonly property string systemInfoText: {
        const lines = []
        lines.push(qsTr("Version: ") + appVersion)
        lines.push(qsTr("Qt: ") + qtVersion)
        for (let i = 0; i < systemInfoLines.length; ++i) {
            lines.push(String(systemInfoLines[i]))
        }
        return lines.join("\n")
    }

    width: aboutMode ? 760 : 480
    height: aboutMode ? 640 : 300
    color: surfaceColor
    border.width: aboutMode ? 2 : 0
    border.color: aboutMode ? Theme.highlightColor : "transparent"
    visible: true

    function close() {
        closeRequested()
        visible = false
    }

    Rectangle {
        id: closeButton
        width: Fonts.size30
        height: Fonts.size30
        radius: width / 2
        color: closeButtonMouseArea.containsMouse ? "#d83b01" : Theme.midColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Fonts.size10
        visible: splashScreen.aboutMode

        Text {
            text: "x"
            color: "#ffffff"
            font: Fonts.makeBoldFont(Fonts.standardFont)
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
        anchors.margins: Fonts.size20
        spacing: Fonts.size10

        Image {
            id: logoImage
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Fonts.size150
            Layout.preferredHeight: Fonts.size150
            source: splashScreen.logoSource
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: splashScreen.appName
            color: splashScreen.textColor
            font: Fonts.makeScaledFont(Fonts.standardFont, 2.0)
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Version") + " " + splashScreen.appVersion
            color: splashScreen.secondaryTextColor
            font: Fonts.standardFont
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: splashScreen.websiteLabel
            color: Theme.highlightColor
            font: Fonts.makeUnderlineFont(Fonts.annotationFont)
            visible: splashScreen.aboutMode && text.length > 0 && String(splashScreen.websiteUrl).length > 0

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(splashScreen.websiteUrl)
            }
        }

        TabBar {
            id: aboutTabBar
            Layout.fillWidth: true
            visible: splashScreen.aboutMode
            currentIndex: aboutPageStack.currentIndex
            onCurrentIndexChanged: aboutPageStack.currentIndex = currentIndex

            TabButton {
                text: qsTr("About")
            }

            TabButton {
                text: qsTr("Licenses")
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

                Text {
                    width: parent.width
                    text: splashScreen.systemInfoText
                    wrapMode: Text.WrapAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    color: splashScreen.secondaryTextColor
                    font: Fonts.annotationFont
                }
            }

            ScrollView {
                contentWidth: availableWidth
                clip: true

                Column {
                    width: parent.width
                    spacing: Fonts.size12

                    Repeater {
                        model: splashScreen.licenseModel

                        Rectangle {
                            id: licenseCard
                            required property var modelData

                            width: parent ? parent.width : 0
                            radius: Fonts.size8
                            color: splashScreen.sectionSurfaceColor
                            border.width: Fonts.size1
                            border.color: splashScreen.sectionBorderColor
                            implicitHeight: cardColumn.implicitHeight + Fonts.size24

                            Column {
                                id: cardColumn
                                anchors.fill: parent
                                anchors.margins: Fonts.size12
                                spacing: Fonts.size8

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.version ? licenseCard.modelData.name + " " + licenseCard.modelData.version : licenseCard.modelData.name
                                    wrapMode: Text.Wrap
                                    color: splashScreen.textColor
                                    font: Fonts.makeBoldFont(Fonts.standardFont)
                                }

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.license || ""
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: Fonts.annotationFont
                                    visible: text.length > 0
                                }

                                Text {
                                    width: parent.width
                                    text: licenseCard.modelData.notice || ""
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: Fonts.annotationFont
                                    visible: text.length > 0
                                }

                                Button {
                                    text: qsTr("Open Link")
                                    visible: licenseCard.modelData.url
                                    onClicked: Qt.openUrlExternally(licenseCard.modelData.url)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
