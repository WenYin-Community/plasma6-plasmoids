import QtQuick
import QtQml.Models

// Replaces KWinComponents.ClientModelByScreenAndDesktop and ClientFilterModel
// Provides a flat list of clients with search filtering
ListModel {
    id: clientsModel

    property var workspaceRef: null
    property string searchText: ""
    property bool showNotificationWindows: false

    // Exclusion flags (simplified)
    readonly property int notAcceptingFocusExclusion: 1
    readonly property int dockWindowsExclusion: 2
    readonly property int otherActivitiesExclusion: 4
    readonly property int desktopWindowsExclusion: 8
    readonly property int skipPagerExclusion: 16
    readonly property int switchSwitcherExclusion: 32

    // Update model when workspace changes
    Connections {
        target: workspaceRef
        function onClientAdded(client) { updateModel(); }
        function onClientRemoved(client) { updateModel(); }
        function onClientActivated(client) { updateModel(); }
    }

    function updateModel() {
        if (!workspaceRef) return;

        clear();

        var clients = workspaceRef.clientList ? workspaceRef.clientList() : [];

        for (var i = 0; i < clients.length; i++) {
            var client = clients[i];

            // Apply exclusion filters
            if (!showNotificationWindows) {
                if (client.skipPager || client.switchSwitcher) continue;
            }

            // Apply search filter if text is provided
            if (searchText.length > 0) {
                var caption = client.caption || "";
                var resourceName = client.resourceName || "";
                if (caption.indexOf(searchText) === -1 && resourceName.indexOf(searchText) === -1) {
                    continue;
                }
            }

            append({
                "client": client,
                "screen": client.screen,
                "desktop": client.desktop,
                "caption": client.caption,
                "icon": client.icon,
                "windowId": client.windowId,
                "x": client.x,
                "y": client.y,
                "width": client.width,
                "height": client.height,
                "desktopWindow": client.desktopWindow,
                "closeable": client.closeable,
                "moveableAcrossScreens": client.moveableAcrossScreens
            });
        }
    }

    function index(desktop, screen) {
        // Return a fake index that can be used for filtering
        return desktop * 1000 + screen;
    }
}
