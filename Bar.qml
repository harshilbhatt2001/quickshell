import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "Components/Color.js" as Colors

Scope {
  Variants {
	model: Quickshell.screens

	delegate: Component {
	  PanelWindow {
		id: win

		required property var modelData
		property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

		color: "transparent"
		exclusionMode: ExclusionMode.Normal
		exclusiveZone: 15
		implicitHeight: 1000
		screen: modelData

		mask: Region {}

		anchors {
		  left: true
		  right: true
		  top: true
		}
	  }
	}
  }
}
