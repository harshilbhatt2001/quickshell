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

  function showMpris() {
	if (!MprisManager.hasMedia) {
	  return;
	}
	root.overriden = true;
	root.mpris = true;
	if (root.hovered) {
	  mprisTimer.stop();
	} else {
	  mprisTimer.restart();
	}
  }

  boxColor: Colors.mauve
  defaultItem: time
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true

  // NOTE: this replaces Container's own closed/hovered/opened states, so the
  // base state ("") has to restore the clock itself — see onStateChanged.
  states: [
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
	  when: root.mpris == true && MprisManager.hasMedia

	  PropertyChanges {
		root.boxHeight: root.mprisHeight
		root.boxRadius: 12
		root.boxWidth: root.mprisWidth
		root.visibleTopMargin: root.hovered == true ? 0 : 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(mprisToast);
		}
	  }
	}
  ]

  onHoveredChanged: {
	if (root.hovered) {
	  // Hover shows the player regardless of playback state, as long as
	  // some player exists (paused Zen tab included).
	  root.showMpris();
	} else if (root.mpris) {
	  mprisTimer.stop();
	  root.mpris = false;
	  root.overriden = root.notified;
	}
  }
  onStateChanged: {
	if (root.state === "") {
	  root.stack.replace(root.defaultItem);
	}
  }

  Connections {
	function onNewNotification(notification) {
	  if (notification.lastGeneration == false) {
		root.latestNotif = notification;
		root.overriden = true;
		root.notified = true;
	  }
	}

	target: NotificationManager
  }

  Connections {
	function onHasMediaChanged() {
	  if (!MprisManager.hasMedia && root.mpris) {
		mprisTimer.stop();
		root.mpris = false;
		root.overriden = root.notified;
	  }
	}

	target: MprisManager
  }

  Connections {
	// Firefox/Zen keep a constant mpris:trackid, so trackChanged may not fire
	// for them; the title changing is the reliable signal there.
	function onTrackChanged() {
	  root.showMpris();
	}

	function onTrackTitleChanged() {
	  root.showMpris();
	}

	target: MprisManager.activePlayer
  }

  Timer {
	id: notificationTimer

	interval: 2000
	repeat: false
	running: false

	onTriggered: {
	  root.notified = false;
	  root.overriden = root.mpris;
	}
  }

  Timer {
	id: mprisTimer

	interval: 3000
	repeat: false
	running: false

	onTriggered: {
	  root.mpris = false;
	  root.overriden = root.notified;
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
	  property int pendingButton: Qt.NoButton
	  property double textWidth: root.mprisWidth - ((mprisToastRoot.outerMargin * 2) + (mprisToastRoot.innerMargin
																						* 5) + mprisToastRoot.getInnerHeight())
	  property var trackInfo: MprisManager.getTrackInfo()

	  function getInnerHeight() {
		let fullHeight = root.mprisHeight;
		let fullMargin = mprisToastRoot.innerMargin + mprisToastRoot.outerMargin;

		return fullHeight - (fullMargin * 2);
	  }

	  // Keep the position (and thus the progress bar) ticking while the toast
	  // is visible; Quickshell only re-reads it when asked.
	  Timer {
		interval: 1000
		repeat: true
		running: mprisToastRoot.visible && MprisManager.isPlaying

		onTriggered: {
		  if (MprisManager.activePlayer) {
			MprisManager.activePlayer.positionChanged();
		  }
		}
	  }

	  // Single left click: play/pause. Double left: next. Double right: previous.
	  // The single click is deferred by one double-click interval so that the
	  // first tap of a double click doesn't also toggle playback.
	  Timer {
		id: singleTapTimer

		interval: 250
		repeat: false

		onTriggered: {
		  if (mprisToastRoot.pendingButton === Qt.LeftButton) {
			MprisManager.togglePlaying();
		  }
		  mprisToastRoot.pendingButton = Qt.NoButton;
		}
	  }

	  TapHandler {
		acceptedButtons: Qt.LeftButton | Qt.RightButton

		onTapped: (eventPoint, button) => {
		  if (tapCount === 1) {
			mprisToastRoot.pendingButton = button;
			singleTapTimer.restart();
		  } else if (tapCount === 2) {
			singleTapTimer.stop();
			mprisToastRoot.pendingButton = Qt.NoButton;
			if (button === Qt.LeftButton) {
			  MprisManager.next();
			} else if (button === Qt.RightButton) {
			  MprisManager.previous();
			}
		  }
		}
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
			clip: true
			color: Colors.mauve
			implicitHeight: mprisToastRoot.getInnerHeight()
			implicitWidth: mprisToastRoot.getInnerHeight()
			radius: 5

			IconImage {
			  anchors.fill: parent
			  source: mprisToastRoot.trackInfo ? mprisToastRoot.trackInfo["albumArt"] : ""
			}
		  }

		  ColumnLayout {
			property double textMargin: 1

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			Layout.leftMargin: 0
			Layout.margins: mprisToastRoot.innerMargin + textMargin

			StyledText {
			  Layout.maximumWidth: mprisToastRoot.textWidth
			  color: Colors.text
			  fontSize: 14
			  text: {
				if (!mprisToastRoot.trackInfo) {
				  return "";
				}
				const name = mprisToastRoot.trackInfo["name"];
				const artist = mprisToastRoot.trackInfo["artist"];
				return artist ? name + " - " + artist : name;
			  }
			}

			Item {
			  Layout.fillHeight: true
			  Layout.fillWidth: true
			  Layout.maximumWidth: mprisToastRoot.textWidth
			  Layout.preferredWidth: mprisToastRoot.textWidth

			  Rectangle {
				anchors.fill: parent
				color: Colors.overlay0
				radius: 100

				Rectangle {
				  color: Colors.mauve
				  implicitWidth: parent.width * (mprisToastRoot.trackInfo
												 ? mprisToastRoot.trackInfo["lengthPercent"] : 0)
				  radius: 100

				  Behavior on implicitWidth {
					NumberAnimation {
					  duration: 200
					}
				  }

				  anchors {
					bottom: parent.bottom
					left: parent.left
					top: parent.top
				  }
				}

				StyledText {
				  propo: true
				  text: {
					if (!mprisToastRoot.trackInfo) {
					  return "";
					}
					const icon = mprisToastRoot.trackInfo["playing"] ? "󰐊" : "󰏤";
					const time = mprisToastRoot.trackInfo["timeString"];
					return time ? icon + "  " + time : icon;
				  }

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
