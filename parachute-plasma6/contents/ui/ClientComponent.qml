import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kwin as KWinComponents
import org.kde.kwin as KWin
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore

Item {
    ////////////////////////////

    id: clientItem

    property var client: model.client
    property int noBorderSpacing // Space to add between clientThumbnail and clientDecorations when client has no borders (mainly gtk csd or fullscreen windows)
    property bool ready: false
    property int clientX
    property int clientY
    property int clientWidth
    property int clientHeight
    ////////////////////////////
    // Grid view calculations //
    ////////////////////////////
    property int row: Math.floor(model.index / desktopItem.columns)
    property int column: model.index - desktopItem.columns * row
    property real clientGridScale: clientWidth / clientHeight > desktopItem.gridItemAspectRatio ? desktopItem.gridItemWidth / clientWidth : desktopItem.gridItemHeight / clientHeight
    property real gridX: clientsRepeater.count === 1 ? desktopItem.gridAreaX + (desktopItem.gridAreaWidth - gridWidth) / 2 : desktopItem.gridAreaX + column * desktopItem.gridItemWidth + (desktopItem.gridItemWidth - gridWidth) / 2
    property real gridY: clientsRepeater.count === 1 ? desktopItem.gridAreaY + (desktopItem.gridAreaHeight - gridHeight) / 2 : desktopItem.gridAreaY + row * desktopItem.gridItemHeight + (desktopItem.gridItemHeight - gridHeight) / 2
    property real gridWidth: clientWidth * clientGridScale
    property real gridHeight: clientHeight * clientGridScale

    // Update non-notifiable properties
    function updateClientProperties() {
        if (!client)
            return ;

        clientX = client.x - screenItem.x;
        clientY = client.y - screenItem.y;
        clientWidth = client.width;
        clientHeight = client.height;
        noBorderSpacing = client.noBorder ? desktopItem.big ? 18 : 4 : 0;
    }

    Component.onCompleted: {
        updateClientProperties();
        ready = true;
    }
    states: [
        State {
            when: !ready // To animate when a new window is created

            PropertyChanges {
                target: clientItem
                x: desktopItem.gridAreaX
                y: desktopItem.gridAreaY
                width: 250
                height: 250
            }

        },
        State {
            when: !desktopItem.gridView && ready

            PropertyChanges {
                target: clientItem
                x: clientX
                y: clientY
                width: clientWidth
                height: clientHeight
            }

        },
        State {
            when: desktopItem.gridView && ready

            PropertyChanges {
                target: clientItem
                x: gridX
                y: gridY
                width: gridWidth
                height: gridHeight
            }

        }
    ]

    KSvg.FrameSvgItem {
        id: selectedFrame

        width: clientItem.gridWidth
        height: clientItem.gridHeight
        imagePath: "widgets/viewitem"
        prefix: "hover"
        visible: desktopItem.big && mainWindow.idle && mainWindow.selectedClientItem === clientItem
        opacity: 0.7
    }

    Row {
        id: clientDecorations

        x: (clientItem.gridWidth - clientDecorations.width) / 2
        y: desktopItem.clientsPadding
        visible: desktopItem.big && mainWindow.activated && !mainWindow.animating && mainWindow.configShowWindowTitles && !clientThumbnail.Drag.active
        spacing: 10

        Kirigami.Icon {
            id: icon

            height: mainWindow.clientsDecorationsHeight
            width: height
            source: clientItem.client ? clientItem.client.icon : null
        }

        Text {
            id: caption

            property real maxWidth: clientItem.gridWidth - 5 * icon.width

            function updateWidth() {
                caption.width = undefined;
                if (caption.width > caption.maxWidth)
                    caption.width = caption.maxWidth;

            }

            height: mainWindow.clientsDecorationsHeight
            text: clientItem.client ? clientItem.client.caption : ""
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: "white"
            textFormat: Text.PlainText
            onMaxWidthChanged: updateWidth()
            onTextChanged: updateWidth()
        }

    }

    PlasmaComponents.Button {
        id: closeButton

        x: clientItem.gridWidth - desktopItem.clientsPadding - closeButton.width
        y: desktopItem.clientsPadding
        height: mainWindow.clientsDecorationsHeight
        width: height
        visible: selectedFrame.visible && mainWindow.configShowWindowTitles
        flat: true
        focusPolicy: Qt.NoFocus
        onClicked: clientItem.client.close()

        Image {
            anchors.fill: parent
            source: "images/close.svg"
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            cache: true
        }

    }

    KWin.WindowThumbnail {
        id: clientThumbnail

        property int thumbnailPadding: desktopItem.clientsPadding + noBorderSpacing

        anchors.fill: Drag.active ? undefined : parent // tried to change in the state, but doesn't work
        anchors.margins: thumbnailPadding
        anchors.topMargin: desktopItem.big && mainWindow.configShowWindowTitles ? thumbnailPadding + mainWindow.clientsDecorationsHeight : thumbnailPadding
        Drag.source: clientItem.client
        client: clientItem.client || null
        clip: true
        visible: mainWindow.activated

        states: State {
            when: clientThumbnail.Drag.active

            PropertyChanges {
                target: clientThumbnail
                x: clientDragHandler.centroid.position.x - clientThumbnail.width / 2
                y: clientDragHandler.centroid.position.y - clientThumbnail.height / 2
                width: 250
                height: 250
                clip: false
                Drag.hotSpot.x: clientThumbnail.width / 2
                Drag.hotSpot.y: clientThumbnail.height / 2
            }

        }

    }

    DragHandler {
        id: clientDragHandler

        target: null
        onActiveChanged: {
            mainWindow.dragging = active;
            active ? clientThumbnail.Drag.active = true : clientThumbnail.Drag.drop();
        }
    }

    Loader {
        active: client ? true : false

        sourceComponent: Connections {
            function onInteractiveMoveResizeFinished() {
                updateClientProperties();
            }

            // onClientMaximizedStateChanged 已移除，改用 frameGeometryChanged
            function onFrameGeometryChanged() {
                updateClientProperties();
            }

            target: client
        }

    }

    Behavior on x {
        enabled: mainWindow.activated

        NumberAnimation {
            duration: mainWindow.configAnimationsDuration
            easing.type: mainWindow.easingType
        }

    }

    Behavior on y {
        enabled: mainWindow.activated

        NumberAnimation {
            duration: mainWindow.configAnimationsDuration
            easing.type: mainWindow.easingType
        }

    }

    Behavior on width {
        enabled: mainWindow.activated

        NumberAnimation {
            duration: mainWindow.configAnimationsDuration
            easing.type: mainWindow.easingType
        }

    }

    Behavior on height {
        enabled: mainWindow.activated

        NumberAnimation {
            duration: mainWindow.configAnimationsDuration
            easing.type: mainWindow.easingType
        }

    }

}
