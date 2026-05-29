import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import GeoToy.Controls 1.0

GroupBox {
    id: control

    Layout.fillWidth: true
    Layout.topMargin: (hasLabel ? Fonts.groupBoxTopMargin : 0)
    Layout.margins: 0
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignTop

    property color borderColor: Theme.midColor
    property color titleColor: Theme.textColor
    property int borderWidth: Fonts.size1
    property int borderRadius: Fonts.size3
    property int titleFontSize: Fonts.standardFont.pixelSize * 1.1
    property bool titleFontBold: true
    property int prevHeight: implicitHeight
    property bool hasLabel: (control.title.length > 0) || control.collapsible
    property int arrowSize: Math.round(titleFontSize * 1.1)
    property bool initialExpanded: true
    property bool expanded: initialExpanded
    property bool collapsible: true
    property bool initialized: false
    property bool animateHeight: true

    signal toggled(bool expanded)

    Behavior on implicitHeight {
        enabled: control.initialized && control.animateHeight
        NumberAnimation {
            id: heightAnim
            duration: 150
            onStopped: {
                if (!control.expanded && control.contentItem) {
                    control.contentItem.visible = false;
                }
            }
        }
    }

    Component.onCompleted: {
        if (control.contentItem) {
            control.contentItem.clip = true;
        }

        control.initialized = false;
        control.expanded = control.initialExpanded;
        control.prevHeight = control.implicitHeight;
        if (!control.expanded) {
            if (control.contentItem)
                control.contentItem.visible = false;
            control.implicitHeight = 0;
        } else {
            if (control.contentItem)
                control.contentItem.visible = true;
        }
        control.initialized = true;
    }

    background: Rectangle {
        color: "transparent"
        border.color: control.borderColor
        border.width: control.borderWidth
        radius: control.borderRadius
    }

    label: Item {
        visible: control.hasLabel
        x: control.borderWidth * Fonts.size4
        y: -(customLabel.height + control.borderWidth * Fonts.size2)
        width: customLabel.width + (control.collapsible ? arrow.width : 0) + control.borderWidth * Fonts.size8
        height: visible ? customLabel.height + control.borderWidth * Fonts.size2 : 0

        Rectangle {
            id: labelBackground
            color: control.background.color
            width: parent.width
            height: parent.height
            x: -(control.borderWidth * Fonts.size2)
            y: 0
        }

        Text {
            id: arrow
            text: "▶"
            visible: control.collapsible
            color: control.titleColor
            font.pixelSize: titleFontSize
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: control.arrowSize
            height: control.arrowSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            transformOrigin: Item.Center
            rotation: control.expanded ? 90 : 0
        }

        Text {
            id: customLabel
            text: control.title
            color: control.enabled ? control.titleColor : Theme.disabledTextColor
            font.pixelSize: titleFontSize
            font.bold: control.titleFontBold
            font.family: Fonts.standardFont.family
            elide: Text.ElideRight
            anchors.centerIn: parent
            renderType: Text.NativeRendering

            leftPadding: control.borderWidth * Fonts.size2
            rightPadding: control.borderWidth * Fonts.size2
            topPadding: control.borderWidth * Fonts.size2
            bottomPadding: control.borderWidth * Fonts.size2
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!control.collapsible)
                    return;
                var nextExpanded = !control.expanded;
                if (nextExpanded) {
                    if (control.contentItem)
                        control.contentItem.visible = true;
                    control.expanded = true;
                    control.toggled(control.expanded);
                    control.implicitHeight = control.prevHeight;
                } else {
                    control.prevHeight = control.implicitHeight;
                    if (control.contentItem)
                        control.contentItem.visible = true;
                    control.expanded = false;
                    control.toggled(control.expanded);
                    control.implicitHeight = 0;
                }
            }
        }
    }

    padding: Fonts.size10
    topPadding: Fonts.size10
}
