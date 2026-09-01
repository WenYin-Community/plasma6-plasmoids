import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Particles
import QtQuick.Window

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

import "./js/archiveDir.js" as ArchiveDirUtils

WallpaperItem {
    id: root

    property string archiveDir: ""
    property var archiveFiles: []
    property int selectedIndex: 0
    property bool archiveLoaded: false
    readonly property string selectedFile: (root.configuration.SelectedFile || "").toString()
    property string lastAppliedFile: ""
    property string previewFile: ""

    property string todayInfoUrl: ""
    property string todayTitle: ""
    property string lastDownloadDate: ""

    // 完全独立：python3 标准库请求 Bing API、下载今日壁纸并清理只保留最近 30 张。
    // 当日文件已存在则跳过（每日仅首次下载）；第二个参数 1 表示强制重新下载。
    // 脚本以 \n 分行经 /bin/sh 双引号传给 python -c：Python 复合语句（if/for）不能写在
    // 分号单行内；且须避免 $、`、"、反斜杠，否则会被 shell 展开或截断
    readonly property string bingDownloadScript: "import json, urllib.request, sys, glob, os\n" +
        "target = sys.argv[1]\n" +
        "force = len(sys.argv) > 2 and sys.argv[2] == '1'\n" +
        "img = None\n" +
        "if force or not os.path.exists(target):\n" +
        "    img = json.load(urllib.request.urlopen('https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1', timeout=15))['images'][0]\n" +
        "    url = img['url'] if img['url'].startswith('http') else 'https://www.bing.com' + img['url']\n" +
        "    urllib.request.urlretrieve(url, target)\n" +
        "    files = sorted(glob.glob(os.path.dirname(target) + '/*.jpg'))\n" +
        "    [os.remove(f) for f in files[:-30]]\n" +
        "print(img.get('title', '') if img else '')\n" +
        "print(img.get('copyrightlink', '') if img else '')"

    // 独立清理：只保留最近 30 张（下载脚本内也内置同样逻辑，此处覆盖"当日已存在跳过下载"的情况）
    readonly property string bingPruneScript: "import sys, glob, os; files = sorted(glob.glob(sys.argv[1] + '/*.jpg')); [os.remove(f) for f in files[:-30]]"

    readonly property string selectedArchivePath: {
        if (selectedIndex < 0 || selectedIndex >= archiveFiles.length) {
            return "";
        }
        return archiveDir + "/" + archiveFiles[selectedIndex];
    }
    readonly property string imagePath: selectedArchivePath.length > 0 ? selectedArchivePath : ""
    readonly property string imageSource: toFileUrl(imagePath)

    contextualActions: [
        PlasmaCore.Action {
            text: i18nd("plasma_wallpaper_com.wenyin.bingwallpapersource","Refresh today's wallpaper")
            icon.name: "view-refresh"
            onTriggered: root.downloadToday(true)
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
            enabled: root.todayInfoUrl.length > 0
            onTriggered: Qt.openUrlExternally(root.toBingUrl(root.todayInfoUrl))
        }
    ]

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

    function runCommand(command) {
        executable.connectSource(command);
    }

    function downloadToday(force) {
        if (!archiveDir) {
            return;
        }
        lastDownloadDate = todayText();
        var target = archiveDir + "/" + todayText() + ".jpg";
        var cmd = "python3 -c \"" + bingDownloadScript + "\" " + ArchiveDirUtils.shellQuote(target);
        if (force) {
            cmd += " 1";
        }
        runCommand(cmd);
    }

    function selectArchiveByIndex(idx) {
        if (idx < 0 || idx >= archiveFiles.length) {
            return;
        }
        selectedIndex = idx;
        root.configuration.SelectedFile = archiveFiles[idx];
        root.configuration.writeConfig();
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
        runCommand("mkdir -p " + ArchiveDirUtils.shellQuote(archiveDir));
    }

    function pruneArchive() {
        if (!archiveDir) {
            return;
        }
        runCommand("python3 -c \"" + bingPruneScript + "\" " + ArchiveDirUtils.shellQuote(archiveDir));
    }

    function listArchiveFiles() {
        runCommand("find " + ArchiveDirUtils.shellQuote(archiveDir) + " -maxdepth 1 -type f -name '*.jpg' -printf '%f\\n'");
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

    // 动态天气效果（参考 org.kde.snow/org.kde.rain）：1=下雪 2=下雨
    Item {
        id: weatherLayer
        anchors.fill: parent
        visible: root.configuration.ParticleType > 0

        readonly property bool isSnow: root.configuration.ParticleType === 1

        ParticleSystem {
            id: weatherParticles
        }

        ItemParticle {
            system: weatherParticles
            delegate: weatherLayer.isSnow ? snowDelegate : rainDelegate
        }

        Emitter {
            system: weatherParticles
            enabled: root.configuration.ParticleType > 0
            emitRate: weatherLayer.isSnow ? 14 : 80
            lifeSpan: weatherLayer.isSnow ? 6000 : 1500
            velocity: PointDirection {
                y: weatherLayer.isSnow ? 60 : 320
                yVariation: weatherLayer.isSnow ? 30 : 80
                xVariation: 30
            }
            size: 8
            sizeVariation: 4
            width: parent.width
            height: 10
            y: -20
        }

        Component {
            id: snowDelegate

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: "white"
                opacity: 0.85
            }
        }

        Component {
            id: rainDelegate

            Rectangle {
                width: 2
                height: 20
                radius: 1
                color: "#B0DCF8"
                opacity: 0.55
                transform: Rotation {
                    angle: 12
                }
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

            // 按命令内容分发（避免并发命令的 pendingAction 串扰）
            if (source.indexOf("HPImageArchive") >= 0) {
                // 下载完成（或跳过）：非空输出才更新标题/信息链接，刷新列表
                var lines = stdout.split("\n");
                if (lines[0]) {
                    root.todayTitle = lines[0];
                    // 新图下载成功：切换到当日并持久化 SelectedFile，否则跨天后仍停留在旧图。
                    // 运行时修改配置须显式 writeConfig() 才会落盘到 appletsrc，否则重启后弹回旧值。
                    var todayFile = root.todayText() + ".jpg";
                    if (root.configuration.SelectedFile !== todayFile) {
                        root.configuration.SelectedFile = todayFile;
                        root.configuration.writeConfig();
                        root.lastAppliedFile = todayFile;
                    }
                }
                if (lines[1]) {
                    root.todayInfoUrl = lines[1];
                }
                root.listArchiveFiles();
                return;
            }

            if (source.indexOf("import sys, glob, os; files") >= 0) {
                // 清理完成：刷新列表
                root.listArchiveFiles();
                return;
            }

            if (source.indexOf("find ") === 0) {
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

            // mkdir：无需处理（列表由 onCompleted 与下载完成时刷新）
        }
    }

    Component.onCompleted: {
        archiveDir = ArchiveDirUtils.resolveArchiveDir();
        ensureArchiveDir();
        pruneArchive();
        downloadToday();
        listArchiveFiles();
    }

    // 跨天自动刷新：每分钟检测日期变化，跨天后重新下载当日壁纸
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            if (root.archiveDir && root.todayText() !== root.lastDownloadDate) {
                root.downloadToday();
            }
        }
    }
}
