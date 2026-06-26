import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: root

  required property string body
  required property string summary

  Rectangle {
	anchors.fill: parent
	radius: 30

	gradient: MidpointGradient {
	  color: Colors.green
	  midpoint: 0.7
	}
  }

  Column {
	anchors.centerIn: parent
	spacing: 5

	StyledText {
	  anchors.horizontalCenter: parent.horizontalCenter
	  font.pointSize: 11
	  text: root.summary
	}

	StyledText {
	  elide: Text.ElideRight
	  horizontalAlignment: Text.AlignHCenter
	  text: root.body
	  verticalAlignment: Text.AlignVCenter
		width: root.width - 20

	  font {
		pointSize: 10
		weight: 500
	  }
	}
  }
}
