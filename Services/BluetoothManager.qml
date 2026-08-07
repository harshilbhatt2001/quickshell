pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
  id: root

  property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter
  property string defaultAdapterName: Bluetooth.defaultAdapter.adapterId

  function getConnected() {
	let deviceList = getDevicesList();
	for (let device in deviceList) {
	  let currentDevice = deviceList[device];
	  if (currentDevice.connected == true) {
		return true;
	  }
	}
	return false;
  }

  function getConnectedDevicesList() {
	let devicesList = getDevicesList();
	let connectedList = [];
	for (let device of devicesList) {
	  if (device.connected == true) {
		connectedList.push(device);
	  }
	}
	return connectedList;
  }

  function getDeviceText(device) {
	let deviceName = device.deviceName;

	let deviceIcon = getIcon(device.icon);

	return {
	  "icon": deviceIcon,
	  "name": deviceName
	};
  }

  function getDevicesList() {
	return root.defaultAdapter.devices.values;
  }

  function getIcon(name) {
	const icons = {
	  "audio-card": "󰓃",
	  "audio-input-microphone": "",
	  "audio-headphones": "󰋋",
	  "audio-headset": "󰋋",
	  "battery": "󰂀",
	  "camera-photo": "󰻛",
	  "computer": "",
	  "input-keyboard": "󰌌",
	  "input-mouse": "󰍽",
	  "input-gaming": "󰊴",
	  "phone": "󰏲"
	};

	return icons[name] || "󰾰";
  }
}
