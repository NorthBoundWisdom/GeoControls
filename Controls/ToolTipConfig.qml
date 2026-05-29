pragma Singleton
import QtQuick 2.15

Item {
    id: tooltipConfig
    visible: false

    // Centralized tooltip timing (ms)
    // Keep values grouped so UX tuning is done in one place.
    property int immediateDelay: 0

    property int shortDelay: 400
    property int longDelay: 1000

    property int persistentTimeout: -1
    property int transientTimeout: 1500
}
