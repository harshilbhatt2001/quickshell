import QtQuick
import Quickshell
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: fullTimeRoot

  Rectangle {
	anchors.fill: parent
	radius: 30

	gradient: MidpointGradient {
	  color: Colors.red
	}
  }

  Item {
	id: timeColumnContainer

	anchors.fill: parent

	Column {
	  id: timeColumn

	  spacing: 5

	  anchors {
		centerIn: parent
	  }

	  StyledText {
		anchors.horizontalCenter: parent.horizontalCenter
		color: Colors.surface0
		text: Time.time

		font {
		  pointSize: 30
		}
	  }

	  StyledText {
		anchors.horizontalCenter: parent.horizontalCenter
		color: Colors.surface1
		text: Time.date

		font {
		  pointSize: 9
		  weight: 400
		}
	  }
	}
  }
}
