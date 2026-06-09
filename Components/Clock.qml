// Time.qml

// with this line our type becomes a Singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
  id: root
  property string time
	property string day

  Process {
    id: timeProc
    command: ["date", "+%T"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Process {
    id: dateProc
    command: ["date", "+%A %B %d %Y"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.day = this.text
    }
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: timeProc.running = true, dateProc.running = true
  }
}
