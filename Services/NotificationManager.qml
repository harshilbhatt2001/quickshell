pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Color.js" as Colors

Singleton {
  id: root

  property alias notif: server

  signal newNotification(notificiation: Notification)

  NotificationServer {
	id: server

	actionsSupported: true
	bodyMarkupSupported: true
	bodySupported: true
	imageSupported: true

	onNotification: notification => {
	  notification.tracked = true;
	  root.newNotification(notification);
	}
  }
}
