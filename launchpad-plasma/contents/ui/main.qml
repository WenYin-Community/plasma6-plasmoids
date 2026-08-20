    /*
    SPDX-FileCopyrightText: 2014-2015 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtCore
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.plasma5support as P5Support


PlasmoidItem {
    id: kicker

    anchors.fill: parent

    signal reset

    property bool isDash: true // Plasmoid.pluginName === "org.kde.plasma.kickerdash"

    switchWidth: isDash || !fullRepresentationItem ? 0 :fullRepresentationItem.Layout.minimumWidth
    switchHeight: isDash || !fullRepresentationItem ? 0 :fullRepresentationItem.Layout.minimumHeight

    // this is a bit of a hack to prevent Plasma from spawning a dialog on its own when we're Dash
   preferredRepresentation: isDash ?fullRepresentation : null

   compactRepresentation: isDash ? null : compactRepresentation
   fullRepresentation: compactRepresentation

    property Item dragSource: null

    property QtObject globalFavorites: rootModel.favoritesModel
    property QtObject systemFavorites: rootModel.systemFavoritesModel
    property QtObject applicationMenuFavorites: applicationMenuFavoritesModel

    Plasmoid.icon: Plasmoid.configuration.useCustomButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon

    onSystemFavoritesChanged: {
        if (systemFavorites) {
            systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
        }
    }

    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    function updateSvgMetrics() {
        lineSvg.horLineHeight = lineSvg.elementSize("horizontal-line").height;
        lineSvg.vertLineWidth = lineSvg.elementSize("vertical-line").width;
    }

    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }

    Kicker.RootModel {
        id: rootModel

        autoPopulate: false

        appNameFormat: Plasmoid.configuration.appNameFormat
        flat: kicker.isDash || Plasmoid.configuration.limitDepth
        sorted: Plasmoid.configuration.alphaSort
        showSeparators: !kicker.isDash
        // TODO: appletInterface property now can be ported to "applet" and have the real Applet* assigned directly
        appletInterface: kicker

        showAllApps: kicker.isDash
        showAllAppsCategorized: false //<> true
        showTopLevelItems: !kicker.isDash
        showRecentApps: true //<>Plasmoid.configuration.showRecentApps
        showRecentDocs: true //<>Plasmoid.configuration.showRecentDocs
        recentOrdering: Plasmoid.configuration.recentOrdering

        onShowRecentAppsChanged: {
            Plasmoid.configuration.showRecentApps = showRecentApps;
        }

        onShowRecentDocsChanged: {
            Plasmoid.configuration.showRecentDocs = showRecentDocs;
        }

        onRecentOrderingChanged: {
            Plasmoid.configuration.recentOrdering = recentOrdering;
        }
    }

    Connections {
        target: systemFavorites

        function onFavoritesChanged() {
            if (target) {
                Plasmoid.configuration.favoriteSystemActions = target.favorites;
            }
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onFavoriteSystemActionsChanged() {
            if (systemFavorites) {
                systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
            }
        }
    }

    P5Support.DataSource {
        id: pmEngine
        engine: "powermanagement"
        connectedSources: ["PowerDevil", "Sleep States"]
        function performOperation(what) {
            var service = serviceForSource("PowerDevil")
            var operation = service.operationDescription(what)
            service.startOperationCall(operation)
        }
    }


    Kicker.RunnerModel {
        id: runnerModel

        appletInterface: kicker

        favoritesModel: globalFavorites
        mergeResults: true

        runners: {
            const results = ["krunner_services", "krunner_systemsettings"];

            if (kicker.isDash) {
                results.push("krunner_sessions", "krunner_powerdevil", "calculator", "unitconverter");
            }

            if (Plasmoid.configuration.useExtraRunners) {
                results.push(...Plasmoid.configuration.extraRunners);
            }

            return results;
        }
    }

    Kicker.KAStatsFavoritesModel {
        id: applicationMenuFavoritesModel
        enabled: true
        maxFavorites: -1

        function initForKickerInstance(appletId) {
            initForClient("org.kde.plasma.kicker.favorites.instance-" + appletId);
            refresh();
        }
    }

    // 动态发现 Application Menu (kicker) 实例，替代硬编码 instance ID。
    // 本机无 plasma_engine_applets 插件，改为从 appletsrc 配置解析实例 ID
    P5Support.DataSource {
        id: appletScanner
        engine: "executable"
        connectedSources: []

        function scanKickerInstance() {
            var configDir = StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString();
            if (configDir.startsWith("file://")) {
                configDir = configDir.substring(7);
            }
            connectSource("grep -B5 'plugin=org.kde.plasma.kicker' " + configDir + "/plasma-org.kde.plasma.desktop-appletsrc");
        }

        onNewData: function(source, data) {
            disconnectSource(source);
            var stdout = (data["stdout"] || "").trim();
            var m = /\[Applets\]\[(\d+)\]/.exec(stdout);
            if (m) {
                applicationMenuFavoritesModel.initForKickerInstance(m[1]);
            }
        }
    }

    Kicker.DragHelper {
        id: dragHelper

        dragIconSize: Kirigami.Units.iconSizes.medium
    }

    Kicker.ProcessRunner {
        id: processRunner
    }

    Kicker.WindowSystem {
        id: windowSystem
    }

    KSvg.FrameSvgItem {
        id: highlightItemSvg

        visible: false

        imagePath: "widgets/viewitem"
        prefix: "hover"
    }

    KSvg.FrameSvgItem {
        id: listItemSvg

        visible: false

        imagePath: "widgets/listitem"
        prefix: "normal"
    }

    KSvg.Svg {
        id: lineSvg
        imagePath: "widgets/line"

        property int horLineHeight
        property int vertLineWidth
    }

    PlasmaComponents3.Label {
        id: toolTipDelegate

        width: contentWidth
        height: undefined
        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 0.5

        property Item toolTip

        text: toolTip ? toolTip.text : ""
    }

    Timer {
        id: justOpenedTimer

        repeat: false
        interval: 600
    }

    Connections {
        target: kicker

        function onExpandedChanged(expanded) {
            if (expanded) {
                windowSystem.monitorWindowVisibility(Plasmoid.fullRepresentationItem);
                justOpenedTimer.start();
            } else {
                kicker.reset();
            }
        }
    }

    function resetDragSource() {
        dragSource = null;
    }

    function enableHideOnWindowDeactivate() {
        kicker.hideOnWindowDeactivate = true;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Edit Applications…")
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    Component.onCompleted: {
        if (Plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            Plasmoid.activationTogglesExpanded = !kicker.isDash
        }

        windowSystem.focusIn.connect(enableHideOnWindowDeactivate);
        kicker.hideOnWindowDeactivate = true;

        updateSvgMetrics();
        if (PlasmaCore.Theme && PlasmaCore.Theme.themeChanged) {
            PlasmaCore.Theme.themeChanged.connect(updateSvgMetrics);
        }

        rootModel.refreshed.connect(reset);

        dragHelper.dropped.connect(resetDragSource);

        appletScanner.scanKickerInstance();
    }
}
