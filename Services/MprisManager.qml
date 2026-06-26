pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  property MprisPlayer defaultPlayer: Mpris.players.values[0]
  property real pos: defaultPlayer.position / defaultPlayer.length

  function getPlaying() {
	if (!defaultPlayer) {
	  return false;
	} else {
	  return defaultPlayer.playbackState == MprisPlaybackState.Playing;
	}
  }

  function prev() {
	defaultPlayer.previous();
  }

  function skip() {
	defaultPlayer.next();
  }
}
