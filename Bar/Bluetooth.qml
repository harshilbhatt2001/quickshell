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
	  name: "closed"
	  when: root.hovered == false && root.opened == false

	  PropertyChanges {
		root.boxHeight: 25
		root.boxRadius: 9
		root.boxWidth: 33
	  }
	},
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

		  RowLayout {
			id: deviceInfoRow

			property double margin: 7

			spacing: margin * 2

			anchors {
			  fill: parent
			  leftMargin: margin
			}

			Rectangle {
			  id: iconContainer

			  property double boxRadius: 4

			  color: Colors.text
			  implicitHeight: deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2)
			  implicitWidth: deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2)
			  radius: boxRadius

			  Rectangle {
				id: batteryIndicator

				color: Colors.green
				implicitHeight: (deviceListRoot.plaqueHeight - (deviceInfoRow.margin * 2))
								* devicePlaqueRoot.deviceText["batteryRaw"]
				radius: iconContainer.boxRadius

				anchors {
				  bottom: parent.bottom
				  left: parent.left
				  right: parent.right
				}
			  }

			  HoverHandler {
				id: batteryHoverHandler

				onHoveredChanged: {
				  if (batteryHoverHandler.hovered == true) {
					batteryText.text = devicePlaqueRoot.deviceText["battery"];
				  } else {
					batteryText.text = devicePlaqueRoot.deviceText["icon"];
				  }
				}
			  }

			  CenteredText {
				id: batteryText

				fontSize: 17
				text: devicePlaqueRoot.deviceText["icon"]
			  }
			}

			Column {
			  Layout.alignment: Qt.AlignVCenter
			  Layout.fillWidth: true

			  StyledText {
				color: Colors.text
				fontSize: 14
				text: devicePlaqueRoot.deviceText["name"]
			  }

			  StyledText {
				color: Colors.subtext1
				fontSize: 10
				text: devicePlaqueRoot.deviceText["mac"]
			  }
			}
		  }
		}
	  }
	}
  }
}
