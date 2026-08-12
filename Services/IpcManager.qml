pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  signal logoutMenu

  IpcHandler {
	function openLogoutMenu(): void {
	  root.logoutMenu();
	}

	target: "root"
  }
}
