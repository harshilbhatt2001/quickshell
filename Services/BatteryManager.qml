pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../Color.js" as Colors

Singleton {
  id: root

  property bool batteryInUse: root.batteryPresent && root.batteryLaptop
  property bool batteryLaptop: root.mainBattery.isLaptopBattery
  property double batteryPercentage: root.mainBattery.percentage
  property bool batteryPresent: root.mainBattery.ready
  property UPowerDevice mainBattery: UPower.displayDevice

  function getBatteryColor() {
	let criticalLevel = 20;
	let batteryPercentage = getBatteryPercentage(mainBattery);

	if (mainBattery.state == UPowerDeviceState.Charging) {
	  return Colors.mauve;
	} else if (mainBattery.state == UPowerDeviceState.PendingCharge | mainBattery.state
			   == UPowerDeviceState.PendingDischarge) {
	  return Colors.peach;
	} else if (batteryPercentage <= criticalLevel) {
	  return Colors.red;
	} else {
	  return Colors.green;
	}
  }

  function getBatteryIcon(battery) {
	if (battery.state == UPowerDeviceState.Charging) {
	  return "󰂄";
	} else if (battery.state == UPowerDeviceState.PendingCharge | battery.state
			   == UPowerDeviceState.PendingDischarge) {
	  return "󰚥";
	} else if (battery.state == UPowerDeviceState.Discharging | battery.state
			   == UPowerDeviceState.FullyCharged) {
	  let iconArr = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
	  let batteryCharge = battery.percentage;
	  let chargeIndex = Math.ceil(batteryCharge * iconArr.length) - 1;
	  return iconArr[chargeIndex];
	}
  }

  function getBatteryName(battery) {
	let pathsplit = battery.nativePath.split("/");
	let batteryName = pathsplit[pathsplit.length];
	return pathsplit;
  }

  function getBatteryPercentage(battery) {
	return battery.percentage * 100;
  }

  function getBatteryText() {
	let icon = getBatteryIcon(mainBattery);
	let percentage = getBatteryPercentage(mainBattery);
	return icon + " " + percentage + "%";
  }

  function getMainBatteryInfo() {
	let battery = UPower.devices.values[0];
	let batteryState = battery.state;
	let batteryName = getBatteryName(battery);
	let time = 0;
	let timeString = "";
	let timeToEmpty = battery.timeToEmpty;
	if (timeToEmpty == 0) {
	  timeString = "full";
	  time = battery.timeToFull;
	} else {
	  timeString = "empty";
	  time = timeToEmpty;
	}
	return {
	  "name": batteryName,
	  "charge": battery.percentage,
	  "energy": battery.energy,
	  "capacity": battery.energyCapacity,
	  "time": time,
	  "timeString": timeString,
	  "health": battery.healthPercentage
	};
  }
}
