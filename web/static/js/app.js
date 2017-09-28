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
const ID_TRACK_ARTIST = 'track-artist'
const ID_SOURCE_GAME = 'source-game'
const ID_SOURCE_SYSTEM = 'source-system'

let trackCount = document.getElementsByClassName(CLASS_TRACK_DETAILS).length
const nowPlaying = document.getElementById(ID_NOW_PLAYING)
const fastForwardButton = document.getElementById(ID_FAST_FORWARD)
const nowPlayingSpan = document.getElementById(ID_TRACK_TITLE)
const trackArtistSpan = document.getElementById(ID_TRACK_ARTIST)
const sourceGameSpan = document.getElementById(ID_SOURCE_GAME)
const sourceSystemSpan = document.getElementById(ID_SOURCE_SYSTEM)
let currentTrackDetail;

init()

function init() {
  nowPlaying.onended = playRandomTrack
  fastForwardButton.onclick = playRandomTrack
  nowPlaying.muted = window.location.search === '?quiet'
  document.addEventListener('keypress', playOrPause)

  let trackDetails = document.getElementsByClassName(CLASS_TRACK_DETAILS)
  for (let idx = 0; idx < trackCount; idx++) {
    let trackDetail = trackDetails[idx]
    trackDetail.onclick = (e)=>trackClicked(trackDetail,e)
  }

  if (window.location.hash) {
    let [match, id] = window.location.hash.match(/#(track-\d+)/)
    if (id) {
      playTrack(document.getElementById(id))
      return
    }
  }
  playRandomTrack()
}


function playOrPause(e) {
  if (e.key === ' ') {
    nowPlaying.paused ? nowPlaying.play() : nowPlaying.pause()
    e.preventDefault()
  }
}

function playRandomTrack() {
  let trackIndex = Math.floor(Math.random() * trackCount)
  let trackDetail = document.getElementsByClassName('track')[trackIndex]
  playTrack(trackDetail)
}

function trackClicked(trackDetail, event) {
  playTrack(trackDetail)
}

function playTrack(trackDetail) {
  let trackNumber = trackDetail.dataset.number
  nowPlaying.pause()
  nowPlaying.innerHTML = ''
  let sources = trackDetail.querySelector('.srcs')
  for (let mirror of ['aplus', 'blu', 'ocrm']) {
    let source = document.createElement('source')
    source.src = sources.dataset[mirror]
    nowPlaying.appendChild(source)
    nowPlaying.src = source.src
  }
  nowPlaying.play()

  updateHeader(trackDetail)

  if (currentTrackDetail) {
    currentTrackDetail.classList.remove('nowplaying')
  }
  currentTrackDetail = trackDetail
  trackDetail.classList.add('nowplaying')
}

function updateHeader(trackDetail) {
  nowPlayingSpan.innerHTML = trackDetail.dataset.title
  trackArtistSpan.innerHTML = trackDetail.dataset.artist
  sourceGameSpan.innerHTML = trackDetail.dataset.game
  sourceSystemSpan.innerHTML = trackDetail.dataset.system
  document.title = formatTitle(trackDetail.dataset.title)
}

function formatTitle(trackTitle) {
  return `${trackTitle} - OverClocked Jukebox`
}

