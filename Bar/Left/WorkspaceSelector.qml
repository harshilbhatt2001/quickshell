import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property double extraHoveredWidth
  property bool hovered: extraHoveredWidth > 0 ? true : false
  property color selectorColor: Colors.surface2
  required property double selectorFocusedExtra
  required property double selectorHeight
  required property double selectorWidth
  required property HyprlandWorkspace workspace
  property string workspaceState: WorkspaceManager.getWorkspaceState(workspace)

  implicitWidth: selectorWidth + (root.hovered == true ? (root.workspaceState == "focused"
														  ? selectorFocusedExtra : 0) : 0)

  Behavior on implicitWidth {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }
  states: [
	State {
	  name: ""
	  when: root.workspaceState == "inactive"

	  PropertyChanges {
		root.selectorColor: Colors.surface2
	  }
	},
	State {
	  name: "active"
	  when: root.workspaceState == "active"

	  PropertyChanges {
		root.selectorColor: Colors.overlay2
	  }
	},
	State {
	  name: "focused"
	  when: root.workspaceState == "focused"

	  PropertyChanges {
		root.selectorColor: Colors.lavender
	  }
	}
  ]

  TapHandler {
	id: tapHandler

	onTapped: root.workspace.activate()
  }

  anchors {
	bottom: parent.bottom
	top: parent.top
  }

  Rectangle {
	color: root.selectorColor
	radius: 6

	Behavior on color {
	  ColorAnimation {
		duration: 100
	  }
	}

	anchors {
	  fill: parent
	}

	StyledText {
	  anchors.centerIn: parent
	  font.pointSize: 10.5
	  text: root.workspace.id
	}
  }
}
