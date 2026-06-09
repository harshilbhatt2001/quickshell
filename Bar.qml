import Quickshell
import Quickshell.Hyprland
import QtQuick
import "Components/Color.js" as Colors

import "Components"
import "Components/Pill"

Scope {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: win
                required property var modelData

                screen: modelData

								Behavior on implicitHeight {
									NumberAnimation { duration: 0; easing.type: Easing.InOutQuad }
								}

                property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

								color: "transparent"

								exclusionMode: ExclusionMode.Normal

								mask: Region {
									item: container
								}

                anchors {
                    top: true
                    left: true
                    right: true
                }

								implicitHeight: 1000
								exclusiveZone: 15

								Pill {
									id: container
									monitor: win.monitor
								}
            }
        }
    }
}
