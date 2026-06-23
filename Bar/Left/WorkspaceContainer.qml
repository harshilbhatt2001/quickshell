import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property double extraHoveredWidth
  required property HyprlandMonitor monitor
  required property double rowLeftMargin
  required property double rowSpacing
  required property double rowYmargin
  required property double selectorFocusedExtra
  required property double selectorHeight
  required property double selectorWidth

  Item {
	implicitWidth: 20
	opacity: root.extraHoveredWidth > 0 ? 1 : 0

	Behavior on opacity {
	  NumberAnimation {
		duration: 100
	  }
	}

	TapHandler {
	  id: tapHandler

	  onTapped: WorkspaceManager.activateNextFreeWorkspace()
	}

	anchors {
	  bottom: parent.bottom
	  bottomMargin: 5 + root.rowYmargin
	  right: parent.right
	  rightMargin: 4
	  top: parent.top
	  topMargin: 5 + root.rowYmargin
	}

	Rectangle {
	  anchors.fill: parent
	  color: Colors.red
	  radius: 4

	  StyledText {
		anchors.centerIn: parent
		text: "+"
	  }
	}
  }

  Row {
	spacing: root.rowSpacing

	anchors {
	  bottom: parent.bottom
	  bottomMargin: root.rowYmargin
	  left: parent.left
	  leftMargin: root.rowLeftMargin
	  top: parent.top
	  topMargin: root.rowYmargin
	}

	Repeater {
	  model: WorkspaceManager.getWorkspacesForMonitor(root.monitor)

	  WorkspaceSelector {
		required property HyprlandWorkspace modelData

		extraHoveredWidth: root.extraHoveredWidth
		selectorFocusedExtra: root.selectorFocusedExtra
		selectorHeight: root.selectorHeight
		selectorWidth: root.selectorWidth
		workspace: modelData
	  }
	}
  }
}
