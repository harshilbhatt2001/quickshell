import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

import "../Color.js" as Colors

Item {
  id: containerRoot

  property color boxColor: Colors.surface0
  property double boxHeight: 28
  property double boxRadius: 9
  property double boxWidth: 100
  property Component defaultItem
  required property HyprlandMonitor exclusiveMonitor
  property bool exclusiveToScreen: false
  property alias mouse: mouseArea
  property alias rect: container
  property alias stack: containerContent

  function getVisible() {
	if (containerRoot.exclusiveToScreen) {
	  if (Hyprland.focusedMonitor != containerRoot.exclusiveMonitor) {
		return -4 - containerRoot.boxHeight - 5;
	  } else {
		return 0;
	  }
	} else {
	  return 0;
	}
  }

  clip: true
  implicitHeight: boxHeight
  implicitWidth: boxWidth

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
  Behavior on boxWidth {
	SpringAnimation {
	  damping: 0.3
	  spring: 4
	}
  }

  anchors {
	top: parent.top
	topMargin: getVisible()
  }

  NumberAnimation {
	id: defaultCurve

	duration: 200
	easing: Easing.InOutBack
  }

  MouseArea {
	id: mouseArea

	anchors.fill: parent
	hoverEnabled: true
	z: 1
  }

  Rectangle {
	id: container

	anchors.fill: parent
	color: containerRoot.boxColor
	radius: containerRoot.boxRadius

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

	  Component.onCompleted: containerContent.push(containerRoot.defaultItem)
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
