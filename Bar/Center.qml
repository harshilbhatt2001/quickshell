import QtQuick
import Quickshell
import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: centerPill

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveToScreen: true
  state: ""

  states: [
	State {
	  name: "hovered"

	  PropertyChanges {
		centerPill.boxColor: Colors.teal
		centerPill.boxHeight: 200
	  }
	}
  ]

  mouse.onEntered: {
	print("entered");
	centerPill.state = "hovered";
  }
  mouse.onExited: {
	print("something");
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
}
