pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"
import "Bluetooth"

Container {
  id: root

  animOffset: 200
  boxColor: Colors.peach
  boxHeight: 25
  boxWidth: 30
  defaultItem: icon
  exclusiveToScreen: true
  forceHidden: BluetoothManager.getConnected()
  state: ""

  states: [
	State {
	  name: ""

	  PropertyChanges {
		root.boxHeight: 25
		root.boxWidth: 30
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(icon);
		}
	  }
	},
	State {
	  name: "expanded"

	  PropertyChanges {
		root.boxHeight: 250
		root.boxRadius: 20
		root.boxWidth: 350
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(expanded);
		}
	  }
	}
  ]

  hover.onHoveredChanged: hover.hovered == false ? state = "" : undefined
  tap.onTapped: state = "expanded"

  Component {
	id: icon

	Item {
	  CenteredText {
		text: "󰂱"
	  }
	}
  }

  Component {
	id: expanded

	Expanded {}
  }
}
