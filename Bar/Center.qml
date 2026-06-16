pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../Color.js" as Colors
import "../Components/"
import "../Services/"
import "./Center"

Container {
  id: root

  property Notification latestNotification: NotificationManager.getLatestNotification() || null
  required property HyprlandMonitor monitor
  property NotificationServer notifServer: NotificationManager.notif
  property string previousState

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  state: ""

  states: [
	State {
	  name: ""

	  PropertyChanges {
		root.boxHeight: 28
		root.boxRadius: 9
		root.boxWidth: 100
		root.visibleTopMargin: 0
	  }

	  StateChangeScript {
		script: {
		  if (root.previousState != "hovered") {
			root.stack.replace(time);
		  }
		  root.previousState = "";
		}
	  }
	},
	State {
	  name: "hovered"

	  PropertyChanges {
		root.boxHeight: 35
		root.boxRadius: 15
		root.boxWidth: 110
		root.visibleTopMargin: 0
	  }

	  StateChangeScript {
		script: {
		  root.previousState = "hovered";
		}
	  }
	},
	State {
	  name: "expanded"

	  PropertyChanges {
		root.boxHeight: 140
		root.boxRadius: 30
		root.boxWidth: 300
		root.visibleTopMargin: 0
	  }

	  StateChangeScript {
		script: {
		  if (root.state != "notifications") {
			root.stack.replace(fullTime);
			root.previousState = "expanded";
		  }
		}
	  }
	},
	State {
	  extend: "expanded"
	  name: "notifications"

	  PropertyChanges {
		root.boxHeight: 320
	  }
	},
	State {
	  name: "notified"

	  PropertyChanges {
		root.boxHeight: 90
		root.boxRadius: 30
		root.boxWidth: 330
		root.visibleTopMargin: 20
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(notification);
		  root.previousState = "notified";
		}
	  }
	}
  ]

  hover.onHoveredChanged: {
	hover.hovered == true ? root.state == "notified" ? root.state = "notified" : root.state = "hovered" :
													   root.state = "";
  }
  onLatestNotificationChanged: {
	if (latestNotification != null && Hyprland.focusedMonitor == monitor) {
	  if (root.latestNotification.lastGeneration == false) {
		root.state = "notified";
		notificationViewTimer.start();
	  }
	}
  }
  tap.onTapped: {
	root.state == "hovered" ? root.state = "expanded" : undefined;
  }

  Timer {
	id: notificationViewTimer

	interval: 3000
	repeat: false
	running: false || !root.hover.hovered

	onTriggered: {
	  root.state = "";
	}
  }

  Component {
	id: time

	Item {
	  CenteredText {
		text: Time.time
	  }
	}
  }

  Component {
	id: fullTime

	Expanded {
	  NotificationList {
		id: notifList

		animEnabled: false
		radius: root.boxRadius
		rootState: root.state
		server: root.notifServer
		state: ""

		TapHandler {
		  onTapped: {
			notifList.animEnabled = true;
			root.state = "notifications";
			Qt.callLater(() => {
						   notifList.animEnabled = false;
						 });
		  }
		}
	  }
	}
  }

  Component {
	id: notification

	NotificationDisplay {
	  body: root.latestNotification.body
	  summary: root.latestNotification.summary

	  TapHandler {
		onTapped: {
		  root.state = "notifications";
		  root.stack.replace(fullTime);
		}
	  }
	}
  }
}
