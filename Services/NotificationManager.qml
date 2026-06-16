pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: root

  property alias notif: server

  function getLatestNotification() {
	let notificationList = server.trackedNotifications.values;
	let len = notificationList.length;
	if (len <= 0) {
	  len = 1;
	}
	let latestNotification = notificationList[len - 1];
	return latestNotification;
  }

  NotificationServer {
	id: server

	bodyMarkupSupported: true
	bodySupported: true

	onNotification: notification => {
	  notification.tracked = true;
	}
  }
}
