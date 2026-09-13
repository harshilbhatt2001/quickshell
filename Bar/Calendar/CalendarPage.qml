pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../Color.js" as Colors
import "../../Components/"
import "../../Services/"

// Header + one calendar view. A view has `anchor`, `selected`, `title`,
// `step(n)`, and the `anchorRequested`/`selectRequested` signals — see
// MonthView. Register new views (day, 3-day, week) in `views`.
Item {
  id: root

  property date anchor: new Date()
  property double margin: 6
  property date selected: new Date()
  property string view: "month"
  readonly property var views: ({
								  "month": monthView
								})

  implicitHeight: column.implicitHeight + root.margin * 2
  implicitWidth: column.implicitWidth + root.margin * 2

  onAnchorChanged: CalendarManager.anchor = root.anchor

  ColumnLayout {
	id: column

	spacing: 4

	anchors {
	  fill: parent
	  margins: root.margin
	}

	RowLayout {
	  Layout.fillWidth: true
	  spacing: 0

	  ArrowButton {
		icon: "󰅁"

		onClicked: viewLoader.item.step(-1)
	  }

	  StyledText {
		Layout.fillWidth: true
		color: Colors.base
		fontSize: 11
		horizontalAlignment: Qt.AlignHCenter
		text: viewLoader.item ? viewLoader.item.title : ""
	  }

	  ArrowButton {
		icon: "󰅂"

		onClicked: viewLoader.item.step(1)
	  }
	}

	Loader {
	  id: viewLoader

	  Layout.fillWidth: true
	  sourceComponent: root.views[root.view]

	  onLoaded: {
		item.anchor = Qt.binding(() => root.anchor);
		item.selected = Qt.binding(() => root.selected);
		item.anchorRequested.connect(d => root.anchor = d);
		item.selectRequested.connect(d => root.selected = d);
	  }
	}
  }

  Component {
	id: monthView

	MonthView {}
  }

  component ArrowButton: Rectangle {
	id: arrow

	property string icon

	signal clicked

	color: arrowHover.hovered ? Qt.alpha(Colors.base, 0.12) : "transparent"
	implicitHeight: 20
	implicitWidth: 24
	radius: 6

	Behavior on color {
	  ColorAnimation {
		duration: 120
	  }
	}

	HoverHandler {
	  id: arrowHover
	}

	TapHandler {
	  onTapped: arrow.clicked()
	}

	StyledText {
	  anchors.centerIn: parent
	  color: Colors.base
	  fontSize: 11
	  text: arrow.icon
	}
  }
}
