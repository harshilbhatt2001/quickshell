import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property HyprlandWorkspace workspace

  Rectangle {
	StyledText {
		text: "some"
	}
  }
}
