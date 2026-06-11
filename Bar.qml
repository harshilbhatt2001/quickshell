import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "Components/Color.js" as Colors

import "Components"

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
		exclusiveZone: 20
		implicitHeight: 1000
		screen: modelData

		Behavior on implicitHeight {
		  NumberAnimation {
			duration: 0
			easing.type: Easing.InOutQuad
		  }
		}
		mask: Region {
		  Region {
			item: workspaceSwitcher
		  }

		  Region {
			item: pillItem
		  }

		  Region {
			item: utilsItem
		  }
		}

		anchors {
		  left: true
		  right: true
		  top: true
		}

		Workspace {
		  id: workspaceSwitcher

		  monitor: win.monitor
		}

		RectangularShadow {
		  anchors.fill: pillItem
		  blur: 20
		  color: Colors.crust
		  offset.x: 3
		  offset.y: 3
		  radius: pillItem.radius
		  spread: 7
		}

		Pill {
		  id: pillItem

		  monitor: win.monitor
		}

		Item {
		  anchors.fill: parent

		  Utils {
			id: utilsItem

			monitor: win.monitor
		  }
		}
	  }
	}
  }
}
