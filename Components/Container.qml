import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors

Item {
  id: root

  property double animOffset: 0
  property color boxColor: Colors.surface0
  property double boxHeight: 28
  property double boxRadius: 9
  property double boxWidth: 100
  readonly property double calculatedTopMargin: {
	if (!root.exclusiveToScreen) {
	  return visibleTopMargin;
	}

	if (Hyprland.focusedMonitor == root.exclusiveMonitor) {
	  if (!root.forceHidden) {
		return visibleTopMargin;
	  } else if (root.hoverableWhenHidden) {
		return 7 - root.boxHeight - 5;
	  }
	}

	return -4 - root.boxHeight - 5;
  }
  property Component defaultItem
  required property HyprlandMonitor exclusiveMonitor
  property bool exclusiveToScreen: false
  property bool forceHidden: false
  property alias hover: hoverHandler
  property bool hoverableWhenHidden: false
  property bool hovered: false
  property alias rect: container
  property alias stack: containerContent
  property alias tap: tapHandler
  property double visibleTopMargin: 0

  implicitHeight: boxHeight
  implicitWidth: root._widthCollapsed ? 0 : root.boxWidth
  visible: !root._fullyHidden

  property bool _widthCollapsed: false
  property bool _fullyHidden: false

  Behavior on anchors.topMargin {
	animation: defaultCurve
  }
  Behavior on boxHeight {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }
  Behavior on boxRadius {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }
  Behavior on implicitWidth {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }

  onForceHiddenChanged: {
	if (root.forceHidden == true) {
	  hideTimer.restart();
	} else {
	  hideTimer.stop();
	  subHideTimer.stop();
	  root._fullyHidden = false;
	  root._widthCollapsed = false;
	}
  }

  Timer {
	id: hideTimer

	interval: 250
	repeat: false
	running: false

	onTriggered: {
	  root._widthCollapsed = true;
	  subHideTimer.restart();
	}
  }

  Timer {
	id: subHideTimer

	interval: 200
	repeat: false
	running: false

	onTriggered: {
	  root._fullyHidden = true;
	}
  }

  anchors {
	top: parent.top
	topMargin: calculatedTopMargin
  }

  NumberAnimation {
	id: defaultCurve

	duration: 200 + root.animOffset
	easing: Easing.InOutBack
  }

  HoverHandler {
	id: hoverHandler

	onHoveredChanged: {
	  if (hoverHandler.hovered == true) {
		root.hovered = true;
	  } else {
		root.hovered = false;
	  }
	}
  }

  TapHandler {
	id: tapHandler
  }

  Rectangle {
	id: container

	anchors.fill: parent
	clip: true
	color: root.boxColor
	radius: root.boxRadius

	StackView {
	  id: containerContent

	  anchors.fill: parent

	  replaceEnter: Transition {
		PropertyAnimation {
		  duration: 100
		  from: 0
		  property: "opacity"
		  to: 1
		}

		PropertyAnimation {
		  duration: 100
		  from: -5
		  property: "anchors.topMargin"
		  to: 0
		}
	  }
	  replaceExit: Transition {
		PropertyAnimation {
		  duration: 100
		  from: 1
		  property: "opacity"
		  to: 0
		}
	  }

	  Component.onCompleted: containerContent.push(root.defaultItem)
	  onCurrentItemChanged: {
		if (currentItem) {
		  // Dynamically center the incoming child to the StackView
		  currentItem.anchors.horizontalCenter = containerContent.horizontalCenter;
		  currentItem.anchors.verticalCenter = containerContent.verticalCenter;
		}
	  }
	}
  }
}
