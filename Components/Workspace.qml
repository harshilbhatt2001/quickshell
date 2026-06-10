pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "Color.js" as Colors

Item {
	id: workspaceRowContainer
	required property HyprlandMonitor monitor
	state: ""

	function getNextEmptyWorkspaceId() {
		let maxId = 0;
		let workspaces = Hyprland.workspaces.values;

		for (let i = 0; i < workspaces.length; i++) {
			let ws = workspaces[i];
			// Look at all numerical workspaces globally (ignoring special workspaces like scratchpads)
			if (ws.id > maxId && ws.id < 99) { 
				maxId = ws.id;
			}
		}

		// Returns the next global workspace ID (e.g., if max is 3, returns 4)
		console.log(maxId + 1)
		return maxId === 0 ? 1 : maxId + 1;
	}

	anchors {
		top: parent.top
		left: parent.left
		leftMargin: 15
		topMargin: -33
	}

	HoverHandler {
		id: workspaceHoverHandler
	}

	Behavior on anchors.topMargin {
		NumberAnimation { duration: 100 }
	}

	property int textBottomMargin: 0

	Behavior on textBottomMargin {
		NumberAnimation {duration: 80}
	}

	states: [
		State {
			name: ""
			// When not hovered, stay at default
			when: !workspaceHoverHandler.hovered
			PropertyChanges { workspaceRowContainer.anchors.topMargin: -33 }
		},
		State {
			name: "hovered"
			// Keep the workspace dropped whenever hovered is true
			when: workspaceHoverHandler.hovered
			PropertyChanges { workspaceRowContainer.anchors.topMargin: -20 }
			PropertyChanges { workspaceRowContainer.textBottomMargin: 7 }
		}
	]

	implicitWidth: 200
	implicitHeight: 65

	Row {
		id: workspaceRow
		spacing: 5


		Repeater {
			model: Hyprland.workspaces.values

			Item {
				id: selectorContainer
				required property int index
				property HyprlandWorkspace currentWorkspace: Hyprland.workspaces.values[index]
				property HyprlandWorkspace globalFocusedWorkspace: Hyprland.focusedWorkspace
				implicitHeight: 50
				implicitWidth: currentWorkspace.focused && workspaceRowContainer.state == "hovered" ? 50 : workspaceRowContainer.state == "hovered" ? 30 : 25

				onGlobalFocusedWorkspaceChanged: {
					if (globalFocusedWorkspace.id === currentWorkspace.id) {
						selectorContainer.state = "workspaceSwitched"
						switchFeedbackTimer.restart()
					}
				}

				Timer {
					id: switchFeedbackTimer
					interval: 200
					repeat: false
					onTriggered: selectorContainer.state = ""
				}

				anchors {
					top: parent.top
					topMargin: 0
				}

				HoverHandler {
					id: selectorHoverHandler
				}

				MouseArea {
					id: selectorMouseArea
					anchors.fill: parent
					hoverEnabled: true
					propagateComposedEvents: true

					onClicked: selectorContainer.currentWorkspace.activate()
				}

				Behavior on anchors.topMargin {
					NumberAnimation {duration: 100}
				}

				Behavior on implicitWidth {
					NumberAnimation {duration: 100}
				}

				states: [
					State {
						name: ""
						when: !selectorHoverHandler.hovered
						PropertyChanges { selectorContainer.anchors.topMargin: 0 }
					},
					State {
						name: "individualHovered"
						when: selectorHoverHandler.hovered
						PropertyChanges { selectorContainer.anchors.topMargin: 10 }
					},
					State {
						name: "workspaceSwitched"
						PropertyChanges { selectorContainer.anchors.topMargin: 5 }
					}
				]

				visible: Hyprland.workspaces.values[index].monitor == monitor && index > 0 && selectorContainer.currentWorkspace.name != "special:scratch" && selectorContainer.currentWorkspace.name != "special:music"

				RectangularShadow {
					anchors.fill: selector
					offset.x: 3
					offset.y: 3
					radius: selector.radius
					blur: 20
					z: -1
					spread: 7
					color: Colors.crust
				}
				Rectangle {
					z: 1
					id: selector
					state: ""

					color: selectorContainer.currentWorkspace.focused ? Colors.mauve : workspaceRowContainer.monitor.activeWorkspace.id == selectorContainer.currentWorkspace.id ? Colors.lavender : Colors.overlay1
					radius: 8
					anchors.fill: parent

					Behavior on color {
						ColorAnimation {duration: 100}
					}

					Text {
						id: workspaceIdentifier
						text: selectorContainer.currentWorkspace.name
						font.family: "FiraMono Nerd Font"
						font.pixelSize: workspaceRowContainer.state == "hovered" ? 15 : 13
						anchors {
							bottom: parent.bottom
							horizontalCenter: parent.horizontalCenter
							bottomMargin: workspaceRowContainer.textBottomMargin
						}
					}

				}
			}
		}
		Item {
			implicitHeight: 40
			implicitWidth: 20
			

			anchors {
				top: parent.top
				topMargin: workspaceRowContainer.state == "hovered" ? 0 : -10
			}

			Behavior on anchors.topMargin {
				NumberAnimation {duration: 100}
			}

			MouseArea {
				id: newWorkspaceButton
				anchors.fill: parent

				onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${workspaceRowContainer.getNextEmptyWorkspaceId()}})`)
			}
			Rectangle {
				color: Colors.surface2
				anchors.fill: parent
				radius: 10
				border.color: Colors.text
				border.width: 2
				Text {
					text: "+"
					color: Colors.text
					font.family: "FiraMono Nerd Font"
					font.pixelSize: 20
					anchors {
						bottom: parent.bottom
						horizontalCenter: parent.horizontalCenter
					}
				}
			}
		}
	}
}
