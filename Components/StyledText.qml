import QtQuick
import "../Color.js" as Colors

Text {
  id: root

  property double fontSize: 12
  property bool propo: false

  color: Colors.base
  elide: Text.ElideRight

  font {
	family: root.propo == true ? "FiraMono Nerd Font Propo" : "FiraMono Nerd Font"
	pointSize: fontSize
	weight: 800
  }
}
