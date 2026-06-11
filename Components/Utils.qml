pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import "./Utils"

RowLayout {
  id: utilsContainer

  required property HyprlandMonitor monitor
  property bool shown: monitor !== null && monitor.focused

  opacity: shown ? 1 : 0
  state: ""

  Behavior on anchors.topMargin {
	SmoothedAnimation {
	  duration: 300
	}
  }
  Behavior on opacity {
	NumberAnimation {
	  duration: 50
	}
  }
  states: [
	State {
	  name: ""
	}
  ]

  anchors {
	right: parent.right
	rightMargin: 7
	top: parent.top
	topMargin: shown ? -33 : -40
  }

  Battery {}
  // Mpris {}

}
