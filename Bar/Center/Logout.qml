import QtQuick
import "../../Components/"
import "../../Services/"

Item {
  CenteredText {
	text: "some"
  }

  Shortcut {
	sequence: "Escape"

	onActivated: {
	  console.log("shortcut triggered");
	  FocusManager.exitRaise();
	}
  }
}
