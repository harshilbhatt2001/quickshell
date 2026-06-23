import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property HyprlandMonitor monitor

  RowLayout {
	anchors.fill: parent


	Repeater {
	  model: WorkspaceManager.getWorkspacesForMonitor(root.monitor)

	  WorkspaceSelector {
		required property HyprlandWorkspace modelData

		workspace: modelData
	  }
	}
  }
}
