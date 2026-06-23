pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root

  function getWorkspacesForMonitor(monitor) {
	let allWorkspaces = Hyprland.workspaces;
	let monitorWorkspaces = [];
	for (let workspace in allWorkspaces) {
	  let currentWorkspace = allWorkspaces[workspace];

	  if (currentWorkspace.monitor == monitor) {
		console.log("correct");
	  } else {
		console.log("incorrect");
	  }
	}
  }
}
