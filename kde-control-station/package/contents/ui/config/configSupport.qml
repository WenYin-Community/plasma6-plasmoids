import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
   
    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // 项目信息
        Label {
            text: i18n("KDE Control Station")
            font.pixelSize: Kirigami.Units.gridUnit * 1.5
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        Label {
            text: i18n("A modern control station for KDE Plasma 6")
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true
        }

        // 仓库信息
        Label {
            text: i18n("Repository:")
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        Label {
            text: "github.com/WenYin-Community/plasma6-plasmoids"
            color: Kirigami.Theme.linkColor
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://github.com/WenYin-Community/plasma6-plasmoids")
            }
        }

        // 贡献者
        Label {
            text: i18n("Contributors:")
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        Label {
            text: "Eliver Lara (Original Author)\nWenYin-Community (Qt6 Port & Fixes)"
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true
        }

        // 分隔线
        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing
        }

        // 支持信息
        Label {
            text: i18n("I'd be very thankful if you like to support the development of this applet by donating or by simply spreading the word, TIA! :)")
            
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Row {
            spacing: 10
            height: Kirigami.Units.gridUnit * 2.5
            Layout.topMargin: 20
            Image {
                height: parent.height
                source: "../../assets/Paypal.png"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://www.paypal.me/EliverLara/")
                    }
                }
            }
            Image {
                height: parent.height
                source: "../../assets/Ko-Fi.png"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://ko-fi.com/eliverlara")
                    }
                }
            }
        }

        // 版权信息
        Label {
            text: "Copyright © 2026 Eliver Lara. Licensed under GPLv3."
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
