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

	  PropertyChanges {
		centerPill.boxHeight: 28
		centerPill.boxRadius: 9
		centerPill.boxWidth: 100
	  }

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
		centerPill.boxRadius: 15
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

	Item {
	  Rectangle {
		anchors.fill: parent
		radius: 30

		gradient: Gradient {
		  GradientStop {
			color: "transparent"
			position: 0.0
		  }

		  GradientStop {
			color: "transparent"
			position: 0.6
		  }

		  GradientStop {
			color: Colors.red
			position: 1.0
		  }
		}
	  }

	  Column {
		anchors.centerIn: parent
		spacing: 5

		StyledText {
		  anchors.horizontalCenter: parent.horizontalCenter
		  font.pointSize: 30
		  text: Time.time
		}

		StyledText {
		  anchors.horizontalCenter: parent.horizontalCenter
		  color: Colors.surface0
		  text: Time.date

		  font {
			pointSize: 9
			weight: 400
		  }
		}
	  }
	}
  }
}
