pragma ComponentBehavior: Bound
import QtQuick

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

// Time grid for 1, 3 or 7 days. Week (7) snaps to the locale's week start.
Item {
  id: root

  property date anchor: new Date()
  readonly property var dayList: {
	const list = [];
	for (let i = 0; i < root.days; i++) {
	  list.push(new Date(root.firstDay.getFullYear(), root.firstDay.getMonth(), root.firstDay.getDate()
						 + i));
	}
	return list;
  }
  property int days: 3
  readonly property date firstDay: {
	const d = new Date(root.anchor.getFullYear(), root.anchor.getMonth(), root.anchor.getDate());
	if (root.days === 7) {
	  const jsFirst = Qt.locale().firstDayOfWeek % 7;
	  d.setDate(d.getDate() - ((d.getDay() - jsFirst + 7) % 7));
	}
	return d;
  }
  readonly property double gutter: 30
  readonly property double headerHeight: 30
  // Hours shown: 8–20 unless an event falls outside that.
  readonly property int hourEnd: {
	let h = 20;
	for (const e of root.visibleEvents) {
	  if (!e.allDay) {
		h = Math.max(h, Math.min(24, Math.ceil(e.end.getHours() + e.end.getMinutes() / 60)));
	  }
	}
	return h;
  }
  readonly property int hourStart: {
	let h = 8;
	for (const e of root.visibleEvents) {
	  if (!e.allDay) {
		h = Math.min(h, e.start.getHours());
	  }
	}
	return h;
  }
  property date now: new Date()
  readonly property double pxPerHour: 16
  property date selected: new Date()
  readonly property string title: {
	if (root.days === 1) {
	  return Qt.formatDate(root.firstDay, "dddd d MMMM");
	}
	const last = root.dayList[root.days - 1];
	const sameMonth = last.getMonth() === root.firstDay.getMonth();
	return Qt.formatDate(root.firstDay, sameMonth ? "d" : "d MMM") + " – " + Qt.formatDate(last,
																						   "d MMM");
  }
  readonly property var visibleEvents: {
	const start = root.firstDay;
	const end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + root.days);
	return CalendarManager.events.filter(e => e.start < end && e.end > start);
  }

  signal anchorRequested(date day)
  signal createRequested(date start)
  signal eventRequested(var event)
  signal selectRequested(date day)

  // Lays out one day's timed events into side-by-side lanes where they overlap.
  // Returns [{event, lane, lanes}].
  function layoutDay(day) {
	const events = CalendarManager.eventsOn(day).filter(e => !e.allDay);
	const laneEnds = [];
	const placed = [];
	let cluster = [];
	let clusterEnd = null;

	const flush = () => {
	  const lanes = laneEnds.length;
	  for (const p of cluster) {
		p.lanes = lanes;
	  }
	  placed.push(...cluster);
	  cluster = [];
	  laneEnds.length = 0;
	};

	for (const e of events) {
	  if (clusterEnd !== null && e.start >= clusterEnd) {
		flush();
	  }
	  let lane = laneEnds.findIndex(end => end <= e.start);
	  if (lane === -1) {
		lane = laneEnds.length;
	  }
	  laneEnds[lane] = e.end;
	  cluster.push({
					 "event": e,
					 "lane": lane,
					 "lanes": 1
				   });
	  clusterEnd = clusterEnd === null || e.end > clusterEnd ? e.end : clusterEnd;
	}
	flush();
	return placed;
  }

  function sameDay(a, b) {
	return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate()
		=== b.getDate();
  }

  function step(n) {
	root.anchorRequested(new Date(root.firstDay.getFullYear(), root.firstDay.getMonth(),
								  root.firstDay.getDate() + n * root.days));
  }

  function yFor(d, day) {
	const dayStart = new Date(day.getFullYear(), day.getMonth(), day.getDate(), root.hourStart);
	return Math.max(0, (d - dayStart) / 3600000 * root.pxPerHour);
  }

  implicitHeight: root.headerHeight + (root.hourEnd - root.hourStart) * root.pxPerHour + 4

  Timer {
	interval: 60000
	repeat: true
	running: true

	onTriggered: root.now = new Date()
  }

  Row {
	id: columns

	readonly property double columnWidth: (root.width - root.gutter) / root.days

	anchors.fill: parent
	anchors.leftMargin: root.gutter

	Repeater {
	  model: root.dayList

	  Item {
		id: column

		readonly property var allDay: CalendarManager.eventsOn(column.day).filter(e => e.allDay)
		readonly property date day: column.modelData
		readonly property bool isToday: root.sameDay(column.day, root.now)
		required property var modelData
		readonly property var placed: root.layoutDay(column.day)

		height: parent.height
		width: columns.columnWidth

		TapHandler {
		  onTapped: eventPoint => {
			root.selectRequested(column.day);
			const p = grid.mapFromItem(column, eventPoint.position);
			const hit = grid.childAt(p.x, p.y);
			if (hit && hit.objectName === "event") {
			  root.eventRequested(hit.modelData.event);
			} else if (p.y >= 0 && CalendarManager.available) {
			  const halfHours = Math.floor(p.y / root.pxPerHour * 2);
			  root.createRequested(new Date(column.day.getFullYear(), column.day.getMonth(),
											column.day.getDate(), root.hourStart, halfHours * 30));
			}
		  }
		}

		Rectangle {
		  anchors.horizontalCenter: parent.horizontalCenter
		  color: column.isToday ? Colors.base : "transparent"
		  height: 18
		  radius: 9
		  width: Math.min(column.width - 4, dayLabel.implicitWidth + 12)
		  y: 0

		  StyledText {
			id: dayLabel

			anchors.centerIn: parent
			color: column.isToday ? Colors.mauve : Colors.base
			fontSize: 8
			fontWeight: column.isToday ? 8 : 6
			text: (root.days === 7 ? Qt.formatDate(column.day, "ddd").slice(0, 2) : Qt.formatDate(column.day,
																								  "ddd")) + " " + column.day.getDate()
		  }
		}

		Rectangle {
		  anchors.left: parent.left
		  anchors.right: parent.right
		  anchors.rightMargin: 2
		  color: Colors.base
		  height: 10
		  opacity: 0.85
		  radius: 3
		  visible: column.allDay.length > 0
		  y: 19

		  StyledText {
			anchors.fill: parent
			anchors.leftMargin: 3
			anchors.rightMargin: 3
			color: Colors.mauve
			fontSize: 6
			fontWeight: 6
			text: column.allDay.length > 1 ? column.allDay[0].title + " +" + (column.allDay.length - 1) : (
											   column.allDay[0] ? column.allDay[0].title : "")
			verticalAlignment: Qt.AlignVCenter
		  }
		}

		Item {
		  id: grid

		  anchors.left: parent.left
		  anchors.right: parent.right
		  clip: true
		  height: (root.hourEnd - root.hourStart) * root.pxPerHour
		  y: root.headerHeight

		  Rectangle {
			anchors.left: parent.left
			color: Colors.base
			height: parent.height
			opacity: 0.15
			width: 1
		  }

		  Repeater {
			model: root.hourEnd - root.hourStart

			Rectangle {
			  required property int index

			  color: Colors.base
			  height: 1
			  opacity: 0.12
			  width: parent.width
			  y: index * root.pxPerHour
			}
		  }

		  Repeater {
			model: column.placed

			Rectangle {
			  id: block

			  readonly property double laneWidth: (grid.width - 3) / block.modelData.lanes
			  required property var modelData

			  color: block.hovered ? Colors.surface0 : Colors.base
			  height: Math.max(8, root.yFor(block.modelData.event.end, column.day) - block.y - 1)
			  objectName: "event"
			  radius: 3
			  width: block.laneWidth - 1
			  x: 2 + block.modelData.lane * block.laneWidth
			  y: root.yFor(block.modelData.event.start, column.day)

			  HoverHandler {
				id: blockHover
			  }

			  StyledText {
				anchors.fill: parent
				anchors.leftMargin: 3
				anchors.rightMargin: 2
				anchors.topMargin: 1
				color: Colors.text
				fontSize: 6
				fontWeight: 6
				maximumLineCount: Math.max(1, Math.floor((block.height - 2) / 10))
				text: block.modelData.event.title
				wrapMode: Text.Wrap
			  }
			}
		  }

		  Rectangle {
			color: Colors.red
			height: 1
			visible: column.isToday && root.now.getHours() >= root.hourStart && root.now.getHours()
					 < root.hourEnd
			width: parent.width
			y: root.yFor(root.now, column.day)

			Rectangle {
			  anchors.verticalCenter: parent.verticalCenter
			  color: Colors.red
			  height: 5
			  radius: 2.5
			  width: 5
			  x: -2
			}
		  }
		}
	  }
	}
  }

  Repeater {
	model: root.hourEnd - root.hourStart

	StyledText {
	  required property int index

	  color: Colors.base
	  fontSize: 6
	  fontWeight: 5
	  horizontalAlignment: Qt.AlignRight
	  opacity: 0.6
	  text: (root.hourStart + index < 10 ? "0" : "") + (root.hourStart + index) + ":00"
	  width: root.gutter - 4
	  y: root.headerHeight + index * root.pxPerHour - 4
	}
  }
}
