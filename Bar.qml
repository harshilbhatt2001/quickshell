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

		  RowLayout {
			anchors {
			  left: parent.left
			  leftMargin: 3
			  right: parent.right
			  rightMargin: 3
			  top: parent.top
			}

			Row {
			  id: left

			  Layout.alignment: Qt.AlignTop

			  WorkspaceSelector {
				monitor: win.monitor
			  }
			}

			Item {
			  Layout.fillWidth: true
			}

			Row {
			  id: center

			  Layout.alignment: Qt.AlignTop

			  Time {
				monitor: win.monitor
			  }
			}

			Item {
			  Layout.fillWidth: true
			}

			Row {
			  id: right

			  Layout.alignment: Qt.AlignTop
			}
		  }
		}
	  }
	}
  }
}
