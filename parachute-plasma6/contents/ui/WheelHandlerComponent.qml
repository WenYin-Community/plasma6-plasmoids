import QtQuick
import org.kde.kwin as KWinComponents

Item {
    anchors.fill: parent

    WheelHandler {
        property int wheelDelta: 0

        onWheel: wheelDelta += event.angleDelta.y;

        onActiveChanged: {        
            if (active) return;

            if (wheelDelta >= 120 || wheelDelta <= -120) {
                wheelDelta > 0 ? KWinComponents.Workspace.slotSwitchDesktopPrevious() : KWinComponents.Workspace.slotSwitchDesktopNext();
                wheelDelta = 0;
            }
        }
    }
}