pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../Color.js" as Colors
import "../Components/"
import "../Services/"

Container {
  id: root

  property Notification latestNotif
  required property HyprlandMonitor monitor
  property bool mpris: false
  property double mprisHeight: 60
  property double mprisWidth: 350
  property double notificationHeight: 100
  property double notificationWidth: 350
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
		  if (!root.stack.currentItem) {
			return;
		  }
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
		root.boxHeight: root.notificationHeight
		root.boxRadius: 12
		root.boxWidth: root.notificationWidth
		root.visibleTopMargin: 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(notification);
		  notificationTimer.restart();
		}
	  }
	},
	State {
	  name: "mpris"
	  when: root.mpris == true

	  PropertyChanges {
		root.boxHeight: root.mprisHeight
		root.boxRadius: 12
		root.boxWidth: root.mprisWidth
		root.visibleTopMargin: 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(mprisToast);
		  mprisTimer.restart();
		}
	  }
	}
  ]

  Connections {
	function onNewNotification() {
	  notification => {
		if (notification.lastGeneration == false) {
		  root.latestNotif = notification;
		  root.overriden = true;
		  root.notified = true;
		}
	  };
	}

	target: NotificationManager
  }

  Connections {
	function onTrackChanged() {
	  root.overriden = true;
	  root.mpris = true;
	  console.log("track changed");
	}

	target: MprisManager.defaultPlayer
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

  Timer {
	id: mprisTimer

	interval: 2000
	repeat: false
	running: false

	onTriggered: {
	  root.mpris = false;
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

	Item {
	  id: notificationRoot

	  property double innerMargin: 5
	  property double outerMargin: 6

	  function getInnerHeight() {
		let fullHeight = root.notificationHeight;
		let fullMargin = notificationRoot.innerMargin + notificationRoot.outerMargin;

		return fullHeight - (fullMargin * 2);
	  }

	  Rectangle {
		color: Colors.surface1
		radius: 9

		anchors {
		  fill: parent
		  margins: notificationRoot.outerMargin
		}

		RowLayout {
		  Rectangle {
			Layout.margins: notificationRoot.innerMargin
			color: Colors.mauve
			implicitHeight: notificationRoot.getInnerHeight()
			implicitWidth: notificationRoot.getInnerHeight()
			radius: 5

			IconImage {
			  anchors.fill: parent
			  anchors.margins: 10
			  source: root.latestNotif.image
			}
		  }

		  ColumnLayout {
			property double textMargin: 4

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			Layout.leftMargin: 0
			Layout.margins: notificationRoot.innerMargin + textMargin

			StyledText {
			  color: Colors.text
			  fontSize: 14
			  text: root.latestNotif.summary
			}

			StyledText {
			  Layout.fillHeight: true
			  Layout.maximumWidth: root.notificationWidth - ((notificationRoot.outerMargin * 2) + (
															   notificationRoot.innerMargin * 3) + notificationRoot.getInnerHeight())
			  color: Colors.subtext0
			  elide: Qt.ElideRight
			  fontWeight: 5
			  maximumLineCount: 2
			  text: root.latestNotif.body
			  wrapMode: Text.WordWrap
			}
		  }
		}
	  }
	}
  }

  Component {
	id: mprisToast

	Item {
	  id: mprisToastRoot

	  property double innerMargin: 4
	  property double outerMargin: 4
	  property var trackInfo: MprisManager.getTrackInfo()

	  function getInnerHeight() {
		let fullHeight = root.mprisHeight;
		let fullMargin = mprisToastRoot.innerMargin + mprisToastRoot.outerMargin;

		return fullHeight - (fullMargin * 2);
	  }

	  Rectangle {
		color: Colors.surface1
		radius: 9

		anchors {
		  fill: parent
		  margins: mprisToastRoot.outerMargin
		}

		RowLayout {
		  Rectangle {
			Layout.margins: mprisToastRoot.innerMargin
			color: Colors.mauve
			implicitHeight: mprisToastRoot.getInnerHeight()
			implicitWidth: mprisToastRoot.getInnerHeight()
			radius: 5

			IconImage {
			  anchors.fill: parent
			  source: mprisToastRoot.trackInfo["albumArt"]
			}
		  }

		  ColumnLayout {
			property double textMargin: 1

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			Layout.leftMargin: 0
			Layout.margins: mprisToastRoot.innerMargin + textMargin

			StyledText {
			  Layout.maximumWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())
			  color: Colors.text
			  fontSize: 14
			  text: mprisToastRoot.trackInfo["name"] + " - " + mprisToastRoot.trackInfo["artist"]
			}

			Item {
			  Layout.fillHeight: true
			  Layout.fillWidth: true
			  Layout.maximumWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())
			  Layout.preferredWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (
														  mprisToastRoot.innerMargin * 5) + mprisToastRoot.getInnerHeight())

			  Rectangle {
				anchors.fill: parent
				color: Colors.overlay0
				radius: 100

				Rectangle {
				  color: Colors.mauve
				  implicitWidth: parent.width * mprisToastRoot.trackInfo["lengthPercent"]
				  radius: 100

				  anchors {
					bottom: parent.bottom
					left: parent.left
					top: parent.top
				  }
				}

				StyledText {
				  text: MprisManager.getTimeString()

				  anchors {
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
				  }
				}
			  }
			}
		  }
		}
	  }
	}
  }
}
