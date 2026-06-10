import Quickshell
import Quickshell.Hyprland

import QtQuick
import QtQuick.Effects

import "Components"
import "Components/Color.js" as Colors

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
									Region {
										item: workspaceSwitcher
									}
									Region {
										item: pillItem
									}
								}

                anchors {
                    top: true
                    left: true
                    right: true
                }

								implicitHeight: 1000
								exclusiveZone: 20

								Workspace {
									id: workspaceSwitcher
									monitor: win.monitor
								}

								RectangularShadow {
									anchors.fill: pillItem
									offset.x: 3
									offset.y: 3
									radius: pillItem.radius
									blur: 20
									spread: 7
									color: Colors.crust
								}
								Pill {
									id: pillItem
									monitor: win.monitor
								}

								Item {
									anchors.fill: parent
									Utils {
										monitor: win.monitor
									}
								}
            }
        }
    }
}
