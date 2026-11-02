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

    function updateModel() {
        if (!workspaceRef)
            return ;

        clear();
        // KWin 6 QML (declarative script) exposes the window list as `stackingOrder`;
        // windowList() only exists on the legacy QtScript workspace wrapper.
        var clients = workspaceRef.stackingOrder || [];
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
            // ListModel cannot store a QList of VirtualDesktop objects (it turns into a
            // nested model), so keep a flat, comma separated list of desktop ids.
            var desktopIds = [];
            for (var j = 0; j < client.desktops.length; j++) {
                desktopIds.push(String(client.desktops[j].id));
            }
            append({
                "client": client,
                "screen": workspaceRef ? workspaceRef.screens.indexOf(client.output) : 0,
                "desktopIds": desktopIds.join(","),
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

    // Update model when workspace changes.
    // A ListModel can only contain ListElements, so the signal handlers live here
    // instead of in a nested Connections item.
    Component.onCompleted: {
        if (!workspaceRef)
            return;
        if (workspaceRef.windowAdded)
            workspaceRef.windowAdded.connect(updateModel);
        if (workspaceRef.windowRemoved)
            workspaceRef.windowRemoved.connect(updateModel);
        if (workspaceRef.windowActivated)
            workspaceRef.windowActivated.connect(updateModel);
        updateModel();
    }

    Component.onDestruction: {
        if (!workspaceRef)
            return;
        if (workspaceRef.windowAdded)
            workspaceRef.windowAdded.disconnect(updateModel);
        if (workspaceRef.windowRemoved)
            workspaceRef.windowRemoved.disconnect(updateModel);
        if (workspaceRef.windowActivated)
            workspaceRef.windowActivated.disconnect(updateModel);
    }

}
