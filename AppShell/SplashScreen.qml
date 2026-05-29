pragma ComponentBehavior: Bound
import GeoToy.Controls 1.0

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: splashScreen

    property string appVersion: appVersionInfo || "0.0.0"
    property bool darkMode: false
    property bool aboutMode: false
    property bool devMode: false
    property var startTime: new Date()
    readonly property string systemInfo: buildSystemInfo()

    property font standardFont: Qt.application.font
    property font annotationFont: {
        var f = Qt.font({
            family: standardFont.family,
            weight: standardFont.weight,
            italic: standardFont.italic,
            underline: standardFont.underline,
            strikeout: standardFont.strikeout
        })
        if (standardFont.pixelSize > 0) {
            f.pixelSize = Math.max(1, Math.round(standardFont.pixelSize * 0.9))
        } else if (standardFont.pointSize > 0) {
            f.pointSize = standardFont.pointSize * 0.9
        } else {
            f.pixelSize = Math.max(1, Math.round(Qt.application.font.pixelSize * 0.9))
        }
        return f
    }

    QtObject {
        id: fontUtil
        function withSize(baseFont, px, pt) {
            if (px > 0) {
                return {
                    pixelSize: px
                }
            }
            if (pt > 0) {
                return {
                    pointSize: pt
                }
            }
            return {
                pixelSize: Qt.application.font.pixelSize
            }
        }
        function bold(baseFont) {
            var f = Qt.font({
                family: baseFont.family,
                weight: Font.Bold,
                italic: baseFont.italic,
                underline: baseFont.underline,
                strikeout: baseFont.strikeout
            })
            var s = withSize(baseFont, baseFont.pixelSize, baseFont.pointSize)
            if (s.pixelSize) {
                f.pixelSize = s.pixelSize
            } else {
                f.pointSize = s.pointSize
            }
            return f
        }
        function underline(baseFont) {
            var f = Qt.font({
                family: baseFont.family,
                weight: baseFont.weight,
                italic: baseFont.italic,
                underline: true,
                strikeout: baseFont.strikeout
            })
            var s = withSize(baseFont, baseFont.pixelSize, baseFont.pointSize)
            if (s.pixelSize) {
                f.pixelSize = s.pixelSize
            } else {
                f.pointSize = s.pointSize
            }
            return f
        }
    }

    property color textColor: darkMode ? "#ffffff" : "#202020"
    property color baseColor: darkMode ? "#1e1e1e" : "#ffffff"
    property color accentColor: darkMode ? "#2980b9" : "#6DB6FF"
    property color secondaryTextColor: darkMode ? "#aaaaaa" : "#909090"
    property color shadowColor: darkMode ? "#30000000" : "#10000000"
    property color sectionSurfaceColor: darkMode ? "#262626" : "#f7f9fc"
    property color sectionBorderColor: darkMode ? "#3a3a3a" : "#d7dfeb"
    property color tabInactiveColor: darkMode ? "#2b2b2b" : "#eef3fa"
    property color tabTextInactiveColor: darkMode ? "#d0d0d0" : "#506070"
    property color warningTextColor: darkMode ? "#ffb454" : "#9a5800"
    property int aboutCurrentTabIndex: 0
    readonly property var openSourceLibraries: [
        {
            name: qsTr("Qt"),
            version: qtVersion,
            scope: qsTr("Runtime Core"),
            usage: qsTr("Desktop UI, QML, window system, network access, and OpenGL integration."),
            license: "LGPL v3",
            notice: qsTr("This product uses Qt modules available under the LGPL; Qt also offers GPL and commercial licensing, and some modules are not covered by the LGPL."),
            distributionTip: qsTr("External package dependency; include the corresponding Qt license text with the installer for official distribution."),
            url: "https://doc.qt.io/qt-6/licensing.html"
        },
        {
            name: qsTr("Open CASCADE Technology (OCCT)"),
            version: "",
            scope: qsTr("Runtime Core"),
            usage: qsTr("3D geometric modeling, topological data structures, B-Rep processing, and the 3D display kernel."),
            license: "LGPL v2.1 with OCCT exception",
            notice: qsTr("OCCT 6.7.0 and later are distributed under LGPL v2.1 with the Open CASCADE Exception; product documentation should explicitly mention OCCT when distributing."),
            distributionTip: qsTr("External package dependency; include the OCCT license text with the installer for official distribution."),
            url: "https://dev.opencascade.org/resources/licensing"
        },
        {
            name: "OpenCV",
            version: "",
            scope: qsTr("Runtime Features"),
            usage: qsTr("Image processing, contour and morphology operations, plus support for selected point-cloud and 2D algorithms."),
            license: "Apache-2.0",
            notice: qsTr("The current build pulls in OpenCV modules such as core, imgproc, and imgcodecs through the package manager."),
            distributionTip: qsTr("External package dependency; include the OpenCV license text with the installer for official distribution."),
            url: "https://opencv.org/about/"
        },
        {
            name: "PCL",
            version: "",
            scope: qsTr("Runtime Features"),
            usage: qsTr("Point-cloud I/O, filtering, segmentation, feature extraction, and surface processing."),
            license: "BSD-3-Clause",
            notice: qsTr("The current PcAlg module directly depends on PCL components such as common, io, filters, and segmentation."),
            distributionTip: qsTr("External package dependency; include the PCL license text with the installer for official distribution."),
            url: "https://github.com/PointCloudLibrary/pcl"
        },
        {
            name: "FreeType",
            version: "",
            scope: qsTr("Runtime Features"),
            usage: qsTr("Viewer text rendering and glyph rasterization."),
            license: "FTL / GPL-2.0-or-later",
            notice: qsTr("The vendored copy in this repository follows FreeType's official dual-license distribution model."),
            distributionTip: qsTr("LICENSE.TXT is already included in the repository; still include the license text with the installer for official distribution."),
            url: "https://freetype.org/license.html"
        },
        {
            name: "CGAL",
            version: "",
            scope: qsTr("Geometry Algorithms"),
            usage: qsTr("2D boolean operations, skeletons, triangulation, and other geometry algorithms."),
            license: "GPL-3.0-or-later / LGPL-3.0-or-later by package / commercial",
            notice: qsTr("Licensing differs across CGAL packages; the exact CGAL components used by this product should follow the license files provided in the installed environment."),
            distributionTip: qsTr("External package dependency; provide the license files that match the actually installed CGAL components before official distribution."),
            url: "https://www.cgal.org/license.html"
        },
        {
            name: qsTr("Eigen3"),
            version: "",
            scope: qsTr("Mathematical Foundations"),
            usage: qsTr("Linear algebra, matrix operations, and vector math used across Geo3d, PcAlg, urdfdom2, and related modules."),
            license: "MPL-2.0",
            notice: qsTr("The main project and multiple submodules directly depend on Eigen3."),
            distributionTip: qsTr("External package dependency; include the Eigen3 license text with the installer for official distribution."),
            url: "https://eigen.tuxfamily.org/"
        },
        {
            name: qsTr("Boost"),
            version: "",
            scope: qsTr("Core Algorithms"),
            usage: qsTr("Boost.Graph, Boost.Variant, and several general-purpose template facilities."),
            license: "BSL-1.0",
            notice: qsTr("The main project and Geo2d use Boost components directly."),
            distributionTip: qsTr("External package dependency; include the Boost license text with the installer for official distribution."),
            url: "https://www.boost.org/users/license.html"
        },
        {
            name: "CavalierContours",
            version: "",
            scope: qsTr("Geometry Algorithms"),
            usage: qsTr("2D offsetting, contours, intersections, and related geometric processing."),
            license: "MIT",
            notice: qsTr("Pinned as a third-party dependency in a repository subdirectory for Geo2d."),
            distributionTip: qsTr("LICENSE is already included in the repository; still include the license text with the installer for official distribution."),
            url: "https://github.com/jbuckmccready/CavalierContours"
        },
        {
            name: "libtess2",
            version: "",
            scope: qsTr("Geometry Algorithms"),
            usage: qsTr("2D contour triangulation and polygon tessellation."),
            license: "SGI Free Software License B",
            notice: qsTr("Used in selected 2D shape assembly and triangulation workflows."),
            distributionTip: qsTr("LICENSE.txt is already included in the repository; still include the license text with the installer for official distribution."),
            url: "https://github.com/memononen/libtess2"
        },
        {
            name: "GLM",
            version: "",
            scope: qsTr("Graphics Math"),
            usage: qsTr("Matrix and vector math for the Viewer2D OpenGL backend."),
            license: "Happy Bunny License / MIT License",
            notice: qsTr("GLM is officially distributed under either the Happy Bunny License or the MIT License."),
            distributionTip: qsTr("External package dependency; include the GLM license text with the installer for official distribution."),
            url: "https://github.com/g-truc/glm"
        },
        {
            name: "tinyxml2",
            version: "",
            scope: qsTr("URDF / XML"),
            usage: qsTr("XML parser used by URDF-related features."),
            license: "zlib License",
            notice: qsTr("The tinyxml2 license text is written directly at the top of the header file in the repository."),
            distributionTip: qsTr("The license text lives in the source header; include a third-party notices file as well for official distribution."),
            url: "https://github.com/leethomason/tinyxml2"
        },
        {
            name: "nlohmann/json",
            version: "",
            scope: qsTr("Data Serialization"),
            usage: qsTr("JSON configuration, data exchange, and serialization in several utility layers."),
            license: "MIT",
            notice: qsTr("The main project currently brings in nlohmann_json through the package manager."),
            distributionTip: qsTr("External package dependency; include the nlohmann/json license text with the installer for official distribution."),
            url: "https://github.com/nlohmann/json"
        },
        {
            name: "fmt",
            version: "",
            scope: qsTr("Infrastructure"),
            usage: qsTr("String formatting and log message assembly."),
            license: "MIT",
            notice: qsTr("Modules such as RfLog, PcAlg, and Geo3d depend on fmt directly."),
            distributionTip: qsTr("External package dependency; include the fmt license text with the installer for official distribution."),
            url: "https://github.com/fmtlib/fmt"
        },
        {
            name: "quill",
            version: "",
            scope: qsTr("Infrastructure"),
            usage: qsTr("Asynchronous logging backend."),
            license: "MIT",
            notice: qsTr("The RfLog module uses quill for log persistence and output."),
            distributionTip: qsTr("External package dependency; include the quill license text with the installer for official distribution."),
            url: "https://github.com/odygrd/quill"
        },
        {
            name: "magic_enum",
            version: "",
            scope: qsTr("Infrastructure"),
            usage: qsTr("C++ enum reflection and name mapping."),
            license: "MIT",
            notice: qsTr("Used to reduce boilerplate for enum-to-string conversion."),
            distributionTip: qsTr("LICENSE is already included in the repository; still include the license text with the installer for official distribution."),
            url: "https://github.com/Neargye/magic_enum"
        },
        {
            name: "happly",
            version: "",
            scope: qsTr("PLY IO"),
            usage: qsTr("Header-only implementation for PLY point-cloud and mesh I/O."),
            license: "MIT",
            notice: qsTr("The license text is written directly at the top of `happly.hpp` in the repository."),
            distributionTip: qsTr("The license text lives in the source header; include a third-party notices file as well for official distribution."),
            url: "https://github.com/nmwsharp/happly"
        },
        {
            name: "miniply",
            version: "",
            scope: qsTr("PLY IO"),
            usage: qsTr("Fast PLY parsing implementation currently built from embedded source."),
            license: "MIT",
            notice: qsTr("The license text is written directly at the top of `miniply.h` in the repository."),
            distributionTip: qsTr("The license text lives in the source header; include a third-party notices file as well for official distribution."),
            url: "https://github.com/vilya/miniply"
        }
    ]

    function close() {
        var endTime = new Date()
        var displayTime = endTime - startTime

        console.log("SplashScreen display time: " + displayTime + " ms")
        if (aboutWindow) {
            aboutWindow.close()
        } else {
            splashScreen.visible = false
        }
    }

    function buildSystemInfo() {
        var info = ""
        info += qsTr("System Information:") + "\n"
        info += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        info += qsTr("Version: ") + splashScreen.appVersion + " (Qt " + qtVersion + ")\n"
        info += qsTr("Build Mode: ") + (splashScreen.devMode ? qsTr("Development") : qsTr("User")) + "\n"
        info += qsTr("Compiler: ") + compilerName + "\n"
        info += qsTr("Build Timestamp: ") + buildTimestamp + "\n"
        info += qsTr("Platform: ") + platformName + " / " + Qt.platform.os + "\n"
        info += qsTr("System: ") + osPrettyName + "\n"
        info += qsTr("Kernel: ") + kernelType + " " + kernelVersion + "\n"
        info += qsTr("CPU Architecture: ") + cpuArch + " (" + qsTr("Build: ") + buildCpuArch + ")\n"
        info += qsTr("Product Type: ") + productType + " " + productVersion + "\n"
        info += qsTr("Host Name: ") + hostName + "\n"

        info += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        info += qsTr("Runtime Environment:") + "\n"
        info += qsTr("Application Path: ") + appDir + "\n"
        info += qsTr("System Locale: ") + localeName + "\n"
        info += qsTr("UI Languages: ") + uiLanguages.join(", ") + "\n"
        info += qsTr("Graphics API: ") + graphicsApi + "\n"

        info += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        info += "OpenGL:\n"
        info += qsTr("Version: ") + openGLVersion + "\n"
        info += qsTr("Vendor: ") + openGLVendor + "\n"
        info += qsTr("Renderer: ") + openGLRenderer + "\n"
        info += "Profile: " + openGLProfile + "\n"
        info += qsTr("Context Format: ") + openGLContextFormat + "\n"
        info += qsTr("Requested Format: ") + openGLRequestedFormat + "\n"
        info += qsTr("Requested Profile: ") + openGLRequestedProfile + "\n"
        info += "Renderable: " + openGLRenderableType + "\n"

        info += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        info += qsTr("Screen Information:") + "\n"
        if (screenInfoLines.length > 0) {
            info += screenInfoLines.join("\n") + "\n"
        }

        info += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        info += qsTr("About RoboticPlus:") + "\n"
        info += qsTr("RoboticPlus focuses on RoBIM industrial software and smart factory solutions.") + "\n"
        info += qsTr("Its products cover cutting, welding, and grinding workflows for metal fabrication.") + "\n"
        info += qsTr("The company helps manufacturers upgrade toward intelligent production.") + "\n"
        info += "\n"
        info += qsTr("Website: https://www.roboticplus.com/") + "\n"
        info += qsTr("Products: RoBIM industrial software, smart factory solutions") + "\n"
        info += qsTr("Services: bevel cutting, profile cutting, intelligent welding, intelligent grinding") + "\n"
        return info
    }

    width: aboutMode ? 760 : 480
    height: aboutMode ? 640 : 300
    color: baseColor

    border.width: aboutMode ? 2 : 0
    border.color: aboutMode ? accentColor : "transparent"

    Component.onCompleted: {
        startTime = new Date()
        darkMode = isDarkMode
        aboutMode = isAboutMode
        splashScreen.devMode = isDevMode
        aboutCurrentTabIndex = 0
    }

    visible: true

    Rectangle {
        id: closeButton
        width: 30
        height: 30
        radius: 15
        color: closeButtonMouseArea.containsMouse ? "#ff4444" : "#cccccc"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        visible: aboutMode

        Text {
            text: "×"
            color: "white"
            font: fontUtil.bold(splashScreen.standardFont)
            anchors.centerIn: parent
        }

        MouseArea {
            id: closeButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                splashScreen.close()
            }
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: 20

        Image {
            id: logoImage
            source: "qrc:/icons/AppIcon.png"
            width: 150
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit

            NumberAnimation on rotation {
                from: -2
                to: 2
                duration: 3000
                loops: Animation.Infinite
                easing.type: Easing.InOutQuad
                running: splashScreen.visible
                alwaysRunToEnd: true
            }
        }

        Text {
            id: appNameText
            text: qsTr("RoBIM PCR")
            color: textColor
            font: {
                var f = fontUtil.bold(splashScreen.standardFont)
                if (splashScreen.standardFont.pixelSize > 0) {
                    f.pixelSize = splashScreen.standardFont.pixelSize * 2
                } else if (splashScreen.standardFont.pointSize > 0) {
                    f.pointSize = splashScreen.standardFont.pointSize * 2
                }
                return f
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logoImage.bottom
            anchors.topMargin: 10
        }

        Text {
            id: versionText
            text: qsTr("Version") + " " + appVersion
            color: secondaryTextColor
            font: splashScreen.standardFont
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: appNameText.bottom
            anchors.topMargin: 5
        }

        Text {
            id: websiteLink
            text: qsTr("RoboticPlus Website")
            color: accentColor
            font: fontUtil.underline(splashScreen.annotationFont)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: versionText.bottom
            anchors.topMargin: 8
            visible: aboutMode

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.openUrlExternally("https://www.roboticplus.com/")
                }
            }
        }

        TabBar {
            id: aboutTabBar
            anchors.top: websiteLink.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            visible: splashScreen.aboutMode
            currentIndex: splashScreen.aboutCurrentTabIndex
            spacing: 8
            background: Rectangle {
                color: "transparent"
            }

            onCurrentIndexChanged: {
                splashScreen.aboutCurrentTabIndex = currentIndex
            }

            Repeater {
                model: [qsTr("About"), qsTr("Open Source Licenses")]

                TabButton {
                    id: aboutTabButton
                    required property var modelData
                    text: modelData
                    implicitHeight: 38
                    implicitWidth: Math.max(140, contentItem.implicitWidth + 28)

                    background: Rectangle {
                        radius: 8
                        color: aboutTabButton.checked ? splashScreen.accentColor : splashScreen.tabInactiveColor
                        border.width: aboutTabButton.checked ? 0 : 1
                        border.color: aboutTabButton.checked ? "transparent" : splashScreen.sectionBorderColor
                    }

                    contentItem: Text {
                        text: aboutTabButton.text
                        color: aboutTabButton.checked ? "#ffffff" : splashScreen.tabTextInactiveColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: splashScreen.standardFont
                        elide: Text.ElideRight
                    }
                }
            }
        }

        StackLayout {
            id: aboutPageStack
            anchors.top: splashScreen.aboutMode ? aboutTabBar.bottom : websiteLink.bottom
            anchors.topMargin: splashScreen.aboutMode ? 12 : 15
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            visible: splashScreen.aboutMode
            currentIndex: splashScreen.aboutCurrentTabIndex

            Item {
                Flickable {
                    id: systemInfoScroll
                    anchors.fill: parent
                    clip: true

                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    contentWidth: width
                    contentHeight: systemInfoText.height

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AlwaysOff
                    }

                    Text {
                        id: systemInfoText
                        width: systemInfoScroll.width - 20
                        wrapMode: Text.WrapAnywhere
                        horizontalAlignment: Text.AlignHCenter
                        color: splashScreen.secondaryTextColor
                        font: splashScreen.annotationFont
                        text: splashScreen.systemInfo
                    }
                }
            }

            Item {
                Flickable {
                    id: openSourceScroll
                    anchors.fill: parent
                    clip: true

                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    contentWidth: width
                    contentHeight: openSourceColumn.implicitHeight

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AlwaysOff
                    }

                    Column {
                        id: openSourceColumn
                        width: openSourceScroll.width - 14
                        spacing: 12

                        Rectangle {
                            width: parent.width
                            radius: 10
                            color: splashScreen.sectionSurfaceColor
                            border.width: 1
                            border.color: splashScreen.sectionBorderColor
                            implicitHeight: summaryColumn.implicitHeight + 24

                            Column {
                                id: summaryColumn
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    width: parent.width
                                    text: qsTr("The notes also label three distribution states: \"external package dependency / license already included in repository / local license text missing in repository\", making later packaging review easier.")
                                    wrapMode: Text.Wrap
                                    color: splashScreen.secondaryTextColor
                                    font: splashScreen.annotationFont
                                }
                            }
                        }

                        Repeater {
                            model: splashScreen.openSourceLibraries

                            Rectangle {
                                id: openSourceCard
                                required property var modelData
                                width: openSourceColumn.width
                                radius: 10
                                color: splashScreen.sectionSurfaceColor
                                border.width: 1
                                border.color: splashScreen.sectionBorderColor
                                implicitHeight: cardColumn.implicitHeight + 24

                                Column {
                                    id: cardColumn
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Text {
                                        width: parent.width
                                        text: openSourceCard.modelData.version && openSourceCard.modelData.version.length > 0 ? openSourceCard.modelData.name + " " + openSourceCard.modelData.version : openSourceCard.modelData.name
                                        wrapMode: Text.Wrap
                                        color: splashScreen.textColor
                                        font: fontUtil.bold(splashScreen.standardFont)
                                    }

                                    Text {
                                        width: parent.width
                                        text: qsTr("Scope: ") + openSourceCard.modelData.scope
                                        wrapMode: Text.Wrap
                                        color: splashScreen.secondaryTextColor
                                        font: splashScreen.annotationFont
                                    }

                                    Text {
                                        width: parent.width
                                        text: qsTr("Usage: ") + openSourceCard.modelData.usage
                                        wrapMode: Text.Wrap
                                        color: splashScreen.secondaryTextColor
                                        font: splashScreen.annotationFont
                                    }

                                    Text {
                                        width: parent.width
                                        text: qsTr("License: ") + openSourceCard.modelData.license
                                        wrapMode: Text.Wrap
                                        color: openSourceCard.modelData.needsReview ? splashScreen.warningTextColor : splashScreen.textColor
                                        font: splashScreen.annotationFont
                                    }

                                    Text {
                                        width: parent.width
                                        text: qsTr("Notes: ") + openSourceCard.modelData.notice
                                        wrapMode: Text.Wrap
                                        color: splashScreen.secondaryTextColor
                                        font: splashScreen.annotationFont
                                    }

                                    Text {
                                        width: parent.width
                                        text: qsTr("Distribution Tip: ") + openSourceCard.modelData.distributionTip
                                        wrapMode: Text.Wrap
                                        color: openSourceCard.modelData.needsReview ? splashScreen.warningTextColor : splashScreen.secondaryTextColor
                                        font: splashScreen.annotationFont
                                    }

                                    Button {
                                        text: qsTr("Open License Link")
                                        onClicked: {
                                            Qt.openUrlExternally(openSourceCard.modelData.url)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        if (typeof splashEngine !== 'undefined' && splashEngine) {
            splashEngine = null
        }
    }
}
