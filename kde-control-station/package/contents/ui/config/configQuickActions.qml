import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import QtQuick.Layouts

KCM.SimpleKCM {
    id: quickActionsForm

    property bool cfg_enableQuickActions: Plasmoid.configuration.enableQuickActions

    Kirigami.FormLayout {

        RowLayout {
            
            anchors.fill: parent

            ButtonGroup { 
                id: group 
                onClicked: button => quickActionsForm.cfg_enableQuickActions = button.text === "Enabled"
            }

            ColumnLayout {
                AnimatedImage {
                    source: "assets/quick-action-enabled.gif"
                    sourceSize.width: 200
                    sourceSize.height: 150
                }

                RadioButton {
                    checked: quickActionsForm.cfg_enableQuickActions
                    text: qsTr("Enabled")
                    ButtonGroup.group: group
                }
            }

            ColumnLayout {
                AnimatedImage {
                    source: "assets/quick-action-disabled.gif"
                    sourceSize.width: 200
                    sourceSize.height: 150
                }

                RadioButton {
                    checked: !quickActionsForm.cfg_enableQuickActions
                    text: qsTr("Disabled")
                    ButtonGroup.group: group
                }
            }
            
        }
       
    }
}