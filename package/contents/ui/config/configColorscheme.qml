import QtQml 2.0
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    // 声明所有配置属性以消除 "SimpleKCM does not have a property" 警告
    property alias cfg_lightTheme: labelA.text
    property alias cfg_darkTheme: labelB.text
    property alias cfg_lightGlobalTheme: labelC.text
    property alias cfg_darkGlobalTheme: labelD.text
    property alias cfg_preferChangeGlobalTheme: preferChangeGlobalTheme.checked

    // 以下属性仅用于消除警告，configColorscheme 页面不使用它们
    property int cfg_scale: 100
    property int cfg_layout: 0
    property bool cfg_animations: false
    property bool cfg_transparency: false
    property bool cfg_showBorders: true
    property int cfg_transparencyLevel: 40
    property bool cfg_isDarkTheme: false
    property string cfg_icon: "configure"
    property bool cfg_useCustomButtonImage: false
    property string cfg_customButtonImage: ""
    property bool cfg_showKDEConnect: true
    property bool cfg_showNightLight: true
    property bool cfg_showColorSwitcher: true
    property bool cfg_showDnd: true
    property bool cfg_showVolume: true
    property bool cfg_showBrightness: true
    property bool cfg_showMediaPlayer: true
    property bool cfg_showAvatar: true
    property bool cfg_showBattery: true
    property bool cfg_showSessionActions: true
    property bool cfg_showScreenshot: false
    property bool cfg_showCmd1: false
    property bool cfg_showCmd2: false
    property bool cfg_showPercentage: false
    property string cfg_cmdRun1: ""
    property string cfg_cmdTitle1: ""
    property string cfg_cmdIcon1: ""
    property string cfg_cmdRun2: ""
    property string cfg_cmdTitle2: ""
    property string cfg_cmdIcon2: ""
    property bool cfg_volume_widget_flat: false
    property bool cfg_volume_widget_title: true
    property bool cfg_volume_widget_thin: false
    property bool cfg_brightness_widget_flat: false
    property bool cfg_brightness_widget_title: true
    property bool cfg_brightness_widget_thin: false
    property bool cfg_useSystemColorsOnToggles: true
    property bool cfg_useSystemColorsOnSliders: true
    property color cfg_toggleButtonsColor: "#007aff"
    property color cfg_toggleButtonsIconColor: "#ffffff"
    property color cfg_slidersColor: "#ffffff"
    property string cfg_customLayoutModel: "null"
    property bool cfg_usePlasmaSliders: false
    property bool cfg_hideWidgetOnScreenshot: false
    property string cfg_screenshotCommand: "spectacle"
    property bool cfg_enableQuickActions: true
    property bool cfg_playVolumeFeedback: false

    property string command: preferChangeGlobalTheme.checked ? 
                            "plasma-apply-lookandfeel --list" : 
                            "plasma-apply-colorscheme --list-schemes | tail --lines=+2"
    
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        signal colorsListReady(var colors)

        function exec(cmd) {
            connectSource(cmd)
        }

        onNewData: {
            var colors = data["stdout"].split("\n")
            if(!preferChangeGlobalTheme.checked) {
                for (var i = 0; i < colors.length; i++) { // parse command output
                    colors[i] = colors[i].substring(3).split(" ")[0]
                }
            } 
            colors.pop()
            colorsListReady(colors)
            disconnectSource(sourceName) // cmd finished
            
        }

    }

    // Copies of the last saved ComboBox entries.
    Label {
        id: labelA
        visible: false
    }
    Label {
        id: labelB
        visible: false
    }
   
    Label {
        id: labelC
        visible: false
    }
    Label {
        id: labelD
        visible: false
    }

    function setText(comboBox, text) { // comboboxes don't really allow to set current entry by text => manually search for them
        var found = false
        for (var colorIndex = 0; colorIndex < comboBox.count; colorIndex++) {
            if (comboBox.currentText === text) {
                found = true
                break
            }
            comboBox.incrementCurrentIndex()
        }
        if (!found)
            console.log("Color not found (perhaps it has been removed?).")
    }

    Connections {
        target: executable
        function onColorsListReady(colors) {
            cBoxA.model = colors
            cBoxB.model = colors
            // look for color in list

            setText(cBoxA, preferChangeGlobalTheme.checked ? labelC.text : labelA.text)
            setText(cBoxB,  preferChangeGlobalTheme.checked ? labelD.text : labelB.text)
            // enable changes user just after everything is set up
            cBoxA.isChangeAvailable = true
            cBoxB.isChangeAvailable = true
        }
    }

    ColumnLayout {
        
        CheckBox {
            id: preferChangeGlobalTheme
            text: i18n("Change global theme instead of just changing color scheme")
            onClicked: {
                executable.exec(command)
            }
        }
        GridLayout {
            columns: 2
            Label {
                Layout.row :0
                Layout.column: 0
                text: i18n("Light color")
            }

            ComboBox {
                id: cBoxA
                property bool isChangeAvailable: false

                Layout.row: 0
                Layout.column: 1
                Layout.minimumWidth: 300
                onCurrentTextChanged: {
                    var targetLabel =  preferChangeGlobalTheme.checked ? labelC : labelA
                    if (isChangeAvailable)
                        targetLabel.text = currentText
                }
            }

            Label {
                Layout.row :1
                Layout.column: 0
                text: i18n("Dark color")
            }

            ComboBox {
                id: cBoxB
                property bool isChangeAvailable: false

                Layout.row: 1
                Layout.column: 1
                Layout.minimumWidth: 300

                onCurrentTextChanged: {
                    var targetLabel =  preferChangeGlobalTheme.checked ? labelD : labelB
                    if (isChangeAvailable)
                       targetLabel.text = currentText
                }
            }
        }
    }

    Component.onCompleted: {
        executable.exec(command)
    }
}
