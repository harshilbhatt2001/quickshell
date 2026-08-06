import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  required property HyprlandMonitor monitor

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: root.monitor

  states: [
	State {
	  name: "hovered"
	  when: root.hovered == true

	  PropertyChanges {
		root.boxHeight: 32
		root.boxRadius: 12
		root.boxWidth: 107
	  }
	}
  ]

  Component {
	id: time

	StyledText {
	  horizontalAlignment: Qt.AlignCenter
	  text: Time.time
	  verticalAlignment: Qt.AlignVCenter
	}
  }
}
