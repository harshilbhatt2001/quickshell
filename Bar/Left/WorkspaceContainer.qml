import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property HyprlandMonitor monitor

  Row {
	anchors.fill: parent

	Repeater {
	  model: WorkspaceManager.getWorkspacesForMonitor(root.monitor)

	  CenteredText {
		text: console.log("some")
	  }

	  //  WorkspaceSelector {
	  // required property HyprlandWorkspace modelData
	  //
	  // workspace: modelData
	  //  }
	}
  }
}
