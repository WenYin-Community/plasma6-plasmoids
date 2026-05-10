import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami


Item
{
    property color sourceColor
    property alias source: icon.source
    property alias selected: icon.selected
    property bool fullSizeIcon : false
    property bool customIcon: false
    property bool enableQuickAction: false

    signal quickActionTriggered

    property color highlightColor: root.useSystemColorsOnToggles ? root.themeHighlightColor : root.toggleButtonsColor
    property color iconColor: root.useSystemColorsOnToggles ?  Kirigami.Theme.highlightedTextColor : root.toggleButtonsIconColor

    Rectangle {
        id: rect
        radius: width/2
        color: icon.selected ? highlightColor : sourceColor.valid ? sourceColor : root.disabledBgColor
        anchors.fill: parent
        

        Kirigami.Icon {
            id: icon
            visible: true
            anchors.fill: parent
            anchors.margins: fullSizeIcon ? root.largeSpacing : root.smallSpacing
            anchors.centerIn: parent
            selected: false
            isMask: customIcon
            color: selected ? iconColor : Kirigami.Theme.textColor
        }
    }

    MouseArea {
        enabled: !root.editingLayout && enableQuickAction
        hoverEnabled: true
        anchors.fill: parent
        
        onClicked: quickActionTriggered()
    }
}
