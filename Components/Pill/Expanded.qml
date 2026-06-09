import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../Color.js" as Colors
import "../"

Item {
	anchors.fill: parent

	Column {
		spacing: 5
		anchors.centerIn: parent

		Text {
			font.family: "FiraMono Nerd Font"
			font.pixelSize: 40
			color: Colors.text
			anchors.horizontalCenter: parent.horizontalCenter
			text: Clock.time
		}
			Text {
				font.family: "FiraMono Nerd Font"
				color: Colors.subtext0
				anchors.horizontalCenter: parent.horizontalCenter
				text: Clock.day
			}
	}
}
