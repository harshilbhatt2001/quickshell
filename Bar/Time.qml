pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../Color.js" as Colors
import "../Components/"
import "../Services/"
import "./Calendar/"

Container {
  id: root

  property bool island: false
  property double islandHeight: root.mprisHeight
  property int islandPage: 0
  property double islandWidth: 350
  property Notification latestNotif
  required property HyprlandMonitor monitor
  property double mprisHeight: 76
  property double mprisWidth: 380
  property double notificationHeight: 100
  property double notificationWidth: 350
  property bool notified: false

  function closeIsland() {
	islandTimer.stop();
	root.island = false;
	root.islandPage = 0;
	root.overriden = root.notified;
  }

  function openIsland() {
	root.overriden = true;
	root.island = true;
	if (root.hovered) {
	  islandTimer.stop();
	} else {
	  islandTimer.restart();
	}
  }

  function showMpris() {
	if (!MprisManager.hasMedia) {
	  return;
	}
	root.islandPage = 0;
	root.openIsland();
  }

  boxColor: Colors.base
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
	  name: "island"
	  when: root.island == true && (root.hovered || MprisManager.hasMedia)

	  PropertyChanges {
		root.boxHeight: root.islandHeight
		root.boxRadius: 12
		root.boxWidth: root.islandWidth
		root.visibleTopMargin: root.hovered == true ? 0 : 5
	  }

	  StateChangeScript {
		script: {
		  root.stack.replace(island);
		}
	  }
	}
  ]

  onHoveredChanged: {
	if (root.hovered) {
	  root.openIsland();
	} else if (root.island && !CalendarManager.editing) {
	  root.closeIsland();
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
	function onEditingChanged() {
	  if (!CalendarManager.editing && root.island && !root.hovered) {
		root.closeIsland();
	  }
	}

	target: CalendarManager
  }

  Connections {
	function onHasMediaChanged() {
	  if (!MprisManager.hasMedia && root.island && !root.hovered) {
		root.closeIsland();
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
	  root.overriden = root.island;
	}
  }

  Timer {
	id: islandTimer

	interval: 3000
	repeat: false
	running: false

	onTriggered: root.closeIsland()
  }

  Component {
	id: island

	Item {
	  id: islandRoot

	  readonly property var pageComponents: ({
											   "mpris": mprisToast,
											   "calendar": calendarPage
											 })
	  readonly property var pages: MprisManager.hasMedia ? ["mpris", "calendar"] : ["calendar"]

	  function scroll(step) {
		const next = swipe.currentIndex + step;
		if (next < 0 || next >= swipe.count || wheelCooldown.running) {
		  return;
		}
		root.islandPage = next;
		wheelCooldown.restart();
	  }

	  Binding {
		property: "islandHeight"
		target: root
		value: swipe.currentItem ? swipe.currentItem.implicitHeight : root.mprisHeight
	  }

	  Binding {
		property: "islandWidth"
		target: root
		value: swipe.currentItem && swipe.currentItem.implicitWidth > 0 ? swipe.currentItem.implicitWidth :
																		  root.mprisWidth
	  }

	  Connections {
		function onIslandPageChanged() {
		  swipe.setCurrentIndex(root.islandPage);
		}

		target: root
	  }

	  // Thumb (horizontal) wheel only. Qt Wayland reports Hyprland axis events
	  // as TouchPad, not Mouse, so don't filter on device.
	  WheelHandler {
		acceptedDevices: PointerDevice.AllDevices
		orientation: Qt.Horizontal

		onWheel: event => {
		  if (event.angleDelta.x !== 0) {
			islandRoot.scroll(event.angleDelta.x < 0 ? 1 : -1);
		  }
		}
	  }

	  Timer {
		id: wheelCooldown

		interval: 300
	  }

	  SwipeView {
		id: swipe

		anchors.fill: parent
		clip: true
		hoverEnabled: false
		interactive: false

		Component.onCompleted: swipe.setCurrentIndex(root.islandPage)
		onCurrentIndexChanged: root.islandPage = swipe.currentIndex

		Repeater {
		  model: islandRoot.pages

		  Loader {
			required property string modelData

			sourceComponent: islandRoot.pageComponents[modelData]
		  }
		}
	  }

	  Row {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 2
		spacing: 4
		visible: swipe.count > 1

		Repeater {
		  model: swipe.count

		  Rectangle {
			required property int index

			color: Colors.text
			height: 3
			opacity: index === swipe.currentIndex ? 0.9 : 0.3
			radius: 1.5
			width: index === swipe.currentIndex ? 12 : 3

			Behavior on opacity {
			  NumberAnimation {
				duration: 200
			  }
			}
			Behavior on width {
			  NumberAnimation {
				duration: 200
				easing.type: Easing.OutCubic
			  }
			}
		  }
		}
	  }
	}
  }

  Component {
	id: calendarPage

	CalendarPage {}
  }

  Component {
	id: time

	StyledText {
	  property string component: "time"

	  color: Colors.text
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
		color: Colors.surface0
		radius: 9

		anchors {
		  fill: parent
		  margins: notificationRoot.outerMargin
		}

		RowLayout {
		  Rectangle {
			Layout.margins: notificationRoot.innerMargin
			color: Colors.surface1
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

	  readonly property double artSize: root.mprisHeight - mprisToastRoot.margin * 2
	  readonly property double margin: 10
	  property int pendingButton: Qt.NoButton
	  readonly property var times: mprisToastRoot.trackInfo
								   ? mprisToastRoot.trackInfo["timeString"].split("/") : []
	  property var trackInfo: MprisManager.getTrackInfo()

	  implicitHeight: root.mprisHeight
	  implicitWidth: root.mprisWidth

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

	  RowLayout {
		spacing: 12

		anchors {
		  fill: parent
		  margins: mprisToastRoot.margin
		}

		Rectangle {
		  id: art

		  Layout.preferredHeight: mprisToastRoot.artSize
		  Layout.preferredWidth: mprisToastRoot.artSize
		  clip: true
		  color: Colors.surface1
		  radius: 10

		  Rectangle {
			id: artMask

			anchors.fill: parent
			layer.enabled: true
			radius: art.radius
			visible: false
		  }

		  StyledText {
			anchors.centerIn: parent
			color: Colors.overlay1
			fontSize: 18
			text: "󰝚"
			visible: !cover.source || cover.status !== Image.Ready
		  }

		  IconImage {
			id: cover

			anchors.fill: parent
			layer.enabled: true
			opacity: MprisManager.isPlaying ? 1 : 0.35
			source: mprisToastRoot.trackInfo ? mprisToastRoot.trackInfo["albumArt"] : ""

			layer.effect: MultiEffect {
			  maskEnabled: true
			  maskSource: artMask
			}
			Behavior on opacity {
			  NumberAnimation {
				duration: 200
			  }
			}
		  }

		  StyledText {
			anchors.centerIn: parent
			color: Colors.text
			fontSize: 16
			opacity: MprisManager.isPlaying ? 0 : 1
			text: "󰐊"

			Behavior on opacity {
			  NumberAnimation {
				duration: 200
			  }
			}
		  }
		}

		ColumnLayout {
		  Layout.fillHeight: true
		  Layout.fillWidth: true
		  spacing: 2

		  StyledText {
			Layout.fillWidth: true
			color: Colors.text
			fontSize: 12
			fontWeight: 7
			text: mprisToastRoot.trackInfo ? mprisToastRoot.trackInfo["name"] : ""
		  }

		  StyledText {
			Layout.fillWidth: true
			color: Colors.subtext0
			fontSize: 9
			fontWeight: 5
			text: mprisToastRoot.trackInfo ? (mprisToastRoot.trackInfo["artist"]
											  || mprisToastRoot.trackInfo["album"] || "") : ""
		  }

		  Item {
			Layout.fillHeight: true
		  }

		  RowLayout {
			Layout.fillWidth: true
			spacing: 8

			StyledText {
			  color: Colors.overlay1
			  fontSize: 8
			  fontWeight: 5
			  text: mprisToastRoot.times.length === 2 ? mprisToastRoot.times[0] : ""
			  visible: text.length > 0
			}

			// Android-style wavy progress: the played part is a moving sine wave
			// in the Nix logo's blues, the rest a flat line. Flattens when paused.
			Canvas {
			  id: wave

			  property double amplitude: MprisManager.isPlaying ? 2.5 : 0
			  property double phase: 0
			  property double progress: mprisToastRoot.trackInfo ? mprisToastRoot.trackInfo["lengthPercent"] :
																   0

			  Layout.fillWidth: true
			  implicitHeight: 12

			  Behavior on amplitude {
				NumberAnimation {
				  duration: 300
				}
			  }
			  NumberAnimation on phase {
				duration: 1200
				from: 0
				loops: Animation.Infinite
				running: MprisManager.isPlaying && mprisToastRoot.visible
				to: 2 * Math.PI
			  }
			  Behavior on progress {
				NumberAnimation {
				  duration: 400
				}
			  }

			  onAmplitudeChanged: wave.requestPaint()
			  onPaint: {
				const ctx = wave.getContext("2d");
				const w = wave.width;
				const mid = wave.height / 2;
				const head = Math.max(0, Math.min(w, w * wave.progress));
				ctx.reset();
				ctx.lineWidth = 2;
				ctx.lineCap = "round";

				ctx.strokeStyle = Colors.surface1;
				ctx.beginPath();
				ctx.moveTo(head, mid);
				ctx.lineTo(w, mid);
				ctx.stroke();

				if (head > 0) {
				  const grad = ctx.createLinearGradient(0, 0, head, 0);
				  grad.addColorStop(0, "#5277c3");
				  grad.addColorStop(1, "#7ebae4");
				  ctx.strokeStyle = grad;
				  ctx.beginPath();
				  for (let x = 0; x <= head; x += 1) {
					const y = mid + Math.sin(x / 12 * 2 * Math.PI + wave.phase) * wave.amplitude;
					if (x === 0) {
					  ctx.moveTo(x, y);
					} else {
					  ctx.lineTo(x, y);
					}
				  }
				  ctx.stroke();
				}

				ctx.fillStyle = "#7ebae4";
				ctx.beginPath();
				ctx.arc(head, mid, 2.5, 0, 2 * Math.PI);
				ctx.fill();
			  }
			  onPhaseChanged: wave.requestPaint()
			  onProgressChanged: wave.requestPaint()
			  onWidthChanged: wave.requestPaint()
			}

			StyledText {
			  color: Colors.overlay1
			  fontSize: 8
			  fontWeight: 5
			  text: mprisToastRoot.times.length > 0 ? mprisToastRoot.times[mprisToastRoot.times.length - 1] :
													  ""
			  visible: text.length > 0
			}
		  }
		}
	  }
	}
  }
}
