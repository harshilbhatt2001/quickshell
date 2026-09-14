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
  property string view: "3day"
  readonly property var viewOrder: ["day", "3day", "week", "month"]
  readonly property var views: ({
								  "day": dayView,
								  "3day": threeDayView,
								  "week": weekView,
								  "month": monthView
								})

  function cycleView() {
	root.view = root.viewOrder[(root.viewOrder.indexOf(root.view) + 1) % root.viewOrder.length];
  }

  implicitHeight: column.implicitHeight + root.margin * 2
  implicitWidth: column.implicitWidth + root.margin * 2

  onAnchorChanged: CalendarManager.anchor = root.anchor

  // Vertical wheel steps the period; the island owns the horizontal wheel.
  WheelHandler {
	acceptedDevices: PointerDevice.AllDevices
	orientation: Qt.Vertical

	onWheel: event => {
	  if (!wheelCooldown.running && viewLoader.item) {
		viewLoader.item.step(event.angleDelta.y < 0 ? 1 : -1);
		wheelCooldown.restart();
	  }
	}
  }

  Timer {
	id: wheelCooldown

	interval: 150
  }

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

	  HeaderButton {
		text: "󰅁"

		onClicked: viewLoader.item.step(-1)
	  }

	  HeaderButton {
		Layout.fillWidth: true
		fontSize: 11
		text: viewLoader.item ? viewLoader.item.title : ""

		onClicked: root.cycleView()
	  }

	  HeaderButton {
		text: "󰅂"

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
	id: dayView

	DaysView {
	  days: 1
	}
  }

  Component {
	id: threeDayView

	DaysView {
	  days: 3
	}
  }

  Component {
	id: weekView

	DaysView {
	  days: 7
	}
  }

  Component {
	id: monthView

	MonthView {}
  }

  component HeaderButton: Rectangle {
	id: button

	property alias fontSize: label.fontSize
	property alias text: label.text

	signal clicked

	color: buttonHover.hovered ? Qt.alpha(Colors.base, 0.12) : "transparent"
	implicitHeight: 20
	implicitWidth: Math.max(24, label.implicitWidth + 12)
	radius: 6

	Behavior on color {
	  ColorAnimation {
		duration: 120
	  }
	}

	HoverHandler {
	  id: buttonHover
	}

	TapHandler {
	  onTapped: button.clicked()
	}

	StyledText {
	  id: label

	  anchors.centerIn: parent
	  color: Colors.base
	  fontSize: 11
	}
  }
}
