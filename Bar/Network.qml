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

  required property HyprlandMonitor monitor
  property bool opened: false

  animOffset: 250
  boxColor: Colors.red
  boxHeight: 25
  boxWidth: 33
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: !NetworkManager.connectedWifi

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
		root.boxHeight: 28
		root.boxRadius: 12
		root.boxWidth: 350
	  }

	  StateChangeScript {
		script: {
		  stack.replace(wifiInfo);
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
	  horizontalAlignment: Qt.AlignCenter
	  propo: true
	  text: NetworkManager.getNetworkDetails(NetworkManager.defaultAdapter)["icon"]
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: wifiInfo

	StyledText {
	  horizontalAlignment: Qt.AlignCenter
	  propo: true
	  text: NetworkManager.getWifiText()
	  verticalAlignment: Qt.AlignVCenter
	}
  }
}
