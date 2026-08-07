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
	let deviceMac = device.address;
	let hasBattery = device.batteryAvailable;
	let deviceBattery = deviceIcon;
	let deviceBatteryRaw = 0;
	if (hasBattery) {
	  deviceBattery = device.battery * 100;
	  deviceBatteryRaw = device.battery;
	}

	return {
	  "icon": deviceIcon,
	  "name": deviceName,
	  "mac": deviceMac,
	  "hasBattery": hasBattery,
	  "battery": deviceBattery,
	  "batteryRaw": deviceBatteryRaw
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
