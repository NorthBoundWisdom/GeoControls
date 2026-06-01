import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import GeoControls 1.0

ComboBox {
    id: control
    hoverEnabled: enabled

    // custom properties
    property int defaultHeight: Math.max(Fonts.inputFieldHeight, Fonts.standardFontMetrics.height + Fonts.size10)
    property int defaultRadius: Fonts.size2
    property int defaultPadding: Fonts.size6
    property bool isExpanded: false
    property string placeholderText: ""
    property bool detectMouseExit: true
    property bool skipCurrentIndexChange: false
    property bool skipNextAutoPopup: false
    property bool acceptOnDelegateClick: false
    property string tooltipText: ""
    property int tooltipDelay: ToolTipConfig.shortDelay
    property int minimumTextWidth: Fonts.size50
    property int verticalTextPadding: Fonts.inputPadding
    readonly property bool inputComposing: editableTextField.inputMethodComposing
    readonly property int minimumUsableWidth: minimumTextWidth + indicator.width + defaultPadding * 3

    property color textColor: Theme.textColor
    property color placeholderColor: Theme.disabledTextColor
    property color editableBackgroundColor: Theme.baseColor
    property color readOnlyBackgroundColor: Theme.buttonColor
    property color highlightColor: Theme.highlightColor
    property color alternateBaseColor: Theme.alternateBaseColor
    property color midColor: Theme.midColor
    property color buttonHoveredColor: Theme.lightColor
    property color buttonDisabledColor: Theme.disabledTextColor

    font: Fonts.standardFont
    implicitHeight: defaultHeight
    implicitWidth: Math.max(Fonts.size120, minimumUsableWidth)

    signal textEdited(string text)

    onActivated: {
        if (skipCurrentIndexChange) {
            skipCurrentIndexChange = false
            return
        }
    }

    function appendItem(value) {
        if (!model.includes(value)) {
            let newModel = model

            newModel.unshift(value)
            model = newModel
        }
    }

    function applyHighlightedSelection() {
        if (!control.popup.visible || control.highlightedIndex < 0)
            return false
        let idx = control.highlightedIndex
        control.currentIndex = idx
        if (control.editable) {
            control.skipNextAutoPopup = true
            control.editText = control.textAt(idx)
        }
        return true
    }

    contentItem: Item {
        TextField {
            id: editableTextField
            visible: control.editable
            anchors.fill: parent
            text: control.editText
            font: control.font
            color: control.textColor
            placeholderText: control.placeholderText
            placeholderTextColor: control.placeholderColor
            verticalAlignment: TextInput.AlignVCenter
            padding: 0
            topPadding: control.verticalTextPadding
            bottomPadding: control.verticalTextPadding
            leftPadding: defaultPadding * 1.2
            rightPadding: control.indicator.width + defaultPadding * 1.2
            background: null
            selectByMouse: true

            inputMethodHints: Qt.ImhNone

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier)) {
                    editableTextField.selectAll()
                    event.accepted = true
                } else if (editableTextField.inputMethodComposing && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape)) {
                    // Let IME consume confirm/cancel keys while composing.
                    event.accepted = false
                    return
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    control.applyHighlightedSelection()
                    if (text.length > 0) {
                        control.accepted()
                    }
                    editableTextField.focus = false
                    event.accepted = true
                    control.popup.close()
                    control.isExpanded = false
                    return
                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                    if (control.applyHighlightedSelection()) {
                        control.accepted()
                        control.popup.close()
                        control.isExpanded = false
                    }
                    // Keep default tab focus navigation behavior.
                    event.accepted = false
                    return
                } else if (event.key === Qt.Key_Escape) {
                    editableTextField.text = ""
                    control.editText = ""
                    editableTextField.focus = false
                    event.accepted = true
                }
            }

            onTextChanged: {
                control.editText = text
                if (!editableTextField.inputMethodComposing) {
                    control.textEdited(text)
                }
            }
        }

        MouseArea {
            id: focusLoseArea
            anchors.fill: parent
            hoverEnabled: control.detectMouseExit
            enabled: control.editable && editableTextField.activeFocus && control.detectMouseExit

            onExited: {
                if (control.editable && editableTextField.activeFocus && control.detectMouseExit) {
                    editableTextField.focus = false
                }
            }

            onPressed: function (event) {
                event.accepted = false
            }
            onReleased: function (event) {
                event.accepted = false
            }
            onClicked: function (event) {
                event.accepted = false
            }
        }

        Text {
            id: readOnlyText
            visible: !control.editable
            anchors.fill: parent
            leftPadding: defaultPadding * 1.2
            rightPadding: control.indicator.width + defaultPadding * 1.2
            text: (control.currentIndex === -1) ? control.placeholderText : (control.displayText || control.placeholderText)
            font: control.font
            color: {
                return (control.currentIndex === -1) ? control.placeholderColor : (control.displayText ? control.textColor : control.placeholderColor)
            }
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: control.editable ? Qt.IBeamCursor : Qt.ArrowCursor

            onClicked: {
                if (mouseX > parent.width - control.indicator.width - control.defaultPadding * 1.2) {
                    control.isExpanded = !control.isExpanded
                    control.popup.visible = control.isExpanded
                } else if (control.editable) {
                    editableTextField.forceActiveFocus()
                } else {
                    control.isExpanded = !control.isExpanded
                    control.popup.visible = control.isExpanded
                }
            }

            onPressed: function (event) {
                if (control.editable && event.x <= parent.width - control.indicator.width - control.defaultPadding * 1.2) {
                    event.accepted = false
                }
            }
        }
    }

    delegate: ItemDelegate {
        width: control.width
        height: control.defaultHeight
        hoverEnabled: true

        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: {
                if (modelData && typeof modelData === "object") {
                    if (control.textRole && control.textRole !== "") {
                        return modelData[control.textRole] || ""
                    }

                    return modelData.name || modelData.toString() || ""
                }
                return modelData || ""
            }
            color: control.textColor
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            anchors.fill: parent
            anchors.leftMargin: Fonts.size10
            anchors.rightMargin: Fonts.size10
            clip: true
        }

        background: Rectangle {
            anchors.fill: parent
            color: highlighted ? control.highlightColor : hovered ? control.highlightColor : control.alternateBaseColor
            opacity: 0.5
        }

        onClicked: {
            var comboBox = control || ListView.view
            comboBox.currentIndex = index;
            // Keep compatibility with existing pages that commit via onActivated.
            comboBox.activated(index)
            if (comboBox.editable) {
                var textValue = ""
                if (modelData && typeof modelData === "object") {
                    if (comboBox.textRole && comboBox.textRole !== "") {
                        textValue = modelData[comboBox.textRole] || ""
                    } else {
                        textValue = modelData.name || modelData.toString() || ""
                    }
                } else {
                    textValue = modelData || ""
                }
                comboBox.skipNextAutoPopup = true
                comboBox.editText = textValue
            }
            if (comboBox.acceptOnDelegateClick) {
                comboBox.accepted()
            }
            comboBox.isExpanded = false
            comboBox.popup.close()
        }
    }

    // popup window style
    popup: Popup {
        visible: control.isExpanded
        y: control.height
        width: control.width

        implicitHeight: Math.min(contentItem.implicitHeight, control.window ? control.window.height / 3 : Fonts.size300)
        padding: Fonts.size1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: control.editableBackgroundColor
            border.color: control.midColor
            border.width: Fonts.size1
            radius: defaultRadius
        }
    }

    // indicator style
    indicator: Canvas {
        id: canvas
        x: control.width - width - defaultPadding * 1.2
        y: control.topPadding + (control.availableHeight - height) / 2
        width: Fonts.size10
        height: Fonts.size7
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() {
                canvas.requestPaint()
            }
            function onTextColorChanged() {
                canvas.requestPaint()
            }
            function onHoveredChanged() {
                canvas.requestPaint()
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            if (!ctx) {
                console.warn("Failed to get 2D context")
                return
            }

            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = control.hovered ? control.highlightColor : control.textColor
            ctx.fill()
        }
    }

    // background style
    background: Rectangle {
        implicitWidth: Fonts.size120
        implicitHeight: control.defaultHeight
        color: {
            if (!control.enabled) {
                return control.buttonDisabledColor
            }
            if (control.editable) {
                return control.hovered ? Qt.lighter(control.highlightColor, 1.8) : control.editableBackgroundColor
            }
            return control.pressed ? Qt.darker(control.readOnlyBackgroundColor, 1.2) : control.hovered ? control.buttonHoveredColor : control.readOnlyBackgroundColor
        }
        border.color: {
            if (!control.enabled) {
                return control.midColor
            }
            if (control.pressed || control.editable) {
                return control.highlightColor
            }
            if (control.hovered) {
                return control.highlightColor
            }
            return control.midColor
        }
        border.width: (control.visualFocus || control.editable || (control.hovered && control.enabled)) ? Fonts.size2 : Fonts.size1
        radius: defaultRadius
        opacity: (control.hovered && control.enabled) ? 0.5 : 1.0
    }

    // Tooltip support
    CustomToolTip {
        visible: tooltipText !== "" && hovered && enabled
        delay: tooltipDelay
        text: tooltipText
    }
}
