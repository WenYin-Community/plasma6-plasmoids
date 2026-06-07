import QtQml.Models
import QtQuick
import org.kde.kwin as KWinComponents

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

    function updateModel() {
        if (!workspaceRef)
            return ;

        clear();
        var clients = workspaceRef.windowList ? workspaceRef.windowList() : [];
        for (var i = 0; i < clients.length; i++) {
            var client = clients[i];
            // Apply exclusion filters
            if (!showNotificationWindows) {
                if (client.skipPager || client.skipSwitcher)
                    continue;

            }
            // Apply search filter if text is provided
            if (searchText.length > 0) {
                var caption = client.caption || "";
                var resourceName = client.resourceName || "";
                if (caption.indexOf(searchText) === -1 && resourceName.indexOf(searchText) === -1)
                    continue;

            }
            append({
                "client": client,
                "screen": workspaceRef ? workspaceRef.screens.indexOf(client.output) : 0,
                "desktops": client.desktops,
                "caption": client.caption,
                "icon": client.icon,
                "internalId": client.internalId,
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

    // Update model when workspace changes
    Connections {
        function onWindowAdded(client) {
            updateModel();
        }

        function onWindowRemoved(client) {
            updateModel();
        }

        function onWindowActivated(client) {
            updateModel();
        }

        target: workspaceRef
    }

}
