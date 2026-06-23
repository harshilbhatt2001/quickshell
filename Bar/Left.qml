pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../Color.js" as Colors
import "../Components/"
import "../Services/"
import "./Center"
import "./Left/"

Container {
  id: root

  property double extraHoveredWidth: 0
  required property HyprlandMonitor monitor
  property double rowLeftMargin: 4
  property double rowSpacing: 3
  property double rowYmargin: 3
  property double selectorFocusedExtra: 15
  property double selectorHeight: 20
  property double selectorWidth: 20
  property double spacing: 3
  property double workspaceNumber: WorkspaceManager.getNumberOfWorkspaces(monitor)

  boxHeight: 25
  boxWidth: (selectorWidth * workspaceNumber) + ((2 * rowLeftMargin) + (rowSpacing * (
																		  workspaceNumber - 1))) + extraHoveredWidth + (hoverHandler.hovered == true
																														? selectorFocusedExtra : 0)
  exclusiveMonitor: monitor

  defaultItem: WorkspaceContainer {
	extraHoveredWidth: root.extraHoveredWidth
	monitor: root.monitor
	rowLeftMargin: root.rowLeftMargin
	rowSpacing: root.rowSpacing
	rowYmargin: root.rowYmargin
	selectorFocusedExtra: root.selectorFocusedExtra
	selectorHeight: root.selectorHeight
	selectorWidth: root.selectorWidth
  }
  Behavior on rowYmargin {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }
  states: [
	State {
	  name: ""
	  when: !hoverHandler.hovered
	},
	State {
	  name: "hovered"
	  when: hoverHandler.hovered

	  PropertyChanges {
		root.boxHeight: 40
		root.extraHoveredWidth: 25
		root.rowYmargin: 5
		root.selectorWidth: 40
	  }
	}
  ]

  HoverHandler {
	id: hoverHandler
  }
}
