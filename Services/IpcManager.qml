pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  signal logoutTriggered()

  IpcHandler {
	function logout() {
	  root.logoutTriggered();
	}

	target: "main"
  }
}
