import QtQuick 2.15
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.15
import GeoToy.Controls 1.0

ToolBar {
    id: statusBar

    height: Fonts.statusBarHeight
    background: Rectangle {
        color: Qt.lighter(Theme.windowColor, 1.1)
    }

    property var progressMgr: cmdMngr ? cmdMngr.getProgressManager() : null

    property int currentProgress: 0

    property string currentProgressMessage: ""

    property real progressValue: 0.0

    property bool progressIsRatio: false

    property bool isCancelling: false

    property bool isCancellable: true

    property string statusText: ""
    property string viewerText: ""
    readonly property bool showStatusSeparator: statusText !== "" && viewerText !== "" && !progressBarRow.visible

    function setStatusText(text) {
        statusText = text || ""
    }

    function setViewerText(text) {
        viewerText = text || ""
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Fonts.size10
        anchors.rightMargin: Fonts.size10

        CustomLabel {
            id: statusLabel
            objectName: "statusLabel"
            text: statusBar.statusText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
        }

        CustomLabel {
            id: spLabel
            text: " | "
            visible: statusBar.showStatusSeparator
            Layout.preferredWidth: visible ? Fonts.separatorWidth : 0
            Layout.minimumWidth: visible ? Fonts.separatorWidth : 0
            Layout.maximumWidth: visible ? Fonts.separatorWidth : 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
        }

        CustomLabel {
            id: viewerLabel
            objectName: "viewerLabel"
            text: statusBar.viewerText
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop
            visible: !progressBarRow.visible
        }

        // Spacer to push progress bar to the right
        Item {
            Layout.fillWidth: true
            visible: progressBarRow.visible
        }

        // Progress Bar Container with Cancel Button
        RowLayout {
            id: progressBarRow
            spacing: Fonts.size5
            visible: false
            Layout.preferredHeight: Fonts.statusBarHeight

            // Progress Bar - positioned at the right
            Item {
                id: progressBarContainer
                Layout.preferredWidth: statusBar.width / 3
                Layout.maximumWidth: statusBar.width / 3
                Layout.preferredHeight: Fonts.statusBarHeight

                Rectangle {
                    id: progressBarBackground
                    anchors.fill: parent
                    color: Qt.darker(Theme.windowColor, 1.1)
                    border.color: Theme.midColor
                    border.width: Fonts.size1
                    radius: Fonts.size3
                    clip: true  // Clip to prevent overflow

                    Rectangle {
                        id: determinateFill
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * progressValue
                        color: Theme.highlightColor
                        opacity: 0.7
                        radius: Fonts.size3
                        visible: progressIsRatio
                        clip: true

                        Rectangle {
                            id: determinateStripe
                            y: 0
                            height: parent.height
                            width: Math.max(progressBarContainer.width * 0.05, Fonts.size20)
                            color: Qt.lighter(Theme.highlightColor, 1.3)
                            opacity: 0.3
                            radius: Fonts.size3
                            visible: progressIsRatio && progressBarRow.visible
                            clip: true

                            SequentialAnimation on x {
                                running: determinateStripe.visible
                                loops: Animation.Infinite
                                NumberAnimation {
                                    from: -determinateStripe.width
                                    to: determinateFill.width
                                    duration: 2000
                                    easing.type: Easing.Linear
                                }
                            }
                        }
                    }

                    // Animated progress indicator (indeterminate, >1)
                    Rectangle {
                        id: progressIndicator
                        x: -width
                        y: 0
                        width: Math.max(progressBarBackground.width * 0.3, Fonts.size20)
                        height: progressBarBackground.height
                        color: Theme.highlightColor
                        opacity: 0.7
                        radius: Fonts.size3

                        SequentialAnimation on x {
                            id: progressAnimation
                            running: progressBarRow.visible && progressBarContainer.width > 0 && !progressIsRatio
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: -progressIndicator.width
                                to: progressBarBackground.width
                                duration: 1500
                                easing.type: Easing.Linear
                            }
                        }

                        visible: !progressIsRatio
                    }

                    Text {
                        id: progressText
                        anchors.centerIn: parent
                        text: isCancelling ? "Cancelling..." : (currentProgressMessage !== "" ? currentProgressMessage : (progressValue > 0 ? Math.round(progressValue * 100) + "%" : ""))
                        color: Theme.textColor
                        font: Fonts.annotationFont
                        visible: isCancelling || currentProgressMessage !== "" || (progressIsRatio && progressValue > 0)
                    }
                }
            }

            // Cancel Button
            Button {
                id: cancelButton
                visible: isCancellable
                Layout.preferredWidth: Fonts.iconButtonSize
                Layout.preferredHeight: Fonts.iconButtonSize
                Layout.maximumWidth: Fonts.iconButtonSize
                Layout.maximumHeight: Fonts.iconButtonSize

                background: Rectangle {
                    color: cancelButton.hovered ? Qt.darker(Theme.midColor, 1.2) : Qt.darker(Theme.windowColor, 1.1)
                    border.color: Theme.midColor
                    border.width: Fonts.size1
                    radius: Fonts.size3
                }

                contentItem: Text {
                    text: "×"
                    color: Theme.textColor
                    font: Fonts.annotationFont
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (progressMgr) {
                        isCancelling = true
                        currentProgressMessage = "Cancelling..."
                        progressMgr.requestCancellation()
                    }
                }
            }
        }
    }

    Connections {
        target: progressMgr
        enabled: progressMgr !== null
        function onOperationStarted(operationName, cancellable) {
            progressBarRow.visible = true
            currentProgress = 0
            currentProgressMessage = operationName || ""
            progressValue = 0.0
            progressIsRatio = false
            isCancelling = false
            isCancellable = cancellable
        }
        function onProgressChanged(percentage, message) {
            if (!isCancelling) {
                currentProgress = percentage
                currentProgressMessage = message || ""
            }
            if (percentage > 0 && percentage <= 100) {
                progressIsRatio = true
                progressValue = percentage / 100.0
            } else {
                progressIsRatio = false
                progressValue = 0.0
            }
        }
        function onOperationCompleted(success, message) {
            // Hide progress bar after a short delay
            Qt.callLater(function () {
                progressBarRow.visible = false
                currentProgress = 0
                currentProgressMessage = ""
                progressValue = 0.0
                progressIsRatio = false
                isCancelling = false
                isCancellable = true
            })
        }
    }
}
