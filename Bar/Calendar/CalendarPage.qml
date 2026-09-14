pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

// Header + one calendar view, or the event editor in its place. A view has
// `anchor`, `selected`, `title`, `step(n)` and the `anchorRequested` /
// `selectRequested` / `eventRequested` / `createRequested` signals — see
// MonthView and DaysView. Register new views in `views`.
Item {
  id: root

  property date anchor: new Date()
  property date createStart: new Date()
  property var editingEvent: null
  property bool editorOpen: false
  property double margin: 8
  property date selected: new Date()
  property string view: "month"
  readonly property var viewOrder: ["day", "3day", "week", "month"]
  readonly property var views: ({
								  "day": dayView,
								  "3day": threeDayView,
								  "week": weekView,
								  "month": monthView
								})

  function cycleView() {
	root.view = root.viewOrder[(root.viewOrder.indexOf(root.view) + 1) % root.viewOrder.length];
  }

  function openCreate(start) {
	root.createStart = start;
	root.editingEvent = null;
	root.editorOpen = true;
  }

  function openEvent(event) {
	root.editingEvent = event;
	root.editorOpen = true;
  }

  implicitHeight: column.implicitHeight + root.margin * 2
  implicitWidth: 460

  onAnchorChanged: CalendarManager.anchor = root.anchor

  // Vertical wheel steps the period; the island owns the horizontal wheel.
  WheelHandler {
	acceptedDevices: PointerDevice.AllDevices
	enabled: !root.editorOpen
	orientation: Qt.Vertical

	onWheel: event => {
	  if (!wheelCooldown.running && viewLoader.item) {
		viewLoader.item.step(event.angleDelta.y < 0 ? 1 : -1);
		wheelCooldown.restart();
	  }
	}
  }

  Timer {
	id: wheelCooldown

	interval: 150
  }

  ColumnLayout {
	id: column

	spacing: 6

	anchors {
	  fill: parent
	  margins: root.margin
	}

	RowLayout {
	  Layout.fillWidth: true
	  spacing: 2

	  HeaderButton {
		text: "󰅁"

		onClicked: viewLoader.item.step(-1)
	  }

	  HeaderButton {
		Layout.fillWidth: true
		fontSize: 11
		text: root.editorOpen ? (root.editingEvent ? "Edit event" : "New event") : (viewLoader.item
																					? viewLoader.item.title : "")

		onClicked: root.cycleView()
	  }

	  HeaderButton {
		text: "󰅂"

		onClicked: viewLoader.item.step(1)
	  }

	  HeaderButton {
		text: "󰐕"
		visible: CalendarManager.available && !root.editorOpen

		onClicked: {
		  const now = new Date();
		  const s = root.selected;
		  root.openCreate(new Date(s.getFullYear(), s.getMonth(), s.getDate(), now.getHours() + 1, 0));
		}
	  }
	}

	Loader {
	  id: viewLoader

	  Layout.fillWidth: true
	  sourceComponent: root.views[root.view]
	  visible: !root.editorOpen

	  onLoaded: {
		item.anchor = Qt.binding(() => root.anchor);
		item.selected = Qt.binding(() => root.selected);
		item.anchorRequested.connect(d => root.anchor = d);
		item.selectRequested.connect(d => root.selected = d);
		item.eventRequested.connect(e => root.openEvent(e));
		item.createRequested.connect(d => root.openCreate(d));
	  }
	}

	Loader {
	  Layout.fillWidth: true
	  active: root.editorOpen
	  sourceComponent: editor
	  visible: root.editorOpen
	}
  }

  Component {
	id: editor

	EventEditor {
	  event: root.editingEvent
	  start: root.createStart

	  onDone: root.editorOpen = false
	}
  }

  Component {
	id: dayView

	DaysView {
	  days: 1
	}
  }

  Component {
	id: threeDayView

	DaysView {
	  days: 3
	}
  }

  Component {
	id: weekView

	DaysView {
	  days: 7
	}
  }

  Component {
	id: monthView

	MonthView {}
  }

  component HeaderButton: Rectangle {
	id: button

	property alias fontSize: label.fontSize
	property alias text: label.text

	signal clicked

	color: buttonHover.hovered ? Qt.alpha(Colors.base, 0.12) : "transparent"
	implicitHeight: 22
	implicitWidth: Math.max(26, label.implicitWidth + 12)
	radius: 6

	Behavior on color {
	  ColorAnimation {
		duration: 120
	  }
	}

	HoverHandler {
	  id: buttonHover
	}

	TapHandler {
	  onTapped: button.clicked()
	}

	StyledText {
	  id: label

	  anchors.centerIn: parent
	  color: Colors.base
	  fontSize: 11
	}
  }
}
