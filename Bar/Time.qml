pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  property Notification latestNotif
  property double latestNotifId: latestNotif.id || 0
  required property HyprlandMonitor monitor
  property bool notified: false
  property bool overriden: false

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: root.monitor

  states: [
	State {
	  name: "closed"
	  when: root.hovered == false && root.overriden == false

	  PropertyChanges {
		root.boxHeight: 28
		root.boxRadius: 9
		root.boxWidth: 100
	  }

	  StateChangeScript {
		script: {
		  if (root.stack.currentItem.component != "time") {
			root.stack.replace(time);
		  }
		}
	  }
	},
	State {
	  name: "hovered"
	  when: root.hovered == true && root.overriden == false

	  PropertyChanges {
		root.boxHeight: 32
		root.boxRadius: 12
		root.boxWidth: 107
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(time);
		}
	  }
	},
	State {
	  name: "notified"
	  when: root.notified == true

	  PropertyChanges {
		root.boxHeight: 32
		root.boxRadius: 12
		root.boxWidth: 200
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(notification);
		  console.log("notification");
		  notificationTimer.restart();
		}
	  }
	}
  ]

  Connections {
	function onNewNotification() {
	  notification => {
		if (notification != root.latestNotif) {
		  root.latestNotif = notification;
		  root.overriden = true;
		  root.notified = true;
		} else {
		  console.log("notif already called");
		}
	  };
	}

	target: NotificationManager
  }

  Timer {
	id: notificationTimer

	interval: 2000
	repeat: false
	running: false

	onTriggered: {
	  root.notified = false;
	  root.overriden = false;
	}
  }

  Component {
	id: time

	StyledText {
	  property string component: "time"

	  horizontalAlignment: Qt.AlignCenter
	  text: Time.time
	  verticalAlignment: Qt.AlignVCenter
	}
  }

  Component {
	id: notification

	StyledText {
	  property string component: "notification"

	  horizontalAlignment: Qt.AlignCenter
	  text: root.latestNotif.summary
	  verticalAlignment: Qt.AlignVCenter
	}
  }
}
