import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

Item {
  id: root

  property MprisPlayer player: MprisManager.defaultPlayer

  Rectangle {
	color: Colors.red
	radius: 5

	anchors {
	  bottomMargin: 15
	  fill: parent
	  leftMargin: 10
	  rightMargin: parent.width - ((parent.width * MprisManager.pos) - 10)
	  topMargin: 15
	}
  }

  RowLayout {
	anchors {
	  bottomMargin: 2
	  fill: parent
	  leftMargin: 7
	  rightMargin: 7
	  topMargin: 2
	}

	Item {
	  Layout.fillHeight: true
	  Layout.preferredWidth: height

	  Image {
		anchors.fill: parent
		fillMode: Image.PreserveAspectFit
		source: MprisManager.defaultPlayer.trackArtUrl
	  }
	}

	Item {
	  Layout.fillHeight: true
	  Layout.fillWidth: true

	  StyledText {
		elide: Qt.ElideRight
		horizontalAlignment: Qt.AlignHCenter
		text: MprisManager.defaultPlayer.trackArtist + " - " + MprisManager.defaultPlayer.trackTitle
		verticalAlignment: Qt.AlignVCenter

		anchors {
		  fill: parent
		}
	  }
	}
  }
}
