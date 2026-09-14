pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

// Inline add/edit form. `event` null means a new event starting at `start`.
Rectangle {
  id: root

  property bool allDay: root.event ? root.event.allDay : false
  property int calendarIndex: root.event ? Math.max(0, CalendarManager.calendars.indexOf(
													  root.event.calendar)) : 0
  property date end: root.event ? root.event.end : new Date(root.start.getTime() + 3600000)
  property var event: null
  readonly property bool isNew: root.event === null
  readonly property date parsedEnd: root.parseDateTime(dateField.text, endField.text)
  readonly property date parsedStart: root.parseDateTime(dateField.text, startField.text)
  property date start: new Date()
  readonly property bool valid: titleField.text.trim().length > 0 && !isNaN(root.parsedStart.getTime(
																			  )) && (root.allDay || (!isNaN(root.parsedEnd.getTime()) && root.parsedEnd
																									 > root.parsedStart))

  signal done

  function calendarLabel(name) {
	return !name ? "" : (name.indexOf("@") !== -1 ? "Primary" : name);
  }

  function parseDateTime(dateText, timeText) {
	const d = dateText.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
	const t = root.allDay ? ["", "0", "0"] : timeText.match(/^(\d{1,2}):(\d{2})$/);
	if (!d || !t) {
	  return new Date(NaN);
	}
	return new Date(Number(d[1]), Number(d[2]) - 1, Number(d[3]), Number(t[1]), Number(t[2]));
  }

  function save() {
	if (!root.valid || CalendarManager.busy) {
	  return;
	}
	const title = titleField.text.trim();
	const start = root.parsedStart;
	const end = root.allDay ? new Date(start.getFullYear(), start.getMonth(), start.getDate() + 1) :
							  root.parsedEnd;
	if (root.isNew) {
	  CalendarManager.addEvent(CalendarManager.calendars[root.calendarIndex], title, start, end,
							   root.allDay);
	} else {
	  CalendarManager.editEvent(root.event, title, start, end);
	}
	root.done();
  }

  color: Colors.base
  implicitHeight: column.implicitHeight + 20
  radius: 12

  Component.onCompleted: {
	CalendarManager.editing = true;
	titleField.forceActiveFocus();
  }
  Component.onDestruction: CalendarManager.editing = false
  Keys.onEscapePressed: root.done()

  ColumnLayout {
	id: column

	spacing: 6

	anchors {
	  fill: parent
	  margins: 8
	}

	Field {
	  id: titleField

	  Layout.fillWidth: true
	  fontSize: 13
	  placeholder: "Title"
	  text: root.event ? root.event.title : ""
	}

	RowLayout {
	  Layout.fillWidth: true
	  spacing: 6

	  Field {
		id: dateField

		Layout.preferredWidth: 110
		text: Qt.formatDate(root.start, "yyyy-MM-dd")
	  }

	  Field {
		id: startField

		Layout.preferredWidth: 60
		text: Qt.formatTime(root.start, "HH:mm")
		visible: !root.allDay
	  }

	  StyledText {
		color: Colors.overlay0
		fontSize: 9
		text: "–"
		visible: !root.allDay
	  }

	  Field {
		id: endField

		Layout.preferredWidth: 60
		text: Qt.formatTime(root.end, "HH:mm")
		visible: !root.allDay
	  }

	  Chip {
		active: root.allDay
		enabled: root.isNew
		text: "all day"

		onClicked: root.allDay = !root.allDay
	  }

	  Item {
		Layout.fillWidth: true
	  }

	  Chip {
		enabled: root.isNew && CalendarManager.calendars.length > 1
		text: root.calendarLabel(root.isNew ? CalendarManager.calendars[root.calendarIndex] :
											  root.event.calendar)

		onClicked: root.calendarIndex = (root.calendarIndex + 1) % CalendarManager.calendars.length
	  }
	}

	RowLayout {
	  Layout.fillWidth: true
	  spacing: 6

	  Chip {
		text: "Delete"
		tint: Colors.red
		visible: !root.isNew

		onClicked: {
		  CalendarManager.deleteEvent(root.event);
		  root.done();
		}
	  }

	  Item {
		Layout.fillWidth: true
	  }

	  Chip {
		text: "Cancel"

		onClicked: root.done()
	  }

	  Chip {
		active: true
		enabled: root.valid && !CalendarManager.busy
		text: root.isNew ? "Add" : "Save"

		onClicked: root.save()
	  }
	}
  }

  component Chip: Rectangle {
	id: chip

	property bool active: false
	property alias text: chipLabel.text
	property color tint: Colors.mauve

	signal clicked

	border.color: chip.tint
	border.width: 1
	color: chip.active ? chip.tint : (chipHover.hovered && chip.enabled ? Qt.alpha(chip.tint, 0.15) :
																		  "transparent")
	implicitHeight: 24
	implicitWidth: Math.min(160, chipLabel.implicitWidth + 20)
	opacity: chip.enabled ? 1 : 0.4
	radius: 10

	Behavior on color {
	  ColorAnimation {
		duration: 120
	  }
	}

	HoverHandler {
	  id: chipHover
	}

	TapHandler {
	  enabled: chip.enabled

	  onTapped: chip.clicked()
	}

	StyledText {
	  id: chipLabel

	  anchors.centerIn: parent
	  color: chip.active ? Colors.base : chip.tint
	  elide: Text.ElideRight
	  fontSize: 9
	  fontWeight: 7
	  horizontalAlignment: Qt.AlignHCenter
	  width: Math.min(implicitWidth, 124)
	}
  }
  component Field: Rectangle {
	id: field

	property alias fontSize: input.fontSize
	property string placeholder: ""
	property alias text: input.text

	function forceActiveFocus() {
	  input.forceActiveFocus();
	}

	border.color: input.activeFocus ? Colors.mauve : Colors.surface1
	border.width: 1
	color: Colors.surface0
	implicitHeight: 28
	radius: 7

	Behavior on border.color {
	  ColorAnimation {
		duration: 120
	  }
	}

	StyledText {
	  anchors.fill: input
	  color: Colors.overlay0
	  fontSize: input.fontSize
	  text: field.placeholder
	  verticalAlignment: Qt.AlignVCenter
	  visible: input.text.length === 0
	}

	TextInput {
	  id: input

	  property double fontSize: 10

	  clip: true
	  color: Colors.text
	  font.family: "FiraMono Nerd Font"
	  font.pointSize: input.fontSize
	  font.weight: 600
	  selectedTextColor: Colors.base
	  selectionColor: Colors.mauve
	  verticalAlignment: TextInput.AlignVCenter

	  Keys.onEscapePressed: root.done()
	  Keys.onReturnPressed: root.save()
	  Keys.onTabPressed: input.nextItemInFocusChain().forceActiveFocus()

	  anchors {
		fill: parent
		leftMargin: 7
		rightMargin: 7
	  }
	}
  }
}
