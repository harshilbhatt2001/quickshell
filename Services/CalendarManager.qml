pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Google Calendar through gcalcli (`gcalcli agenda --tsv`, `add`, `edit`,
// `delete`). gcalcli owns the OAuth dance; run `gcalcli init` once. Without
// it `available` stays false and the calendar is just a calendar.
Singleton {
  id: root

  property bool _stale: false
  // Any day inside the month being shown; the fetch window is that month
  // plus one either side so paging to a neighbouring month never waits.
  property date anchor: new Date()
  property bool available: false
  property bool busy: agendaProc.running || mutateProc.running
  // Writable calendars, primary first.
  property var calendars: []
  // Pins the island open and grants the bar keyboard focus.
  property bool editing: false
  // [{ start: Date, end: Date, allDay: bool, title: string, calendar: string }]
  // sorted by start. All-day `end` is exclusive, as Google reports it.
  property var events: []
  property var excludedCalendars: ["Makerspace Delft Bookings", "Makerspace Delft Events",
	"Premier League"]
  readonly property date rangeEnd: new Date(root.anchor.getFullYear(), root.anchor.getMonth() + 2,
											1)

  readonly property date rangeStart: new Date(root.anchor.getFullYear(), root.anchor.getMonth() - 1,
											  1)

  function _minutes(start, end) {
	return Math.max(1, Math.round((end - start) / 60000));
  }

  function _parse(text) {
	const lines = text.split("\n").filter(l => l.length > 0);
	// gcalcli prints a header even for an empty agenda, so no output at all
	// means it failed; keep whatever we last fetched.
	if (lines.length === 0) {
	  return;
	}

	const columns = lines.shift().split("\t");
	const col = name => columns.indexOf(name);
	const iStartDate = col("start_date");
	const iStartTime = col("start_time");
	const iEndDate = col("end_date");
	const iEndTime = col("end_time");
	const iTitle = col("title");
	const iCalendar = col("calendar");

	const parsed = [];
	for (const line of lines) {
	  const f = line.split("\t");
	  if (f.length <= Math.max(iTitle, iCalendar)) {
		continue;
	  }
	  if (root.excludedCalendars.includes(f[iCalendar])) {
		continue;
	  }
	  parsed.push({
					"start": root._toDate(f[iStartDate], f[iStartTime]),
					"end": root._toDate(f[iEndDate], f[iEndTime]),
					"allDay": !f[iStartTime],
					"title": f[iTitle].replace(/\\n/g, " "),
					"calendar": f[iCalendar]
				  });
	}
	parsed.sort((a, b) => a.start - b.start);
	root.events = parsed;
  }

  function _run(script, args) {
	mutateProc.command = ["sh", "-c", script, "gcalcli"].concat(args);
	mutateProc.running = true;
  }

  function _toDate(dateStr, timeStr) {
	const [y, m, d] = dateStr.split("-").map(Number);
	const [hh, mm] = (timeStr || "0:0").split(":").map(Number);
	return new Date(y, m - 1, d, hh, mm);
  }

  function _when(d) {
	return root._ymd(d) + " " + Qt.formatTime(d, "HH:mm");
  }

  function _ymd(d) {
	return Qt.formatDate(d, "yyyy-MM-dd");
  }

  function addEvent(calendar, title, start, end, allDay) {
	if (allDay) {
	  root._run(
			"exec gcalcli --calendar \"$1\" add --noprompt --allday --title \"$2\" --when \"$3\" --duration \"$4\"",
			[calendar, title, root._ymd(start), String(Math.max(1, Math.round((end - start) / 86400000)))]);
	} else {
	  root._run(
			"exec gcalcli --calendar \"$1\" add --noprompt --title \"$2\" --when \"$3\" --duration \"$4\"",
			[calendar, title, root._when(start), String(root._minutes(start, end))]);
	}
  }

  function deleteEvent(event) {
	root._run("exec gcalcli --calendar \"$1\" delete --iamaexpert \"$2\" \"$3\" \"$4\"",
			  [event.calendar, event.title, root._when(event.start), root._when(event.end)]);
  }

  // Title-only changes go through `gcalcli edit`, answering its prompts on
  // stdin ([t]itle, [s]ave). Time changes are delete + add, because gcalcli
  // 4.5's [w]hen and len[g]th prompts crash (TypeError on all_day).
  function editEvent(event, title, start, end) {
	const sameTime = event.start.getTime() === start.getTime() && event.end.getTime() === end.getTime(
			);


	if (sameTime) {
	  root._run("printf '%s' \"$5\" | exec gcalcli --calendar \"$1\" edit \"$2\" \"$3\" \"$4\"",
				[event.calendar, event.title, root._when(event.start), root._when(event.end), "t\n" + title
				 + "\ns\n"]);
	  return;
	}
	const allDayFlag = event.allDay ? "--allday " : "";
	root._run(
		  "gcalcli --calendar \"$1\" delete --iamaexpert \"$2\" \"$3\" \"$4\" && exec gcalcli --calendar \"$1\" add --noprompt "
		  + allDayFlag + "--title \"$5\" --when \"$6\" --duration \"$7\"", [event.calendar, event.title,
																			root._when(event.start), root._when(event.end), title, event.allDay ? root._ymd(
																																					start) : root._when(start), String(event.allDay ? Math.max(1,
																																																			   Math.round((end - start) / 86400000)) :
																																																	  root._minutes(start, end))]);
  }

  // Events touching the calendar day containing `day`, in start order.
  function eventsOn(day) {
	const dayStart = new Date(day.getFullYear(), day.getMonth(), day.getDate());
	const dayEnd = new Date(day.getFullYear(), day.getMonth(), day.getDate() + 1);
	return root.events.filter(e => e.start < dayEnd && e.end > dayStart);
  }

  function hasEventsOn(day) {
	return root.eventsOn(day).length > 0;
  }

  function refresh() {
	if (agendaProc.running) {
	  root._stale = true;
	  return;
	}
	agendaProc.running = true;
  }

  onRangeStartChanged: root.refresh()

  Process {
	id: agendaProc

	// `command -v` first so a machine without gcalcli fails quietly (exit 3)
	// instead of logging "command not found" every five minutes.
	command: ["sh", "-c",
	  "command -v gcalcli >/dev/null 2>&1 || exit 3; exec gcalcli agenda --tsv --details calendar \"$1\" \"$2\"",
	  "gcalcli", root._ymd(root.rangeStart), root._ymd(root.rangeEnd)]
	running: true

	stdout: StdioCollector {
	  onStreamFinished: root._parse(this.text)
	}

	onExited: exitCode => {
	  root.available = exitCode === 0;
	  if (root.available && root.calendars.length === 0) {
		listProc.running = true;
	  }
	  if (root._stale) {
		root._stale = false;
		agendaProc.running = true;
	  }
	}
  }

  Process {
	id: listProc

	command: ["gcalcli", "--nocolor", "list"]

	stdout: StdioCollector {
	  onStreamFinished: {
		const names = [];
		for (const line of this.text.split("\n")) {
		  const m = line.match(/^\s*(owner|writer)\s+(.+?)\s*$/);
		  if (m) {
			names.push(m[2]);
		  }
		}
		root.calendars = names;
	  }
	}
  }

  Process {
	id: mutateProc

	onExited: root.refresh()
  }

  Timer {
	interval: 5 * 60 * 1000
	repeat: true
	running: true

	onTriggered: root.refresh()
  }
}
