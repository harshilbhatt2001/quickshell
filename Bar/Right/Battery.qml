pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"
import "Bluetooth"

Container {
  id: root

  animOffset: 160
  boxColor: Colors.green
  boxHeight: 25
  boxWidth: 40
  defaultItem: icon
  exclusiveToScreen: true
  forceHidden: BatteryManager.battery.isLaptopBattery

  Component {
	id: icon

	CenteredText {
	  text: BatteryManager.batteryPercentage
	}
  }
}
