import QtQuick 2.15
import QtQuick.Layouts 1.15
import GeoControls 1.0

RowLayout {
    id: control

    property int page: 1
    property int pageCount: 1
    property int maxVisiblePages: 7

    signal pageRequested(int page)

    spacing: Fonts.size4

    function requestPage(nextPage) {
        var bounded = Math.max(1, Math.min(control.pageCount, nextPage))
        if (bounded === control.page)
            return
        control.page = bounded
        control.pageRequested(bounded)
    }

    readonly property int visibleCount: Math.max(1, Math.min(maxVisiblePages, pageCount))
    readonly property int firstPage: Math.max(1, Math.min(page - Math.floor(visibleCount / 2), pageCount - visibleCount + 1))

    CustomButton {
        text: "<"
        enabled: control.page > 1
        defaultHeight: Fonts.iconButtonSize
        defaultPadding: Fonts.size6
        onClicked: control.requestPage(control.page - 1)
    }

    Repeater {
        model: control.visibleCount

        SegmentedButton {
            required property int index
            readonly property int pageNumber: control.firstPage + index

            text: String(pageNumber)
            selected: pageNumber === control.page
            defaultHeight: Fonts.iconButtonSize
            defaultPadding: Fonts.size6
            onClicked: control.requestPage(pageNumber)
        }
    }

    CustomButton {
        text: ">"
        enabled: control.page < control.pageCount
        defaultHeight: Fonts.iconButtonSize
        defaultPadding: Fonts.size6
        onClicked: control.requestPage(control.page + 1)
    }
}
