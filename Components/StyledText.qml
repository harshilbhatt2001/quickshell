import QtQuick
import "../Color.js" as Colors

Text {
  id: root

  property double fontSize: 12
  property double fontWeight: 8
  property bool propo: false

  color: Colors.base
  elide: Text.ElideRight

  font {
	family: root.propo == true ? "FiraMono Nerd Font Propo" : "FiraMono Nerd Font"
	pointSize: fontSize
	weight: root.fontWeight * 100
  }
}
