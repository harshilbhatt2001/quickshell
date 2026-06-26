import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../../Color.js" as Colors
import "../../../Components/"
import "../../../Services/"

Item {
  id: root

  property double topBarHeight: 35

  Rectangle {
	color: Colors.surface0
	radius: 17

	anchors {
	  bottomMargin: 5
	  fill: parent
	  leftMargin: 5
	  rightMargin: 5
	  topMargin: 5
	}

	Rectangle {
	  id: topBar

	  property double topBarHeight: root.topBarHeight

	  color: Colors.peach
	  implicitHeight: topBarHeight
	  radius: 9

	  anchors {
		left: parent.left
		leftMargin: 5
		right: parent.right
		rightMargin: 5
		top: parent.top
		topMargin: 5
	  }

	  RowLayout {
		id: topBarRow

		property double topBarRowPadding: 4

		spacing: 3

		anchors {
		  left: parent.left
		  leftMargin: topBarRowPadding
		  right: parent.right
		  rightMargin: topBarRowPadding
		  top: parent.top
		  topMargin: topBarRowPadding
		}

		Rectangle {
		  Layout.fillWidth: true
		  // color: Qt.lighter(Colors.peach, 1.2)
		  color: Colors.surface1
		  implicitHeight: topBar.topBarHeight - (topBarRow.topBarRowPadding * 2)
		  radius: 6

		  StyledText {
			anchors.verticalCenter: parent.verticalCenter
			color: Colors.text
			horizontalAlignment: Qt.AlignLeft
			text: " " + BluetoothManager.defaultAdapterName
		  }
		}

		Rectangle {
		  id: scanButton

		  color: Qt.lighter(Colors.peach, 1.15)
		  implicitHeight: topBar.topBarHeight - (topBarRow.topBarRowPadding * 2)
		  implicitWidth: topBar.topBarHeight - (topBarRow.topBarRowPadding * 2)
		  radius: 6

		  Behavior on color {
			ColorAnimation {
			  duration: 100
			}
		  }
		  states: [
			State {
			  name: "hovered"

			  PropertyChanges {
				scanButton.color: Colors.green
			  }
			}
		  ]

		  border {
			color: Colors.surface0
			width: 2
		  }

		  HoverHandler {
			onHoveredChanged: hovered == true ? scanButton.state = "hovered" : scanButton.state = ""
		  }

		  TapHandler {
			onTapped: {
			  BluetoothManager.toggleDiscover();
			}
		  }

		  CenteredText {
			id: scanButtonText

			text: ""

			NumberAnimation {
			  id: animateRotation

			  duration: 1000
			  from: 0
			  loops: Animation.Infinite
			  properties: "rotation"
			  running: BluetoothManager.defaultAdapter.discovering
			  target: scanButtonText
			  to: 360

			  onStopped: {
				scanButton.rotation = 0;
			  }
			}
		  }
		}
	  }
	}

	ListView {
	  boundsBehavior: Flickable.StopAtBounds
	  clip: true
	  model: BluetoothManager.getDevicesList()
	  spacing: 5

	  delegate: Item {
		id: deviceRoot

		required property real index
		required property BluetoothDevice modelData

		height: 55
		width: ListView.view.width

		Rectangle {
		  id: containerBox

		  anchors.fill: parent
		  clip: true
		  color: Colors.peach
		  radius: 7

		  Rectangle {
			anchors.centerIn: parent
			color: Colors.green
			implicitHeight: parent.height - 10
			implicitWidth: parent.width * (deviceRoot.modelData.batteryAvailable == true
										   ? deviceRoot.modelData.battery : 0) - 10
			opacity: 0.7
			radius: 7
			visible: deviceRoot.modelData.batteryAvailable == true
		  }

		  RowLayout {
			anchors {
			  bottomMargin: 4
			  fill: parent
			  leftMargin: 4
			  rightMargin: 4
			  topMargin: 4
			}

			Rectangle {
			  Layout.fillHeight: true
			  Layout.preferredWidth: height
			  color: deviceRoot.modelData.connected ? Colors.green : Qt.lighter(Colors.peach, 1.25)
			  radius: 5

			  CenteredText {
				color: Colors.surface0
				font.pointSize: 30
				text: BluetoothManager.getIcon(deviceRoot.modelData.icon)
			  }
			}

			ColumnLayout {
			  Layout.fillWidth: true

			  Rectangle {
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: Qt.lighter(Colors.peach, 1.15)
				radius: 4

				StyledText {
				  anchors.fill: parent
				  anchors.verticalCenter: parent.verticalCenter
				  elide: Qt.ElideRight
				  text: deviceRoot.modelData.name
				}
			  }

			  Rectangle {
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: "transparent"

				StyledText {
				  anchors.fill: parent
				  anchors.verticalCenter: parent.verticalCenter
				  color: Colors.surface2
				  font.weight: 300
				  text: deviceRoot.modelData.address
				}
			  }
			}

			Item {
			  Layout.fillHeight: true
			  Layout.preferredWidth: height

			  RowLayout {
				anchors.fill: parent

				Rectangle {
				  id: itemEntry

				  Layout.fillHeight: true
				  Layout.fillWidth: true
				  color: Colors.red
				  radius: 3

				  Loader {
					id: deleteButtonLoader

					anchors.fill: parent
					sourceComponent: forgetButton

					states: [
					  State {
						name: ""
						when: deviceRoot.modelData.connected == false

						PropertyChanges {
						  deleteButtonLoader.sourceComponent: forgetButton
						}
					  },
					  State {
						name: "connected"
						when: deviceRoot.modelData.connected == true

						PropertyChanges {
						  deleteButtonLoader.sourceComponent: disconnectButton
						}
					  }
					]
				  }

				  Component {
					id: disconnectButton

					Item {
					  anchors.fill: parent

					  TapHandler {
						onTapped: deviceRoot.modelData.disconnect()
					  }

					  CenteredText {
						text: ""
					  }
					}
				  }

				  Component {
					id: forgetButton

					Item {
					  anchors.fill: parent

					  TapHandler {
						onTapped: deviceRoot.modelData.forget()
					  }

					  CenteredText {
						text: "󰩹"
					  }
					}
				  }
				}

				Rectangle {
				  id: greenButton

				  property Component loadedItem: connectButton

				  Layout.fillHeight: true
				  Layout.fillWidth: true
				  color: Colors.green
				  radius: 3

				  states: [
					State {
					  name: ""
					  when: deviceRoot.modelData.paired == true

					  PropertyChanges {
						greenButton.color: Colors.green
						greenButton.loadedItem: connectButton
					  }
					},
					State {
					  name: "unpaired"
					  when: deviceRoot.modelData.paired == false

					  PropertyChanges {
						greenButton.color: Colors.blue
						greenButton.loadedItem: pairButton
					  }
					}
				  ]

				  Loader {
					anchors.fill: parent
					sourceComponent: greenButton.loadedItem
				  }

				  Component {
					id: connectButton

					Item {
					  anchors.fill: parent

					  CenteredText {
						text: "󱘖"
					  }

					  TapHandler {
						onTapped: deviceRoot.modelData.connect()
					  }
					}
				  }

				  Component {
					id: pairButton

					Item {
					  anchors.fill: parent

					  CenteredText {
						text: ""
					  }

					  TapHandler {
						onTapped: {
						  deviceRoot.modelData.pair();
						}
					  }
					}
				  }
				}
			  }
			}
		  }
		}
	  }

	  anchors {
		bottomMargin: 5
		fill: parent
		leftMargin: 5
		rightMargin: 5
		topMargin: 10 + root.topBarHeight
	  }
	}
  }
}
