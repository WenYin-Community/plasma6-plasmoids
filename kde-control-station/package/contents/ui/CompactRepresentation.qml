import QtQml
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
Item {
    id: compactRep
    
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage && Plasmoid.configuration.customButtonImage.length != 0)
    
    RowLayout {
        anchors.fill: parent
        
        Kirigami.Icon {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: useCustomButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon
            smooth: true
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.expanded = !root.expanded
                }
            }
        }
    }
}
