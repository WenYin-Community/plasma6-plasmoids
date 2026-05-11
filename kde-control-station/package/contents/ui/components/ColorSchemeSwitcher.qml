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
    id: colorSchemeSwitcher

    visible: root.showColorSwitcher
    Layout.fillHeight: true
    Layout.fillWidth: true
    title: i18n("Dark Theme")
    property string command: root.preferChangeGlobalTheme ? 
                            "plasma-apply-lookandfeel -a " : 
                            "plasma-apply-colorscheme "

    property alias sourceColor: icon.sourceColor
    
    Lib.Icon {
        id: icon
        anchors.fill: parent
        fullSizeIcon: colorSchemeSwitcher.fullSizeIcon
        source: Qt.resolvedUrl("../icons/feather/dark-mode.svg")
        selected: root.isDarkTheme
        customIcon: true
    }

    onClicked: {
        var colorSchemeName = root.isDarkTheme ? root.generalLightTheme : root.generalDarkTheme
        executable.swapColorScheme(`${command}"${colorSchemeName}"`);
        root.isDarkTheme = !root.isDarkTheme
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

        function swapColorScheme(what) {
            exec(what)
        }
    }
}
