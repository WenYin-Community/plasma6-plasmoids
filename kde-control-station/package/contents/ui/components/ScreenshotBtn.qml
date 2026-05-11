import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.plasmoid
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami 

import "../lib" as Lib
import "../js/colorType.js" as ColorType

Lib.CardButton {
    id: screenshotBtn

    visible: root.showScreenshot

    property bool mini: false 

    Layout.fillHeight: true
    Layout.fillWidth: true
    title: i18n("Screenshot")
    property string command: root.screenshotCommand ?? "spectacle"
    shouldStickIconSize: true
    Kirigami.Icon {
        anchors.fill: parent
        anchors.centerIn: parent
        source: "camera-photo-symbolic"
    }

    onClicked: {
        if(root.hideWidgetBeforeScreenshot) { root.expanded = false; }
        executable.exec(command);
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: { 
            disconnectSource(sourceName)
        }
        
        function exec(cmd) {
            connectSource(cmd)
        }
    }
}
