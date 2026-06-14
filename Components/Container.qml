import QtQuick
import QtQuick.Controls
import Quickshell

import "../Color.js" as Colors

Item {
  id: containerRoot

  property color boxColor: Colors.surface0
  property double boxHeight: 28
  property double boxRadius: 9
  property double boxWidth: 100
  property Component defaultItem
  property bool exclusiveToScreen: false
  property alias mouse: mouseArea
  property alias rect: container
  property alias stack: containerContent

  function getVisible() {
	if (containerRoot.exclusiveToScreen) {
	  let minMargin = -2 - containerRoot.boxHeight;
	  console.log(minMargin);
	  return minMargin - 5;
	} else {
	  return 0;
	}
  }

  implicitHeight: boxHeight
  implicitWidth: boxWidth

  Behavior on boxHeight {
	animation: defaultAnim
  }
  Behavior on boxWidth {
	animation: defaultAnim
  }

  anchors {
	top: parent.top
	topMargin: getVisible()
  }

  SpringAnimation {
	id: defaultAnim

	damping: 0.3
	spring: 4
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
