pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  property double devicePlaqeuSpacing
  property double devicePlaqueHeight
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
		root.boxRadius: 12
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
	  id: deviceListRoot

	  property string component: "deviceList"
	  property double plaqueHeight: 60
	  property double plaqueSpacing: 4

	  spacing: plaqueSpacing

	  Item {
		implicitHeight: 1
		implicitWidth: 10
	  }

	  Repeater {
		delegate: devicePlaque
		model: BluetoothManager.getConnectedDevicesList()
	  }

	  Component {
		id: devicePlaque

		Rectangle {
		  id: devicePlaqueRoot

		  readonly property variant deviceText: BluetoothManager.getDeviceText(modelData)
		  readonly property double margin: 5
		  required property var modelData

		  color: Colors.surface1
		  implicitHeight: deviceListRoot.plaqueHeight
		  radius: 10

		  anchors {
			left: parent.left
			leftMargin: devicePlaqueRoot.margin
			right: parent.right
			rightMargin: devicePlaqueRoot.margin
		  }

		  Item {
			anchors.fill: parent

			Rectangle {
			  id: iconContainer

			  property double margin: 7

			  color: Colors.text
			  implicitWidth: deviceListRoot.plaqueHeight - (margin * 2)
			  radius: 4

			  anchors {
				bottom: parent.bottom
				left: parent.left
				margins: iconContainer.margin
				top: parent.top
			  }

			  CenteredText {
				fontSize: 17
				text: devicePlaqueRoot.deviceText["icon"]
			  }
			}
		  }
		}
	  }
	}
  }
}
