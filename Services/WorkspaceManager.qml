pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root

  function getAllNumberedWorkspaces() {
	let allWorkspaces = Hyprland.workspaces.values;
	let filteredWorkspaces = [];
	for (let workspace in allWorkspaces) {
	  let currentWorkspace = allWorkspaces[workspace];
	  if (!currentWorkspace.name.includes("special")) {
		if (currentWorkspace) {
		  filteredWorkspaces.push(currentWorkspace);
		}
	  }
	}
  }

  function getWorkspacesForMonitor(monitor) {
	let allWorkspaces = getAllNumberedWorkspaces();
	let monitorWorkspaces = [];

	for (let workspace in allWorkspaces) {
	  let currentWorkspace = allWorkspaces[workspace];
	  if (currentWorkspace.monitor == monitor) {
		console.log(currentWorkspace.id);
		if (currentWorkspace) {
		  monitorWorkspaces.push(currentWorkspace);
		}
	  }
	}
	return monitorWorkspaces;
  }
}
