import QtQml
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


import "../../../components" as Components
import "../../../lib" as Lib

Lib.Card {
    id: sectionQuickToggleButtons
    Layout.fillWidth: true
    Layout.fillHeight: true
    flat: true
    noMargins: true
    
    // NETWORK
    property var network: network
    Components.Network {
        id: network
    }
    
    // BLUETOOTH
    property QtObject btManager : BluezQt.Manager
    
    // All Buttons
    ColumnLayout {
        id: buttonsColumn
        anchors.fill: parent
        anchors.margins: 1
        spacing: 1

        RowLayout {
            anchors.margins: 1
            spacing: 1
            Components.NetworkBtn{}
            Components.BluetoothBtn{}
        }

        RowLayout {
            anchors.margins: 1
            spacing: 1
            Components.DndButton{}
            Components.KDEConnect{}
        }
    }
}
