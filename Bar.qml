import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "Bar"
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
			item: left
		  }

		  Region {
			item: center
		  }

		  Region {
			item: right
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

		  Row {
			id: left

			height: childrenRect.height

			anchors {
			  left: parent.left
			  leftMargin: 7
			}

			Left {
			  monitor: win.monitor
			}
		  }

		  Row {
			id: center

			height: childrenRect.height

			anchors {
			  horizontalCenter: parent.horizontalCenter
			}

			Center {
			  monitor: win.monitor
			}
		  }

		  Row {
			id: right

			height: childrenRect.height

			anchors {
			  right: parent.right
			  rightMargin: 7
			}

			Right {
			  monitor: win.monitor
			}
		  }
		}
	  }
	}
  }
}
