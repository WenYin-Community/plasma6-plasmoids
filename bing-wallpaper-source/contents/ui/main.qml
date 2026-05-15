import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.wallpapers.potd

WallpaperItem {
    id: root

    property string archiveDir: ""
    property var archiveFiles: []
    property int selectedIndex: 0
    property int refreshNonce: 0
    property string pendingAction: ""
    property bool archiveLoaded: false
    readonly property string selectedFile: (root.configuration.SelectedFile || "").toString()
    property string lastAppliedFile: ""
    property string previewFile: ""

    readonly property string selectedArchivePath: {
        if (selectedIndex < 0 || selectedIndex >= archiveFiles.length) {
            return "";
        }
        return archiveDir + "/" + archiveFiles[selectedIndex];
    }
    readonly property string imagePath: selectedArchivePath.length > 0 ? selectedArchivePath : backend.localUrl
    readonly property string imageSource: toFileUrl(imagePath)
    readonly property bool isTodayImage: selectedArchivePath.length > 0 && selectedIndex === 0

    contextualActions: [
        PlasmaCore.Action {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Refresh today's wallpaper")
            icon.name: "view-refresh"
            onTriggered: root.refreshNonce += 1
        },
        PlasmaCore.Action {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Previous")
            icon.name: "go-previous"
            enabled: root.archiveLoaded && root.archiveFiles.length > 0 && root.selectedIndex < root.archiveFiles.length - 1
            onTriggered: root.selectArchiveByIndex(root.selectedIndex + 1)
        },
        PlasmaCore.Action {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Next")
            icon.name: "go-next"
            enabled: root.archiveLoaded && root.archiveFiles.length > 0 && root.selectedIndex > 0
            onTriggered: root.selectArchiveByIndex(root.selectedIndex - 1)
        },
        PlasmaCore.Action {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Search image info")
            icon.name: "help-about"
            enabled: backend.infoUrl.toString().length > 0
            onTriggered: Qt.openUrlExternally(root.toBingUrl(backend.infoUrl.toString()))
        }
    ]

    function shellQuote(raw) {
        var s = (raw || "").toString();
        return "'" + s.split("'").join("'\\''") + "'";
    }

    function toFileUrl(path) {
        if (!path) {
            return "";
        }
        if (path.startsWith("file://")) {
            return path;
        }
        return "file://" + path;
    }

    function toBingUrl(link) {
        if (!link) {
            return "";
        }
        if (link.startsWith("http://") || link.startsWith("https://")) {
            return link;
        }
        if (link.startsWith("/")) {
            return "https://www.bing.com" + link;
        }
        return link;
    }

    function todayText() {
        var d = new Date();
        var y = d.getFullYear().toString();
        var m = ("0" + (d.getMonth() + 1)).slice(-2);
        var day = ("0" + d.getDate()).slice(-2);
        return y + m + day;
    }

    function resolveArchiveDir() {
        var pictures = StandardPaths.standardLocations(StandardPaths.PicturesLocation);
        var dir = pictures.length > 0
            ? pictures[0].toString()
            : StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString() + "/Pictures";
        if (dir.startsWith("file://")) {
            dir = dir.substring(7);
        }
        return dir + "/bing-wallpaper-source";
    }

    function runCommand(command, action) {
        pendingAction = action;
        executable.connectSource(command);
    }

    function selectArchiveByIndex(idx) {
        if (idx < 0 || idx >= archiveFiles.length) {
            return;
        }
        selectedIndex = idx;
        root.configuration.SelectedFile = archiveFiles[idx];
        lastAppliedFile = archiveFiles[idx];
        // imageSource 会自动更新，触发 onImageSourceChanged 调用 loadImage
    }

    function syncSelectedIndex() {
        if (!archiveLoaded || archiveFiles.length === 0) {
            selectedIndex = 0;
            imageView.loadImage();
            return;
        }

        var targetFile = selectedFile || lastAppliedFile;
        var idx = archiveFiles.indexOf(targetFile);
        if (idx < 0) {
            idx = 0;
        }
        if (selectedIndex !== idx) {
            selectedIndex = idx;
            lastAppliedFile = archiveFiles[idx];
        }
        imageView.loadImage();
    }

    function ensureArchiveDir() {
        runCommand("mkdir -p " + shellQuote(archiveDir), "mkdir");
    }

    function listArchiveFiles() {
        runCommand("find " + shellQuote(archiveDir) + " -maxdepth 1 -type f -name '*.jpg' -printf '%f\\n'", "list");
    }

    function saveTodayImage() {
        if (!backend.localUrl || backend.localUrl.length === 0) {
            return;
        }
        var target = archiveDir + "/" + todayText() + ".jpg";
        var cmd = "cp -f " + shellQuote(backend.localUrl) + " " + shellQuote(target);
        runCommand(cmd, "save");
    }

    onImageSourceChanged: Qt.callLater(imageView.loadImage)
    onSelectedFileChanged: {
        if (selectedFile && selectedFile.length > 0) {
            lastAppliedFile = selectedFile;
            previewFile = selectedFile;
        }
        Qt.callLater(syncSelectedIndex);
    }
    onPreviewFileChanged: {
        if (previewFile && previewFile.length > 0) {
            var idx = archiveFiles.indexOf(previewFile);
            if (idx >= 0 && idx !== selectedIndex) {
                selectedIndex = idx;
                imageView.loadImage();
            }
        }
    }
    onArchiveLoadedChanged: {
        if (archiveLoaded) {
            Qt.callLater(syncSelectedIndex);
        }
    }

    PotdBackend {
        id: backend
        identifier: "bing"
        arguments: {
            const w = imageView.sourceSize.width;
            const h = imageView.sourceSize.height;
            return [w, h, root.refreshNonce];
        }
        updateOverMeteredConnection: root.configuration.UpdateOverMeteredConnection

        onLocalUrlChanged: {
            root.saveTodayImage();
            Qt.callLater(imageView.loadImage);
        }

        onImageChanged: Qt.callLater(imageView.loadImage)
    }

    QQC2.StackView {
        id: imageView
        anchors.fill: parent

        readonly property int fillMode: root.configuration.FillMode
        readonly property size sourceSize: Qt.size(imageView.width * Screen.devicePixelRatio, imageView.height * Screen.devicePixelRatio)

        property Item pendingImage
        property bool doesSkipAnimation: true

        onFillModeChanged: Qt.callLater(imageView.loadImage)
        onSourceSizeChanged: Qt.callLater(imageView.loadImage)

        function loadImage() {
            if (root.imageSource.length === 0) {
                return;
            }

            if (imageView.pendingImage) {
                imageView.pendingImage.statusChanged.disconnect(replaceWhenLoaded);
                imageView.pendingImage.destroy();
                imageView.pendingImage = null;
            }

            imageView.doesSkipAnimation = imageView.empty;
            imageView.pendingImage = imageComponent.createObject(imageView, {
                "source": root.imageSource,
                "fillMode": imageView.fillMode,
                "opacity": imageView.doesSkipAnimation ? 1 : 0,
                "sourceSize": imageView.sourceSize,
                "width": imageView.width,
                "height": imageView.height
            });
            imageView.pendingImage.statusChanged.connect(imageView.replaceWhenLoaded);
            imageView.replaceWhenLoaded();
        }

        function replaceWhenLoaded() {
            if (!imageView.pendingImage) {
                return;
            }
            if (imageView.pendingImage.status === Image.Loading) {
                return;
            }
            imageView.pendingImage.statusChanged.disconnect(imageView.replaceWhenLoaded);
            imageView.replace(
                imageView.pendingImage,
                {},
                imageView.doesSkipAnimation ? QQC2.StackView.Immediate : QQC2.StackView.Transition
            );
            imageView.pendingImage = null;
        }

        Component {
            id: imageComponent

            Image {
                asynchronous: true
                cache: false
                autoTransform: true
                smooth: true

                QQC2.StackView.onActivated: root.accentColorChanged()
                QQC2.StackView.onDeactivated: destroy()
                QQC2.StackView.onRemoved: destroy()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: root.configuration.Color
            z: -1
            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration
                }
            }
        }

        replaceEnter: Transition {
            OpacityAnimator {
                to: 1
                duration: Math.round(Kirigami.Units.veryLongDuration * 5)
            }
        }

        replaceExit: Transition {
            PauseAnimation {
                duration: Math.round(Kirigami.Units.veryLongDuration * 5) + 500
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var stdout = (data["stdout"] || "").trim();
            var stderr = (data["stderr"] || "").trim();
            executable.disconnectSource(source);

            if (stderr.length > 0) {
                console.warn("BingWallpaperSource command stderr:", stderr);
            }

            if (pendingAction === "list") {
                if (!stdout) {
                    root.archiveFiles = [];
                    root.archiveLoaded = true;
                    root.syncSelectedIndex();
                    return;
                }
                var files = stdout.split("\n").filter(function(x) { return x.length > 0; });
                files.sort();
                files.reverse();
                root.archiveFiles = files;
                root.archiveLoaded = true;
                root.syncSelectedIndex();
                return;
            }

            if (pendingAction === "save" || pendingAction === "mkdir") {
                root.listArchiveFiles();
            }
        }
    }

    Component.onCompleted: {
        archiveDir = resolveArchiveDir();
        ensureArchiveDir();
        listArchiveFiles();
    }
}
