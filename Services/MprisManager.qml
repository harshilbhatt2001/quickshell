pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  property MprisPlayer _lastPlayer: null

  // The player the bar talks to. Prefers whichever player is currently
  // playing, then sticks with the last one it used (so a paused Zen tab keeps
  // showing on hover), then falls back to the first one available.
  readonly property MprisPlayer activePlayer: {
	const players = Mpris.players.values;
	const playing = players.find(p => p.isPlaying);
	if (playing) {
	  return playing;
	}
	if (root._lastPlayer && players.includes(root._lastPlayer)) {
	  return root._lastPlayer;
	}
	return players[0] || null;
  }
  readonly property bool hasMedia: root.activePlayer !== null
  readonly property bool isPlaying: root.activePlayer !== null && root.activePlayer.isPlaying

  // Firefox/Zen always report Position = 0 even while playing, so a progress
  // bar would be a lie for them. Only claim to know the position when it moves.
  function getTrackInfo() {
	const p = root.activePlayer;
	if (!p) {
	  return null;
	}
	const position = Number(p.position) || 0;
	const length = Number(p.length) || 0;
	const hasLength = p.lengthSupported && length > 0;
	const hasPosition = hasLength && position > 0;
	return {
	  "name": p.trackTitle,
	  "artist": p.trackArtist,
	  "album": p.trackAlbum,
	  "albumArt": p.trackArtUrl,
	  "playing": p.isPlaying,
	  "hasLength": hasLength,
	  "hasPosition": hasPosition,
	  "lengthPercent": hasPosition ? Math.min(1, position / length) : 0,
	  "timeString": hasPosition ? secondsToString(position) + "/" + secondsToString(length) : (
									hasLength ? secondsToString(length) : "")
	};
  }

  function next() {
	if (root.activePlayer && root.activePlayer.canGoNext) {
	  root.activePlayer.next();
	}
  }

  function previous() {
	if (root.activePlayer && root.activePlayer.canGoPrevious) {
	  root.activePlayer.previous();
	}
  }

  function secondsToString(seconds) {
	seconds = Math.max(0, Math.floor(Number(seconds) || 0));
	const h = Math.floor(seconds / 3600);
	const m = Math.floor((seconds % 3600) / 60);
	const s = seconds % 60;
	const mm = String(m).padStart(2, "0");
	const ss = String(s).padStart(2, "0");
	return h > 0 ? h + ":" + mm + ":" + ss : m + ":" + ss;
  }

  // Fraction of the track length, 0..1.
  function seek(fraction) {
	const p = root.activePlayer;
	if (!p || !p.canSeek || !p.lengthSupported) {
	  return;
	}
	const length = Number(p.length) || 0;
	if (length <= 0) {
	  return;
	}
	p.position = Math.max(0, Math.min(1, Number(fraction) || 0)) * length;
	// Quickshell doesn't re-read the position after a seek, so nudge the
	// bindings that depend on it.
	p.positionChanged();
  }

  function togglePlaying() {
	if (root.activePlayer && root.activePlayer.canTogglePlaying) {
	  root.activePlayer.togglePlaying();
	}
  }

  onActivePlayerChanged: {
	if (root.activePlayer) {
	  root._lastPlayer = root.activePlayer;
	}
  }
}
