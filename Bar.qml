import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "./Bar"
import "Color.js" as Colors

Scope {
  Variants {
	model: Quickshell.screens

	delegate: Component {
	  PanelWindow {
		id: win

		property double barExclusionZone: 15
		property double barMaxHeight: 1000
		required property var modelData
		property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

		color: "transparent"
		exclusionMode: ExclusionMode.Normal
		exclusiveZone: barExclusionZone
		implicitHeight: barMaxHeight
		screen: modelData

		mask: Region {
		  Region {
			item: center
		  }
		}

		anchors {
		  left: true
		  right: true
		  top: true
		}

		Item {
		  anchors {
			fill: parent
			topMargin: 3
		  }

		  RowLayout {
			anchors {
			  left: parent.left
			  right: parent.right
			  top: parent.top
			}

			Row {
			  id: left
			}

			Item {
			  Layout.fillWidth: true
			}

			Row {
			  id: center

			  Time {
				monitor: win.monitor
			  }
			}

			Item {
			  Layout.fillWidth: true
			}

			Row {
			  id: right
			}
		  }
		}
	  }
	}
  }
}
