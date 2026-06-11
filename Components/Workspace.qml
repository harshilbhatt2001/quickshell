pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import "Color.js" as Colors

Item {
  id: workspaceRowContainer

  required property HyprlandMonitor monitor
  property int textBottomMargin: 0

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
	console.log(maxId + 1);
	return maxId === 0 ? 1 : maxId + 1;
  }

  implicitHeight: 65
  implicitWidth: 200
  state: ""

  Behavior on anchors.topMargin {
	NumberAnimation {
	  duration: 100
	}
  }
  states: [
	State {
	  name: ""
	  // When not hovered, stay at default
	  when: !workspaceHoverHandler.hovered

	  PropertyChanges {
		workspaceRowContainer.anchors.topMargin: -33
	  }
	},
	State {
	  name: "hovered"
	  // Keep the workspace dropped whenever hovered is true
	  when: workspaceHoverHandler.hovered

	  PropertyChanges {
		workspaceRowContainer.anchors.topMargin: -20
	  }

	  PropertyChanges {
		workspaceRowContainer.textBottomMargin: 7
	  }
	}
  ]
  Behavior on textBottomMargin {
	NumberAnimation {
	  duration: 80
	}
  }

  anchors {
	left: parent.left
	leftMargin: 15
	top: parent.top
	topMargin: -33
  }

  HoverHandler {
	id: workspaceHoverHandler
  }

  Row {
	id: workspaceRow

	spacing: 5

	Repeater {
	  model: Hyprland.workspaces.values

	  Item {
		id: selectorContainer

		property HyprlandWorkspace activeWorkspace: workspaceRowContainer.monitor.activeWorkspace
		property HyprlandWorkspace currentWorkspace: Hyprland.workspaces.values[index]
		property HyprlandWorkspace globalFocusedWorkspace: Hyprland.focusedWorkspace
		required property int index

		function getImplicitWidth() {
		  let implicitWidth = 25;

		  if (workspaceRowContainer.state == "hovered") {
			implicitWidth += 5;
			if (currentWorkspace.focused) {
			  implicitWidth += 20;
			}
		  }
		  return implicitWidth;
		}

		function shouldBeVisible() {
		  let isSpecialWorkspace = !selectorContainer.currentWorkspace.name.includes("special:");
		  let isCurrentMonitor = Hyprland.workspaces.values[index].monitor
			  == workspaceRowContainer.monitor;
		  return isSpecialWorkspace && isCurrentMonitor;
		}

		implicitHeight: 50
		implicitWidth: getImplicitWidth()
		visible: shouldBeVisible()

		Behavior on anchors.topMargin {
		  NumberAnimation {
			duration: 100
		  }
		}
		Behavior on implicitWidth {
		  NumberAnimation {
			duration: 100
		  }
		}
		states: [
		  State {
			name: ""
			when: !selectorHoverHandler.hovered

			PropertyChanges {
			  selectorContainer.anchors.topMargin: 0
			}
		  },
		  State {
			name: "individualHovered"
			when: selectorHoverHandler.hovered

			PropertyChanges {
			  selectorContainer.anchors.topMargin: 10
			}
		  },
		  State {
			name: "workspaceSwitched"

			PropertyChanges {
			  selectorContainer.anchors.topMargin: 5
			}
		  }
		]

		// onActiveWorkspaceChanged: {
		//   if (workspaceRowContainer.monitor.activeWorkspace.id == "1") {}
		//   if (workspaceRowContainer.monitor.activeWorkspace.id == "4") {}
		// }
		onGlobalFocusedWorkspaceChanged: {
		  if (globalFocusedWorkspace.name === currentWorkspace.name && globalFocusedWorkspace.monitor
			  === workspaceRowContainer.monitor && workspaceRowContainer.monitor.activeWorkspace.name
			  === currentWorkspace.name) {
			selectorContainer.state = "workspaceSwitched";
			switchFeedbackTimer.restart();
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

		RectangularShadow {
		  anchors.fill: selector
		  blur: 20
		  color: Colors.crust
		  offset.x: 3
		  offset.y: 3
		  radius: selector.radius
		  spread: 7
		  z: -1
		}

		Rectangle {
		  id: selector

		  anchors.fill: parent
		  color: selectorContainer.currentWorkspace.focused ? Colors.mauve :
															  workspaceRowContainer.monitor.activeWorkspace
															  == selectorContainer.currentWorkspace ? Colors.lavender : Colors.overlay1
		  radius: 8
		  state: ""
		  z: 1

		  Behavior on color {
			ColorAnimation {
			  duration: 100
			}
		  }

		  Text {
			id: workspaceIdentifier

			font.family: "FiraMono Nerd Font"
			font.pixelSize: workspaceRowContainer.state == "hovered" ? 15 : 13
			text: selectorContainer.currentWorkspace.name

			anchors {
			  bottom: parent.bottom
			  bottomMargin: workspaceRowContainer.textBottomMargin
			  horizontalCenter: parent.horizontalCenter
			}
		  }
		}
	  }
	}

	Item {
	  implicitHeight: 40
	  implicitWidth: 20

	  Behavior on anchors.topMargin {
		NumberAnimation {
		  duration: 100
		}
	  }

	  anchors {
		top: parent.top
		topMargin: workspaceRowContainer.state == "hovered" ? 0 : -10
	  }

	  MouseArea {
		id: newWorkspaceButton

		anchors.fill: parent

		onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = 
${workspaceRowContainer.getNextEmptyWorkspaceId()}})`)
	  }

	  Rectangle {
		anchors.fill: parent
		border.color: Colors.text
		border.width: 2
		color: Colors.surface2
		radius: 10

		Text {
		  color: Colors.text
		  font.family: "FiraMono Nerd Font"
		  font.pixelSize: 20
		  text: "+"

		  anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		  }
		}
	  }
	}
  }
}
