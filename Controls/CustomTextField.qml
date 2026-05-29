import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import GeoToy.Controls 1.0

TextField {
    id: control

    // custom properties
    property int defaultHeight: Fonts.inputFieldHeight
    property int defaultRadius: Fonts.size2
    property int defaultPadding: Fonts.inputPadding

    property string originalText: ""

    property bool mouseInside: false

    property bool autoAcceptOnMouseExit: false

    property bool showClipIndicator: true

    property bool showEmptyIndicator: true
    property bool _skipFocusCommitOnce: false

    property alias actualText: control.text

    placeholderText: showEmptyIndicator ? "(empty)" : ""
    placeholderTextColor: disabledTextColor

    signal textContentChanged(string newText)
    signal editingCommitted(string committedText)

    property color textColor: Theme.textColor
    property color baseColor: Theme.baseColor
    property color midColor: Theme.midColor
    property color highlightColor: Theme.highlightColor
    property color disabledTextColor: Theme.disabledTextColor
    property color highlightedTextColor: Theme.highlightedTextColor

    font: Fonts.standardFont
    implicitHeight: defaultHeight
    implicitWidth: Fonts.standardFontMetrics.averageCharacterWidth * Fonts.size8

    padding: defaultPadding
    leftPadding: padding
    rightPadding: padding

    color: control.enabled ? (text.length === 0 ? disabledTextColor : textColor) : disabledTextColor
    selectedTextColor: highlightedTextColor
    selectionColor: highlightColor

    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: activeFocus ? TextInput.AlignRight : TextInput.AlignLeft
    selectByMouse: true
    persistentSelection: false

    background: Rectangle {
        implicitHeight: control.defaultHeight
        color: !control.enabled ? disabledTextColor : control.readOnly ? disabledTextColor : control.hovered ? Qt.lighter(highlightColor, 1.8) : baseColor
        border.color: !control.enabled ? midColor : control.activeFocus ? highlightColor : control.hovered ? highlightColor : midColor
        opacity: control.enabled ? 1.0 : 0.1
        border.width: control.activeFocus ? Fonts.size2 : Fonts.size1
        radius: defaultRadius

        Behavior on border.color {
            ColorAnimation {
                duration: 80
            }
        }

        Rectangle {
            id: clipIndicator
            anchors.right: parent.right
            anchors.rightMargin: Fonts.size2
            anchors.verticalCenter: parent.verticalCenter
            width: Fonts.size3
            height: parent.height - Fonts.size4
            color: highlightColor
            opacity: control.showClipIndicator && control.actualText.length > 0 && (control.contentWidth > control.width - control.leftPadding - control.rightPadding) ? 0.6 : 0
            radius: Fonts.size1

            SequentialAnimation on opacity {
                running: control.showClipIndicator && control.actualText.length > 0 && (control.contentWidth > control.width - control.leftPadding - control.rightPadding)
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.2
                    duration: 800
                }
                NumberAnimation {
                    to: 0.6
                    duration: 800
                }
            }
        }

        Rectangle {
            id: gradientMask
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Fonts.size2 * Fonts.standardFontMetrics.averageCharacterWidth
            opacity: control.showClipIndicator && control.actualText.length > 0 && (control.contentWidth > control.width - control.leftPadding - control.rightPadding) ? 0.8 : 0

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 1.0
                    color: highlightColor
                }
            }
        }
    }

    Component {
        id: editMenuComponent
        Menu {
            font: Fonts.standardFont
            MenuItem {
                text: qsTr("Cut")
                enabled: control.selectedText.length > 0 && !control.readOnly
                onTriggered: control.cut()
            }
            MenuItem {
                text: qsTr("Copy")
                enabled: control.selectedText.length > 0
                onTriggered: control.copy()
            }
            MenuItem {
                text: qsTr("Paste")
                enabled: control.canPaste && !control.readOnly
                onTriggered: control.paste()
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Select All")
                enabled: control.text.length > 0
                onTriggered: control.selectAll()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        acceptedButtons: Qt.RightButton
        preventStealing: true
        propagateComposedEvents: true

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                var menu = editMenuComponent.createObject(control);
                menu.popup();
            }
        }

        onPressed: function (mouse) {
            mouse.accepted = false;
        }
        onReleased: function (mouse) {
            mouse.accepted = false;
        }
        onDoubleClicked: function (mouse) {
            mouse.accepted = false;
        }
        onPositionChanged: function (mouse) {
            mouse.accepted = false;
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true

        onEntered: {
            control.mouseInside = true;
            cursorShape = Qt.IBeamCursor;
        }

        onExited: {
            control.mouseInside = false;
            cursorShape = Qt.ArrowCursor;

            if (control.autoAcceptOnMouseExit && control.activeFocus) {
                control.accepted();
                control.focus = false;
            }
        }

        CustomToolTip {
            visible: hoverArea.containsMouse && control.actualText.length > 0 && (control.contentWidth > control.width - control.leftPadding - control.rightPadding)
            timeout: ToolTipConfig.persistentTimeout
            text: control.actualText
        }
    }

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            control._skipFocusCommitOnce = true;
            control.editingCommitted(control.text);
            control.accepted();
            control.editingFinished();
            Qt.callLater(function () {
                control.focus = false;
            });
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            control.actualText = originalText;
            control.focus = false;
            event.accepted = true;
        }
    }

    Keys.onEscapePressed: {
        focus = false;
    }

    onFocusChanged: {
        if (!focus && activeFocus) {
            if (control._skipFocusCommitOnce) {
                control._skipFocusCommitOnce = false;
                return;
            }
            control.editingCommitted(control.text);
            control.accepted();
            control.editingFinished();
        }
    }

    onTextChanged: {
        if (activeFocus && text !== "(empty)") {
            actualText = text;
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            originalText = actualText;

            if (text === "(empty)") {}
        }
    }

    onActualTextChanged: {
        textContentChanged(actualText);
    }
}
