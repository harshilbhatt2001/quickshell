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
import "./Left/"

Container {
  id: root

  required property HyprlandMonitor monitor

  boxHeight: 25
  boxWidth: 200
  exclusiveMonitor: monitor

  defaultItem: WorkspaceContainer {
	monitor: root.monitor
  }
}
