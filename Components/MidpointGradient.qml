import QtQuick

Gradient {
  id: root

  required property color color
  property double midpoint: 0.6

  GradientStop {
	color: "transparent"
	position: 0.0
  }

  GradientStop {
	color: "transparent"
	position: root.midpoint
  }

  GradientStop {
	color: root.color
	position: 1.0
  }
}
