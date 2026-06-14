import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: centerPill

  required property HyprlandMonitor monitor
  property string previousState

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: centerPill.monitor
  exclusiveToScreen: true
  state: ""

  states: [
	State {
	  name: ""

	  StateChangeScript {
		script: {
		  if (centerPill.previousState != "hovered") {
			centerPill.stack.replace(time);
		  }
		  centerPill.previousState = "";
		}
	  }
	},
	State {
	  name: "hovered"

	  PropertyChanges {
		centerPill.boxHeight: 35
		centerPill.boxWidth: 110
	  }

	  StateChangeScript {
		script: {
		  centerPill.previousState = "hovered";
		}
	  }
	},
	State {
	  name: "expanded"

	  PropertyChanges {
		centerPill.boxHeight: 140
		centerPill.boxRadius: 30
		centerPill.boxWidth: 300
	  }

	  StateChangeScript {
		script: {
		  centerPill.stack.replace(fullTime);
		  centerPill.previousState = "expanded";
		}
	  }
	}
  ]

  mouse.onClicked: {
	centerPill.state == "expanded" ? centerPill.state = "" : centerPill.state = "expanded";
  }
  mouse.onEntered: {
	centerPill.state = "hovered";
  }
  mouse.onExited: {
	centerPill.state = "";
  }

  Component {
	id: time

	Item {
	  CenteredText {
		text: Time.time
	  }
	}
  }

  Component {
	id: fullTime

	Column {
	  Layout.alignment: Qt.AlignCenter
	  spacing: 5

	  Item {
		CenteredText {
		  text: Time.time
		}
	  }

	  Item {
		CenteredText {
		  text: Time.date
		}
	  }
	}
  }
}
