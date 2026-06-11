import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: container

  required property color boxColor
  property double boxHeight
  property double boxRadius
  required property string boxState
  property double boxWidth
  property double openHeight
  property double openWidth
  required property Component sourceComponent

  Layout.topMargin: 0
  implicitHeight: boxHeight || 50
  implicitWidth: boxWidth || 30
  state: boxState

  Behavior on anchors.topMargin {
	SmoothAnim {}
  }
  Behavior on implicitHeight {
	SmoothAnim {}
  }
  Behavior on implicitWidth {
	SmoothAnim {}
  }
  states: [
	State {
	  name: ""
	},
	State {
	  name: "open"

	  PropertyChanges {
		container.Layout.topMargin: 35
		container.implicitHeight: openHeight || 150
		container.implicitWidth: openWidth || 200
	  }
	}
  ]

  Rectangle {
	id: mainBackground

	anchors.fill: parent
	color: container.boxColor
	radius: container.boxRadius || 10

	Loader {
	  anchors.fill: parent
	  sourceComponent: container.sourceComponent
	}
  }

  component SmoothAnim: SpringAnimation {
	damping: 0.18
	mass: 0.5
	spring: 3
  }
}
