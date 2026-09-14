pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Spectrum bars from cava's raw output. Only runs while `active`; without
// cava installed `bars` stays empty and nothing is drawn.
Singleton {
  id: root

  property bool active: false
  readonly property int barCount: 32
  // 0..1 per bar, left to right.
  property var bars: []

  Process {
	id: cavaProc

	command: ["sh", "-c", "command -v cava >/dev/null 2>&1 || exit 3; "
	  + "cfg=\"${XDG_RUNTIME_DIR:-/tmp}/quickshell-cava.conf\"; "
	  + "printf '[general]\\nbars = %s\\nframerate = 30\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\n[smoothing]\\nnoise_reduction = 70\\n' \"$1\" > \"$cfg\"; "
	  + "exec cava -p \"$cfg\"", "cava", String(root.barCount)]
	running: root.active

	stdout: SplitParser {
	  onRead: line => {
		root.bars = line.split(";").filter(v => v.length > 0).map(v => Number(v) / 100);
	  }
	}

	onRunningChanged: {
	  if (!running) {
		root.bars = [];
	  }
	}
  }
}
