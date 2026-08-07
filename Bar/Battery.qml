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

  property double batteryDisplayHeight: 100
  required property HyprlandMonitor monitor
  property bool opened: false
  property double radius: 9

  boxColor: Colors.green
  boxHeight: 25
  boxRadius: radius
  boxWidth: 55
  defaultItem: icon
  exclusiveMonitor: root.monitor

  states: [
	State {
	  name: "closed"
	  when: root.hovered == false && root.opened == false

	  PropertyChanges {
		root.boxHeight: 25
		root.boxRadius: 9
		root.boxWidth: 55
	  }
	},
	State {
	  name: "hovered"
	  when: root.hovered == true && root.opened == false

	  PropertyChanges {
		root.boxHeight: 28
		root.boxWidth: 60
	  }
	},
	State {
	  name: "opened"
	  when: root.opened == true && root.hovered == true

	  PropertyChanges {
		root.boxHeight: root.batteryDisplayHeight
		root.boxRadius: 12
		root.boxWidth: 350
	  }

	  StateChangeScript {
		script: {
		  stack.replace(batteryDisplay);
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

	Item {
	  MidpointGradient {
		anchors.fill: parent
		angle: -45
		blur: 0.6
		color: BatteryManager.getBatteryColor()
		midpoint: 0.55
		radius: radius
	  }

	  CenteredText {
		property string component: "icon"

		propo: true
		text: BatteryManager.getBatteryText()
	  }
	}
  }

  Component {
	id: batteryDisplay

	Item {
	  id: batteryDisplayRoot

	  property double innerMargin: 5
	  property double outerMargin: 6

	  Rectangle {
		id: batteryBackground

		anchors.fill: parent
		anchors.margins: batteryDisplayRoot.outerMargin
		color: Colors.surface1
		radius: 8

		RowLayout {
		  anchors.fill: parent

		  Rectangle {
			id: percentBox

			property double percentBoxRadius: 5

			Layout.fillHeight: true
			Layout.margins: batteryDisplayRoot.innerMargin
			color: Colors.text
			implicitWidth: root.batteryDisplayHeight - (batteryDisplayRoot.innerMargin * 2) - (
							 batteryDisplayRoot.outerMargin * 2)
			radius: 5

			Rectangle {
			  color: Colors.green
			  implicitHeight: (root.batteryDisplayHeight - (batteryDisplayRoot.innerMargin * 2) - (
								 batteryDisplayRoot.outerMargin * 2)) * BatteryManager.mainBattery.percentage
			  radius: percentBox.percentBoxRadius

			  anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			  }
			}

			CenteredText {
			  fontSize: 15
			  text: BatteryManager.getBatteryPercentage(BatteryManager.mainBattery) + "%"
			}
		  }

		  Column {
			id: batColumn

			property var batInfo: BatteryManager.getMainBatteryInfo()

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true

			StyledText {
			  color: Colors.text
			  fontSize: 13
			  text: "Battery - " + batColumn.batInfo["name"]
			}

			StyledText {
			  color: Colors.text
			  fontSize: 13
			  text: batColumn.batInfo["energy"] + " / " + batColumn.batInfo["capacity"] + "Wh"
			}
		  }
		}
	  }
	}
  }
}
