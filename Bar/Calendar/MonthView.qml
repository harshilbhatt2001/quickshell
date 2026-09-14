pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

ColumnLayout {
  id: root

  property date anchor: new Date()
  readonly property double cellHeight: 58
  readonly property double cellWidth: root.width / 7
  // JS weekday (Sunday = 0) the grid starts on.
  readonly property int firstWeekday: Qt.locale().firstDayOfWeek % 7
  readonly property int inlineEvents: 2
  readonly property int listedEvents: 5
  property date selected: new Date()
  readonly property var selectedEvents: CalendarManager.eventsOn(root.selected)
  readonly property string title: Qt.formatDate(root.anchor, "MMMM yyyy")
  readonly property date today: new Date()

  signal anchorRequested(date day)
  signal createRequested(date start)
  signal eventRequested(var event)
  signal selectRequested(date day)

  function dayAt(index) {
	const first = new Date(root.anchor.getFullYear(), root.anchor.getMonth(), 1);
	const offset = (first.getDay() - root.firstWeekday + 7) % 7;
	return new Date(first.getFullYear(), first.getMonth(), 1 - offset + index);
  }

  function sameDay(a, b) {
	return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate()
		=== b.getDate();
  }

  function step(n) {
	root.anchorRequested(new Date(root.anchor.getFullYear(), root.anchor.getMonth() + n, 1));
  }

  spacing: 4

  Row {
	Layout.alignment: Qt.AlignHCenter

	Repeater {
	  model: 7

	  StyledText {
		required property int index

		color: Colors.surface1
		fontSize: 10
		height: 22
		horizontalAlignment: Qt.AlignHCenter
		text: {
		  const js = (root.firstWeekday + index) % 7;
		  return Qt.locale().dayName(js === 0 ? 7 : js, Locale.ShortFormat).slice(0, 2);
		}
		verticalAlignment: Qt.AlignVCenter
		width: root.cellWidth
	  }
	}
  }

  Grid {
	Layout.alignment: Qt.AlignHCenter
	columns: 7

	Repeater {
	  model: 42

	  Item {
		id: cell

		readonly property date day: root.dayAt(index)
		readonly property var events: CalendarManager.eventsOn(cell.day)
		readonly property bool inMonth: cell.day.getMonth() === root.anchor.getMonth()
		required property int index
		readonly property bool isSelected: root.sameDay(cell.day, root.selected)
		readonly property bool isToday: root.sameDay(cell.day, root.today)

		height: root.cellHeight
		opacity: cell.inMonth ? 1 : 0.35
		width: root.cellWidth

		HoverHandler {
		  id: cellHover
		}

		TapHandler {
		  onDoubleTapped: {
			if (CalendarManager.available) {
			  root.createRequested(new Date(cell.day.getFullYear(), cell.day.getMonth(), cell.day.getDate(), 9,
											0));
			}
		  }
		  onTapped: root.selectRequested(cell.day)
		}

		Rectangle {
		  anchors.fill: parent
		  anchors.margins: 2
		  border.color: Colors.base
		  border.width: cell.isSelected ? 1 : 0
		  color: cellHover.hovered ? Qt.alpha(Colors.base, 0.08) : "transparent"
		  radius: 8

		  Behavior on color {
			ColorAnimation {
			  duration: 120
			}
		  }
		}

		Rectangle {
		  id: pill

		  anchors.horizontalCenter: parent.horizontalCenter
		  color: cell.isToday ? Colors.base : "transparent"
		  height: 22
		  radius: 11
		  width: 28
		  y: 4

		  StyledText {
			anchors.centerIn: parent
			color: cell.isToday ? Colors.mauve : Colors.base
			fontSize: 11
			fontWeight: cell.isToday || cell.isSelected ? 8 : 5
			text: cell.day.getDate()
		  }
		}

		Column {
		  anchors.left: parent.left
		  anchors.leftMargin: 6
		  anchors.right: parent.right
		  anchors.rightMargin: 6
		  anchors.top: pill.bottom
		  anchors.topMargin: 2
		  spacing: 1

		  Repeater {
			model: cell.events.slice(0, root.inlineEvents)

			StyledText {
			  required property int index
			  required property var modelData

			  color: Colors.base
			  fontSize: 7
			  fontWeight: 6
			  text: {
				const extra = cell.events.length - root.inlineEvents;
				const more = index === root.inlineEvents - 1 && extra > 0 ? "  +" + extra : "";
				return "· " + modelData.title + more;
			  }
			  width: parent.width
			}
		  }
		}
	  }
	}
  }

  Rectangle {
	Layout.fillWidth: true
	Layout.topMargin: 6
	color: Colors.base
	implicitHeight: root.listedEvents * 24 + 12
	radius: 10
	visible: CalendarManager.available

	Column {
	  anchors.fill: parent
	  anchors.margins: 6
	  spacing: 0

	  Repeater {
		model: root.selectedEvents.slice(0, root.listedEvents)

		Rectangle {
		  id: eventRow

		  required property int index
		  required property var modelData

		  color: rowHover.hovered ? Colors.surface0 : "transparent"
		  height: 24
		  radius: 6
		  width: parent.width

		  Behavior on color {
			ColorAnimation {
			  duration: 120
			}
		  }

		  HoverHandler {
			id: rowHover
		  }

		  TapHandler {
			onTapped: root.eventRequested(eventRow.modelData)
		  }

		  RowLayout {
			anchors.fill: parent
			spacing: 10

			StyledText {
			  Layout.leftMargin: 6
			  Layout.preferredWidth: 96
			  color: Colors.subtext0
			  fontSize: 10
			  fontWeight: 5
			  text: eventRow.modelData.allDay ? "all day" : Qt.formatTime(eventRow.modelData.start, "HH:mm")
												+ " – " + Qt.formatTime(eventRow.modelData.end, "HH:mm")
			  verticalAlignment: Qt.AlignVCenter
			}

			StyledText {
			  Layout.fillWidth: true
			  Layout.rightMargin: 6
			  color: Colors.text
			  fontSize: 10
			  fontWeight: 6
			  text: {
				const extra = root.selectedEvents.length - root.listedEvents;
				if (eventRow.index === root.listedEvents - 1 && extra > 0) {
				  return eventRow.modelData.title + "  +" + extra;
				}
				return eventRow.modelData.title;
			  }
			  verticalAlignment: Qt.AlignVCenter
			}

			StyledText {
			  Layout.rightMargin: 8
			  color: Colors.overlay0
			  fontSize: 9
			  fontWeight: 5
			  text: eventRow.modelData.calendar.indexOf("@") !== -1 ? "" : eventRow.modelData.calendar
			  verticalAlignment: Qt.AlignVCenter
			}
		  }
		}
	  }

	  StyledText {
		color: Colors.overlay0
		fontSize: 10
		fontWeight: 5
		height: 24
		leftPadding: 10
		text: "No events"
		verticalAlignment: Qt.AlignVCenter
		visible: root.selectedEvents.length === 0
	  }
	}
  }
}
