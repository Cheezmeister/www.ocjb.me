// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
//

const CLASS_TRACK_DETAILS = 'track'
const ID_NOW_PLAYING = 'nowplaying'
const ID_FAST_FORWARD = 'fast-forward'
const ID_TRACK_TITLE = 'track-title'

let trackCount = document.getElementsByClassName(CLASS_TRACK_DETAILS).length
let nowPlaying = document.getElementById(ID_NOW_PLAYING)
let fastForwardButton = document.getElementById(ID_FAST_FORWARD)
let nowPlayingSpan = document.getElementById(ID_TRACK_TITLE)

nowPlaying.onended = playRandomTrack
fastForwardButton.onclick = playRandomTrack
nowPlaying.muted = window.location.search === '?quiet'
playRandomTrack()

function playRandomTrack() {
  let trackNum = Math.ceil(Math.random() * trackCount)
  playTrack(trackNum)
}

function playTrack(trackNumber) {
  // TODO Use all mirrors to fallback
  let link = document.getElementById(`dl-blueblue-${trackNumber}`)
  nowPlaying.src = link.href
  nowPlaying.play()

  let trackDetails = document.getElementsByClassName(CLASS_TRACK_DETAILS)

  for (let idx = 0; idx < trackCount; idx++) {
    let trackDetail = trackDetails[idx]
    if (trackDetail.id == `track-details-${trackNumber}`) {
      trackDetail.attributes['class'].value = 'track row well nowplaying'
      nowPlayingSpan.innerHTML = trackDetail.dataset.title
      document.title = trackDetail.dataset.title
      console.log(trackDetail)
    } else {
      trackDetail.attributes['class'].value = 'track row well'
    }
  }
}

