pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root

  signal raiseCancelled
  signal raiseRequested

  function exitRaise() {
	console.log("exiting raise");
	root.raiseCancelled();
  }

  function requestRaise() {
	root.raiseRequested();
  }
}
