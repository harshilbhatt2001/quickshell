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
import "./Right/"

Row {
  id: root

  required property HyprlandMonitor monitor

  Bluetooth {
	exclusiveMonitor: root.monitor
  }
}
