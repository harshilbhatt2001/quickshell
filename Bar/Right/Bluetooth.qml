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

  property bool shown: false

  animOffset: 200
  boxColor: Colors.peach
  boxHeight: 25
  boxWidth: 30
  defaultItem: icon
  exclusiveToScreen: true
  forceHidden: !(root.shown || BluetoothManager.getConnected())
  hoverableWhenHidden: true
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
		  root.shown = true;
		}
	  }
	}
  ]

  hover.onHoveredChanged: {
	if (hover.hovered == false) {
	  root.state = "";
	  hoverIntervalTimer.start();
	} else {
	  root.shown = true;
	  hoverIntervalTimer.start();
	}
  }
  tap.onTapped: state = "expanded"

  Timer {
	id: hoverIntervalTimer

	interval: 500
	repeat: false
	running: false

	onTriggered: {
	  if (root.hover.hovered == false) {
		root.shown = false;
	  }
	}
  }

  Component {
	id: icon

	Item {
	  CenteredText {
		text: BluetoothManager.getConnected() == true ? "󰂱" : "󰂲"
	  }
	}
  }

  Component {
	id: expanded

	Expanded {}
  }
}
