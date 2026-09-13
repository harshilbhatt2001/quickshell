pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Google Calendar events, pulled through gcalcli (`gcalcli --tsv agenda`).
// gcalcli owns the OAuth dance; run `gcalcli init` once to authorise. When it
// isn't installed or hasn't been authorised, `available` stays false and the
// calendar page is just a calendar.
Singleton {
  id: root

  // Any day inside the month the calendar is currently showing. The fetch
  // window is that month plus one month either side, so paging between
  // adjacent months never waits on gcalcli.
  property bool _stale: false
  property date anchor: new Date()
  property bool available: false
  // [{ start: Date, end: Date, allDay: bool, title: string }], sorted by start.
  // For all-day events `end` is exclusive (midnight after the last day), which
  // is how Google reports them.
  property var events: []
  readonly property date rangeEnd: new Date(root.anchor.getFullYear(), root.anchor.getMonth() + 2,
											1)

  readonly property date rangeStart: new Date(root.anchor.getFullYear(), root.anchor.getMonth() - 1,
											  1)

  function _parse(text) {
	const lines = text.split("\n").filter(l => l.length > 0);
	// gcalcli prints a header even for an empty agenda, so no output at all
	// means it failed; keep whatever we last fetched.
	if (lines.length === 0) {
	  return;
	}

	// 4.5+ prints a header row naming the columns; fall back to the default
	// column order for older versions.
	let columns = ["start_date", "start_time", "end_date", "end_time", "title"];
	if (lines[0].indexOf("start_date") !== -1) {
	  columns = lines.shift().split("\t");
	}
	const col = name => columns.indexOf(name);
	const iStartDate = col("start_date");
	const iStartTime = col("start_time");
	const iEndDate = col("end_date");
	const iEndTime = col("end_time");
	const iTitle = col("title");

	const parsed = [];
	for (const line of lines) {
	  const f = line.split("\t");
	  if (f.length <= iTitle) {
		continue;
	  }
	  const allDay = !f[iStartTime];
	  parsed.push({
					"start": root._toDate(f[iStartDate], f[iStartTime]),
					"end": root._toDate(f[iEndDate], f[iEndTime]),
					"allDay": allDay,
					"title": f[iTitle].replace(/\\n/g, " ")
				  });
	}
	parsed.sort((a, b) => a.start - b.start);
	root.events = parsed;
  }

  function _toDate(dateStr, timeStr) {
	const [y, m, d] = dateStr.split("-").map(Number);
	const [hh, mm] = (timeStr || "0:0").split(":").map(Number);
	return new Date(y, m - 1, d, hh, mm);
  }

  function _ymd(d) {
	const pad = n => (n < 10 ? "0" : "") + n;
	return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
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
	  "command -v gcalcli >/dev/null 2>&1 || exit 3; exec gcalcli --tsv agenda \"$1\" \"$2\"",
	  "gcalcli", root._ymd(root.rangeStart), root._ymd(root.rangeEnd)]
	running: true

	stdout: StdioCollector {
	  onStreamFinished: root._parse(this.text)
	}

	onExited: exitCode => {
	  root.available = exitCode === 0;
	  if (root._stale) {
		root._stale = false;
		agendaProc.running = true;
	  }
	}
  }

  Timer {
	interval: 5 * 60 * 1000
	repeat: true
	running: true

	onTriggered: root.refresh()
  }
}
