import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../components" as Components
import "../../../lib" as Lib

Lib.Card {
    id: sectionQuickToggleButtons
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    // All Buttons
    ColumnLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: 1
        spacing: 1

        Components.NetworkBtn{
            flat: true
            noMargins: true
            isLongButton: true
        }
        Components.BluetoothBtn{
            flat: true
            noMargins: true
            isLongButton: true
            heading: i18n("Bluetooth")
        }
        Components.ColorSchemeSwitcher{
            flat: true
            noMargins: true
            isLongButton: true
            heading: i18n("Appearance")
        }
    }
}