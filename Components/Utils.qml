
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./Utils"

RowLayout {
	id: utilsContainer
	required property HyprlandMonitor monitor
	state: ""

	anchors {
		right: parent.right
		top: parent.top
	}
	
	states: [
		State {
			name: ""
		}
	]

	Rectangle {
		color: "red"
		implicitWidth: 40
		implicitHeight: 40
	}
	Rectangle {
		color: "blue"
		implicitWidth: 40
		implicitHeight: 40
	}

	// Battery {}
	// Mpris {}

}
