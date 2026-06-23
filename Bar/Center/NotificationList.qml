import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property bool animEnabled
  required property double radius
  required property string rootState
  required property NotificationServer server

  Behavior on anchors.topMargin {
	enabled: root.animEnabled

	SpringAnimation {
	  damping: 0.35
	  spring: 4
	}
  }
  states: [
	State {
	  name: ""
	  when: root.rootState != "notifications"

	  PropertyChanges {
		root.anchors.topMargin: root.parent.height - 21
	  }
	},
	State {
	  name: "expanded"
	  when: root.rootState == "notifications"

	  PropertyChanges {
		root.anchors.topMargin: 5
	  }
	}
  ]

  anchors {
	bottom: parent.bottom
	left: parent.left
	right: parent.right
	top: parent.top
	topMargin: parent.height - 21
  }

  Rectangle {
	id: background

	anchors.fill: parent
	color: Colors.surface0
	radius: root.radius - 3

	states: [
	  State {
		name: ""
		when: root.rootState != "notifications"

		PropertyChanges {}
	  },
	  State {
		name: "expanded"
		when: root.rootState == "notifications"

		PropertyChanges {
		  background.anchors.bottomMargin: 5
		  background.anchors.leftMargin: 5
		  background.anchors.rightMargin: 5
		}
	  }
	]

	anchors {
	  bottomMargin: 15
	  leftMargin: 20
	  rightMargin: 20
	}
  }

  Item {
	id: notifListContainer

	anchors.fill: parent
	clip: true
	opacity: 0

	anchors {
	  bottomMargin: 5
	  leftMargin: 5
	  rightMargin: 5
	  topMargin: 5
	}

	CenteredText {
	  color: Colors.overlay0
	  text: "No Notifications"
	  visible: root.server.trackedNotifications.values.length <= 0
	}

	ListView {
	  id: notifScrollingList

	  anchors.fill: parent
	  boundsBehavior: Flickable.StopAtBounds
	  height: Math.min(contentHeight, parent.height)
	  implicitHeight: background.height
	  model: root.server.trackedNotifications.values.length
	  spacing: 7

	  delegate: Item {
		id: notifRoot

		property Notification currentNotif: root.server.trackedNotifications.values[(notifRoot.notifLen
																					 - 1) - index]
		required property real index
		property real notifLen: root.server.trackedNotifications.values.length

		height: 50
		width: ListView.view.width

		states: [
		  State {
			name: ""
			when: notifHover.hovered == false
		  },
		  State {
			name: "hovered"
			when: notifHover.hovered == false

			PropertyChanges {}
		  }
		]

		HoverHandler {
		  id: notifHover
		}

		Rectangle {
		  id: dismissButton

		  color: Colors.red
		  implicitWidth: 100
		  radius: 10

		  Behavior on anchors.rightMargin {
			NumberAnimation {
			  duration: 100
			}
		  }
		  states: [
			State {
			  name: ""
			  when: notifHover.hovered == false
			},
			State {
			  name: "hovered"
			  when: notifHover.hovered == true

			  PropertyChanges {
				dismissButton.anchors.rightMargin: 5
			  }
			}
		  ]

		  StyledText {
			color: Colors.surface0
			font.pointSize: 15
			horizontalAlignment: Qt.AlignRight
			text: "󰩹"
			verticalAlignment: Qt.AlignVCenter

			anchors {
			  fill: parent
			  rightMargin: 14
			}
		  }

		  TapHandler {
			onTapped: {
			  notifRoot.currentNotif.dismiss();
			}
		  }

		  anchors {
			bottom: parent.bottom
			bottomMargin: 3
			right: parent.right
			rightMargin: 10
			top: parent.top
			topMargin: 3
		  }
		}

		Rectangle {
		  id: textContainer

		  anchors.fill: parent
		  clip: true
		  color: Colors.surface2
		  radius: 9

		  Behavior on anchors.rightMargin {
			NumberAnimation {
			  duration: 100
			}
		  }
		  states: [
			State {
			  name: ""
			  when: notifHover.hovered == false
			},
			State {
			  name: "hovered"
			  when: notifHover.hovered == true

			  PropertyChanges {
				textContainer.anchors.rightMargin: 40
			  }
			}
		  ]

		  Column {
			id: textColumn

			anchors {
			  centerIn: parent
			  left: parent.left
			  right: parent.right
			}

			StyledText {
			  color: Colors.text
			  horizontalAlignment: Text.AlignHCenter
			  text: notifRoot.currentNotif.summary
			  verticalAlignment: Text.AlignVCenter
			  width: notifRoot.width - 10
			}

			StyledText {
			  color: Colors.subtext1
			  horizontalAlignment: Text.AlignHCenter
			  text: notifRoot.currentNotif.body
			  verticalAlignment: Text.AlignVCenter
			  width: notifRoot.width - 10
			}
		  }
		}
	  }

	  anchors {
		bottomMargin: 5
		leftMargin: 10
		rightMargin: 10
		topMargin: 5
	  }
	}
  }

  MultiEffect {
	id: notifListClipper

	anchors.fill: notifListContainer
	maskEnabled: true
	maskSource: clipsource
	opacity: 0
	source: notifListContainer

	Behavior on opacity {
	  NumberAnimation {
		duration: 100
	  }
	}
	states: [
	  State {
		name: ""
		when: root.rootState != "notifications"

		PropertyChanges {
		  notifListClipper.opacity: 0
		}
	  },
	  State {
		name: "expanded"
		when: root.rootState == "notifications"

		PropertyChanges {
		  notifListClipper.opacity: 1
		}
	  }
	]
  }

  Rectangle {
	id: clipsource

	anchors.fill: background
	color: "black"
	layer.enabled: true
	radius: background.radius
	visible: false
  }
}
