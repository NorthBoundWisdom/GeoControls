import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoControls 1.0

Item {
    id: root

    property var windowHandle: null
    property bool showMinimize: true
    property bool showMaximize: true
    property bool showClose: true
    property real heightScale: 1.0
    property int buttonWidthOverride: 0
    property int chromeHeightOverride: 0

    property color iconColor: Theme.textColor
    property color hoverColor: Theme.buttonHoveredColor
    property color pressedColor: Theme.buttonPressedColor
    property color closeHoverColor: "#D83B01"
    property color closePressedColor: "#B13719"

    readonly property int buttonWidth: buttonWidthOverride > 0 ? buttonWidthOverride : Math.max(Fonts.size40, Fonts.size30)
    readonly property int baseChromeHeight: chromeHeightOverride > 0 ? chromeHeightOverride : Math.max(Fonts.menuBarHeight + Fonts.size8, Fonts.titleBarHeight + Fonts.size4)
    readonly property int buttonHeight: Math.max(Fonts.scaledUiSize(22), Math.round(baseChromeHeight * heightScale))
    readonly property int iconSize: Math.max(Fonts.size12, Fonts.iconSize)
    readonly property bool isRestore: windowHandle !== null && (windowHandle.visibility === Window.Maximized || windowHandle.visibility === Window.FullScreen)
    readonly property int visibleButtonCount: (showMinimize ? 1 : 0) + (showMaximize ? 1 : 0) + (showClose ? 1 : 0)

    width: visibleButtonCount * buttonWidth
    height: buttonHeight
    implicitWidth: visibleButtonCount * buttonWidth
    implicitHeight: buttonHeight

    Row {
        anchors.fill: parent
        spacing: 0

        ToolButton {
            id: minimizeButton
            visible: root.showMinimize
            enabled: root.windowHandle !== null
            width: root.buttonWidth
            height: root.buttonHeight
            padding: 0
            hoverEnabled: true
            focusPolicy: Qt.NoFocus

            background: Rectangle {
                color: minimizeButton.pressed ? root.pressedColor : (minimizeButton.hovered ? root.hoverColor : "transparent")
            }

            contentItem: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: Math.max(2, Fonts.size2)
                    color: root.iconColor
                }
            }

            onClicked: {
                if (root.windowHandle) {
                    root.windowHandle.showMinimized()
                }
            }

            CustomToolTip {
                visible: minimizeButton.hovered
                delay: ToolTipConfig.shortDelay
                timeout: ToolTipConfig.persistentTimeout
                text: qsTr("Minimize")
            }
        }

        ToolButton {
            id: maximizeButton
            visible: root.showMaximize
            enabled: root.windowHandle !== null
            width: root.buttonWidth
            height: root.buttonHeight
            padding: 0
            hoverEnabled: true
            focusPolicy: Qt.NoFocus
            icon.source: root.isRestore ? "qrc:/GeoControls/icons/Restore.svg" : "qrc:/GeoControls/icons/Maximize.svg"
            icon.width: root.iconSize
            icon.height: root.iconSize
            icon.color: root.iconColor
            display: AbstractButton.IconOnly

            background: Rectangle {
                color: maximizeButton.pressed ? root.pressedColor : (maximizeButton.hovered ? root.hoverColor : "transparent")
            }

            onClicked: {
                if (!root.windowHandle) {
                    return
                }
                if (root.windowHandle.visibility === Window.Maximized || root.windowHandle.visibility === Window.FullScreen) {
                    root.windowHandle.showNormal()
                } else {
                    root.windowHandle.showMaximized()
                }
            }

            CustomToolTip {
                visible: maximizeButton.hovered
                delay: ToolTipConfig.shortDelay
                timeout: ToolTipConfig.persistentTimeout
                text: root.isRestore ? qsTr("Restore") : qsTr("Maximize")
            }
        }

        ToolButton {
            id: closeButton
            visible: root.showClose
            enabled: root.windowHandle !== null
            width: root.buttonWidth
            height: root.buttonHeight
            padding: 0
            hoverEnabled: true
            focusPolicy: Qt.NoFocus

            background: Rectangle {
                color: closeButton.pressed ? root.closePressedColor : (closeButton.hovered ? root.closeHoverColor : "transparent")
            }

            contentItem: Item {
                implicitWidth: root.iconSize
                implicitHeight: root.iconSize

                readonly property color strokeColor: closeButton.hovered ? "#FFFFFF" : root.iconColor
                readonly property real strokeThickness: Math.max(2, Math.round(root.iconSize / 6))
                readonly property real strokeLength: Math.max(strokeThickness * 3, Math.round(root.iconSize * 0.92))

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.strokeLength
                    height: parent.strokeThickness
                    radius: height / 2
                    color: parent.strokeColor
                    rotation: 45
                    antialiasing: true
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.strokeLength
                    height: parent.strokeThickness
                    radius: height / 2
                    color: parent.strokeColor
                    rotation: -45
                    antialiasing: true
                }
            }

            onClicked: {
                if (root.windowHandle) {
                    root.windowHandle.close()
                }
            }

            CustomToolTip {
                visible: closeButton.hovered
                delay: ToolTipConfig.shortDelay
                timeout: ToolTipConfig.persistentTimeout
                text: qsTr("Close")
            }
        }
    }
}
