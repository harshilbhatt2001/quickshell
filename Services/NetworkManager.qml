pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
  id: root

  property NetworkDevice defaultAdapter: Networking.devices.values[0]

  function getConnectivity() {
	if (Networking.connectivity == NetworkConnectivity.Full) {
	  return 0;
	  // if ethernet hide ts (return 2)
	} else if (Networking.connectivity == NetworkConnectivity.Limited || Networking.connectivity
			   == NetworkConnectivity.Portal) {
	  return 1;
	} else {
	  return 2;
	}
  }

  function getIcon() {
	let state = getConnectivity();
	let iconArr = [""];
  }
}
