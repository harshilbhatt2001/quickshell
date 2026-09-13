pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../Color.js" as Colors

Singleton {
  id: root

  property alias notif: server

  signal newNotification(notificiation: Notification)

  // "Open" a notification the way a click on it should: prefer the app's own
  // default action (freedesktop spec — apps that support it will focus the
  // right conversation/tab themselves), otherwise fall back to focusing the
  // app's window in Hyprland. Returns true if something was done.
  function activate(notification) {
	if (!notification) {
	  return false;
	}

	const actions = notification.actions;
	for (let i = 0; i < actions.length; i++) {
	  if (actions[i].identifier === "default") {
		actions[i].invoke();
		return true;
	  }
	}

	return root.focusAppWindow(notification.desktopEntry, notification.appName);
  }

  // Find a Hyprland window whose class matches the notification's desktop
  // entry or app name (case-insensitive) and focus it.
  function focusAppWindow(desktopEntry, appName) {
	let candidates = [];
	if (desktopEntry) {
	  let entry = desktopEntry.toLowerCase().replace(/\.desktop$/, "");
	  candidates.push(entry);
	  // "com.mitchellh.ghostty" -> "ghostty": some apps' window class is only
	  // the last segment of their app id.
	  const lastSegment = entry.split(".").pop();
	  if (lastSegment && lastSegment !== entry) {
		candidates.push(lastSegment);
	  }
	}
	if (appName) {
	  candidates.push(appName.toLowerCase());
	}
	if (candidates.length === 0) {
	  return false;
	}

	const toplevels = Hyprland.toplevels.values;
	for (let i = 0; i < toplevels.length; i++) {
	  const toplevel = toplevels[i];
	  const ipc = toplevel.lastIpcObject;
	  const classes = [ipc["class"], ipc["initialClass"], toplevel.wayland ? toplevel.wayland.appId :
																			 ""];
	  for (let j = 0; j < classes.length; j++) {
		const cls = (classes[j] || "").toLowerCase();
		if (cls && candidates.indexOf(cls) !== -1) {
		  if (toplevel.wayland) {
			toplevel.wayland.activate();
		  } else {
			Hyprland.dispatch(`hl.dsp.focus({ window = "address:${toplevel.address}" })`);
		  }
		  return true;
		}
	  }
	}
	return false;
  }

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
