import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import "../Color.js" as Colors
import "../"

Item {
	Text {
		font.family: "FiraMono Nerd Font"
		anchors.centerIn: parent
		font.pixelSize: 15
		color: Colors.text
		text: Clock.time
	}
}
