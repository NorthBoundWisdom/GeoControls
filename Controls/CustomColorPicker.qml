import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import GeoControls 1.0

Dialog {
    id: control

    property int unit: Fonts.standardFontMetrics.height
    property color windowColor: Theme.windowColor
    property color buttonColor: Theme.buttonColor
    property color baseColor: Theme.baseColor
    property color buttonTextColor: Theme.buttonTextColor
    property color midColor: Theme.midColor
    property color highlightColor: Theme.highlightColor
    property color textColor: Theme.textColor
    property color alternateBaseColor: Theme.alternateBaseColor
    property int dialogRadius: Fonts.size8
    property int panelRadius: Fonts.size6
    property color subtleBorderColor: Qt.rgba(midColor.r, midColor.g, midColor.b, 0.55)
    property color panelBackgroundColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.35)

    property color selectedColor: Qt.rgba(1, 1, 1, 1)
    // Optional initial color from caller. Keep explicit to avoid runtime unresolved reference.
    property color previewColor: Qt.rgba(1, 1, 1, 1)
    property int colorHandleRadius: Fonts.size8
    title: qsTr("Color Picker")
    modal: true

    // Center the dialog in the application window
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    width: Math.max(mainLayout.implicitWidth + unit * Fonts.size2, Fonts.size420)
    height: Math.max(mainLayout.implicitHeight + unit * Fonts.size2, Fonts.size420)
    leftPadding: Math.round(unit * 0.45)
    rightPadding: Math.round(unit * 0.45)
    topPadding: Math.round(unit * 0.45)
    bottomPadding: Math.round(unit * 0.45)

    onOpened: {
        var initial = isValidRgbColor(selectedColor) ? selectedColor : previewColor
        applyColorToUi(initial);
        // Re-apply after layout pass so cursor positions are correct even when sizes are not ready on first tick.
        Qt.callLater(function () {
            applyColorToUi(initial)
        })
    }

    background: Rectangle {
        color: windowColor
        border.color: subtleBorderColor
        border.width: Fonts.size1
        radius: dialogRadius
        antialiasing: true
    }

    header: Rectangle {
        id: headerRect
        color: "transparent"
        height: Math.round(unit * 1.8)
        border.width: 0
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: dialogRadius
            color: Qt.rgba(alternateBaseColor.r, alternateBaseColor.g, alternateBaseColor.b, 0.85)
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: dialogRadius
            color: Qt.rgba(alternateBaseColor.r, alternateBaseColor.g, alternateBaseColor.b, 0.85)
        }
        CustomLabel {
            id: titleLabel
            text: control.title
            color: textColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: unit
            font: Fonts.standardFont
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Fonts.size1
            color: subtleBorderColor
        }
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: Math.round(unit * 0.15)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: Fonts.size300
            Layout.preferredHeight: unit * 1.7
            Layout.margins: 0
            color: control.selectedColor
            border.color: subtleBorderColor
            border.width: Fonts.size1
            radius: panelRadius
        }

        Item {
            id: colorPickerPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Math.round(unit * 6.4)
            Layout.preferredHeight: Math.round(unit * 7.2)
            Layout.margins: 0

            property color colorValue: Qt.rgba(1, 0, 0, 1)

            function updateFinalColor() {
                if (colorPanel && colorPanel.xPercent !== undefined && colorPanel.yPercent !== undefined) {
                    if (isNaN(colorPanel.xPercent) || isNaN(colorPanel.yPercent)) {
                        return
                    }

                    var hueColor = colorPanel.getHueColor(colorPanel.xPercent)
                    if (hueColor) {
                        var saturationColor = colorPanel.getSaturationColor(hueColor, colorPanel.yPercent)
                        if (saturationColor && colorPanel.brightnessPercent !== undefined) {
                            if (isNaN(colorPanel.brightnessPercent)) {
                                return
                            }

                            var finalColor = Qt.rgba(saturationColor.r * colorPanel.brightnessPercent, saturationColor.g * colorPanel.brightnessPercent, saturationColor.b * colorPanel.brightnessPercent, 1.0)
                            colorValue = finalColor
                            control.updateColor()
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: panelRadius
                color: panelBackgroundColor
                border.width: Fonts.size1
                border.color: subtleBorderColor
            }

            Item {
                id: pickerRow
                anchors.fill: parent
                anchors.margins: Fonts.size1

                Rectangle {
                    id: colorPanel
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: brightnessBar.left
                    anchors.rightMargin: Fonts.size8
                    radius: panelRadius
                    color: "transparent"
                    clip: true

                    property real xPercent: width > 0 ? Math.max(0, Math.min(1, pickerCursor.x / width)) : 0
                    property real yPercent: height > 0 ? Math.max(0, Math.min(1, pickerCursor.y / height)) : 0
                    property real brightnessPercent: brightnessBar.height > 0 ? Math.max(0, Math.min(1, 1.0 - (brightnessCursor.y / brightnessBar.height))) : 1.0

                    onXPercentChanged: colorPickerPanel.updateFinalColor()
                    onYPercentChanged: colorPickerPanel.updateFinalColor()
                    onBrightnessPercentChanged: colorPickerPanel.updateFinalColor()

                    function getHueColor(x) {
                        if (isNaN(x) || x < 0 || x > 1) {
                            return Qt.rgba(1, 0, 0, 1)
                        }

                        var h = x
                        var r, g, b

                        if (h < 1 / 6) {
                            r = 1
                            g = h * 6
                            b = 0
                        } else if (h < 2 / 6) {
                            r = 2 - h * 6
                            g = 1
                            b = 0
                        } else if (h < 3 / 6) {
                            r = 0
                            g = 1
                            b = (h - 2 / 6) * 6
                        } else if (h < 4 / 6) {
                            r = 0
                            g = (4 / 6 - h) * 6
                            b = 1
                        } else if (h < 5 / 6) {
                            r = (h - 4 / 6) * 6
                            g = 0
                            b = 1
                        } else {
                            r = 1
                            g = 0
                            b = (1 - h) * 6
                        }

                        if (isNaN(r) || isNaN(g) || isNaN(b)) {
                            return Qt.rgba(1, 0, 0, 1)
                        }

                        return Qt.rgba(r, g, b, 1)
                    }

                    function getSaturationColor(hueColor, y) {
                        if (!hueColor || isNaN(y) || y < 0 || y > 1) {
                            return Qt.rgba(1, 0, 0, 1)
                        }

                        var whiteness = y

                        var r = hueColor.r * (1 - whiteness) + whiteness
                        var g = hueColor.g * (1 - whiteness) + whiteness
                        var b = hueColor.b * (1 - whiteness) + whiteness

                        if (isNaN(r) || isNaN(g) || isNaN(b)) {
                            return Qt.rgba(1, 0, 0, 1)
                        }

                        return Qt.rgba(r, g, b, 1.0)
                    }

                    Item {
                        anchors.fill: parent

                        Rectangle {
                            id: hueGradient
                            anchors.fill: parent
                            radius: panelRadius

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0.0
                                    color: "#FF0000"
                                }
                                GradientStop {
                                    position: 0.16667
                                    color: "#FFFF00"
                                }
                                GradientStop {
                                    position: 0.33333
                                    color: "#00FF00"
                                }
                                GradientStop {
                                    position: 0.5
                                    color: "#00FFFF"
                                }
                                GradientStop {
                                    position: 0.66667
                                    color: "#0000FF"
                                }
                                GradientStop {
                                    position: 0.83333
                                    color: "#FF00FF"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#FF0000"
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: panelRadius
                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop {
                                    position: 0.0
                                    color: "#00FFFFFF"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#FFFFFFFF"
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: panelRadius
                            border.width: Fonts.size1
                            border.color: subtleBorderColor
                            color: "transparent"
                        }
                    }

                    Item {
                        id: pickerCursor
                        property bool isInitialized: false

                        Component.onCompleted: {
                            if (!isInitialized) {
                                x = 0
                                y = 0
                                isInitialized = true
                            }
                        }

                        Rectangle {
                            x: -width / 2
                            y: -height / 2
                            width: colorHandleRadius * Fonts.size2
                            height: colorHandleRadius * Fonts.size2
                            radius: colorHandleRadius
                            border.color: "black"
                            border.width: Fonts.size2
                            color: "transparent"
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: Fonts.size2
                                border.color: "white"
                                border.width: Fonts.size2
                                radius: width / 2
                                color: "transparent"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        function handleMouse(mouse) {
                            if (mouse.buttons & Qt.LeftButton) {
                                if (width > 0 && height > 0 && !isNaN(mouse.x) && !isNaN(mouse.y)) {
                                    pickerCursor.x = Math.max(0, Math.min(mouse.x, width))
                                    pickerCursor.y = Math.max(0, Math.min(mouse.y, height))
                                    colorPickerPanel.updateFinalColor()
                                }
                            }
                        }
                        onPositionChanged: mouse => handleMouse(mouse)
                        onPressed: mouse => handleMouse(mouse)
                    }
                }

                Rectangle {
                    id: brightnessBar
                    width: Fonts.size20
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: panelRadius

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0.0
                            color: {
                                if (isNaN(colorPanel.xPercent) || isNaN(colorPanel.yPercent)) {
                                    return "#FF0000"
                                }

                                var hueColor = colorPanel.getHueColor(colorPanel.xPercent)
                                var saturationColor = colorPanel.getSaturationColor(hueColor, colorPanel.yPercent)

                                if (!saturationColor) {
                                    return "#FF0000"
                                }

                                return saturationColor
                            }
                        }
                        GradientStop {
                            position: 1.0
                            color: "#000000"
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: panelRadius
                        border.width: Fonts.size1
                        border.color: subtleBorderColor
                        color: "transparent"
                    }

                    Item {
                        id: brightnessCursor
                        property bool isInitialized: false
                        y: 0
                        x: 0

                        Component.onCompleted: {
                            if (!isInitialized) {
                                y = 0
                                isInitialized = true
                            }
                        }

                        Rectangle {
                            x: -height / 2
                            y: -height / 2
                            width: parent.parent.width + height
                            height: Fonts.size4
                            radius: Fonts.size2
                            border.color: "black"
                            border.width: Fonts.size1
                            color: "white"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        function handleMouse(mouse) {
                            if (mouse.buttons & Qt.LeftButton) {
                                if (height > 0 && !isNaN(mouse.y)) {
                                    brightnessCursor.y = Math.max(0, Math.min(mouse.y, height))
                                    colorPickerPanel.updateFinalColor()
                                }
                            }
                        }
                        onPositionChanged: mouse => handleMouse(mouse)
                        onPressed: mouse => handleMouse(mouse)
                    }
                }
            }
        }

        GridLayout {
            id: rgbInputLayout

            Layout.fillWidth: true
            Layout.margins: 0
            columns: 3
            columnSpacing: Math.round(unit * 0.6)
            rowSpacing: Math.round(unit * 0.15)

            CustomLabel {
                text: qsTr("R:")
                color: textColor
            }
            CustomTextField {
                id: redInput
                Layout.fillWidth: true
                property bool updating: false
                text: "0"
                validator: IntValidator {
                    bottom: 0
                    top: 255
                }
                onTextChanged: {
                    if (!updating && text) {
                        updateColorFromInputs()
                    }
                }
            }
            CustomLabel {
                text: "(0-255)"
                color: textColor
            }

            CustomLabel {
                text: qsTr("G:")
                color: textColor
            }
            CustomTextField {
                id: greenInput
                Layout.fillWidth: true
                property bool updating: false
                text: "0"
                validator: IntValidator {
                    bottom: 0
                    top: 255
                }
                onTextChanged: {
                    if (!updating && text) {
                        updateColorFromInputs()
                    }
                }
            }
            CustomLabel {
                text: "(0-255)"
                color: textColor
            }

            CustomLabel {
                text: qsTr("B:")
                color: textColor
            }
            CustomTextField {
                id: blueInput
                Layout.fillWidth: true
                property bool updating: false
                text: "0"
                validator: IntValidator {
                    bottom: 0
                    top: 255
                }
                onTextChanged: {
                    if (!updating && text) {
                        updateColorFromInputs()
                    }
                }
            }
            CustomLabel {
                text: "(0-255)"
                color: textColor
            }
        }
    }

    footer: Rectangle {
        id: footerRect
        color: "transparent"
        implicitHeight: buttonRow.implicitHeight + unit
        clip: true
        Rectangle {
            anchors.fill: parent
            radius: dialogRadius
            color: Qt.rgba(alternateBaseColor.r, alternateBaseColor.g, alternateBaseColor.b, 0.85)
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: dialogRadius
            color: Qt.rgba(alternateBaseColor.r, alternateBaseColor.g, alternateBaseColor.b, 0.85)
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Fonts.size1
            color: subtleBorderColor
        }

        RowLayout {
            id: buttonRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: unit
            spacing: Math.round(unit * 0.6)
            property int actionButtonWidth: Math.max(cancelBtn.implicitWidth, okBtn.implicitWidth)

            CustomButton {
                id: cancelBtn
                text: qsTr("Cancel")
                buttonColor: control.buttonColor
                buttonTextColor: control.buttonTextColor
                width: buttonRow.actionButtonWidth
                onClicked: control.reject()
            }

            CustomButton {
                id: okBtn
                text: qsTr("OK")
                buttonColor: highlightColor
                buttonTextColor: Theme.highlightedTextColor
                width: buttonRow.actionButtonWidth
                onClicked: control.accept()
            }
        }
    }

    Connections {
        target: colorPickerPanel
        function onColorValueChanged() {
            redInput.updating = true
            greenInput.updating = true
            blueInput.updating = true

            updateTextFields()

            redInput.updating = false
            greenInput.updating = false
            blueInput.updating = false
        }
    }

    function updateTextFields() {
        if (colorPickerPanel && colorPickerPanel.colorValue) {
            var r = Math.round((colorPickerPanel.colorValue.r || 0) * 255)
            var g = Math.round((colorPickerPanel.colorValue.g || 0) * 255)
            var b = Math.round((colorPickerPanel.colorValue.b || 0) * 255)

            if (!isNaN(r) && !isNaN(g) && !isNaN(b)) {
                redInput.text = r.toString()
                greenInput.text = g.toString()
                blueInput.text = b.toString()
            }
        }
    }

    function isValidRgbColor(c) {
        return c && c.r !== undefined && c.g !== undefined && c.b !== undefined && !isNaN(c.r) && !isNaN(c.g) && !isNaN(c.b)
    }

    function applyColorToUi(color) {
        if (!isValidRgbColor(color)) {
            return
        }

        colorPickerPanel.colorValue = Qt.rgba(color.r, color.g, color.b, 1.0)
        selectedColor = colorPickerPanel.colorValue

        var hsv = rgbToHsv(color.r, color.g, color.b)
        if (isNaN(hsv.h) || isNaN(hsv.s) || isNaN(hsv.v)) {
            hsv = {
                h: 0,
                s: 0,
                v: 1
            }
        }

        pickerCursor.x = Math.max(0, Math.min(hsv.h * colorPanel.width, colorPanel.width))
        pickerCursor.y = Math.max(0, Math.min(hsv.s * colorPanel.height, colorPanel.height))
        brightnessCursor.y = Math.max(0, Math.min((1 - hsv.v) * brightnessBar.height, brightnessBar.height))
        updateTextFields()
    }

    function rgbToHsv(r, g, b) {
        if (isNaN(r) || isNaN(g) || isNaN(b)) {
            return {
                h: 0,
                s: 0,
                v: 1
            }
        }

        r = Math.max(0, Math.min(1, r))
        g = Math.max(0, Math.min(1, g))
        b = Math.max(0, Math.min(1, b))

        var max = Math.max(r, g, b)
        var min = Math.min(r, g, b)
        var d = max - min
        var h
        var s = (max === 0 ? 0 : d / max)
        var v = max

        if (max === min) {
            h = 0
        } else {
            switch (max) {
            case r:
                h = (g - b) / d + (g < b ? 6 : 0)
                break
            case g:
                h = (b - r) / d + 2
                break
            case b:
                h = (r - g) / d + 4
                break
            }
            h /= 6
        }

        if (isNaN(h) || isNaN(s) || isNaN(v)) {
            return {
                h: 0,
                s: 0,
                v: 1
            }
        }

        var whiteness = 1 - s

        return {
            h: h,
            s: whiteness,
            v: v
        }
    }

    function updateColor() {
        if (colorPickerPanel && colorPickerPanel.colorValue) {
            selectedColor = colorPickerPanel.colorValue
        }
    }

    function updateColorFromInputs() {
        if (!redInput.text || !greenInput.text || !blueInput.text)
            return
        let r = Math.max(0, Math.min(parseInt(redInput.text, 10) || 0, 255)) / 255
        let g = Math.max(0, Math.min(parseInt(greenInput.text, 10) || 0, 255)) / 255
        let b = Math.max(0, Math.min(parseInt(blueInput.text, 10) || 0, 255)) / 255

        if (!isNaN(r) && !isNaN(g) && !isNaN(b)) {
            colorPickerPanel.colorValue = Qt.rgba(r, g, b, 1.0)
            selectedColor = colorPickerPanel.colorValue

            var hsv = rgbToHsv(r, g, b)

            if (!isNaN(hsv.h) && !isNaN(hsv.s) && !isNaN(hsv.v)) {
                pickerCursor.x = Math.max(0, Math.min(hsv.h * colorPanel.width, colorPanel.width))
                pickerCursor.y = Math.max(0, Math.min(hsv.s * colorPanel.height, colorPanel.height))
                brightnessCursor.y = Math.max(0, Math.min((1 - hsv.v) * brightnessBar.height, brightnessBar.height))
            }
        }
    }
}
