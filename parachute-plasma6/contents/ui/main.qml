import QtQuick
import QtQuick.Controls
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.kwin as KWinComponents
import org.kde.milou as Milou
import org.kde.plasma.core as PlasmaCore

Window {
    id: mainWindow

    property bool activated: false
    property bool dragging: false
    property int currentDesktop: KWinComponents.Workspace.desktops.indexOf(KWinComponents.Workspace.currentDesktop)
    property bool horizontalDesktopsLayout: configDesktopsBarPlacement === Enums.Position.Top || configDesktopsBarPlacement === Enums.Position.Bottom
    property int easingType: Easing.OutExpo
    property bool animating: false
    property bool idle: activated && !animating && !dragging
    property bool showDesktopsBar: activated && easingType === Easing.OutExpo
    property bool focusNextItem // See onActiveFocusItemChanged for explanation
    property string searchText
    // Config
    property bool configBlurBackground
    property bool configShowDesktopsBarBackground
    property bool configShowWindowTitles
    property bool configShowDesktopShadows
    property bool configCloseOnMiddleClick
    property bool configShowNotificationWindows
    property real configAnimationsDuration
    property int configSearchMethod
    property int configDesktopsBarPlacement
    // Selection (by mouse or keyboard)
    property var selectedClientItem: null
    property var externallySelectedClient: null
    property var pointAvoidUpdatingSelection: null
    property bool avoidUpdatingSelection: false
    // Consts
    property int desktopMargin: 5
    property int desktopsBarSpacing: 15
    property int clientsDecorationsHeight: 24
    property color highlightColor: Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightColor : "white"

    function toggleActive() {
        if (animating)
            return ;

        animating = true;
        if (activated) {
            easingType = Easing.InExpo;
            for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
                screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).gridView = false;
            }
            avoidEmptyFrameTimer.start();
        } else {
            selectExternallySelectedClient();
            screensRepeater.itemAt(0).searchField.text = "";
            screensRepeater.itemAt(0).searchField.forceActiveFocus();
            for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
                screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).gridView = false;
                screensRepeater.itemAt(currentScreen).opacity = 1;
            }
            activated = true;
            easingType = Easing.OutExpo;
            for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
                screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).gridView = true;
            }
        }
        endAnimationTimer.start();
    }

    function updateScreens() {
        mainWindow.width = KWinComponents.Workspace.virtualScreenGeometry.width;
        mainWindow.height = KWinComponents.Workspace.virtualScreenGeometry.height;
        let screensOnPositionZero = 0;
        for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
            // KWin.ScreenArea not working here, but KWin.ScreenArea === 7
            const screenRect = KWinComponents.Workspace.clientArea(7, KWinComponents.Workspace.screens[currentScreen], KWinComponents.Workspace.currentDesktop);
            if (screenRect.x === 0 && screenRect.y === 0) {
                if (screensOnPositionZero > 0)
                    return ;

                screensOnPositionZero++;
            }
            const currentScreenItem = screensRepeater.itemAt(currentScreen);
            currentScreenItem.x = screenRect.x;
            currentScreenItem.y = screenRect.y;
            currentScreenItem.width = screenRect.width;
            currentScreenItem.height = screenRect.height;
            if (!currentScreenItem.wheelHandlerCreated) {
                Qt.createComponent("WheelHandlerComponent.qml").createObject(currentScreenItem);
                currentScreenItem.wheelHandlerCreated = true;
            }
        }
        const clients = KWinComponents.Workspace.windowList();
        for (let i = 0; i < clients.length; i++) {
            if (clients[i].desktopWindow)
                screensRepeater.itemAt(KWinComponents.Workspace.screens.indexOf(clients[i].output)).desktopBackground.desktopWindow = clients[i];

        }
        if (getCorrectScreensInfo.running)
            getCorrectScreensInfo.stop();

    }

    function getExternallySelectedClient() {
        if (KWinComponents.Workspace.activeWindow) {
            externallySelectedClient = KWinComponents.Workspace.activeWindow;
            // Ugly code for KWin < 5.20
            if (KWinComponents.Workspace.activeWindow.desktopWindow) {
                const currentScreenItem = screensRepeater.itemAt(KWinComponents.Workspace.screens.indexOf(KWinComponents.Workspace.activeWindow.output));
                if (currentScreenItem.desktopBackground.desktopWindow === null)
                    currentScreenItem.desktopBackground.desktopWindow = KWinComponents.Workspace.activeWindow;

            }
        }
    }

    function loadConfig() {
        configBlurBackground = KWin.readConfig("blurBackground", true);
        configShowDesktopsBarBackground = KWin.readConfig("showDesktopsBarBackground", true);
        configShowDesktopShadows = KWin.readConfig("showDesktopShadows", false);
        configShowWindowTitles = KWin.readConfig("showWindowTitles", true);
        configCloseOnMiddleClick = KWin.readConfig("closeOnMiddleClick", true);
        configAnimationsDuration = KWin.readConfig("animationsDuration", 300);
        configShowNotificationWindows = KWin.readConfig("showNotificationWindows", true);
        configDesktopsBarPlacement = KWin.readConfig("desktopsBarPlacement", Enums.Position.Right);
        configSearchMethod = KWin.readConfig("searchMethod", Enums.SearchMethod.Krunner);
    }

    function selectExternallySelectedClient() {
        for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
            const currentClientsRepeater = screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).clientsRepeater;
            for (let currentClient = 0; currentClient < currentClientsRepeater.count; currentClient++) {
                if (currentClientsRepeater.itemAt(currentClient).client === mainWindow.externallySelectedClient) {
                    selectedClientItem = currentClientsRepeater.itemAt(currentClient);
                    avoidUpdatingSelection = true;
                    return ;
                }
            }
        }
    }

    function selectFirstClient() {
        for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
            const currentClientsRepeater = screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).clientsRepeater;
            if (currentClientsRepeater.count > 0) {
                selectedClientItem = currentClientsRepeater.itemAt(0);
                avoidUpdatingSelection = true;
                return ;
            }
        }
    }

    function selectLastClient() {
        for (let currentScreen = screensRepeater.count - 1; currentScreen >= 0; currentScreen--) {
            const currentClientsRepeater = screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).clientsRepeater;
            if (currentClientsRepeater.count > 0) {
                selectedClientItem = currentClientsRepeater.itemAt(currentClientsRepeater.count - 1);
                avoidUpdatingSelection = true;
                return ;
            }
        }
    }

    function selectNextClientOn(position) {
        // Make client positions consider screen positions.
        // The clients centers will be used to calculate distance between clients.
        const selectedClientItemX = selectedClientItem.x + screensRepeater.itemAt(KWinComponents.Workspace.screens.indexOf(selectedClientItem.client.output)).x;
        const selectedClientItemY = selectedClientItem.y + screensRepeater.itemAt(KWinComponents.Workspace.screens.indexOf(selectedClientItem.client.output)).y;
        const selectedClientItemXCenter = selectedClientItemX + selectedClientItem.width / 2;
        const selectedClientItemYCenter = selectedClientItemY + selectedClientItem.height / 2;
        let candidateClientItem = null;
        let candidateClientDistance = Number.MAX_VALUE;
        for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) {
            const currentScreenItem = screensRepeater.itemAt(currentScreen);
            const currentClientsRepeater = currentScreenItem.bigDesktopsRepeater.itemAt(currentDesktop).clientsRepeater;
            for (let currentClient = 0; currentClient < currentClientsRepeater.count; currentClient++) {
                const currentClientItem = currentClientsRepeater.itemAt(currentClient);
                const currentClientItemX = currentClientItem.x + currentScreenItem.x;
                const currentClientItemY = currentClientItem.y + currentScreenItem.y;
                let candidate = false;
                switch (position) {
                case Enums.Position.Left:
                    candidate = currentClientItemX + currentClientItem.width <= selectedClientItemX && currentClientItemY <= selectedClientItemY + selectedClientItemY + selectedClientItem.height && currentClientItemY + currentClientItemY + currentClientItem.height >= selectedClientItemY;
                    break;
                case Enums.Position.Right:
                    candidate = selectedClientItemX + selectedClientItem.width <= currentClientItemX && currentClientItemY <= selectedClientItemY + selectedClientItemY + selectedClientItem.height && currentClientItemY + currentClientItemY + currentClientItem.height >= selectedClientItemY;
                    break;
                case Enums.Position.Top:
                    candidate = currentClientItemY + currentClientItem.height <= selectedClientItemY && currentClientItemX <= selectedClientItemX + selectedClientItemX + selectedClientItem.width && currentClientItemX + currentClientItemX + currentClientItem.width >= selectedClientItemX;
                    break;
                case Enums.Position.Bottom:
                    candidate = selectedClientItemY + selectedClientItem.height <= currentClientItemY && currentClientItemX <= selectedClientItemX + selectedClientItemX + selectedClientItem.width && currentClientItemX + currentClientItemX + currentClientItem.width >= selectedClientItemX;
                    break;
                }
                if (candidate) {
                    const currentClientItemXCenter = currentClientItemX + currentClientItem.width / 2;
                    const currentClientItemYCenter = currentClientItemY + currentClientItem.height / 2;
                    const currentClientDistance = Math.hypot(Math.abs(currentClientItemXCenter - selectedClientItemXCenter), Math.abs(currentClientItemYCenter - selectedClientItemYCenter));
                    if (currentClientDistance < candidateClientDistance) {
                        candidateClientDistance = currentClientDistance;
                        candidateClientItem = currentClientItem;
                    }
                }
            }
        }
        if (candidateClientItem) {
            selectedClientItem = candidateClientItem;
            avoidUpdatingSelection = true;
        }
    }

    flags: Qt.X11BypassWindowManagerHint
    visible: true
    color: "transparent"
    x: activated ? 0 : mainWindow.width * 2
    y: activated ? 0 : mainWindow.height * 2
    Component.onCompleted: {
        loadConfig();
        KWin.registerShortcut("Parachute", "Parachute", "Ctrl+Meta+D", function() {
            selectedClientItem = null;
            toggleActive();
        });
        getExternallySelectedClient();
        getCorrectScreensInfo.start();
    }
    // Milou.ResultsView put internal ToolButton in focus chain, which we don't want.
    // This hack prevents this button from getting focus.
    onActiveFocusItemChanged: {
        if (mainWindow.activeFocusItem.toString().includes("ToolButton"))
            mainWindow.activeFocusItem.nextItemInFocusChain(focusNextItem).focus = true;

    }

    Item {
        id: keyboardHandler

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Escape:
                selectedClientItem = null;
                toggleActive();
                break;
            case Qt.Key_Return:
                toggleActive();
                break;
            case Qt.Key_Home:
                selectFirstClient();
                break;
            case Qt.Key_End:
                selectLastClient();
                break;
            case Qt.Key_Left:
                if (event.modifiers & Qt.ShiftModifier)
                    KWinComponents.Workspace.slotSwitchDesktopPrevious();
                else
                    selectedClientItem ? selectNextClientOn(Enums.Position.Left) : selectFirstClient();
                break;
            case Qt.Key_Right:
                if (event.modifiers & Qt.ShiftModifier)
                    KWinComponents.Workspace.slotSwitchDesktopNext();
                else
                    selectedClientItem ? selectNextClientOn(Enums.Position.Right) : selectLastClient();
                break;
            case Qt.Key_Up:
                if (event.modifiers & Qt.ShiftModifier) {
                    KWinComponents.Workspace.slotSwitchDesktopPrevious();
                } else {
                    let tmpSelectedClientItem = selectedClientItem;
                    selectedClientItem ? selectNextClientOn(Enums.Position.Top) : selectFirstClient();
                    if (tmpSelectedClientItem === selectedClientItem && searchText && mainWindow.configSearchMethod === Enums.SearchMethod.Filter) {
                        const screen = selectedClientItem ? KWinComponents.Workspace.screens.indexOf(selectedClientItem.client.output) : 0;
                        screensRepeater.itemAt(screen).searchField.focus = true;
                    }
                }
                break;
            case Qt.Key_Down:
                if (event.modifiers & Qt.ShiftModifier)
                    KWinComponents.Workspace.slotSwitchDesktopNext();
                else
                    selectedClientItem ? selectNextClientOn(Enums.Position.Bottom) : selectLastClient();
                break;
            case Qt.Key_F5:
                kwinReconfigure.call();
                break;
            }
            if (event.key !== Qt.Key_Tab && event.key !== Qt.Key_Backtab)
                event.accepted = true;

        }

        Repeater {
            id: screensRepeater

            model: KWinComponents.Workspace.screens.length

            // Initial full hd dimensions to avoid division by zero on some internal calculations of ScreenComponent
            ScreenComponent {
                width: 1920
                height: 1080
            }

        }

    }

    ClientsModel {
        id: clientsByScreenAndDesktop

        workspaceRef: KWinComponents.Workspace
        searchText: mainWindow.configSearchMethod === Enums.SearchMethod.Krunner ? "" : mainWindow.searchText
        showNotificationWindows: mainWindow.configShowNotificationWindows
    }

    // Milou.ResultsView doesn't work inside a Repeater so it had to be placed here when it should be in ScreenComponent.
    // It will be reparented according to the searchField that has focus.
    Milou.ResultsView {
        id: milouResults

        anchors.fill: parent
        anchors.margins: 20
        queryString: mainWindow.configSearchMethod === Enums.SearchMethod.Krunner ? searchText : ""
        clip: false
        activeFocusOnTab: false
        onActivated: mainWindow.activated = false
    }

    // Reconfigure KWin via D-Bus (replaces Plasma 5 DBusCall)
    QtObject {
        id: kwinReconfigure

        function call() {
            Qt.createQmlObject('import QtQuick; import org.kde.plasma.workspace.dbus as DBus; DBus.DBusCall { service: "org.kde.KWin"; path: "/KWin"; iface: "org.kde.KWin"; method: "reconfigure"; Component.onCompleted: { call(); destroy(); } }', mainWindow, "kwinReconfigureCaller");
        }

    }

    Connections {
        function onWindowActivated(client) {
            getExternallySelectedClient();
        }

        function onScreensChanged() {
            updateScreens();
        }

        // onScreenResized 已移除 — 需要监听每个 Output 的 geometryChanged 信号
        function onCurrentDesktopChanged(previous, current, output) {
            selectedClientItem = null;
        }

        target: KWinComponents.Workspace
    }

    Connections {
        function onConfigChanged() {
            loadConfig();
        }

        target: options
    }

    // Get keyboard focus back when this script is activated and a client is activated externally
    Timer {
        id: requestActivateTimer

        interval: 10
        repeat: true
        triggeredOnStart: true
        running: mainWindow.activated && KWinComponents.Workspace.activeWindow
        onTriggered: requestActivate()
    }

    // Right after boot, KWin does not return:
    // 1 - Screen positions correctly. Screens overlap at position (0, 0).
    // 2 - Desktop windows id's.
    // This timer tries to recover this info by running every second after the script initialization.
    Timer {
        id: getCorrectScreensInfo

        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: updateScreens()
    }

    // ThumbnailItem hides before ScreenComponent when activated = false, showing a empty frame (background image without windows)
    // in the end of closing animation. This timer runs just before endAnimationTimer to avoid this.
    Timer {
        id: avoidEmptyFrameTimer

        interval: mainWindow.configAnimationsDuration - 60
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) screensRepeater.itemAt(currentScreen).opacity = 0
        }
    }

    Timer {
        id: endAnimationTimer

        interval: mainWindow.configAnimationsDuration
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            animating = false;
            if (easingType === Easing.InExpo) {
                activated = false;
                // Return current big desktop to grid state. Desktops only have to be in original state for opening/closing animations.
                for (let currentScreen = 0; currentScreen < screensRepeater.count; currentScreen++) screensRepeater.itemAt(currentScreen).bigDesktopsRepeater.itemAt(currentDesktop).gridView = true
                KWinComponents.Workspace.activeWindow = selectedClientItem ? selectedClientItem.client : externallySelectedClient;
            }
        }
    }

}
