import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import "Color.js" as Colors

import "./Pill"

Rectangle {
	required property HyprlandMonitor monitor
	id: container
	state: ""
	visible: true

	property bool shown: monitor !== null && monitor.focused

	Behavior on anchors.topMargin {
		SmoothedAnimation { duration: 70; easing.type: Easing.OutBounce }
	}

	opacity: shown ? 1 : 0

	Behavior on opacity {
		NumberAnimation {duration: 50}
	}

	anchors {
		top: parent.top
		topMargin: shown ? 5 : -implicitHeight
		horizontalCenter: parent.horizontalCenter
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent

		onClicked: container.state == 'expanded' ? container.state = "" : container.state = 'expanded';

	}

	implicitWidth: 130
	implicitHeight: 30

	radius: 30

	property real gradientMidpoint: 0.4

	gradient: Gradient {
		GradientStop { position: 0.0; color: Colors.surface0 }
		GradientStop { position: container.gradientMidpoint; color: Colors.surface0 }
		GradientStop { position: 1.0; color: Colors.overlay0 }
	}


	component SmoothAnim: SpringAnimation {
		spring: 3
		mass: 0.5
		damping: 0.18
	}

	Behavior on implicitHeight {
		SmoothAnim {}
	}

	Behavior on implicitWidth {
		SmoothAnim {}
	}

	Behavior on gradientMidpoint {
		NumberAnimation {
			duration: 100
		}
	}

	states: [
		State {
			name: ""
			StateChangeScript {
				script: mainLoader.replace(defaultComponent)
			}
		},
		State {
			name: "expanded"
			StateChangeScript {
				script: mainLoader.replace(expandedComponent)
			}
			PropertyChanges { container.gradientMidpoint: 0.7}
			PropertyChanges { container.implicitHeight: 130}
			PropertyChanges { container.implicitWidth: 300}
		}
	]

	StackView {
		id: mainLoader
		anchors.fill: parent

		MouseArea {
			id: mouseAreaStack
			anchors.fill: parent
			hoverEnabled: true

			// FIX part 1: Prevent internal StackView items from changing cursor grab
			propagateComposedEvents: true

			onClicked: {
				container.state == 'expanded' ? container.state = "" : container.state = 'expanded';
				print("clicked")
			}

			onExited: {
				container.state = ""
			}
		}

		enabled:false

		initialItem: defaultComponent

		// Custom animations for switching components
		replaceEnter: Transition {
			PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
			PropertyAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 100 }
		}
		replaceExit: Transition {
			PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
		}
	}

	Component {
		id: defaultComponent
		Default {}
	}

	Component {
		id: expandedComponent
		Expanded {}
	}

}
