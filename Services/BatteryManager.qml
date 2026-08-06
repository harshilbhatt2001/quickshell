pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
  id: root

  property UPowerDevice battery: Upower.displayDevice
  property bool batteryInUse: root.batteryPresent && root.batteryLaptop
  property bool batteryLaptop: root.battery.isLaptopBattery
  property double batteryPercentage: root.battery.percentage
  property bool batteryPresent: root.battery.ready

  function getBatteryIcon() {
	let battery = root.battery;
	if (battery.state = UpowerDeviceState.Charging) {
	  return "󰂄";
	}
	if (battery.state = UpowerDeviceState.Discharging) {
	}
  }
}
