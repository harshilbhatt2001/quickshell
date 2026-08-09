pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
  id: root

  property NetworkDevice defaultAdapter: Networking.devices.values[0]

  property bool connectedWifi: root.defaultAdapter != null
    && root.defaultAdapter.connected
    && root.defaultAdapter.type == DeviceType.Wifi

  function getConnectedNetworks(networksArr) {
	let connectedNetworks = [];

	for (let network of networksArr) {
	  if (network.state == ConnectionState.Connected) {
		connectedNetworks.push(network);
	  }
	}
	return connectedNetworks;
  }

  function getNetworkDetails(adapter) {
	if (!adapter) {
	  return {
		"adapterName": "",
		"adapterConnected": false,
		"adapterIsWifi": false,
		"networkName": "",
		"networkStrength": 0,
		"icon": "󰤭"
	  };
	}

	let networksArr = adapter.networks.values;
	let connectedNetworks = getConnectedNetworks(networksArr);
	let deviceWifi = isDeviceWifi(adapter);

	let primaryNetwork = connectedNetworks[0];

	let networkName = primaryNetwork.name;
	let networkStrength = primaryNetwork.signalStrength;

	let networkIcon = getWifiIcon(networkStrength);

	let outputDict = {
	  "adapterName": adapter.name,
	  "adapterConnected": adapter.connected,
	  "adapterIsWifi": deviceWifi,
	  "networkName": networkName,
	  "networkStrength": networkStrength,
	  "icon": networkIcon
	};
	return outputDict;
  }

  function getWifiIcon(strength) {
	let iconArr = ["󰤟", "󰤢", "󰤥", "󰤨"];
	let strengthIndex = Math.ceil(strength * iconArr.length);
	return iconArr[strengthIndex - 1];
  }

  function isConnectedAndWifi() {
	return root.connectedWifi;
  }

  function getWifiText() {
	let info = getNetworkDetails(defaultAdapter);

	let adapter = info["adapterName"];
	let name = info["networkName"];

	let finalString = adapter + " - " + name;
	return finalString;
  }

  function isDeviceWifi(adapter) {
	if (adapter.type == DeviceType.Wifi) {
	  return true;
	} else if (adapter.type == DeviceType.Wired) {
	  return false;
	} else {
	  console.log(adapter.type);
	  return false;
	}
  }
}
