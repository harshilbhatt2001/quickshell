import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  required property HyprlandMonitor monitor
  property bool opened: false

  animOffset: 200
  boxColor: Colors.peach
  boxHeight: 25
  boxWidth: 33
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: !(BluetoothManager.getConnected())

  states: [
	State {
	  name: "hovered"
	  when: root.hovered == true && root.opened == false

	  PropertyChanges {
		root.boxHeight: 28
		root.boxWidth: 35
	  }
	},
	State {
	  name: "opened"
	  when: root.opened == true && root.hovered == true

	  PropertyChanges {
		root.boxHeight: 300
		root.boxWidth: 350
	  }

	  StateChangeScript {
		script: {
		  stack.replace(deviceList);
		}
	  }
	}
  ]

  hover.onHoveredChanged: {
	if (hover.hovered == false) {
	  root.opened = false;
	  if (root.state != "icon") {
		root.stack.replace(icon);
	  }
	}
  }
  tap.onTapped: {
	root.opened = true;
  }

  Component {
	id: icon

	StyledText {
	  property string component: "icon"

	  horizontalAlignment: Qt.AlignCenter
	  propo: true
	  text: "󰂱"
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: deviceList

	Column {
	  property string component: "deviceList"

	  spacing: 3

	  Repeater {
		delegate: devicePlaque
		model: BluetoothManager.getConnectedDevicesList()
	  }

	  Component {
		id: devicePlaque

		Rectangle {
		  id: devicePlaqueRoot

		  required property var modelData

		  color: Colors.surface1
		  implicitHeight: 10

		  anchors {
			left: parent.left
			right: parent.right
		  }
		}
	  }
	}
  }
}
