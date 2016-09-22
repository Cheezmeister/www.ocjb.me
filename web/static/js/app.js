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

let trackCount = 75
let nowPlaying = document.getElementById(ID_NOW_PLAYING)

nowPlaying.onended = playRandomTrack
playRandomTrack()

function playRandomTrack() {
  let trackNum = Math.ceil(Math.random() * trackCount)
  playTrack(trackNum)
}

function playTrack(trackNumber) {
  let aud = document.getElementById(`track-${trackNumber}`)
  nowPlaying.src = aud.src
  nowPlaying.play()

  let trackDetails = document.getElementsByClassName(CLASS_TRACK_DETAILS)

  for (let idx = 0; idx < 75; idx++) {
    var trackDetail = trackDetails[idx]
    // trackDetail['class'] = 'track row'
    if (trackDetail.id == `track-details-${trackNumber}`) {
      trackDetail.attributes['class'].value = 'track row nowplaying'
      console.log(trackDetail)
    }
  }
}

