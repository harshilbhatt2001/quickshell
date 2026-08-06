import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  required property HyprlandMonitor monitor

  boxHeight: 25
  exclusiveMonitor: monitor

  Row {
	spacing: 3

	Repeater {
	  delegate: workspaceButton
	  model: WorkspaceManager.getWorkspacesForMonitor(root.exclusiveMonitor)
		delegateModelAccess: DelegateModel.ReadOnly
	}

	Component {
	  id: workspaceButton

	  Item {
		required property var modelData

		height: 10
		width: 10

		Rectangle {
		  anchors.fill: parent
		  color: "red"
		}
	  }
	}
  }
}
