import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import Qt.labs.folderlistmodel

import org.kde.kquickcontrols as KQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

import "./js/archiveDir.js" as ArchiveDirUtils

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    property alias formLayout: root

    property var configDialog
    property var wallpaperConfiguration: wallpaper.configuration

    property string cfg_SelectedFile
    property int cfg_FillMode
    property alias cfg_Color: colorButton.color
    property int cfg_UpdateOverMeteredConnection

    property int pageSize: 5
    property int currentPage: 0
    readonly property int totalPages: Math.max(1, Math.ceil(folderModel.count / pageSize))
    readonly property int pageStart: currentPage * pageSize
    readonly property int pageItemCount: Math.max(0, Math.min(pageSize, folderModel.count - pageStart))

    readonly property string archiveDir: ArchiveDirUtils.resolveArchiveDir()

    function selectedFilePath() {
        if (!cfg_SelectedFile || cfg_SelectedFile.length === 0) {
            return "";
        }
        return archiveDir + "/" + cfg_SelectedFile;
    }

    function findFileIndex(fileName) {
        for (var i = 0; i < folderModel.count; i++) {
            if (folderModel.get(i, "fileName") === fileName) {
                return i;
            }
        }
        return -1;
    }

    function ensureSelectedFile() {
        if (folderModel.count === 0) {
            cfg_SelectedFile = "";
            currentPage = 0;
            return;
        }

        var idx = findFileIndex(cfg_SelectedFile);
        if (idx < 0) {
            cfg_SelectedFile = folderModel.get(0, "fileName");
            idx = 0;
        }

        var page = Math.floor(idx / pageSize);
        currentPage = Math.max(0, Math.min(page, totalPages - 1));
    }

    function selectByRealIndex(realIndex) {
        if (realIndex < 0 || realIndex >= folderModel.count) {
            return;
        }
        var fileName = folderModel.get(realIndex, "fileName");
        cfg_SelectedFile = fileName;
        ensureSelectedFile();
        // 即时应用所选壁纸（无需等待对话框确认）
        wallpaperConfiguration.SelectedFile = fileName;
    }

    QQC2.ComboBox {
        id: resizeComboBox
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Positioning:")
        model: [
            { label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Scaled and cropped"), fillMode: Image.PreserveAspectCrop },
            { label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Scaled"), fillMode: Image.Stretch },
            { label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Scaled, keep proportions"), fillMode: Image.PreserveAspectFit },
            { label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Centered"), fillMode: Image.Pad },
            { label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Tiled"), fillMode: Image.Tile }
        ]

        textRole: "label"
        onActivated: cfg_FillMode = model[currentIndex].fillMode
        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i].fillMode === cfg_FillMode) {
                    currentIndex = i;
                    return;
                }
            }
            currentIndex = 0;
        }
    }

    KQC2.ColorButton {
        id: colorButton
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Background color:")
        dialogTitle: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Select Background Color")
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Network:")
        text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Update when using metered network connection")
        checked: cfg_UpdateOverMeteredConnection === 1
        onToggled: cfg_UpdateOverMeteredConnection = checked ? 1 : 0
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Actions:")

        QQC2.Button {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Open current image")
            icon.name: "document-open"
            enabled: cfg_SelectedFile && cfg_SelectedFile.length > 0
            onClicked: Qt.openUrlExternally("file://" + root.selectedFilePath())
        }

        QQC2.Button {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Clean up images older than 30 days")
            icon.name: "edit-clear-history"
            onClicked: cleanupExec.connectSource("find " + ArchiveDirUtils.shellQuote(root.archiveDir) + " -maxdepth 1 -type f -name '*.jpg' -mtime +30 -delete")
        }
    }

    Item {
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","History:")
        Layout.fillWidth: true
        Layout.preferredHeight: thumbsColumn.implicitHeight + Kirigami.Units.smallSpacing
        visible: folderModel.count > 0

        FolderListModel {
            id: folderModel
            folder: "file://" + root.archiveDir
            nameFilters: ["*.jpg"]
            sortField: FolderListModel.Name
            sortReversed: true
            showDirs: false

            onCountChanged: root.ensureSelectedFile()
            onStatusChanged: {
                if (status === FolderListModel.Ready) {
                    root.ensureSelectedFile();
                }
            }
        }

        ColumnLayout {
            id: thumbsColumn
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: root.pageItemCount

                    delegate: Item {
                        required property int index
                        property int realIndex: root.pageStart + index
                        property string fileName: folderModel.get(realIndex, "fileName")
                        property url fileUrl: folderModel.get(realIndex, "fileUrl")

                        width: 120
                        height: 75

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: parent.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            sourceSize.width: 240
                            sourceSize.height: 150

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: cfg_SelectedFile === parent.parent.fileName
                                    ? Kirigami.Theme.highlightColor
                                    : (thumbMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent")
                                border.width: cfg_SelectedFile === parent.parent.fileName ? 3 : 2
                                radius: 3
                            }
                        }

                        MouseArea {
                            id: thumbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectByRealIndex(parent.realIndex)
                        }

                        QQC2.ToolTip.visible: thumbMouse.containsMouse
                        QQC2.ToolTip.text: fileName
                    }
                }
            }

            RowLayout {
                QQC2.Button {
                    text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Previous page")
                    enabled: root.currentPage > 0
                    onClicked: root.currentPage -= 1
                }

                QQC2.Label {
                    text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","%1 / %2", root.currentPage + 1, root.totalPages)
                }

                QQC2.Button {
                    text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Next page")
                    enabled: root.currentPage < root.totalPages - 1
                    onClicked: root.currentPage += 1
                }
            }
        }
    }

    QQC2.Label {
        Kirigami.FormData.label: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","History:")
        visible: folderModel.count === 0
        text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","No history wallpapers")
        opacity: 0.6
    }

    Plasma5Support.DataSource {
        id: cleanupExec
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            cleanupExec.disconnectSource(source);
            folderModel.folder = "";
            Qt.callLater(function() {
                folderModel.folder = "file://" + root.archiveDir;
                root.ensureSelectedFile();
            });
        }
    }
}
