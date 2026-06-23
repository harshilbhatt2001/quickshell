pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../Color.js" as Colors
import "../Components/"
import "../Services/"
import "./Center"

Container {
  required property HyprlandMonitor monitor

  boxHeight: 25
  boxWidth: 40
  exclusiveMonitor: monitor

  Item {
	StyledText {
	  text: WorkspaceManager.getWorkspacesForMonitor(monitor)
	}
  }
}
