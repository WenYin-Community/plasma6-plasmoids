import Qt5Compat.GraphicalEffects
import QtQml.Models
import QtQuick
import QtQuick.Controls
import org.kde.kwin as KWinComponents

Item {
    //////////////////////////////

    id: desktopItem

    property alias clientsRepeater: clientsRepeater
    property int desktopIndex: model.index
    property bool big: false
    property bool gridView: true
    property int clientsPadding: big ? 10 : 0
    property real mouseAreaX
    property real mouseAreaY
    property real mouseAreaWidth
    property real mouseAreaHeight
    ////////////////////////////
    // Grid view calculations //
    ////////////////////////////
    property real gridAreaX
    property real gridAreaY
    property real gridAreaWidth
    property real gridAreaHeight
    property real sqrtOfCount: Math.sqrt(clientsRepeater.count)
    property int addToColumns: (screenItem.aspectRatio >= 2 && clientsRepeater.count > 2) ? 2 : (sqrtOfCount % 1 === 0) ? 0 : 1
    property int columns: Math.floor(sqrtOfCount) + addToColumns
    property int rows: Math.ceil(clientsRepeater.count / columns)
    property real gridItemWidth: clientsRepeater.count <= 1 ? gridAreaWidth * 0.75 : gridAreaWidth / columns
    property real gridItemHeight: clientsRepeater.count <= 1 ? gridAreaHeight * 0.75 : gridAreaHeight / rows
    property real gridItemAspectRatio: gridItemWidth / gridItemHeight

    Rectangle {
        id: roundedRect

        anchors.fill: parent
        visible: false
        color: "#222222"
        radius: 10
    }

    OpacityMask {
        id: desktopBackground

        anchors.fill: parent
        source: screenItem.desktopBackground
        maskSource: roundedRect
        visible: !big && screenItem.desktopBackground.desktopWindow !== null
        cached: true
    }

    DropShadow {
        anchors.fill: parent
        horizontalOffset: 3
        verticalOffset: 3
        color: "#55000000"
        visible: !big && mainWindow.configShowDesktopShadows
        source: desktopBackground
        cached: true
    }

    ToolTip {
        visible: !big && hoverHandler.hovered
        text: KWinComponents.Workspace.desktopName(desktopIndex + 1)
        delay: 1000
        timeout: 5000
    }

    Rectangle {
        id: mouseArea

        x: mouseAreaX
        y: mouseAreaY
        width: mouseAreaWidth
        height: mouseAreaHeight
        color: "transparent"
        radius: 10
        border.width: !big && desktopIndex === mainWindow.currentDesktop ? 3 : 0
        border.color: mainWindow.highlightColor
        states: [
            State {
                when: dropArea.containsDrag || (!big && mainWindow.idle && hoverHandler.hovered)

                PropertyChanges {
                    target: mouseArea
                    color: mainWindow.highlightColor
                    opacity: 0.4
                }

            }
        ]

        DropArea {
            id: dropArea

            anchors.fill: parent
            onEntered: {
                drag.accepted = false;
                const targetDesktop = KWinComponents.Workspace.desktops[desktopIndex];
                if (!drag.source.desktops.includes(targetDesktop) && drag.source.desktops.length > 0) {
                    drag.accepted = true;
                    return ;
                }
                if (screenItem.screenIndex !== KWinComponents.Workspace.screens.indexOf(drag.source.output) && drag.source.moveableAcrossScreens)
                    drag.accepted = true;

            }
            onDropped: {
                const targetDesktop = KWinComponents.Workspace.desktops[desktopIndex];
                if (!drag.source.desktops.includes(targetDesktop) && drag.source.desktops.length > 0) {
                    // Ensures mainWindow.externallySelectedClient stays on current desktop
                    if (drag.source === mainWindow.externallySelectedClient) {
                        const tmpDragSourceDesktops = drag.source.desktops;
                        drag.source.desktops = [KWinComponents.Workspace.desktops[desktopIndex]];
                        KWinComponents.Workspace.currentDesktop = KWinComponents.Workspace.desktops[desktopIndex];
                        KWinComponents.Workspace.currentDesktop = tmpDragSourceDesktops.length > 0 ? tmpDragSourceDesktops[0] : KWinComponents.Workspace.desktops[desktopIndex]; // Change desktop to select a new mainWindow.externallySelectedClient
                    } else {
                        drag.source.desktops = [KWinComponents.Workspace.desktops[desktopIndex]];
                    }
                }
                if (screenItem.screenIndex !== KWinComponents.Workspace.screens.indexOf(drag.source.output) && drag.source.moveableAcrossScreens)
                    KWinComponents.Workspace.sendClientToScreen(drag.source, KWinComponents.Workspace.screens[screenItem.screenIndex]);

            }
        }

        HoverHandler {
            id: hoverHandler

            function clientAtPos(posX, posY) {
                for (let currentClient = 0; currentClient < clientsRepeater.count; currentClient++) {
                    const currentClientItem = clientsRepeater.itemAt(currentClient);
                    if (posX >= currentClientItem.x && posX <= currentClientItem.x + currentClientItem.width && posY >= currentClientItem.y && posY <= currentClientItem.y + currentClientItem.height)
                        return currentClientItem;

                }
                return null;
            }

            enabled: mainWindow.idle
            onPointChanged: {
                // Just to get pointAvoidUpdatingSelection
                if (mainWindow.avoidUpdatingSelection) {
                    mainWindow.avoidUpdatingSelection = false;
                    mainWindow.pointAvoidUpdatingSelection = point.position;
                    return ;
                }
                // Continue only if mouse moved from pointAvoidUpdatingSelection
                if (mainWindow.pointAvoidUpdatingSelection && Math.abs(mainWindow.pointAvoidUpdatingSelection.x - point.position.x) < 1 && Math.abs(mainWindow.pointAvoidUpdatingSelection.y - point.position.y) < 1)
                    return ;

                // Update selected client if needed
                const clientAtMousePosition = clientAtPos(point.position.x + mouseAreaX, point.position.y + mouseAreaY);
                if (mainWindow.selectedClientItem !== clientAtMousePosition) {
                    mainWindow.selectedClientItem = clientAtMousePosition;
                    mainWindow.pointAvoidUpdatingSelection = point.position;
                }
            }
        }

        TapHandler {
            acceptedButtons: Qt.AllButtons
            onSingleTapped: {
                switch (eventPoint.event.button) {
                case Qt.LeftButton:
                case Qt.NoButton:
                    if (KWinComponents.Workspace.desktops.indexOf(KWinComponents.Workspace.currentDesktop) === model.index)
                        mainWindow.toggleActive();
                    else
                        KWinComponents.Workspace.currentDesktop = KWinComponents.Workspace.desktops[model.index];
                    break;
                case Qt.MiddleButton:
                    if (mainWindow.selectedClientItem && mainWindow.configCloseOnMiddleClick)
                        mainWindow.selectedClientItem.client.close();

                    break;
                case Qt.RightButton:
                    if (!mainWindow.selectedClientItem)
                        break;

                    if (mainWindow.selectedClientItem.client.desktops.length === 0)
                        mainWindow.selectedClientItem.client.desktops = [KWinComponents.Workspace.desktops[model.index]];
                    else
                        mainWindow.selectedClientItem.client.desktops = [];
                    break;
                }
            }
        }

    }

    DelegateModel {
        id: clientsModel

        model: clientsByScreenAndDesktop
        filterOnGroup: "showing"
        items.onChanged: {
            for (let i = 0; i < items.count; ++i) {
                const item = items.get(i);
                const client = item.model.client;
                // Filter: must belong to this desktop and screen, and not be Yakuake or krunner
                const show = client && !client.caption.endsWith(" — Yakuake") && !client.caption.endsWith(" — krunner") && client.width !== 0 && client.height !== 0 && item.model.desktops.includes(KWinComponents.Workspace.desktops[desktopItem.desktopIndex]) && KWinComponents.Workspace.screens.indexOf(client.output) === screenItem.screenIndex;
                if (item.inShowing !== show)
                    item.inShowing = !item.inShowing;

            }
            if (mainWindow.activated) {
                mainWindow.animating = true;
                mainWindow.easingType = Easing.OutExpo;
                endAnimationTimer.start();
            }
        }

        delegate: ClientComponent {
        }

        groups: DelegateModelGroup {
            name: "showing"
            includeByDefault: false
        }

    }

    Repeater {
        id: clientsRepeater

        model: big && mainWindow.searchText && mainWindow.configSearchMethod === Enums.SearchMethod.Krunner ? 0 : clientsModel
    }

}
