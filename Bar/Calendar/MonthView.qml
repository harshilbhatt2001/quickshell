pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

ColumnLayout {
  id: root

  property date anchor: new Date()
  readonly property double cellHeight: 28
  readonly property double cellWidth: root.width / 7
  // JS weekday (Sunday = 0) the grid starts on.
  readonly property int firstWeekday: Qt.locale().firstDayOfWeek % 7
  readonly property int listedEvents: 4
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

  spacing: 2

  Row {
	Layout.alignment: Qt.AlignHCenter

	Repeater {
	  model: 7

	  StyledText {
		required property int index

		color: Colors.surface1
		fontSize: 9
		height: 18
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
		readonly property bool hasEvents: CalendarManager.hasEventsOn(cell.day)
		readonly property bool inMonth: cell.day.getMonth() === root.anchor.getMonth()
		required property int index
		readonly property bool isSelected: root.sameDay(cell.day, root.selected)
		readonly property bool isToday: root.sameDay(cell.day, root.today)

		height: root.cellHeight
		width: root.cellWidth

		HoverHandler {
		  id: cellHover
		}

		TapHandler {
		  onTapped: root.selectRequested(cell.day)
		}

		Rectangle {
		  anchors.centerIn: parent
		  border.color: Colors.base
		  border.width: cell.isSelected && !cell.isToday ? 1 : 0
		  color: cell.isToday ? Colors.base : (cellHover.hovered ? Qt.alpha(Colors.base, 0.12) :
																   "transparent")
		  height: 22
		  radius: 11
		  width: 30

		  Behavior on color {
			ColorAnimation {
			  duration: 120
			}
		  }

		  StyledText {
			anchors.centerIn: parent
			color: cell.isToday ? Colors.mauve : Colors.base
			fontSize: 10
			fontWeight: cell.isToday || cell.isSelected ? 8 : 5
			opacity: cell.inMonth ? 1 : 0.35
			text: cell.day.getDate()
		  }
		}

		Rectangle {
		  anchors.bottom: parent.bottom
		  anchors.bottomMargin: 1
		  anchors.horizontalCenter: parent.horizontalCenter
		  color: Colors.base
		  height: 3
		  opacity: cell.hasEvents ? (cell.inMonth ? 1 : 0.35) : 0
		  radius: 1.5
		  width: 3

		  Behavior on opacity {
			NumberAnimation {
			  duration: 120
			}
		  }
		}
	  }
	}
  }

  Rectangle {
	Layout.fillWidth: true
	Layout.topMargin: 4
	color: Colors.base
	implicitHeight: root.listedEvents * 20 + 8
	radius: 8
	visible: CalendarManager.available

	Column {
	  anchors.fill: parent
	  anchors.margins: 4
	  spacing: 0

	  Repeater {
		model: root.selectedEvents.slice(0, root.listedEvents)

		Rectangle {
		  id: eventRow

		  required property int index
		  required property var modelData

		  color: rowHover.hovered ? Colors.surface0 : "transparent"
		  height: 20
		  radius: 5
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
			spacing: 8

			StyledText {
			  Layout.leftMargin: 4
			  Layout.preferredWidth: 50
			  color: Colors.subtext0
			  fontSize: 9
			  fontWeight: 5
			  text: eventRow.modelData.allDay ? "all day" : Qt.formatTime(eventRow.modelData.start, "HH:mm")
			  verticalAlignment: Qt.AlignVCenter
			}

			StyledText {
			  Layout.fillWidth: true
			  Layout.rightMargin: 4
			  color: Colors.text
			  fontSize: 9
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
		  }
		}
	  }

	  StyledText {
		color: Colors.overlay0
		fontSize: 9
		fontWeight: 5
		height: 20
		leftPadding: 8
		text: "No events"
		verticalAlignment: Qt.AlignVCenter
		visible: root.selectedEvents.length === 0
	  }
	}
  }
}
