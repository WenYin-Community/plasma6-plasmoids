import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {

    property alias cfg_hideWidgetOnScreenshot: hideWidgetOnScreenshot.checked
    property alias cfg_screenshotCommand: screenshotCommand.text

    Kirigami.FormLayout {
        CheckBox {
            id: hideWidgetOnScreenshot
            Kirigami.FormData.label: i18n("Hide widget before screenshotting:")
        }

        TextField {
            id: screenshotCommand
            Kirigami.FormData.label: i18n("Screenshot Command (default is 'spectacle'):")
        }
    }
}