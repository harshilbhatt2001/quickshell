import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../Color.js" as Colors

import "./"

Container {
  id: batteryRoot

  boxColor: Colors.green
  boxState: ""
  sourceComponent: batteryClosed
  visible: UPower.devices[0] ? true : false

  MouseArea {
	anchors.fill: parent
	enabled: true
	hoverEnabled: true
	propagateComposedEvents: true

	onClicked: batteryRoot.boxState == "" ? batteryRoot.boxState = "open" : batteryRoot.boxState = ""
	onExited: batteryRoot.boxState = ""
  }

  Component {
	id: batteryClosed

	Item {
	  id: batteryRoot

	  anchors.fill: parent

	  Text {
		color: Colors.base
		text: "something"

		anchors {
		  bottom: parent.bottom
		  horizontalCenter: parent.horizontalCenter
		}
	  }
	}
  }
}
